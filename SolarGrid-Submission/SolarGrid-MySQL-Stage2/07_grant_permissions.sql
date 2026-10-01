-- Run as root after creating both accounts. No passwords are included.
-- Permissions for the current application milestone.
GRANT SELECT ON solargrid.customers TO 'solargrid_app'@'localhost', 'solargrid_report'@'localhost';
GRANT SELECT ON solargrid.sites TO 'solargrid_app'@'localhost', 'solargrid_report'@'localhost';
GRANT SELECT ON solargrid.equipment_types TO 'solargrid_app'@'localhost', 'solargrid_report'@'localhost';
GRANT SELECT ON solargrid.equipment_units TO 'solargrid_app'@'localhost', 'solargrid_report'@'localhost';
GRANT SELECT ON solargrid.installations TO 'solargrid_app'@'localhost', 'solargrid_report'@'localhost';
GRANT SELECT ON solargrid.installation_equipment TO 'solargrid_app'@'localhost', 'solargrid_report'@'localhost';
GRANT SELECT ON solargrid.invoices TO 'solargrid_app'@'localhost', 'solargrid_report'@'localhost';
GRANT SELECT ON solargrid.invoice_items TO 'solargrid_app'@'localhost', 'solargrid_report'@'localhost';
GRANT SELECT ON solargrid.payments TO 'solargrid_app'@'localhost', 'solargrid_report'@'localhost';
GRANT SELECT ON solargrid.v_invoice_balances TO 'solargrid_app'@'localhost', 'solargrid_report'@'localhost';
GRANT SELECT ON solargrid.v_active_equipment_warranties TO 'solargrid_app'@'localhost', 'solargrid_report'@'localhost';
GRANT SELECT ON solargrid.app_users TO 'solargrid_app'@'localhost';
GRANT INSERT, UPDATE, DELETE ON solargrid.customers TO 'solargrid_app'@'localhost';
GRANT EXECUTE ON PROCEDURE solargrid.sp_complete_installation TO 'solargrid_app'@'localhost';
GRANT EXECUTE ON PROCEDURE solargrid.sp_record_payment TO 'solargrid_app'@'localhost';
SHOW GRANTS FOR 'solargrid_app'@'localhost';
SHOW GRANTS FOR 'solargrid_report'@'localhost';
