"""This file and its contents are licensed under the Apache License 2.0. Please see the included NOTICE for copyright information and LICENSE for a copy of the license.
"""
import getpass
import io
import json
import logging
import os
import pathlib
import socket
import sys

from colorama import Fore, init

if sys.platform == 'win32':
    init(convert=True)

# on windows there will be problems with sqlite and json1 support, so fix it
from label_studio.core.utils.windows_sqlite_fix import windows_dll_fix

windows_dll_fix()

from django.core.management import call_command
from django.core.wsgi import get_wsgi_application
from django.db import DEFAULT_DB_ALIAS, IntegrityError, connections
from django.db.backends.signals import connection_created
from django.db.migrations.executor import MigrationExecutor

from label_studio.core.argparser import parse_input_args
from label_studio.core.utils.params import get_env

logger = logging.getLogger(__name__)

LS_PATH = str(pathlib.Path(__file__).parent.absolute())
DEFAULT_USERNAME = 'default_user@localhost'


def _setup_env():
    sys.path.insert(0, LS_PATH)
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'label_studio.core.settings.label_studio')
    get_wsgi_application()


def _app_run(host, port):
    http_socket = '{}:{}'.format(host, port)
    call_command('runserver', '--noreload', http_socket)


def _set_sqlite_fix_pragma(sender, connection, **kwargs):
    """Enable integrity constraint with sqlite."""
    if connection.vendor == 'sqlite' and get_env('AZURE_MOUNT_FIX'):
        cursor = connection.cursor()
        cursor.execute('PRAGMA journal_mode=wal;')


def is_database_synchronized(database):
    connection = connections[database]
    connection.prepare_database()
    executor = MigrationExecutor(connection)
    targets = executor.loader.graph.leaf_nodes()
    return not executor.migration_plan(targets)


def _apply_database_migrations():
    connection_created.connect(_set_sqlite_fix_pragma)
    if not is_database_synchronized(DEFAULT_DB_ALIAS):
        print('Initializing database..')
        call_command('migrate', '--no-color', verbosity=0)


def _get_config(config_path):
    with io.open(os.path.abspath(config_path), encoding='utf-8') as c:
        config = json.load(c)
    return config


def _create_project(title, user, label_config=None, sampling=None, description=None, ml_backends=None):
    from organizations.models import Organization
    from projects.models import Project

    project = Project.objects.filter(title=title).first()
    if project is not None:
        print('Project with title "{}" already exists'.format(title))
    else:
        org = Organization.objects.first()
        org.add_user(user)
        project = Project.objects.create(title=title, created_by=user, organization=org)
        print('Project with title "{}" successfully created'.format(title))

    if label_config is not None:
        with open(os.path.abspath(label_config)) as c:
            project.label_config = c.read()

    if sampling is not None:
        project.sampling = sampling

    if description is not None:
        project.description = description

    if ml_backends is not None:
        from ml.models import MLBackend

        # e.g.: localhost:8080,localhost:8081;localhost:8082
        for url in ml_backends:
            logger.info('Adding new ML backend %s', url)
            MLBackend.objects.create(project=project, url=url)

    project.save()
    return project


def _get_user_info(username):
    from users.models import User
    from users.serializers import UserSerializer

    if not username:
        username = DEFAULT_USERNAME

    user = User.objects.filter(email=username)
    if not user.exists():
        print({'status': 'error', 'message': f"user {username} doesn't exist"})
        return

    user = user.first()
    user_data = UserSerializer(user).data
    user_data['token'] = user.auth_token.key
    user_data['status'] = 'ok'
    print('=> User info:')
    print(user_data)
    return user_data


def _create_user(input_args, config):
    from organizations.models import Organization
    from users.models import User

    username = input_args.username or config.get('username') or get_env('USERNAME')
    password = input_args.password or config.get('password') or get_env('PASSWORD')
    token = input_args.user_token or config.get('user_token') or get_env('USER_TOKEN')

    if not username:
        user = User.objects.filter(email=DEFAULT_USERNAME).first()
        if user is not None:
            if password and not user.check_password(password):
                user.set_password(password)
                user.save()
                print(f'User {DEFAULT_USERNAME} password changed')
            return user

        if input_args.quiet_mode:
            return None

        print(f'Please enter default user email, or press Enter to use {DEFAULT_USERNAME}')
        username = input('Email: ')
        if not username:
            username = DEFAULT_USERNAME

    if not password and not input_args.quiet_mode:
        password = getpass.getpass(f'User password for {username}: ')

    try:
        user = User.objects.create_user(email=username, password=password)
        user.is_staff = True
        user.is_superuser = True
        user.save()

        if token and len(token) > 5:
            from rest_framework.authtoken.models import Token

            Token.objects.filter(key=user.auth_token.key).update(key=token)
        elif token:
            print(f'Token {token} is not applied to user {DEFAULT_USERNAME} ' f"because it's empty or len(token) < 5")

    except IntegrityError:
        print('User {} already exists'.format(username))

    user = User.objects.get(email=username)
    org = Organization.objects.first()
    if not org:
        org = Organization.create_organization(created_by=user, title='Label Studio')
    else:
        org.add_user(user)
    user.active_organization = org
    user.save(update_fields=['active_organization'])

    return user


def _init(input_args, config):
    user = _create_user(input_args, config)

    if user and input_args.project_name and not _project_exists(input_args.project_name):
        from projects.models import Project

        sampling_map = {
            'sequential': Project.SEQUENCE,
            'uniform': Project.UNIFORM,
            'prediction-score-min': Project.UNCERTAINTY,
        }
        _create_project(
            title=input_args.project_name,

[251 more lines in file. Use offset=201 to continue.]