import sys
from pathlib import Path
from unittest.mock import patch, MagicMock
sys.path.insert(0, str((Path(__file__).resolve().parents[1] / 'SolarGrid-App')))
import app
from werkzeug.security import generate_password_hash
client=app.app.test_client()
assert client.get('/').status_code==302
assert client.get('/login').status_code==200
assert client.post('/customers/new').status_code==400
admin={'user_id':9,'username':'test','role':'ADMIN'}
def login_session():
    with client.session_transaction() as s: s['user_id']=9; s['csrf']='token'
login_session()
conn=MagicMock(); cur=conn.cursor.return_value
with patch('management.mysql.connector.connect',return_value=conn):
    cur.fetchone.return_value=admin
    assert client.get('/customers/new').status_code==200
    assert client.post('/customers/new',data={'csrf':'token','customer_name':''}).status_code==400
    payload=dict(csrf='token',customer_name='Test',customer_type='FARM',phone='123',email='',billing_address='',is_active='1')
    assert client.post('/customers/new',data=payload).status_code==302
    conn.commit.assert_called()
    cur.fetchone.return_value=dict(admin,role='ACCOUNTS')
    assert client.get('/customers/new').status_code==403
    assert client.post('/customers/1/delete',data={'csrf':'token'}).status_code==403
    cur.fetchone.side_effect=[admin,{'customer_id':1,'customer_name':'Linked'}]
    def execute(sql,*args):
        if sql.startswith('DELETE'): raise app.mysql.connector.IntegrityError(errno=1451)
    cur.execute.side_effect=execute
    assert client.post('/customers/1/delete',data={'csrf':'token'}).status_code==409
    conn.rollback.assert_called()
    cur.execute.side_effect=None;cur.fetchone.side_effect=None
    cur.fetchone.return_value=admin
    assert client.post('/logout',data={'csrf':'token'}).status_code==302
    assert client.get('/').status_code==302
    client.get('/login')
    with client.session_transaction() as s: token=s['csrf']
    cur.fetchone.return_value={'user_id':9,'is_active':1,'password_hash':generate_password_hash('test-password-123')}
    assert client.post('/login',data={'csrf':token,'username':'test','password':'test-password-123'}).status_code==302
print('PASS: login, protected pages, CSRF, validation, create commit, read-only role, linked-record delete rollback and logout.')
