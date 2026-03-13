        help_text='Dict of weights for each control tag in metric calculation. Each control tag (e.g. label or choice) will '
        "have it's own key in control weight dict with weight for each label and overall weight."
        'For example, if bounding box annotation with control tag named my_bbox should be included with 0.33 weight in agreement calculation, '
        'and the first label Car should be twice more important than Airplaine, then you have to need the specify: '
        "{'my_bbox': {'type': 'RectangleLabels', 'labels': {'Car': 1.0, 'Airplaine': 0.5}, 'overall': 0.33}",
    )

    # Welcome reader! You might be wondering how `model_version` is
    # set and used; let's explain. `model_version` can either be set
    # to the prediction `model_version` associated with the
    # `tasks.Prediction` model, or to the ML backend title. Yes,
    # understandably, this can be confusing. However, this appears to
    # be the best approach we currently have for improving the
    # experience while maintaining backward compatibility.
    model_version = models.TextField(
        _('model version'), blank=True, null=True, default='', help_text='Machine learning model version'
    )

    data_types = JSONField(_('data_types'), default=dict, null=True)

    is_draft = models.BooleanField(
        _('is draft'), default=False, help_text='Whether or not the project is in the middle of being created'
    )
    is_published = models.BooleanField(
        _('published'), default=False, help_text='Whether or not the project is published to annotators'
    )
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    SEQUENCE = 'Sequential sampling'
    UNIFORM = 'Uniform sampling'
    UNCERTAINTY = 'Uncertainty sampling'

    SAMPLING_CHOICES = (
        (SEQUENCE, 'Tasks are ordered by Data manager ordering'),
        (UNIFORM, 'Tasks are chosen randomly'),
        (UNCERTAINTY, 'Tasks are chosen according to model uncertainty scores (active learning mode)'),
    )

    sampling = models.CharField(max_length=100, choices=SAMPLING_CHOICES, null=True, default=SEQUENCE)
    skip_queue = models.CharField(
        max_length=100, choices=SkipQueue.choices, null=True, default=SkipQueue.REQUEUE_FOR_OTHERS
    )
    show_ground_truth_first = models.BooleanField(_('show ground truth first'), default=False)
    show_overlap_first = models.BooleanField(_('show overlap first'), default=False)
    overlap_cohort_percentage = models.IntegerField(_('overlap_cohort_percentage'), default=100)

    task_data_login = models.CharField(
        _('task_data_login'), max_length=256, blank=True, null=True, help_text='Task data credentials: login'
    )
    task_data_password = models.CharField(
        _('task_data_password'), max_length=256, blank=True, null=True, help_text='Task data credentials: password'
    )

    pinned_at = models.DateTimeField(_('pinned at'), null=True, default=None, help_text='Pinned date and time')

    def __init__(self, *args, **kwargs):
        super(Project, self).__init__(*args, **kwargs)
        self.__original_label_config = self.label_config
        self.__maximum_annotations = self.maximum_annotations
        self.__overlap_cohort_percentage = self.overlap_cohort_percentage
        self.__skip_queue = self.skip_queue

        # TODO: once bugfix with incorrect data types in List
        # logging.warning('! Please, remove code below after patching of all projects (extract_data_types)')
        if self.label_config is not None:
            data_types = extract_data_types(self.label_config)
            if self.data_types != data_types:
                self.data_types = data_types

    @property
    def num_tasks(self):
        return self.tasks.count()

    @property
    def ml_backend(self):
        return fast_first(self.ml_backends.all())

    @property
    def should_retrieve_predictions(self):
        """Returns true if the model was set to be used"""
        if self.show_collab_predictions:
            ml = self.ml_backend
            if ml:
                return ml.title == self.model_version

        return False

    @property
    def num_annotations(self):
        return Annotation.objects.filter(project=self).count()

    @property
    def num_drafts(self):
        return AnnotationDraft.objects.filter(task__project=self).count()

    @property
    def has_predictions(self):
        return self.get_current_predictions().exists()

    @property
    def has_any_predictions(self):
        if flag_set(
            'fflag_perf_back_lsdv_4695_update_prediction_query_to_use_direct_project_relation',
            user='auto',
        ):
            return Prediction.objects.filter(Q(project=self.id)).exists()
        else:
            return Prediction.objects.filter(Q(task__project=self.id)).exists()

    @property
    def business(self):
        return self.created_by.business

    @property
    def is_private(self):
        return None

    @property
    def secure_mode(self):

[1090 more lines in file. Use offset=340 to continue.]