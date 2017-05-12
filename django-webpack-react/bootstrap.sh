#!/bin/bash

PROJECT_NAME="$1"

if [[ -z $PROJECT_NAME ]]; then
    echo "no project name given"
    exit 1
fi

function venv {
    echo "
    - create a virtual env (either anaconda, virtualenv or virtualenvwrapper)
        - conda: conda create -n $PROJECT_NAME python=3.5.2
        - virtualenv: virtualenv -p /usr/bin/python3.5.2 $PROJECT_NAME
        - virtualenvwrapper: mkvirtualenv --python=python3.5.2 $PROJECT_NAME

    - activate the virtual env into current shell session
        - conda: source activate $PROJECT_NAME
        - virtualenv: source $PROJECT_NAME/bin/activate
        - virtualenvwrapper: workon $PROJECT_NAME
    "
}
function project-structure {
    echo "
    Your new project should look something like this
        $PROJECT_NAME
        ├── assets
        │   └── js
        │       ├── app.js
        │       └── index.js
        ├── db.sqlite3
        ├── $PROJECT_NAME
        │   ├── __init__.py
        │   ├── __pycache__
        │   ├── settings.py
        │   ├── urls.py
        │   └── wsgi.py
        ├── dist
        ├── manage.py
        ├── node_modules
        ├── package.json
        ├── requirements.txt
        ├── templates
        │   └── home.html
        ├── webpack.config.js
        └── yarn.lock
    "
}


function bootstrap {

    pip install django django-webpack-loader psycopg2

    django-admin startproject $PROJECT_NAME
    pip freeze > $PROJECT_NAME/requirements.txt
    mkdir -p $PROJECT_NAME/dist
    cp -a scaffolding/assets $PROJECT_NAME/assets

    # link dotfiles
    cp scaffolding/babelrc $PROJECT_NAME/.babelrc
    cp scaffolding/eslintignore $PROJECT_NAME/.eslintignore
    cp scaffolding/gitignore $PROJECT_NAME/.gitignore
    cp scaffolding/editorconfig $PROJECT_NAME/.editorconfig
    cp scaffolding/eslintrc.yaml $PROJECT_NAME/.eslintrc.yaml

    cp scaffolding/package.json $PROJECT_NAME/package.json
    cp scaffolding/webpack.config.js $PROJECT_NAME/webpack.config.js
    cp scaffolding/yarn.lock $PROJECT_NAME/yarn.lock
    cp -a scaffolding/django/templates $PROJECT_NAME
    cp scaffolding/django/urls.py $PROJECT_NAME/$PROJECT_NAME/urls.py
    cat scaffolding/django/settings.py >> $PROJECT_NAME/$PROJECT_NAME/settings.py
    sed -ie "s#DIRS.*\],#DIRS\': \[\'\{\}\/\{\}\'\.format\(BASE_DIR, 'templates\'\)\],#g" $PROJECT_NAME/$PROJECT_NAME/settings.py
    cd $PROJECT_NAME
    git init
    yarn install
    python manage.py migrate
}

bootstrap
echo "$(project-structure)"
