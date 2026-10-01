# SolarGrid Energy Service Management System

IT212 Database Management Systems, Group 1, Cavendish University Zambia.
Lecturer: Mrs Memory Mumbi Lumbwe. Deadline: 12 October 2026.

| Member | Student number |
|---|---|
| Christopher Saputu | 127284 |
| Sailus Chileshe | 127-503 |
| Kamwi Abraham | 125078 |
| Nathan Kamalondo | 104-910 |
| Alpha Musausheni | 125869 |

## Files and status

The technical report includes the ERD, complete relational schema, normalization, Harvard references and evidence. SolarGrid-Normalization.md provides additional worked normalization detail. SQL scripts implement 15 tables, two views and two procedures. The Flask source is in SolarGrid-App. The dated backup is supplied separately for controlled submission because it includes application password hashes.

This folder is prepared for repository upload; it has not been published to GitHub. Do not upload the old starter ZIP files or a Python virtual environment. Recordings must be added or linked by the group after reviewing them; they are not bundled here.

## Fresh installation on a separate machine

Use Python 3 and MySQL 8.0.22 or later (tested project server: MySQL 26.7). Install MySQL Connector and Flask through the included requirements file. The 8.0.22 minimum reflects the app's FOR SHARE privilege requirements.

1. In Workbench as an administrator, run SolarGrid-MySQL/01_create_tables.sql on a new server where solargrid does not exist. Never rerun schema creation or seed scripts against the working demonstration database.
2. Run SolarGrid-MySQL/02_insert_sample_data_editor.sql. Inspect all output and counts; if every statement succeeded, execute COMMIT in that same connection. If any statement failed, execute ROLLBACK and investigate before continuing. Baseline counts apply to seed data, not the later demonstration snapshot.
3. Run SolarGrid-MySQL-Stage2/04_create_views.sql and 05_create_procedures.sql. Use Workbench's Run SQL Script facility for DELIMITER support.
4. Create solargrid_app@localhost and solargrid_report@localhost using Workbench Users and Privileges, each with its own privately chosen password and no broad administrator privileges. Run 07_grant_permissions.sql and 08_operations_permissions.sql as root.
5. On the fresh database only, run SolarGrid-App/START.bat as root once to provision the named application administrator when prompted. Choose a new username and password; seed placeholders are not login credentials. Stop the app after setup.
6. Restart START.bat and explicitly enter solargrid_app as the MySQL username, with its database password. Keep the console open. Visit http://127.0.0.1:5000 and log in using the separate application credentials created in step 5.

START.bat installs requirements and needs package-download access on first setup. Application login and database login are distinct. The app runs locally, without debug mode; production deployment needs additional hardening.

## Existing classroom installation

Do not recreate or reseed the database. Launch SolarGrid-App/START.bat, connect as solargrid_app and log in as your existing application user. No passwords are included in this repository.

## SQL demonstrations

03_check_data_and_reports.sql contains filters, sorting, aggregates, joins and subqueries. 06_verify_stage2.sql is read-only. Use an isolated test database for the separate transaction rollback demonstration. The report explains the transaction and index results. Evidence/DEMONSTRATION-RESULTS.md records the newer confirmed results.

## Backup and restoration

The separate recovery package contains the September 30 snapshot, its SHA-256 manifest, restore helper and read-only verification queries. See its README. A snapshot can lose later committed changes; no point-in-time recovery was demonstrated. Database accounts and grants must be recreated on a new server. Restored routines use root@localhost as definer.

## Limitations

Technician creation, concurrent allocation/payment races, malformed direct procedure input and crash recovery remain unverified live. Monthly receipts measure cash payments, not accrual revenue. The app has classroom security controls but is not a production deployment. Every group member must understand and demonstrate the whole solution.

## Presentation and SQL practice

SolarGrid-Presentation.pptx contains 25 classroom slides. Full table specifications remain in the report, relational schema document and executable DDL. The report provides the full Harvard references. 09_demonstration_queries.sql supplies read-only history, join, aggregation, subquery and index examples for practice. The copied tests in tests/ passed using the app environment; they mock database access.
