"""This file and its contents are licensed under the Apache License 2.0. Please see the included NOTICE for copyright information and LICENSE for a copy of the license.
"""
"""
Django Base settings for Label Studio.

For more information on this file, see
https://docs.djangoproject.com/en/3.1/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/3.1/ref/settings/
"""
import json
import logging
import os
import re
from datetime import timedelta

from django.core.exceptions import ImproperlyConfigured

from label_studio.core.utils.params import get_bool_env, get_env_list

formatter = 'standard'
JSON_LOG = get_bool_env('JSON_LOG', False)
if JSON_LOG:
    formatter = 'json'

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'json': {
            '()': 'label_studio.core.utils.formatter.CustomJsonFormatter',
            'format': '[%(asctime)s] [%(name)s::%(funcName)s::%(lineno)d] [%(levelname)s] [%(user_id)s] %(message)s',
            'datefmt': '%d/%b/%Y:%H:%M:%S %z',
        },
        'standard': {
            'format': '[%(asctime)s] [%(name)s::%(funcName)s::%(lineno)d] [%(levelname)s] %(message)s',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': formatter,
        },
    },
    'root': {
        'handlers': ['console'],
        'level': os.environ.get('LOG_LEVEL', 'DEBUG'),
    },
    'loggers': {
        'pykwalify': {'level': 'ERROR', 'propagate': False},
        'tavern': {'level': 'ERROR', 'propagate': False},
        'asyncio': {'level': 'WARNING'},
        'rules': {'level': 'WARNING'},
        'django': {
            'handlers': ['console'],
            # 'propagate': True,
        },
        'django_auth_ldap': {'level': os.environ.get('LOG_LEVEL', 'DEBUG')},
        'rq.worker': {
            'handlers': ['console'],
            'level': os.environ.get('LOG_LEVEL', 'INFO'),
        },
        'ddtrace': {
            'handlers': ['console'],
            'level': 'WARNING',
        },
        'ldclient.util': {
            'handlers': ['console'],
            'level': 'ERROR',
        },
    },
}

# for printing messages before main logging config applied
if not logging.getLogger().hasHandlers():
    logging.basicConfig(level=logging.DEBUG, format='%(message)s')

from label_studio.core.utils.io import get_data_dir
from label_studio.core.utils.params import get_bool_env, get_env

logger = logging.getLogger(__name__)
SILENCED_SYSTEM_CHECKS = []

# Hostname is used for proper path generation to the resources, pages, etc
HOSTNAME = get_env('HOST', '')
if HOSTNAME:
    if not HOSTNAME.startswith('http://') and not HOSTNAME.startswith('https://'):
        logger.info(
            '! HOST variable found in environment, but it must start with http:// or https://, ignore it: %s', HOSTNAME
        )
        HOSTNAME = ''
    else:
        logger.info('=> Hostname correctly is set to: %s', HOSTNAME)
        if HOSTNAME.endswith('/'):
            HOSTNAME = HOSTNAME[0:-1]

        # for django url resolver
        if HOSTNAME:
            # http[s]://domain.com:8080/script_name => /script_name
            pattern = re.compile(r'^http[s]?:\/\/([^:\/\s]+(:\d*)?)(.*)?')
            match = pattern.match(HOSTNAME)
            FORCE_SCRIPT_NAME = match.group(3)
            if FORCE_SCRIPT_NAME:
                logger.info('=> Django URL prefix is set to: %s', FORCE_SCRIPT_NAME)

DOMAIN_FROM_REQUEST = get_bool_env('DOMAIN_FROM_REQUEST', False)

if DOMAIN_FROM_REQUEST:
    # in this mode HOSTNAME can be only subpath
    if HOSTNAME and not HOSTNAME.startswith('/'):
        raise ImproperlyConfigured('LABEL_STUDIO_HOST must be a subpath if DOMAIN_FROM_REQUEST is True')

INTERNAL_PORT = '8080'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = get_bool_env('DEBUG', True)
DEBUG_MODAL_EXCEPTIONS = get_bool_env('DEBUG_MODAL_EXCEPTIONS', True)

# Whether to verify SSL certs when making external requests, eg in the uploader
# ⚠️ Turning this off means assuming risk. ⚠️
# Overridable at organization level via Organization#verify_ssl_certs
VERIFY_SSL_CERTS = get_bool_env('VERIFY_SSL_CERTS', True)

# 'sqlite-dll-<arch>-<version>.zip' should be hosted at this prefix
WINDOWS_SQLITE_BINARY_HOST_PREFIX = get_env('WINDOWS_SQLITE_BINARY_HOST_PREFIX', 'https://www.sqlite.org/2023/')

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Base path for media root and other uploaded files
BASE_DATA_DIR = get_env('BASE_DATA_DIR')
if BASE_DATA_DIR is None:
    BASE_DATA_DIR = get_data_dir()
os.makedirs(BASE_DATA_DIR, exist_ok=True)
logger.info('=> Database and media directory: %s', BASE_DATA_DIR)

# Databases
# https://docs.djangoproject.com/en/2.1/ref/settings/#databases
DJANGO_DB_MYSQL = 'mysql'
DJANGO_DB_SQLITE = 'sqlite'
DJANGO_DB_POSTGRESQL = 'postgresql'
DJANGO_DB = 'default'
DATABASE_NAME_DEFAULT = os.path.join(BASE_DATA_DIR, 'label_studio.sqlite3')
DATABASE_NAME = get_env('DATABASE_NAME', DATABASE_NAME_DEFAULT)
DATABASES_ALL = {
    DJANGO_DB_POSTGRESQL: {
        'ENGINE': 'django.db.backends.postgresql',
        'USER': get_env('POSTGRE_USER', 'postgres'),
        'PASSWORD': get_env('POSTGRE_PASSWORD', 'postgres'),
        'NAME': get_env('POSTGRE_NAME', 'postgres'),
        'HOST': get_env('POSTGRE_HOST', 'localhost'),
        'PORT': int(get_env('POSTGRE_PORT', '5432')),
    },
    DJANGO_DB_MYSQL: {
        'ENGINE': 'django.db.backends.mysql',
        'USER': get_env('MYSQL_USER', 'root'),
        'PASSWORD': get_env('MYSQL_PASSWORD', ''),
        'NAME': get_env('MYSQL_NAME', 'labelstudio'),
        'HOST': get_env('MYSQL_HOST', 'localhost'),
        'PORT': int(get_env('MYSQL_PORT', '3306')),
    },
    DJANGO_DB_SQLITE: {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': DATABASE_NAME,
        'OPTIONS': {
            # 'timeout': 20,
        },
    },
}
DATABASES_ALL['default'] = DATABASES_ALL[DJANGO_DB_POSTGRESQL]
DATABASES = {'default': DATABASES_ALL.get(get_env('DJANGO_DB', 'default'))}

DEFAULT_AUTO_FIELD = 'django.db.models.AutoField'

if get_bool_env('GOOGLE_LOGGING_ENABLED', False):
    logging.info('Google Cloud Logging handler is enabled.')
    try:
        import google.cloud.logging
        from google.auth.exceptions import GoogleAuthError

        client = google.cloud.logging.Client()
        client.setup_logging()

        LOGGING['handlers']['google_cloud_logging'] = {
            'level': get_env('LOG_LEVEL', 'WARNING'),
            'class': 'google.cloud.logging.handlers.CloudLoggingHandler',
            'client': client,
        }
        LOGGING['root']['handlers'].append('google_cloud_logging')
    except GoogleAuthError:
        logger.exception('Google Cloud Logging handler could not be setup.')

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

[565 more lines in file. Use offset=201 to continue.]