# SolarGrid relational schema

## Relational mapping

PK denotes primary key; FK denotes foreign key; UQ denotes unique; ? denotes nullable. Names below match the implemented tables. ID columns are unsigned integers, with auto-increment for single-column primary keys.

| Relation | Keys and main attributes |
|---|---|
| customers | PK customer_id; customer_name, customer_type, phone, email?, billing_address?, is_active, created_at |
| sites | PK site_id; FK customer_id to customers; site_name, address, town, site_notes? |
| equipment_types | PK equipment_type_id; UQ sku; category, manufacturer, model_name, description?, default_warranty_months, list_price |
| equipment_units | PK equipment_unit_id; FK equipment_type_id; UQ serial_number; received_date, status |
| installations | PK installation_id; FK site_id; scheduled_at, completed_at?, status, work_description, completion_notes? |
| installation_equipment | PK installation_equipment_id; FK installation_id, equipment_unit_id; installed_at, removed_at?, warranty_start, warranty_end, placement_notes?; generated UQ active_equipment_unit_id |
| technicians | PK technician_id; full_name, phone, email?, specialization, is_active |
| installation_technicians | PK and FKs (installation_id, technician_id); assigned_at, assignment_role |
| service_requests | PK service_request_id; FK installation_id; reported_at, problem_description, priority, status, resolved_at? |
| service_request_technicians | PK and FKs (service_request_id, technician_id); assigned_at |
| maintenance_records | PK maintenance_record_id; composite FK (service_request_id, technician_id) to service_request_technicians; performed_at, work_done, maintenance_cost, next_service_date? |
| app_users | PK user_id; UQ username; password_hash, full_name, role, is_active |
| invoices | PK invoice_id; UQ invoice_number; FK customer_id, installation_id?; issue_date, due_date, status |
| invoice_items | PK invoice_item_id; FK invoice_id; UQ (invoice_id, line_number); item_type, description, quantity, unit_price |
| payments | PK payment_id; FK invoice_id, recorded_by to app_users; UQ receipt_number; paid_at, amount, payment_method, external_reference? |

All foreign keys use restrictive update and delete actions. For example, a customer with an existing site cannot be deleted. InnoDB checks foreign keys and requires supporting indexes (Oracle, n.d.-a).

<!-- page break -->

For complete column types and executable constraints, see SolarGrid-MySQL/01_create_tables.sql.
