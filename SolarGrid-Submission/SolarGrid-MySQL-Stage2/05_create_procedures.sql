-- SOLARGRID / IT212 GROUP 1 / STAGE 2
-- Run with Workbench's File > Run SQL Script so DELIMITER is honored.
USE solargrid;
DROP PROCEDURE IF EXISTS sp_complete_installation;
DROP PROCEDURE IF EXISTS sp_record_payment;
DELIMITER $$

CREATE PROCEDURE sp_complete_installation(
    IN p_installation_id INT UNSIGNED,
    IN p_equipment JSON,
    IN p_completed_at DATETIME,
    IN p_completion_notes TEXT
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_site_id INT UNSIGNED;
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_unit_id INT UNSIGNED;
    DECLARE v_start DATE;
    DECLARE v_end DATE;
    DECLARE v_done BOOLEAN DEFAULT FALSE;
    DECLARE cur CURSOR FOR
        SELECT CAST(j.equipment_unit_id AS UNSIGNED), CAST(j.warranty_start AS DATE), CAST(j.warranty_end AS DATE)
        FROM JSON_TABLE(p_equipment, '$[*]' COLUMNS (
            equipment_unit_id INT PATH '$.equipment_unit_id',
            warranty_start DATE PATH '$.warranty_start',
            warranty_end DATE PATH '$.warranty_end'
        )) AS j ORDER BY j.equipment_unit_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    DECLARE EXIT HANDLER FOR SQLWARNING BEGIN ROLLBACK; RESIGNAL; END;

    IF p_installation_id IS NULL OR p_completed_at IS NULL OR p_completed_at > NOW() THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid installation completion input'; END IF;
    IF JSON_TYPE(p_equipment) <> 'ARRAY' OR JSON_LENGTH(p_equipment) = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='At least one equipment unit is required'; END IF;
    IF @@autocommit <> 1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Commit or roll back the current transaction first'; END IF;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION;
    SELECT status, site_id INTO v_status, v_site_id FROM installations WHERE installation_id=p_installation_id FOR UPDATE;
    IF v_status IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Installation not found'; END IF;
    IF v_status NOT IN ('SCHEDULED','IN_PROGRESS') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Installation is not open for completion'; END IF;
    SELECT COUNT(*) INTO v_count FROM installation_technicians it JOIN technicians t ON t.technician_id=it.technician_id WHERE it.installation_id=p_installation_id AND it.assignment_role='LEAD' AND t.is_active=1;
    IF v_count=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='An active lead technician is required'; END IF;
    SELECT COUNT(*) INTO v_count FROM installation_equipment WHERE installation_id=p_installation_id AND removed_at IS NULL;
    IF v_count>0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Installation already has active equipment'; END IF;
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_unit_id, v_start, v_end;
        IF v_done THEN LEAVE read_loop; END IF;
        IF v_start IS NULL OR v_end IS NULL OR v_end < v_start OR v_start > DATE(p_completed_at) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid warranty dates'; END IF;
        SELECT status INTO v_status FROM equipment_units WHERE equipment_unit_id=v_unit_id FOR UPDATE;
        IF v_status IS NULL OR v_status <> 'AVAILABLE' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Every selected equipment unit must be AVAILABLE'; END IF;
        IF EXISTS (SELECT 1 FROM installation_equipment WHERE equipment_unit_id=v_unit_id AND removed_at IS NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Equipment unit is already installed'; END IF;
        INSERT INTO installation_equipment(installation_id,equipment_unit_id,installed_at,warranty_start,warranty_end) VALUES(p_installation_id,v_unit_id,p_completed_at,v_start,v_end);
        UPDATE equipment_units SET status='INSTALLED' WHERE equipment_unit_id=v_unit_id;
    END LOOP;
    CLOSE cur;
    UPDATE installations SET status='COMPLETED', completed_at=p_completed_at, completion_notes=p_completion_notes WHERE installation_id=p_installation_id;
    COMMIT;
    SELECT 'COMPLETED' AS result, p_installation_id AS installation_id;
END$$

CREATE PROCEDURE sp_record_payment(
    IN p_invoice_id INT UNSIGNED,
    IN p_receipt_number VARCHAR(40),
    IN p_paid_at DATETIME,
    IN p_amount DECIMAL(12,2),
    IN p_payment_method VARCHAR(20),
    IN p_external_reference VARCHAR(100),
    IN p_recorded_by INT UNSIGNED
)
BEGIN
    DECLARE v_status VARCHAR(15); DECLARE v_issue DATE; DECLARE v_total DECIMAL(20,2); DECLARE v_paid DECIMAL(20,2); DECLARE v_old_invoice INT UNSIGNED; DECLARE v_old_amount DECIMAL(12,2); DECLARE v_old_at DATETIME; DECLARE v_old_method VARCHAR(20); DECLARE v_old_ref VARCHAR(100); DECLARE v_role VARCHAR(20); DECLARE v_active BOOLEAN;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    DECLARE EXIT HANDLER FOR SQLWARNING BEGIN ROLLBACK; RESIGNAL; END;
    IF p_invoice_id IS NULL OR p_recorded_by IS NULL OR p_amount IS NULL OR p_amount <= 0 OR p_receipt_number IS NULL OR p_paid_at IS NULL OR p_paid_at > NOW() OR p_payment_method NOT IN ('CASH','BANK_TRANSFER','MOBILE_MONEY','CARD') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid payment input'; END IF;
    IF @@autocommit <> 1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Commit or roll back the current transaction first'; END IF;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED; START TRANSACTION;
    SELECT status, issue_date INTO v_status,v_issue FROM invoices WHERE invoice_id=p_invoice_id FOR UPDATE;
    IF v_status IS NULL OR v_status <> 'ISSUED' OR p_paid_at < v_issue THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invoice is not eligible for payment'; END IF;
    SELECT role,is_active INTO v_role,v_active FROM app_users WHERE user_id=p_recorded_by FOR UPDATE;
    IF v_role NOT IN ('ADMIN','ACCOUNTS') OR v_active<>1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Only an active accounts user may record payments'; END IF;
    SELECT COALESCE(SUM(quantity*unit_price),0) INTO v_total FROM invoice_items WHERE invoice_id=p_invoice_id;
    SELECT COALESCE(SUM(amount),0) INTO v_paid FROM payments WHERE invoice_id=p_invoice_id;
    IF EXISTS (SELECT 1 FROM payments WHERE receipt_number=p_receipt_number) THEN
        SELECT invoice_id,amount,paid_at,payment_method,external_reference INTO v_old_invoice,v_old_amount,v_old_at,v_old_method,v_old_ref FROM payments WHERE receipt_number=p_receipt_number FOR UPDATE;
        IF v_old_invoice=p_invoice_id AND v_old_amount=p_amount AND v_old_at=p_paid_at AND v_old_method=p_payment_method AND (v_old_ref <=> p_external_reference) THEN COMMIT; SELECT 'ALREADY_RECORDED' AS result,p_receipt_number AS receipt_number; ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Receipt number already belongs to different payment'; END IF;
    ELSE
        IF v_paid+p_amount > v_total THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Payment would overpay the invoice'; END IF;
        INSERT INTO payments(invoice_id,receipt_number,paid_at,amount,payment_method,external_reference,recorded_by) VALUES(p_invoice_id,p_receipt_number,p_paid_at,p_amount,p_payment_method,p_external_reference,p_recorded_by);
        COMMIT; SELECT 'RECORDED' AS result,p_receipt_number AS receipt_number;
    END IF;
END$$
DELIMITER ;
