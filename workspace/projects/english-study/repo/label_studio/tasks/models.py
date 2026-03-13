"""This file and its contents are licensed under the Apache License 2.0. Please see the included NOTICE for copyright information and LICENSE for a copy of the license.
"""
import base64
import datetime
import logging
import numbers
import os
import random
import uuid
from typing import Any, Mapping, Optional, cast
from urllib.parse import urljoin

import ujson as json
from core.bulk_update_utils import bulk_update
from core.current_request import get_current_request
from core.feature_flags import flag_set
from core.label_config import SINGLE_VALUED_TAGS
from core.redis import start_job_async_or_sync
from core.utils.common import (
    find_first_one_to_one_related_field_by_prefix,
    load_func,
    string_is_url,
    temporary_disconnect_list_signal,
)
from core.utils.db import fast_first
from core.utils.params import get_env
from data_import.models import FileUpload
from data_manager.managers import PreparedTaskManager, TaskManager
from django.conf import settings
from django.contrib.auth.models import AnonymousUser
from django.core.files.storage import default_storage
from django.db import OperationalError, models, transaction
from django.db.models import JSONField, Q
from django.db.models.signals import post_delete, post_save, pre_delete, pre_save
from django.dispatch import Signal, receiver
from django.urls import reverse
from django.utils.timesince import timesince
from django.utils.timezone import now
from django.utils.translation import gettext_lazy as _
from rest_framework.exceptions import ValidationError
from tasks.choices import ActionType

logger = logging.getLogger(__name__)

TaskMixin = load_func(settings.TASK_MIXIN)


