import os

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': os.getenv('APPSERVER_DB_NAME', 'your_db_name'),
        'USER': os.getenv('APPSERVER_DB_USER', ''),
        'PASSWORD': os.getenv('APPSERVER_DB_PASSWORD', ''),
        'HOST': os.getenv('APPSERVER_DB_HOST', 'localhost'),
        'PORT': os.getenv('APPSERVER_DB_PORT', '5432'),
    }
}

