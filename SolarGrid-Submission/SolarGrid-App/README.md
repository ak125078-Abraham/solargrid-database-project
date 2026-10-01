# SolarGrid application

Python Flask application connected directly to MySQL. Features include application login, customer CRUD, sites, equipment catalogue and units, scheduling, technician assignments, installation completion, service and maintenance records, invoice creation, payments, history and reports.

For an existing installation, launch START.bat and explicitly enter solargrid_app at the database username prompt. Enter its password privately, keep the console open, and visit http://127.0.0.1:5000. Sign in using your separate application username and password. Root is reserved for database setup and first administrator provisioning.

For a fresh installation, follow the submission root README in order. Install Python and MySQL first; START.bat creates a virtual environment and installs requirements. The application requires the tables, views, procedures and both grant scripts. The fresh-admin prompt needs a new username and a password of at least 12 characters.

Optional environment variables: SOLARGRID_DB_HOST, SOLARGRID_DB_PORT, SOLARGRID_DB_USER, SOLARGRID_DB_PASSWORD, SOLARGRID_DB_NAME. Do not commit credentials. The app listens on localhost and is intended for classroom demonstration.

Customer records support full CRUD with role and relationship restrictions. Other registers support their implemented workflows, not unrestricted editing/deletion. OPERATIONS.md explains transaction boundaries; the final technical report documents test evidence and limitations.
