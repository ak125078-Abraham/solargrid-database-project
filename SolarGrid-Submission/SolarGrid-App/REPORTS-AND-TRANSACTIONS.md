# Reports and transactions

Restart START.bat, enter the MySQL connection details, then sign in using your existing application account. New navigation links appear at the top of the customer directory.

- Invoice report: live invoice totals, payments and balances; search by customer/invoice and filter outstanding issued invoices. Summary amounts include only issued invoices matching the filter.
- Warranty report: installed equipment expiring between two inclusive dates; defaults to the next 90 days.
- Record payment: ADMIN and ACCOUNTS only. Select an invoice, enter an amount and receipt, and save. The authenticated user is recorded. Overpayments and conflicting receipts are rejected by the procedure.
- Complete installation: ADMIN and OPERATIONS only. Select an open job and available equipment, provide warranty dates, and save. An active lead technician must already be assigned. This version applies one warranty date range to all selected units.

Viewing reports does not change data. Submitting the transaction forms commits changes through the existing procedures. Do not use real payments for classroom tests. Duplicate submission may produce a conflict message because the recorded time changes; the unique receipt prevents a second insert.

Automated route tests use a mock database. Browser installation completion and payment forms were subsequently demonstrated, together with invoice creation, equipment registration, technician assignments and service requests. See the final technical report for evidence and remaining verification limits.
