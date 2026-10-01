-- Read-only examples. Run against the intended classroom database.
USE solargrid;

-- INNER JOIN: installation history for a searched customer.
SELECT c.customer_name, s.site_name, i.installation_id, i.status, i.scheduled_at
FROM customers c
INNER JOIN sites s ON s.customer_id=c.customer_id
INNER JOIN installations i ON i.site_id=s.site_id
WHERE c.customer_name LIKE '%Sunrise%'
ORDER BY i.scheduled_at DESC;

-- LEFT JOIN: include technicians with no installation assignments.
SELECT t.technician_id, t.full_name, COUNT(it.installation_id) AS assignments
FROM technicians t
LEFT JOIN installation_technicians it ON it.technician_id=t.technician_id
GROUP BY t.technician_id,t.full_name
ORDER BY assignments DESC,t.full_name;

-- GROUP BY: cash receipts, not accrual revenue.
SELECT DATE_FORMAT(paid_at,'%Y-%m') AS payment_month, SUM(amount) AS cash_received_zmw
FROM payments
GROUP BY DATE_FORMAT(paid_at,'%Y-%m')
ORDER BY payment_month;

-- Correlated subquery: customers for whom no invoice exists.
SELECT c.customer_id,c.customer_name
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM invoices i WHERE i.customer_id=c.customer_id)
ORDER BY c.customer_name;

-- Reporting view for the demonstrated school.
SELECT invoice_number,invoice_total,paid_total,outstanding_balance,payment_status
FROM v_invoice_balances WHERE customer_id=14;

-- Compare plans without deleting or changing the index.
EXPLAIN SELECT installation_id,site_id,scheduled_at,status
FROM installations WHERE status='SCHEDULED' ORDER BY scheduled_at;
EXPLAIN SELECT installation_id,site_id,scheduled_at,status
FROM installations IGNORE INDEX(ix_installations_schedule)
WHERE status='SCHEDULED' ORDER BY scheduled_at;
