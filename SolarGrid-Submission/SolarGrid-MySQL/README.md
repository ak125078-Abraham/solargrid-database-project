# SolarGrid database scripts

Run 01_create_tables.sql only on a fresh database. Run 02_insert_sample_data_editor.sql, review all output, and COMMIT in the same session only if it succeeded; otherwise ROLLBACK. The seed has fictional classroom records and nonfunctional password placeholders. Run 03_check_data_and_reports.sql for read-only baseline counts, joins, grouping and subqueries.

Next install the views and procedures in SolarGrid-MySQL-Stage2 and configure accounts/grants using the submission root README. Current demonstration counts differ from the initial seed counts. Never reseed the live database.
