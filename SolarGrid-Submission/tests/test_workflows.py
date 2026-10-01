import sys
from pathlib import Path
from unittest.mock import MagicMock,patch
from decimal import Decimal
from datetime import datetime
sys.path.insert(0,str((Path(__file__).resolve().parents[1] / 'SolarGrid-App')))
import app
c=app.app.test_client()
with c.session_transaction() as s: s['user_id']=9;s['csrf']='token'
conn=MagicMock();cur=conn.cursor.return_value
cur.fetchone.return_value={'user_id':9,'username':'admin','role':'ADMIN'}
cur.fetchall.return_value=[]
with patch('management.mysql.connector.connect',return_value=conn):
    for path in ['/reports/invoices','/reports/warranties','/payments/new','/installations/complete']:
        response=c.get(path)
        assert response.status_code==200,(path,response.status_code)
    assert c.get('/reports/warranties?start=bad').status_code==400
    assert c.post('/payments/new',data={'csrf':'token','amount':'NaN'}).status_code==400
    assert c.post('/installations/complete',data={'csrf':'token'}).status_code==400
    cur.fetchall.return_value=[{'now':datetime(2026,9,13,12)}]
    response=c.post('/payments/new',data={'csrf':'token','invoice_id':'11','receipt':'TEST','amount':'1000.00','method':'CASH'})
    assert response.status_code==302
    assert cur.callproc.call_args.args[0]=='sp_record_payment'
    assert cur.callproc.call_args.args[1][-1]==9
    cur.fetchone.return_value={'user_id':9,'username':'ops','role':'OPERATIONS'}
    assert c.get('/payments/new').status_code==403
    cur.fetchone.return_value={'user_id':9,'username':'accounts','role':'ACCOUNTS'}
    assert c.get('/installations/complete').status_code==403
print('PASS: four pages, date validation, invalid amount, empty equipment, payment procedure dispatch and role protection. Mock database only.')