class Task(TaskMixin, models.Model):
    """Business tasks from project"""

    id = models.AutoField(
        auto_created=True,
        primary_key=True,
        serialize=False,
        verbose_name='ID',
        db_index=True,
    )
    data = JSONField(
        'data',
        null=False,
        help_text='User imported or uploaded data for a task. Data is formatted according to '
        'the project label config. You can find examples of data for your project '
        'on the Import page in the Label Studio Data Manager UI.',
    )

    meta = JSONField(
        'meta',
        null=True,
        default=dict,
        help_text='Meta is user imported (uploaded) data and can be useful as input for an ML '
        'Backend for embeddings, advanced vectors, and other info. It is passed to '
        'ML during training/predicting steps.',
    )
    project = models.ForeignKey(
        'projects.Project',
        related_name='tasks',
        on_delete=models.CASCADE,
        null=True,
        help_text='Project ID for this task',
    )
    created_at = models.DateTimeField(_('created at'), auto_now_add=True, help_text='Time a task was created')
    updated_at = models.DateTimeField(_('updated at'), auto_now=True, help_text='Last time a task was updated')
    updated_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        related_name='updated_tasks',
        on_delete=models.SET_NULL,
        null=True,
        verbose_name=_('updated by'),
        help_text='Last annotator or reviewer who updated this task',
    )
    is_labeled = models.BooleanField(
        _('is_labeled'),
        default=False,
        help_text='True if the number of annotations for this task is greater than or equal '
        'to the number of maximum_completions for the project',
    )
    overlap = models.IntegerField(
        _('overlap'),
        default=1,
        db_index=True,
        help_text='Number of distinct annotators that processed the current task',
    )
    file_upload = models.ForeignKey(
        'data_import.FileUpload',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='tasks',
        help_text='Uploaded file used as data source for this task',
    )
    inner_id = models.BigIntegerField(
        _('inner id'),
        default=0,
        null=True,
        help_text='Internal task ID in the project, starts with 1',
    )
    updates = ['is_labeled']
    total_annotations = models.IntegerField(
        _('total_annotations'),
        default=0,
        db_index=True,
        help_text='Number of total annotations for the current task except cancelled annotations',
    )
    cancelled_annotations = models.IntegerField(
        _('cancelled_annotations'),
        default=0,
        db_index=True,
        help_text='Number of total cancelled annotations for the current task',
    )
    total_predictions = models.IntegerField(
        _('total_predictions'),
        default=0,
        db_index=True,
        help_text='Number of total predictions for the current task',
    )

    comment_count = models.IntegerField(
        _('comment count'),
        default=0,
        db_index=True,
        help_text='Number of comments in the task including all annotations',
    )
    unresolved_comment_count = models.IntegerField(
        _('unresolved comment count'),
        default=0,
        db_index=True,
        help_text='Number of unresolved comments in the task including all annotations',
    )
    comment_authors = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        blank=True,
        default=None,
        related_name='tasks_with_comments',
        help_text='Users who wrote comments',
    )
    last_comment_updated_at = models.DateTimeField(
        _('last comment updated at'),
        default=None,
        null=True,
        db_index=True,
        help_text='When the last comment was updated',
    )

    objects = TaskManager()  # task manager by default
    prepared = PreparedTaskManager()  # task manager with filters, ordering, etc for data_manager app

    class Meta:
        db_table = 'task'
        indexes = [
            models.Index(fields=['project', 'is_labeled']),
            models.Index(fields=['project', 'inner_id']),
            models.Index(fields=['id', 'project']),
            models.Index(fields=['id', 'overlap']),
            models.Index(fields=['overlap']),
            models.Index(fields=['project', 'id']),
        ]

    @property
    def file_upload_name(self):
        return os.path.basename(self.file_upload.file.name)

    @classmethod
    def get_random(cls, project):
        """Get random task from a project, this should not be used lightly as its expensive method to run"""

        ids = cls.objects.filter(project=project).values_list('id', flat=True)
        if len(ids) == 0:
            return None

        random_id = random.choice(ids)

        return cls.objects.get(id=random_id)

    @classmethod
    def get_locked_by(cls, user, project=None, tasks=None):
        """Retrieve the task locked by specified user. Returns None if the specified user didn't lock anything."""
        lock = None
        if project is not None:
            lock = fast_first(TaskLock.objects.filter(user=user, expire_at__gt=now(), task__project=project))
        elif tasks is not None:
            locked_task = fast_first(tasks.filter(locks__user=user, locks__expire_at__gt=now()))
            if locked_task:
                return locked_task
        else:
            raise Exception('Neither project or tasks passed to get_locked_by')

        if lock:
            return lock.task

    def get_predictions_for_prelabeling(self):
        """This is called to return either new predictions from the
        model or grab static predictions if they were set, depending
        on the projects configuration.

        """
        from data_manager.functions import evaluate_predictions

        project = self.project
        predictions = self.predictions

        # TODO if we use live_model on project then we will need to check for it here
        if project.show_collab_predictions and project.model_version is not None:
            if project.ml_backend_in_model_version:
                new_predictions = evaluate_predictions([self])
                # TODO this is not as clean as I'd want it to
                # be. Effectively retrieve_predictions will work only for
                # tasks where there is no predictions matching current
                # model version. In case it will return a model_version
                # and we can grab predictions explicitly
                if isinstance(new_predictions, str):
                    model_version = new_predictions
                    return predictions.filter(model_version=model_version)
                else:
                    return new_predictions
            else:
                return predictions.filter(model_version=project.model_version)
        else:
            return []

    def has_lock(self, user=None):
        """
        Check whether current task has been locked by some user

        Also has workaround for fixing not consistent is_labeled flag state
        """
        from projects.functions.next_task import get_next_task_logging_level

        SkipQueue = self.project.SkipQueue

        if self.project.skip_queue == SkipQueue.REQUEUE_FOR_ME:
            # REQUEUE_FOR_ME means: only my skipped tasks go back to me,
            # alien's skipped annotations are counted as regular annotations
            q = Q(was_cancelled=True) & Q(completed_by=user)
        elif self.project.skip_queue == SkipQueue.REQUEUE_FOR_OTHERS:
            # REQUEUE_FOR_OTHERS: my skipped tasks go to others
            # alien's skipped annotations are not counted at all
            q = Q(was_cancelled=True) & ~Q(completed_by=user)
        else:  # SkipQueue.IGNORE_SKIPPED
            # IGNORE_SKIPPED: my skipped tasks don't go anywhere
            # alien's and my skipped annotations are counted as regular annotations

[950 more lines in file. Use offset=261 to continue.]