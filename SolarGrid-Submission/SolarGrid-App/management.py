import getpass
import secrets
import re
import time
from contextlib import contextmanager
from flask import request, session, g, redirect, url_for, render_template, abort, flash
from werkzeug.security import generate_password_hash, check_password_hash
import mysql.connector

@contextmanager
def database(options):
    conn = mysql.connector.connect(**options)
    cur = conn.cursor(dictionary=True)
    try:
        yield conn, cur
    except Exception:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()

def setup_admin(options):
    """Provision a named app admin locally, only when no hashed active admin exists."""
    try:
        with database(options) as (conn, cur):
            cur.execute("SELECT password_hash FROM app_users WHERE role='ADMIN' AND is_active=1")
            if any(r['password_hash'].startswith(('scrypt:', 'pbkdf2:')) for r in cur.fetchall()):
                return True
            print('\nCreate your SolarGrid application login (different from MySQL login).')
            username = input('New application username: ').strip()
            if not re.fullmatch(r'[A-Za-z0-9_.-]{3,80}', username):
                print('Use 3–80 letters, numbers, dots, hyphens or underscores.'); return False
            cur.execute('SELECT user_id FROM app_users WHERE username=%s', (username,))
            if cur.fetchone():
                print('That username already exists. Restart and choose a new one.'); return False
            password = getpass.getpass('New application password (at least 12 characters): ')
            if len(password) < 12 or password != getpass.getpass('Repeat application password: '):
                print('Passwords must match and have at least 12 characters.'); return False
            cur.execute("INSERT INTO app_users(username,password_hash,full_name,role,is_active) VALUES (%s,%s,%s,'ADMIN',1)",
                        (username, generate_password_hash(password), username))
            conn.commit()
            print('Application administrator created. Use this login in your browser.')
            return True
    except mysql.connector.Error:
        print('Cannot prepare the login. Check MySQL credentials and app_users permissions.')
        return False

def install_management(app):
    attempts = {}
    dummy_hash = generate_password_hash(secrets.token_hex(20))

    @app.before_request
    def protect():
        if request.endpoint == 'static': return
        if 'csrf' not in session: session['csrf'] = secrets.token_urlsafe(32)
        if request.method == 'POST' and not secrets.compare_digest(session['csrf'], request.form.get('csrf', '')):
            abort(400, 'This form expired. Refresh the page and try again.')
        g.user = None
        if session.get('user_id'):
            with database(app.config['DB_OPTIONS']) as (_, cur):
                cur.execute('SELECT user_id,username,role FROM app_users WHERE user_id=%s AND is_active=1', (session['user_id'],))
                g.user = cur.fetchone()
        if request.endpoint != 'login' and not g.user: return redirect(url_for('login'))

    @app.errorhandler(mysql.connector.Error)
    def database_error(exc):
        return render_template('message.html', title='Database unavailable', message='Check that MySQL is running and your database account has the required permissions.'), 503

    @app.route('/login', methods=['GET', 'POST'])
    def login():
        error = None
        if request.method == 'POST':
            key = request.remote_addr
            now = time.monotonic()
            recent = [t for t in attempts.get(key, []) if now-t < 300]
            attempts[key] = recent
            if len(recent) >= 5:
                return render_template('login.html', error='Too many attempts. Wait five minutes and try again.'), 429
            with database(app.config['DB_OPTIONS']) as (_, cur):
                cur.execute('SELECT user_id,password_hash,is_active FROM app_users WHERE username=%s', (request.form.get('username', '').strip(),))
                user = cur.fetchone()
            stored = user['password_hash'] if user and user['password_hash'].startswith(('scrypt:', 'pbkdf2:')) else dummy_hash
            valid = check_password_hash(stored, request.form.get('password', ''))
            if user and user['is_active'] and valid and stored != dummy_hash:
                session.clear(); session['user_id'] = user['user_id']; session.permanent = True
                session['csrf'] = secrets.token_urlsafe(32)
                attempts.pop(key, None)
                return redirect(url_for('customers'))
            recent.append(now)
            error = 'Incorrect username or password, or account inactive.'
        return render_template('login.html', error=error)

    @app.post('/logout')
    def logout():
        session.clear()
        return redirect(url_for('login'))

    def authorize(roles):
        if g.user['role'] not in roles: abort(403)

    @app.route('/customers/new', methods=['GET', 'POST'])
    @app.route('/customers/<int:customer_id>/edit', methods=['GET', 'POST'])
    def customer_form(customer_id=None):
        authorize(('ADMIN', 'OPERATIONS'))
        data = dict(customer_name='', customer_type='HOUSEHOLD', phone='', email='', billing_address='', is_active=True)
        if customer_id:
            with database(app.config['DB_OPTIONS']) as (_, cur):
                cur.execute('SELECT * FROM customers WHERE customer_id=%s', (customer_id,))
                data = cur.fetchone()
            if data is None: abort(404)
        error = None
        if request.method == 'POST':
            data = {name: request.form.get(name, '').strip() for name in ('customer_name','customer_type','phone','email','billing_address')}
            data['is_active'] = request.form.get('is_active') == '1'
            if not data['customer_name'] or len(data['customer_name'])>150: error = 'Enter a name of 1–150 characters.'
            elif data['customer_type'] not in ('HOUSEHOLD','SCHOOL','FARM','BUSINESS'): error = 'Select a valid customer type.'
            elif not data['phone'] or len(data['phone'])>30: error = 'Enter a phone number of 1–30 characters.'
            elif len(data['email'])>254 or (data['email'] and not re.fullmatch(r'[^\s@]+@[^\s@]+\.[^\s@]+', data['email'])): error = 'Enter a valid email or leave it blank.'
            elif len(data['billing_address'])>255: error = 'Address must be 255 characters or fewer.'
            if not error:
                values = (data['customer_name'],data['customer_type'],data['phone'],data['email'] or None,data['billing_address'] or None,data['is_active'])
                with database(app.config['DB_OPTIONS']) as (conn, cur):
                    if customer_id:
                        cur.execute('UPDATE customers SET customer_name=%s,customer_type=%s,phone=%s,email=%s,billing_address=%s,is_active=%s WHERE customer_id=%s', values+(customer_id,))
                    else:
                        cur.execute('INSERT INTO customers(customer_name,customer_type,phone,email,billing_address,is_active) VALUES (%s,%s,%s,%s,%s,%s)', values)
                    conn.commit()
                flash('Customer saved successfully.')
                return redirect(url_for('customers'))
        return render_template('customer_form.html', data=data, customer_id=customer_id, error=error), (400 if error else 200)

    @app.route('/customers/<int:customer_id>/delete', methods=['GET','POST'])
    def delete_customer(customer_id):
        authorize(('ADMIN',))
        with database(app.config['DB_OPTIONS']) as (conn, cur):
            cur.execute('SELECT customer_id,customer_name FROM customers WHERE customer_id=%s', (customer_id,))
            customer = cur.fetchone()
            if customer is None: abort(404)
            if request.method == 'POST':
                try:
                    cur.execute('DELETE FROM customers WHERE customer_id=%s', (customer_id,))
                    conn.commit()
                except mysql.connector.IntegrityError as exc:
                    if exc.errno != 1451: raise
                    conn.rollback()
                    return render_template('message.html', title='Customer is in use', message='This customer has linked records and cannot be deleted. Edit the customer and mark them inactive instead.'), 409
                flash('Customer deleted successfully.')
                return redirect(url_for('customers'))
        return render_template('delete_customer.html', customer=customer)
