"""Stage 1: local customer directory backed by the existing SolarGrid database."""
import os
import getpass
import secrets
from datetime import timedelta
from flask import Flask, render_template, request
import mysql.connector

app = Flask(__name__)
app.config['DB_OPTIONS'] = {}
app.config.update(SECRET_KEY=secrets.token_hex(32), SESSION_COOKIE_HTTPONLY=True,
                  SESSION_COOKIE_SAMESITE='Lax', PERMANENT_SESSION_LIFETIME=timedelta(hours=2),
                  MAX_CONTENT_LENGTH=16384)
from management import install_management, setup_admin
install_management(app)
from workflows import install_workflows
install_workflows(app)
from operations import install_operations
install_operations(app)

@app.get('/')
def customers():
    query = request.args.get('q', '').strip()[:150]
    rows = []
    error = None
    connection = None
    cursor = None
    try:
        connection = mysql.connector.connect(**app.config['DB_OPTIONS'])
        cursor = connection.cursor(dictionary=True)
        cursor.execute('''SELECT customer_id, customer_name, customer_type,
                          phone, email, is_active FROM customers
                          WHERE LOCATE(%s, customer_name) > 0 OR LOCATE(%s, phone) > 0
                          ORDER BY customer_name LIMIT 200''', (query, query))
        rows = cursor.fetchall()
    except mysql.connector.Error as exc:
        error = {
            1045: 'MySQL rejected the username or password. Close this window and restart START.bat with your correct MySQL details.',
            1049: 'The solargrid database was not found on this server.',
            1146: 'The customers table was not found in the selected database.',
        }.get(exc.errno, 'Unable to read customers. Check that MySQL is running and the account can read the customers table.')
    finally:
        if cursor is not None:
            cursor.close()
        if connection is not None:
            connection.close()
    return render_template('customers.html', rows=rows, query=query, error=error), (503 if error else 200)

@app.after_request
def headers(response):
    response.headers['Cache-Control'] = 'no-store'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['Content-Security-Policy'] = "default-src 'self'; style-src 'self'; frame-ancestors 'none'"
    return response

if __name__ == '__main__':
    print('\nSolarGrid: first connection test. Password is not saved.\n')
    username = os.getenv('SOLARGRID_DB_USER') or input('MySQL username [root]: ').strip() or 'root'
    password = os.getenv('SOLARGRID_DB_PASSWORD')
    if password is None:
        password = getpass.getpass('MySQL password (characters stay hidden): ')
    app.config['DB_OPTIONS'] = dict(host=os.getenv('SOLARGRID_DB_HOST', '127.0.0.1'),
        port=int(os.getenv('SOLARGRID_DB_PORT', '3306')), user=username, password=password,
        database=os.getenv('SOLARGRID_DB_NAME', 'solargrid'), connection_timeout=5)
    if not setup_admin(app.config['DB_OPTIONS']):
        raise SystemExit('Setup stopped. Check your database connection and restart.')
    print('\nOpen http://127.0.0.1:5000 in your browser. Keep this window open.\n')
    app.run(host='127.0.0.1', port=5000, debug=False)
