from django.db import connection

connection.cursor().execute('SELECT now()')
