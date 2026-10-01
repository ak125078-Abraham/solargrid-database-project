USE solargrid;
SELECT COUNT(*) AS invoice_rows FROM v_invoice_balances;
SELECT COUNT(*) AS active_warranty_rows FROM v_active_equipment_warranties;
SELECT invoice_number, customer_name, invoice_total, paid_total, outstanding_balance, payment_status
FROM v_invoice_balances ORDER BY invoice_id;
SHOW PROCEDURE STATUS WHERE Db='solargrid' AND Name IN ('sp_complete_installation','sp_record_payment');
