import json
import uuid
from datetime import date, timedelta
from decimal import Decimal, InvalidOperation
from flask import render_template, request, g, abort, flash, redirect
import mysql.connector
from management import database

def install_workflows(app):
    def options(): return dict(app.config['DB_OPTIONS'], autocommit=True)
    def query(sql, params=()):
        with database(options()) as (_, cur):
            cur.execute(sql, params)
            return cur.fetchall()
    def call(name, args):
        with database(options()) as (_, cur):
            cur.callproc(name, args)
            for result in cur.stored_results(): result.fetchall()

    @app.get('/reports/invoices')
    def invoice_report():
        q = request.args.get('q','').strip()[:150]
        unpaid = request.args.get('unpaid') == '1'
        rows = query('SELECT * FROM v_invoice_balances WHERE (LOCATE(%s,customer_name)>0 OR LOCATE(%s,invoice_number)>0) '+('AND invoice_status=\'ISSUED\' AND outstanding_balance>0 ' if unpaid else '')+'ORDER BY invoice_id', (q,q))
        issued = [r for r in rows if r['invoice_status']=='ISSUED']
        totals = {key:sum((r[key] for r in issued), Decimal('0')) for key in ('invoice_total','paid_total','outstanding_balance')}
        return render_template('invoices.html',rows=rows,q=q,unpaid=unpaid,totals=totals)

    @app.get('/reports/warranties')
    def warranty_report():
        start = request.args.get('start',date.today().isoformat())
        end = request.args.get('end',(date.today()+timedelta(days=90)).isoformat())
        try:
            if date.fromisoformat(start)>date.fromisoformat(end): raise ValueError()
        except ValueError:
            return render_template('message.html',title='Check the dates',message='Enter a valid start and end date, with the start first.'),400
        rows=query('SELECT * FROM v_active_equipment_warranties WHERE warranty_end BETWEEN %s AND %s ORDER BY warranty_end,serial_number',(start,end))
        return render_template('warranties.html',rows=rows,start=start,end=end)

    @app.route('/payments/new',methods=['GET','POST'])
    def payment_form():
        if g.user['role'] not in ('ADMIN','ACCOUNTS'): abort(403)
        data=request.form if request.method=='POST' else {'receipt':'APP-'+uuid.uuid4().hex[:24],'invoice_id':request.args.get('invoice_id','')}
        error=None
        if request.method=='POST':
            try:
                invoice_id=int(data.get('invoice_id',''))
                amount=Decimal(data.get('amount',''))
                if not amount.is_finite() or amount<=0 or amount>Decimal('9999999999.99') or amount != amount.quantize(Decimal('.01')): raise ValueError()
                receipt=data.get('receipt','').strip()
                method=data.get('method','')
                if not receipt or len(receipt)>40 or method not in ('CASH','BANK_TRANSFER','MOBILE_MONEY','CARD'): raise ValueError()
                # Server time is used. User identity always comes from the authenticated session.
                now=query('SELECT NOW() AS now')[0]['now']
                call('sp_record_payment',(invoice_id,receipt,now,amount,method,None,g.user['user_id']))
                flash('Payment recorded. The invoice balance has been updated.')
                return redirect('/reports/invoices')
            except (ValueError,InvalidOperation): error='Choose an invoice, a payment method, a receipt and a positive amount with at most two decimal places.'
            except mysql.connector.Error as exc:
                error=exc.msg if exc.errno==1644 else 'Payment could not be recorded. No success was confirmed; check the invoice before retrying.'
        invoices=query("SELECT invoice_id,invoice_number,customer_name,outstanding_balance FROM v_invoice_balances WHERE invoice_status='ISSUED' ORDER BY invoice_id")
        return render_template('payment.html',data=data,invoices=invoices,error=error), (400 if error else 200)

    @app.route('/installations/complete',methods=['GET','POST'])
    def installation_form():
        if g.user['role'] not in ('ADMIN','OPERATIONS'): abort(403)
        error=None
        if request.method=='POST':
            try:
                installation_id=int(request.form.get('installation_id',''))
                units=[int(i) for i in request.form.getlist('units')]
                start=date.fromisoformat(request.form.get('start',''))
                end=date.fromisoformat(request.form.get('end',''))
                now=query('SELECT NOW() AS now')[0]['now']
                if not units or len(set(units))!=len(units) or end<start or start>now.date(): raise ValueError()
                notes=request.form.get('notes','').strip()
                if len(notes)>2000: raise ValueError()
                equipment=json.dumps([dict(equipment_unit_id=i,warranty_start=start.isoformat(),warranty_end=end.isoformat()) for i in units])
                call('sp_complete_installation',(installation_id,equipment,now,notes))
                flash('Installation completed and equipment marked installed.')
                return redirect('/installations/complete')
            except ValueError: error='Select a job and equipment, and enter valid warranty dates. Notes must be at most 2,000 characters.'
            except mysql.connector.Error as exc: error=exc.msg if exc.errno==1644 else 'Installation could not be completed. Check its current status before retrying.'
        jobs=query("SELECT i.installation_id,s.site_name,i.status FROM installations i JOIN sites s ON s.site_id=i.site_id WHERE i.status IN ('SCHEDULED','IN_PROGRESS') ORDER BY i.installation_id")
        units=query("SELECT equipment_unit_id,serial_number FROM equipment_units WHERE status='AVAILABLE' ORDER BY equipment_unit_id")
        return render_template('installation.html',jobs=jobs,units=units,error=error,today=date.today().isoformat()), (400 if error else 200)
