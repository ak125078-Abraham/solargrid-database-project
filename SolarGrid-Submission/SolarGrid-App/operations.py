"""Validated operational forms. All SQL identifiers below are fixed application constants."""
from datetime import date, datetime
from decimal import Decimal, InvalidOperation
import re
import uuid
import mysql.connector
from flask import request, render_template, g, abort, redirect, flash, url_for
from management import database

def text_value(name, limit=255, optional=False):
    value=request.form.get(name,'').strip()
    if (not value and not optional) or len(value)>limit:
        raise ValueError(f'{name.replace("_"," ").title()} is required and must be at most {limit} characters.' if not optional else f'{name} is too long.')
    return value or None

def money(value, maximum='9999999999.99', positive=False):
    try:
        result=Decimal(value)
        if not result.is_finite() or result<0 or result>Decimal(maximum) or (positive and result==0) or result!=result.quantize(Decimal('.01')): raise ValueError()
        return result
    except (InvalidOperation,ValueError): raise ValueError('Enter a valid amount with at most two decimal places.')

def selected(name):
    try:
        value=int(request.form.get(name,''))
        if value<=0: raise ValueError()
        return value
    except ValueError: raise ValueError('Choose a valid '+name.replace('_',' ')+'.')

def lock(cur, sql, params, message):
    # Validation of parent records needs shared locks. Only the service request
    # itself is subsequently updated and must retain its exclusive lock.
    if not sql.startswith('SELECT service_request_id FROM service_requests '):
        sql=sql.replace('FOR UPDATE','FOR SHARE')
    cur.execute(sql,params)
    row=cur.fetchone()
    if not row: raise ValueError(message)
    return row

