-- SOLARGRID / IT212 GROUP 1
-- 03: Read-only checks and first management reports.
USE solargrid;
SET @demo_date = DATE('2026-09-12');

-- A. Exact record counts. Compare with README.md.

SELECT 'customers' AS table_name, COUNT(*) AS actual_rows, 12 AS expected_rows FROM customers
UNION ALL
SELECT 'sites' AS table_name, COUNT(*) AS actual_rows, 16 AS expected_rows FROM sites
UNION ALL
SELECT 'equipment_types' AS table_name, COUNT(*) AS actual_rows, 10 AS expected_rows FROM equipment_types
UNION ALL
SELECT 'equipment_units' AS table_name, COUNT(*) AS actual_rows, 60 AS expected_rows FROM equipment_units
UNION ALL
SELECT 'installations' AS table_name, COUNT(*) AS actual_rows, 16 AS expected_rows FROM installations
UNION ALL
SELECT 'installation_equipment' AS table_name, COUNT(*) AS actual_rows, 37 AS expected_rows FROM installation_equipment
UNION ALL
SELECT 'technicians' AS table_name, COUNT(*) AS actual_rows, 10 AS expected_rows FROM technicians
UNION ALL
SELECT 'installation_technicians' AS table_name, COUNT(*) AS actual_rows, 32 AS expected_rows FROM installation_technicians
UNION ALL
SELECT 'service_requests' AS table_name, COUNT(*) AS actual_rows, 12 AS expected_rows FROM service_requests
UNION ALL
SELECT 'service_request_technicians' AS table_name, COUNT(*) AS actual_rows, 14 AS expected_rows FROM service_request_technicians
UNION ALL
SELECT 'maintenance_records' AS table_name, COUNT(*) AS actual_rows, 12 AS expected_rows FROM maintenance_records
UNION ALL
SELECT 'app_users' AS table_name, COUNT(*) AS actual_rows, 3 AS expected_rows FROM app_users
UNION ALL
SELECT 'invoices' AS table_name, COUNT(*) AS actual_rows, 16 AS expected_rows FROM invoices
UNION ALL
SELECT 'invoice_items' AS table_name, COUNT(*) AS actual_rows, 64 AS expected_rows FROM invoice_items
UNION ALL
SELECT 'payments' AS table_name, COUNT(*) AS actual_rows, 18 AS expected_rows FROM payments;

-- B. The generated column should enforce one current placement per equipment unit.
SHOW CREATE TABLE installation_equipment;

-- C. Active equipment whose warranty expires in the next 30 days.
-- Six rows: three units at installation 2 and three at installation 3.
SELECT c.customer_name, s.site_name, eu.serial_number, ie.warranty_end
FROM installation_equipment AS ie
JOIN equipment_units AS eu ON eu.equipment_unit_id = ie.equipment_unit_id
JOIN installations AS i ON i.installation_id = ie.installation_id
JOIN sites AS s ON s.site_id = i.site_id
JOIN customers AS c ON c.customer_id = s.customer_id
WHERE ie.removed_at IS NULL
  AND ie.warranty_end BETWEEN @demo_date AND DATE_ADD(@demo_date, INTERVAL 30 DAY)
ORDER BY ie.warranty_end, eu.serial_number;

-- D. Four unresolved service requests, including two with no technician assigned.
SELECT sr.service_request_id, c.customer_name, sr.priority, sr.status,
       COUNT(srt.technician_id) AS assigned_technicians
FROM service_requests AS sr
JOIN installations AS i ON i.installation_id = sr.installation_id
JOIN sites AS s ON s.site_id = i.site_id
JOIN customers AS c ON c.customer_id = s.customer_id
LEFT JOIN service_request_technicians AS srt
  ON srt.service_request_id = sr.service_request_id
WHERE sr.status NOT IN ('RESOLVED','CANCELLED')
GROUP BY sr.service_request_id, c.customer_name, sr.priority, sr.status
ORDER BY sr.service_request_id;

-- E. Aggregate invoice items and payments SEPARATELY to avoid multiplying totals.
-- Twelve issued invoices. Total invoiced = K422,400; received = K255,200;
-- outstanding = K167,200. Six paid, four partial, two unpaid.
SELECT inv.invoice_number, c.customer_name,
       totals.invoice_total, COALESCE(receipts.paid_total, 0) AS paid_total,
       totals.invoice_total - COALESCE(receipts.paid_total, 0) AS outstanding
FROM invoices AS inv
JOIN customers AS c ON c.customer_id = inv.customer_id
JOIN (
    SELECT invoice_id, SUM(ROUND(quantity * unit_price, 2)) AS invoice_total
    FROM invoice_items GROUP BY invoice_id
) AS totals ON totals.invoice_id = inv.invoice_id
LEFT JOIN (
    SELECT invoice_id, SUM(amount) AS paid_total
    FROM payments GROUP BY invoice_id
) AS receipts ON receipts.invoice_id = inv.invoice_id
WHERE inv.status = 'ISSUED'
ORDER BY inv.invoice_id;

-- F. Cash received by month. This is a receipts report, not accrual revenue.
SELECT DATE_FORMAT(paid_at, '%Y-%m') AS receipt_month,
       COUNT(*) AS number_of_payments, SUM(amount) AS cash_received_zmw
FROM payments
GROUP BY DATE_FORMAT(paid_at, '%Y-%m')
ORDER BY receipt_month;

-- G. Equipment available for later installation transaction demonstrations.
SELECT et.sku, et.category, COUNT(*) AS available_units
FROM equipment_types AS et
JOIN equipment_units AS eu ON eu.equipment_type_id = et.equipment_type_id
WHERE eu.status = 'AVAILABLE'
GROUP BY et.equipment_type_id, et.sku, et.category
ORDER BY et.sku;

-- H. Integrity audits: each query should return ZERO rows.
-- Invoice customer agrees with the installation's site customer.
SELECT inv.invoice_id FROM invoices AS inv
JOIN installations AS i ON i.installation_id = inv.installation_id
JOIN sites AS s ON s.site_id = i.site_id
WHERE inv.customer_id <> s.customer_id;

-- Installed status and active placement agree in the sample dataset.
SELECT eu.equipment_unit_id FROM equipment_units AS eu
LEFT JOIN installation_equipment AS ie
  ON ie.equipment_unit_id = eu.equipment_unit_id AND ie.removed_at IS NULL
WHERE (eu.status = 'INSTALLED' AND ie.installation_equipment_id IS NULL)
   OR (eu.status <> 'INSTALLED' AND ie.installation_equipment_id IS NOT NULL);

-- Every completed installation has equipment and a technician.
SELECT i.installation_id FROM installations AS i
WHERE i.status = 'COMPLETED'
  AND (NOT EXISTS (SELECT 1 FROM installation_equipment AS ie
                   WHERE ie.installation_id = i.installation_id)
       OR NOT EXISTS (SELECT 1 FROM installation_technicians AS it
                       WHERE it.installation_id = i.installation_id));
