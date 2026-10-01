# Views, procedures and permissions

Run 04_create_views.sql for the two reporting views. Run 05_create_procedures.sql through Workbench Run SQL Script for delimiter support; it creates sp_complete_installation and sp_record_payment. These scripts replace existing views/procedures and should be used for deliberate setup or upgrades.

06_verify_stage2.sql is read-only and inspects view results and procedure availability. Create the database accounts first, then run 07_grant_permissions.sql and 08_operations_permissions.sql as administrator. Passwords are chosen privately and are not included. Read the root submission README for full setup order.