def install_operations(app):
    @app.get('/operations')
    def operations_home():
        return render_template('operations_home.html')
    def options(): return dict(app.config['DB_OPTIONS'],autocommit=False)
    def read(sql,params=()):
        with database(options()) as (_,cur):
            cur.execute(sql,params);return cur.fetchall()
    def authorize(finance=False):
        if g.user['role'] not in ('ADMIN','ACCOUNTS' if finance else 'OPERATIONS'): abort(403)
    def error_page(exc):
        if isinstance(exc,ValueError): msg=str(exc)
        elif exc.errno==1062: msg='That unique number or assignment already exists. Check the existing record before trying again.'
        elif exc.errno in (1142,1370):
            app.logger.warning('Operations permission error %s: %s',exc.errno,exc.msg)
            msg='A database permission check failed. Share the denied table and error number from the server window so the exact permission can be checked.'
        else: msg='The operation could not be confirmed. Check existing records before retrying. Database changes in this operation are rolled back if an error occurs before commit.'
        return render_template('message.html',title='Record not saved',message=msg),400

    # Field tuples: name, label, kind, maximum text length (where applicable).
    forms={
        'sites':('Customer sites','sites',[
            ('customer_id','Customer','customers',0),('site_name','Site name','text',100),('address','Address','text',255),('town','Town','text',100),('site_notes','Notes (optional)','optional',2000)]),
        'catalogue':('Equipment catalogue','equipment_types',[
            ('sku','SKU','text',50),('category','Category','category',0),('manufacturer','Manufacturer','text',100),('model_name','Model','text',100),('description','Description (optional)','optional',2000),('default_warranty_months','Default warranty months','integer',0),('list_price','List price (ZMW)','money',0)]),
        'equipment':('Equipment register','equipment_units',[
            ('equipment_type_id','Equipment model','models',0),('serial_number','Serial number','text',100),('received_date','Received date','date',0)]),
        'technicians':('Technicians','technicians',[
            ('full_name','Full name','text',150),('phone','Phone','text',30),('email','Email (optional)','email',254),('specialization','Specialization','text',100)])}

    @app.route('/operations/<kind>',methods=['GET','POST'])
    def register(kind):
        if kind not in forms: abort(404)
        authorize()
        title,table,fields=forms[kind]
        if request.method=='POST':
            try:
                values=[]
                for name,label,typ,length in fields:
                    if typ in ('text','optional','email'):
                        value=text_value(name,length,typ!='text')
                        if typ=='email' and value and not re.fullmatch(r'[^\s@]+@[^\s@]+\.[^\s@]+',value): raise ValueError('Enter a valid email.')
                    elif typ in ('customers','models'): value=selected(name)
                    elif typ=='category':
                        value=request.form.get(name)
                        if value not in ('PANEL','BATTERY','INVERTER','OTHER'): raise ValueError('Choose an equipment category.')
                    elif typ=='integer':
                        value=int(request.form.get(name,''))
                        if not 0<=value<=65535: raise ValueError('Warranty months must be between 0 and 65535.')
                    elif typ=='money': value=money(request.form.get(name,''))
                    else:
                        value=date.fromisoformat(request.form.get(name,''))
                        if value>date.today(): raise ValueError('Received date cannot be in the future.')
                    values.append(value)
                with database(options()) as (conn,cur):
                    if kind=='sites': lock(cur,'SELECT customer_id FROM customers WHERE customer_id=%s AND is_active=1 FOR UPDATE',(values[0],),'Select an active customer.')
                    columns=[f[0] for f in fields]
                    if kind=='equipment': columns.append('status');values.append('AVAILABLE')
                    cur.execute('INSERT INTO '+table+' ('+','.join(columns)+') VALUES ('+','.join(['%s']*len(values))+')',tuple(values))
                    conn.commit()
                flash('Record saved successfully.');return redirect(request.path)
            except (ValueError,mysql.connector.Error) as exc:return error_page(exc)
        choices={}
        if kind=='sites':choices['customers']=read('SELECT customer_id AS id,customer_name AS label FROM customers WHERE is_active=1 ORDER BY customer_name')
        if kind=='equipment':choices['models']=read('SELECT equipment_type_id AS id,CONCAT(sku,\' - \',model_name) AS label FROM equipment_types ORDER BY sku')
        rows=read('SELECT * FROM '+table+' ORDER BY 1 DESC LIMIT 100')
        return render_template('register.html',title=title,fields=fields,choices=choices,rows=rows,today=date.today().isoformat())

    @app.route('/schedule',methods=['GET','POST'])
    def schedule():
        authorize()
        if request.method=='POST':
            try:
                site=selected('site_id');tech=selected('technician_id')
                scheduled=datetime.fromisoformat(request.form.get('scheduled_at',''))
                description=text_value('work_description',2000)
                with database(options()) as (conn,cur):
                    lock(cur,'SELECT s.site_id FROM sites s JOIN customers c ON c.customer_id=s.customer_id WHERE s.site_id=%s AND c.is_active=1 FOR UPDATE',(site,),'Choose a site belonging to an active customer.')
                    lock(cur,'SELECT technician_id FROM technicians WHERE technician_id=%s AND is_active=1 FOR UPDATE',(tech,),'Choose an active lead technician.')
                    cur.execute("INSERT INTO installations(site_id,scheduled_at,status,work_description) VALUES (%s,%s,'SCHEDULED',%s)",(site,scheduled,description));job=cur.lastrowid
                    cur.execute("INSERT INTO installation_technicians(installation_id,technician_id,assignment_role) VALUES (%s,%s,'LEAD')",(job,tech))
                    conn.commit()
                flash(f'Installation {job} scheduled and lead technician assigned.');return redirect('/history')
            except (ValueError,mysql.connector.Error) as exc:return error_page(exc)
        return render_template('schedule.html',sites=read('SELECT s.site_id, s.site_name,c.customer_name FROM sites s JOIN customers c ON c.customer_id=s.customer_id WHERE c.is_active=1 ORDER BY s.site_id'),technicians=read('SELECT technician_id,full_name FROM technicians WHERE is_active=1 ORDER BY full_name'))

    @app.route('/assign-technician',methods=['GET','POST'])
    def assign_technician():
        authorize()
        if request.method=='POST':
            try:
                job=selected('installation_id');tech=selected('technician_id');role=request.form.get('assignment_role')
                if role not in ('LEAD','ASSISTANT'):raise ValueError('Choose a valid role.')
                with database(options()) as (conn,cur):
                    lock(cur,"SELECT installation_id FROM installations WHERE installation_id=%s AND status IN ('SCHEDULED','IN_PROGRESS') FOR UPDATE",(job,),'Choose an open job.')
                    lock(cur,'SELECT technician_id FROM technicians WHERE technician_id=%s AND is_active=1 FOR UPDATE',(tech,),'Choose an active technician.')
                    cur.execute('INSERT INTO installation_technicians(installation_id,technician_id,assignment_role) VALUES (%s,%s,%s)',(job,tech,role));conn.commit()
                flash('Technician assigned.');return redirect('/history?job='+str(job))
            except (ValueError,mysql.connector.Error) as exc:return error_page(exc)
        return render_template('assign.html',jobs=read("SELECT installation_id FROM installations WHERE status IN ('SCHEDULED','IN_PROGRESS') ORDER BY installation_id"),technicians=read('SELECT technician_id,full_name FROM technicians WHERE is_active=1 ORDER BY full_name'))

    @app.get('/history')
    def history():
        q=request.args.get('q','').strip()[:150]
        rows=read("SELECT i.installation_id,c.customer_name,s.site_name,i.scheduled_at,i.completed_at,i.status,i.work_description FROM installations i JOIN sites s ON s.site_id=i.site_id JOIN customers c ON c.customer_id=s.customer_id WHERE LOCATE(%s,c.customer_name)>0 OR LOCATE(%s,s.site_name)>0 ORDER BY i.installation_id DESC",(q,q))
        job=request.args.get('job','');details={}
        if job:
            try:job=int(job)
            except ValueError:abort(400)
            details['Equipment placements']=read('SELECT equipment_unit_id,installed_at,removed_at,warranty_start,warranty_end FROM installation_equipment WHERE installation_id=%s',(job,))
            details['Assigned technicians']=read('SELECT t.full_name,it.assignment_role,it.assigned_at FROM installation_technicians it JOIN technicians t ON t.technician_id=it.technician_id WHERE it.installation_id=%s',(job,))
            details['Service requests']=read('SELECT service_request_id,problem_description,priority,status FROM service_requests WHERE installation_id=%s',(job,))
            details['Maintenance history']=read('SELECT m.performed_at,t.full_name,m.work_done,m.maintenance_cost,m.next_service_date FROM maintenance_records m JOIN service_requests s ON s.service_request_id=m.service_request_id JOIN technicians t ON t.technician_id=m.technician_id WHERE s.installation_id=%s',(job,))
        return render_template('history.html',rows=rows,q=q,job=job,details=details)

    @app.route('/service',methods=['GET','POST'])
    def service():
        authorize()
        if request.method=='POST':
            try:
                job=selected('installation_id');tech=selected('technician_id');problem=text_value('problem_description',2000);priority=request.form.get('priority')
                if priority not in ('LOW','MEDIUM','HIGH','URGENT'):raise ValueError('Choose a priority.')
                with database(options()) as (conn,cur):
                    lock(cur,"SELECT installation_id FROM installations WHERE installation_id=%s AND status='COMPLETED' FOR UPDATE",(job,),'Choose a completed installation.')
                    lock(cur,'SELECT technician_id FROM technicians WHERE technician_id=%s AND is_active=1 FOR UPDATE',(tech,),'Choose an active technician.')
                    cur.execute("INSERT INTO service_requests(installation_id,problem_description,priority,status) VALUES (%s,%s,%s,'ASSIGNED')",(job,problem,priority));sid=cur.lastrowid
                    cur.execute('INSERT INTO service_request_technicians(service_request_id,technician_id) VALUES (%s,%s)',(sid,tech));conn.commit()
                flash(f'Service request {sid} registered and assigned.');return redirect('/service')
            except (ValueError,mysql.connector.Error) as exc:return error_page(exc)
        return render_template('service.html',jobs=read("SELECT installation_id FROM installations WHERE status='COMPLETED' ORDER BY installation_id"),technicians=read('SELECT technician_id,full_name FROM technicians WHERE is_active=1 ORDER BY full_name'),rows=read("SELECT service_request_id,installation_id,problem_description,priority,status FROM service_requests WHERE status NOT IN ('RESOLVED','CANCELLED') ORDER BY service_request_id DESC"))

    @app.route('/maintenance',methods=['GET','POST'])
    def maintenance():
        authorize()
        if request.method=='POST':
            try:
                sid=selected('service_request_id');tech=selected('technician_id');work=text_value('work_done',2000);cost=money(request.form.get('maintenance_cost',''))
                next_date=request.form.get('next_service_date','');next_date=date.fromisoformat(next_date) if next_date else None
                with database(options()) as (conn,cur):
                    lock(cur,"SELECT service_request_id FROM service_requests WHERE service_request_id=%s AND status NOT IN ('RESOLVED','CANCELLED') FOR UPDATE",(sid,),'Service request is already closed or missing.')
                    lock(cur,'SELECT st.technician_id FROM service_request_technicians st JOIN technicians t ON t.technician_id=st.technician_id WHERE st.service_request_id=%s AND st.technician_id=%s AND t.is_active=1 FOR UPDATE',(sid,tech),'Select an active technician assigned to this request.')
                    cur.execute('SELECT NOW() AS now');now=cur.fetchone()['now']
                    if next_date and next_date<now.date():raise ValueError('Next service date cannot precede the work date.')
                    cur.execute('INSERT INTO maintenance_records(service_request_id,technician_id,performed_at,work_done,maintenance_cost,next_service_date) VALUES (%s,%s,%s,%s,%s,%s)',(sid,tech,now,work,cost,next_date))
                    if request.form.get('resolve')=='1':cur.execute("UPDATE service_requests SET status='RESOLVED',resolved_at=%s WHERE service_request_id=%s",(now,sid))
                    conn.commit()
                flash('Maintenance recorded.');return redirect('/service')
            except (ValueError,mysql.connector.Error) as exc:return error_page(exc)
        assignments=read("SELECT st.service_request_id,st.technician_id,t.full_name FROM service_request_technicians st JOIN technicians t ON t.technician_id=st.technician_id JOIN service_requests s ON s.service_request_id=st.service_request_id WHERE t.is_active=1 AND s.status NOT IN ('RESOLVED','CANCELLED') ORDER BY st.service_request_id")
        return render_template('maintenance.html',assignments=assignments)

    @app.route('/invoices/new',methods=['GET','POST'])
    def issue_invoice():
        authorize(True)
        if request.method=='POST':
            try:
                customer=selected('customer_id');number=text_value('invoice_number',30);issue=date.fromisoformat(request.form.get('issue_date',''));due=date.fromisoformat(request.form.get('due_date',''))
                if due<issue or issue>date.today():raise ValueError('Invoice dates are invalid: issue date cannot be future and due date must be on or after issue date.')
                job=request.form.get('installation_id','');job=int(job) if job else None
                lines=[]
                for i in range(1,6):
                    description=request.form.get(f'description_{i}','').strip()
                    if not description:
                        if request.form.get(f'quantity_{i}','').strip() or request.form.get(f'price_{i}','').strip():raise ValueError('Each filled line needs a description.')
                        continue
                    if len(description)>255:raise ValueError('Line description is too long.')
                    typ=request.form.get(f'type_{i}')
                    if typ not in ('EQUIPMENT','INSTALLATION','MAINTENANCE','OTHER'):raise ValueError('Invalid charge type.')
                    quantity=money(request.form.get(f'quantity_{i}',''),'99999999.99',True)
                    price=money(request.form.get(f'price_{i}',''))
                    if quantity*price != (quantity*price).quantize(Decimal('.01')):
                        raise ValueError('Each line total must have at most two decimal places. Adjust its quantity or unit price.')
                    lines.append((typ,description,quantity,price))
                if not lines:raise ValueError('Include at least one invoice line.')
                with database(options()) as (conn,cur):
                    lock(cur,'SELECT customer_id FROM customers WHERE customer_id=%s AND is_active=1 FOR UPDATE',(customer,),'Choose an active customer.')
                    if job:lock(cur,"SELECT i.installation_id FROM installations i JOIN sites s ON s.site_id=i.site_id WHERE i.installation_id=%s AND s.customer_id=%s AND i.status<>'CANCELLED' FOR UPDATE",(job,customer),'Installation must belong to the selected customer and must not be cancelled.')
                    cur.execute("INSERT INTO invoices(invoice_number,customer_id,installation_id,issue_date,due_date,status) VALUES (%s,%s,%s,%s,%s,'ISSUED')",(number,customer,job,issue,due));invoice=cur.lastrowid
                    for n,line in enumerate(lines,1):cur.execute('INSERT INTO invoice_items(invoice_id,line_number,item_type,description,quantity,unit_price) VALUES (%s,%s,%s,%s,%s,%s)',(invoice,n)+line)
                    conn.commit()
                flash('Invoice issued with its line items.');return redirect(url_for('invoice_report',q=number))
            except (ValueError,mysql.connector.Error) as exc:return error_page(exc)
        return render_template('issue_invoice.html',customers=read('SELECT customer_id,customer_name FROM customers WHERE is_active=1 ORDER BY customer_name'),jobs=read("SELECT i.installation_id,c.customer_name FROM installations i JOIN sites s ON s.site_id=i.site_id JOIN customers c ON c.customer_id=s.customer_id WHERE i.status<>'CANCELLED' ORDER BY i.installation_id"),number='SG-APP-'+uuid.uuid4().hex[:16],today=date.today().isoformat())

    @app.get('/reports/operations')
    def operations_report():
        rows=read("SELECT t.full_name,COALESCE(i.jobs,0) AS open_installations,COALESCE(s.jobs,0) AS open_requests FROM technicians t LEFT JOIN (SELECT it.technician_id,COUNT(*) AS jobs FROM installation_technicians it JOIN installations i ON i.installation_id=it.installation_id WHERE i.status IN ('SCHEDULED','IN_PROGRESS') GROUP BY it.technician_id) i ON i.technician_id=t.technician_id LEFT JOIN (SELECT st.technician_id,COUNT(*) AS jobs FROM service_request_technicians st JOIN service_requests sr ON sr.service_request_id=st.service_request_id WHERE sr.status NOT IN ('RESOLVED','CANCELLED') GROUP BY st.technician_id) s ON s.technician_id=t.technician_id ORDER BY t.full_name")
        receipts=read("SELECT DATE_FORMAT(paid_at,'%Y-%m') AS month,SUM(amount) AS cash_received_zmw FROM payments GROUP BY DATE_FORMAT(paid_at,'%Y-%m') ORDER BY month")
        return render_template('operations_report.html',rows=rows,receipts=receipts)
