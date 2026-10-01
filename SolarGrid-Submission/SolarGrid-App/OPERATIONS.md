# Operational screens

The Operations menu adds customer sites, equipment models and units, technicians, installation scheduling and assignments, service requests, maintenance and invoice creation. History shows placements, technician assignments and service work for a selected installation. The operations report shows technician workload and monthly payment receipts.

## Enable

1. In the root MySQL connection, open and run ../SolarGrid-MySQL-Stage2/08_operations_permissions.sql after the existing 07 script.
2. Stop the Flask server with Ctrl+C and launch START.bat again. Connect as solargrid_app with its existing MySQL password.
3. Open the local app and sign in as solaradmin with the application password. Open Operations.

ADMIN and OPERATIONS can manage operational records. ADMIN and ACCOUNTS can issue invoices and record payments. Signed-in application users can view history and reports. The shared MySQL application account holds the combined rights; Flask enforces individual application roles. The reporting database account is unchanged.

## Transaction boundaries

- Scheduling inserts the installation and lead assignment in one transaction.
- Registering service inserts the request and assignment together.
- Maintenance inserts the work record and optionally resolves the request together.
- Invoice creation inserts the header and up to five lines together.

Validation and relevant row locks precede inserts. Errors before commit cause rollback. An interrupted connection during commit can leave the outcome uncertain: inspect history before retrying. Invoices have unique numbers, which also block duplicate invoice submission.

Invoice quantities and prices support two decimals, but their product must also have at most two decimals. This keeps amounts consistent with the existing payment procedure. Issued invoices cannot be edited through these screens. Registers currently support creation and viewing; customer management retains full CRUD.

## Verification

Automated Flask tests passed with a mocked database: 12 new pages render; invoice and scheduling failures roll back without commit; invoice precision, role restrictions and CSRF are checked. Existing login/customer and report/procedure-dispatch tests also passed.

The live school demonstration confirmed catalogue creation, additional technician assignment, installation completion, service resolution, invoice creation and payment recording. Technician creation remains unverified live. See the technical report for the separate September 13 screenshots and September 30 operator-confirmed results.

A new backup was created and restored on September 30. Superseded starter ZIP files should not be submitted.
