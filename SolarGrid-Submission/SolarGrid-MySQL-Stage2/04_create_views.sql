-- SOLARGRID / IT212 GROUP 1 / STAGE 2
-- Run this file in Workbench after committing the sample-data load.
-- Creates two views. Does not change existing business records.
-- These views use caller privileges and expose no passwords.
USE solargrid;

CREATE OR REPLACE ALGORITHM = UNDEFINED SQL SECURITY INVOKER
VIEW v_invoice_balances AS
SELECT inv.invoice_id, inv.invoice_number, inv.customer_id,
       c.customer_name, inv.installation_id, inv.issue_date, inv.due_date,
       inv.status AS invoice_status,
       COALESCE(item_totals.invoice_total, 0.00) AS invoice_total,
       COALESCE(payment_totals.paid_total, 0.00) AS paid_total,
       COALESCE(item_totals.invoice_total, 0.00)
           - COALESCE(payment_totals.paid_total, 0.00) AS outstanding_balance,
       CASE
           WHEN inv.status = 'DRAFT' THEN 'DRAFT'
           WHEN inv.status = 'CANCELLED' THEN 'CANCELLED'
           WHEN COALESCE(item_totals.invoice_total, 0) =
                COALESCE(payment_totals.paid_total, 0) THEN 'PAID'
           WHEN COALESCE(payment_totals.paid_total, 0) = 0 THEN 'UNPAID'
           ELSE 'PARTIALLY_PAID'
       END AS payment_status
FROM invoices AS inv
JOIN customers AS c ON c.customer_id = inv.customer_id
LEFT JOIN (
    SELECT invoice_id, SUM(ROUND(quantity * unit_price, 2)) AS invoice_total
    FROM invoice_items GROUP BY invoice_id
) AS item_totals ON item_totals.invoice_id = inv.invoice_id
LEFT JOIN (
    SELECT invoice_id, SUM(amount) AS paid_total
    FROM payments GROUP BY invoice_id
) AS payment_totals ON payment_totals.invoice_id = inv.invoice_id;

CREATE OR REPLACE ALGORITHM = UNDEFINED SQL SECURITY INVOKER
VIEW v_active_equipment_warranties AS
SELECT ie.installation_equipment_id, ie.installation_id,
       c.customer_id, c.customer_name, s.site_id, s.site_name, s.town,
       eu.equipment_unit_id, eu.serial_number, et.sku,
       et.category, et.manufacturer, et.model_name,
       ie.installed_at, ie.warranty_start, ie.warranty_end
FROM installation_equipment AS ie
JOIN installations AS i ON i.installation_id = ie.installation_id
JOIN sites AS s ON s.site_id = i.site_id
JOIN customers AS c ON c.customer_id = s.customer_id
JOIN equipment_units AS eu ON eu.equipment_unit_id = ie.equipment_unit_id
JOIN equipment_types AS et ON et.equipment_type_id = eu.equipment_type_id
WHERE ie.removed_at IS NULL;

-- Expected BEFORE business demonstration calls: 16 invoices, 36 active placements.
SELECT COUNT(*) AS invoices_in_view FROM v_invoice_balances;
SELECT COUNT(*) AS active_equipment_in_view FROM v_active_equipment_warranties;

-- Exclude draft/cancelled invoices when reporting money owed.
SELECT SUM(invoice_total) AS issued_total_zmw,
       SUM(paid_total) AS received_zmw,
       SUM(outstanding_balance) AS outstanding_zmw
FROM v_invoice_balances WHERE invoice_status = 'ISSUED';
-- Expected: 422400.00, 255200.00, 167200.00.
