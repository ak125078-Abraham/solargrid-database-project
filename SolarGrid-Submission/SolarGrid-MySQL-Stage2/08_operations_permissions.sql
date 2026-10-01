-- Run once using root after 07_grant_permissions.sql.
-- Additional rights for the operational application screens.
GRANT INSERT ON solargrid.sites TO 'solargrid_app'@'localhost';
GRANT INSERT ON solargrid.equipment_types TO 'solargrid_app'@'localhost';
GRANT INSERT ON solargrid.equipment_units TO 'solargrid_app'@'localhost';
GRANT INSERT ON solargrid.installations TO 'solargrid_app'@'localhost';
GRANT SELECT, INSERT ON solargrid.technicians TO 'solargrid_app'@'localhost';
GRANT SELECT, INSERT ON solargrid.installation_technicians TO 'solargrid_app'@'localhost';
GRANT SELECT, INSERT ON solargrid.service_requests TO 'solargrid_app'@'localhost';
GRANT UPDATE (status, resolved_at) ON solargrid.service_requests TO 'solargrid_app'@'localhost';
GRANT SELECT, INSERT ON solargrid.service_request_technicians TO 'solargrid_app'@'localhost';
GRANT SELECT, INSERT ON solargrid.maintenance_records TO 'solargrid_app'@'localhost';
GRANT INSERT ON solargrid.invoices TO 'solargrid_app'@'localhost';
GRANT INSERT ON solargrid.invoice_items TO 'solargrid_app'@'localhost';
SHOW GRANTS FOR 'solargrid_app'@'localhost';
