import sys
from pathlib import Path
from unittest.mock import MagicMock, patch
import mysql.connector
sys.path.insert(0,str((Path(__file__).resolve().parents[1] / 'SolarGrid-App')))
import app
c=app.app.test_client()
with c.session_transaction() as s:s['user_id']=9;s['csrf']='token'
conn=MagicMock();cur=conn.cursor.return_value
cur.fetchone.return_value={'user_id':9,'username':'admin','role':'ADMIN'}
cur.fetchall.return_value=[]
cur.lastrowid=100
with patch('management.mysql.connector.connect',return_value=conn):
    for path in ['/operations','/operations/sites','/operations/catalogue','/operations/equipment','/operations/technicians','/schedule','/assign-technician','/history','/service','/maintenance','/invoices/new','/reports/operations']:
        r=c.get(path)
        assert r.status_code==200,(path,r.status_code)
    invoice={'csrf':'token','customer_id':'1','invoice_number':'TEST & 1','issue_date':'2026-01-01','due_date':'2026-01-02','description_1':'Labour','type_1':'INSTALLATION','quantity_1':'2','price_1':'100'}
    conn.commit.reset_mock()
    r=c.post('/invoices/new',data=invoice)
    assert r.status_code==302
    assert '%26' in r.location
    conn.commit.assert_called_once()
    assert any('INSERT INTO invoice_items' in x.args[0] for x in cur.execute.call_args_list)
    def fail_line(sql,*args):
        if 'INSERT INTO invoice_items' in sql:raise mysql.connector.Error('simulated failure',errno=1062)
    cur.execute.side_effect=fail_line
    conn.commit.reset_mock();conn.rollback.reset_mock()
    assert c.post('/invoices/new',data=invoice).status_code==400
    conn.commit.assert_not_called();conn.rollback.assert_called_once()
    cur.execute.side_effect=None
    conn.commit.reset_mock()
    assert c.post('/invoices/new',data=dict(invoice,quantity_1='.33',price_1='.33')).status_code==400
    conn.commit.assert_not_called()
    assert c.post('/schedule',data={'csrf':'token'}).status_code==400
    schedule={'csrf':'token','site_id':'1','technician_id':'1','scheduled_at':'2026-12-01T10:00','work_description':'Install equipment'}
    def fail_assignment(sql,*args):
        if 'INSERT INTO installation_technicians' in sql:raise mysql.connector.Error('simulated failure',errno=1062)
    cur.execute.side_effect=fail_assignment
    conn.rollback.reset_mock()
    assert c.post('/schedule',data=schedule).status_code==400
    conn.commit.assert_not_called();conn.rollback.assert_called_once()
    cur.execute.side_effect=None
    cur.fetchone.return_value={'user_id':9,'username':'accounts','role':'ACCOUNTS'}
    assert c.get('/schedule').status_code==403
    assert c.post('/service',data={'csrf':'token'}).status_code==403
    cur.fetchone.return_value={'user_id':9,'username':'ops','role':'OPERATIONS'}
    assert c.get('/invoices/new').status_code==403
    assert c.post('/schedule',data={}).status_code==400
print('PASS: 12 screens, invoice transaction and rollback, scheduling rollback, precision validation, role checks and CSRF. Mock database only.')
