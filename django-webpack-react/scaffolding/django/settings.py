STATICFILES_DIRS = (
    os.path.join(BASE_DIR, 'dist'),
)


WEBPACK_LOADER = {
    'DEFAULT': {
        'BUNDLE_DIR_NAME': '',
        'STATS_FILE': os.path.join(BASE_DIR, 'webpack-stats.json')
    }
}

INSTALLED_APPS += [
    'webpack_loader',
]
