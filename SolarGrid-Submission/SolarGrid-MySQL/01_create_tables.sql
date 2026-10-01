-- SOLARGRID / IT212 GROUP 1
-- 01: Create the schema. Run once on a NEW database.
-- Target: MySQL 8.0.16 or later with enforced CHECK constraints.
-- No existing data is deleted. Stop execution on the first SQL error.
-- If solargrid already exists, use a fresh name consistently in all files.
-- This stage implements tables and row-level integrity, not workflow procedures.

SET NAMES utf8mb4;
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,ONLY_FULL_GROUP_BY,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE DATABASE solargrid CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE solargrid;

-- customers: 8 defined fields.
CREATE TABLE customers (
    customer_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    customer_name VARCHAR(150) NOT NULL,
    customer_type VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(254) NULL,
    billing_address VARCHAR(255) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id),
    CONSTRAINT ck_customers_1 CHECK (customer_type IN ('HOUSEHOLD','SCHOOL','FARM','BUSINESS')),
    CONSTRAINT ck_customers_2 CHECK (is_active IN (0,1)),
    CONSTRAINT ck_customers_3 CHECK (CHAR_LENGTH(TRIM(customer_name)) > 0)
) ENGINE=InnoDB;

-- sites: 6 defined fields.
CREATE TABLE sites (
    site_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    customer_id INT UNSIGNED NOT NULL,
    site_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    town VARCHAR(100) NOT NULL,
    site_notes TEXT NULL,
    PRIMARY KEY (site_id),
    CONSTRAINT fk_sites_1 FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;

-- equipment_types: 8 defined fields.
CREATE TABLE equipment_types (
    equipment_type_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    sku VARCHAR(50) NOT NULL,
    category VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    manufacturer VARCHAR(100) NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    default_warranty_months SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    list_price DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (equipment_type_id),
    CONSTRAINT uq_equipment_types_sku UNIQUE (sku),
    CONSTRAINT ck_equipment_types_1 CHECK (category IN ('PANEL','BATTERY','INVERTER','OTHER')),
    CONSTRAINT ck_equipment_types_2 CHECK (list_price >= 0)
) ENGINE=InnoDB;

-- equipment_units: 5 defined fields.
CREATE TABLE equipment_units (
    equipment_unit_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    equipment_type_id INT UNSIGNED NOT NULL,
    serial_number VARCHAR(100) NOT NULL,
    received_date DATE NOT NULL,
    status VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    PRIMARY KEY (equipment_unit_id),
    CONSTRAINT uq_equipment_units_serial UNIQUE (serial_number),
    CONSTRAINT fk_equipment_units_1 FOREIGN KEY (equipment_type_id)
        REFERENCES equipment_types (equipment_type_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT ck_equipment_units_1 CHECK (status IN ('AVAILABLE','INSTALLED','MAINTENANCE','RETIRED'))
) ENGINE=InnoDB;

-- installations: 7 defined fields.
CREATE TABLE installations (
    installation_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    site_id INT UNSIGNED NOT NULL,
    scheduled_at DATETIME NOT NULL,
    completed_at DATETIME NULL,
    status VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    work_description TEXT NOT NULL,
    completion_notes TEXT NULL,
    PRIMARY KEY (installation_id),
    CONSTRAINT fk_installations_1 FOREIGN KEY (site_id)
        REFERENCES sites (site_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT ck_installations_1 CHECK (status IN ('SCHEDULED','IN_PROGRESS','COMPLETED','CANCELLED')),
    CONSTRAINT ck_installations_2 CHECK ((status = 'COMPLETED' AND completed_at IS NOT NULL) OR (status <> 'COMPLETED' AND completed_at IS NULL)),
    INDEX ix_installations_schedule (status, scheduled_at)
) ENGINE=InnoDB;

-- installation_equipment: 8 defined fields plus a generated active-placement key.
CREATE TABLE installation_equipment (
    installation_equipment_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    installation_id INT UNSIGNED NOT NULL,
    equipment_unit_id INT UNSIGNED NOT NULL,
    installed_at DATETIME NOT NULL,
    removed_at DATETIME NULL,
    warranty_start DATE NOT NULL,
    warranty_end DATE NOT NULL,
    placement_notes TEXT NULL,
    active_equipment_unit_id INT UNSIGNED GENERATED ALWAYS AS
        (CASE WHEN removed_at IS NULL THEN equipment_unit_id ELSE NULL END) STORED,
    PRIMARY KEY (installation_equipment_id),
    CONSTRAINT uq_installation_equipment_active_unit UNIQUE (active_equipment_unit_id),
    CONSTRAINT fk_installation_equipment_1 FOREIGN KEY (installation_id)
        REFERENCES installations (installation_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_installation_equipment_2 FOREIGN KEY (equipment_unit_id)
        REFERENCES equipment_units (equipment_unit_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT ck_installation_equipment_1 CHECK (removed_at IS NULL OR removed_at >= installed_at),
    CONSTRAINT ck_installation_equipment_2 CHECK (warranty_end >= warranty_start),
    INDEX ix_installation_equipment_warranty (removed_at, warranty_end)
) ENGINE=InnoDB;

-- technicians: 6 defined fields.
CREATE TABLE technicians (
    technician_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(254) NULL,
    specialization VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (technician_id),
    CONSTRAINT ck_technicians_1 CHECK (is_active IN (0,1))
) ENGINE=InnoDB;

-- installation_technicians: 4 defined fields.
CREATE TABLE installation_technicians (
    installation_id INT UNSIGNED NOT NULL,
    technician_id INT UNSIGNED NOT NULL,
    assigned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assignment_role VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    PRIMARY KEY (installation_id, technician_id),
    CONSTRAINT fk_installation_technicians_1 FOREIGN KEY (installation_id)
        REFERENCES installations (installation_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_installation_technicians_2 FOREIGN KEY (technician_id)
        REFERENCES technicians (technician_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT ck_installation_technicians_1 CHECK (assignment_role IN ('LEAD','ASSISTANT')),
    INDEX ix_installation_technicians_technician (technician_id, installation_id)
) ENGINE=InnoDB;

-- service_requests: 7 defined fields.
CREATE TABLE service_requests (
    service_request_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    installation_id INT UNSIGNED NOT NULL,
    reported_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    problem_description TEXT NOT NULL,
    priority VARCHAR(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    status VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    resolved_at DATETIME NULL,
    PRIMARY KEY (service_request_id),
    CONSTRAINT fk_service_requests_1 FOREIGN KEY (installation_id)
        REFERENCES installations (installation_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT ck_service_requests_1 CHECK (priority IN ('LOW','MEDIUM','HIGH','URGENT')),
    CONSTRAINT ck_service_requests_2 CHECK (status IN ('OPEN','ASSIGNED','IN_PROGRESS','RESOLVED','CANCELLED')),
    CONSTRAINT ck_service_requests_3 CHECK ((status = 'RESOLVED' AND resolved_at IS NOT NULL) OR (status <> 'RESOLVED' AND resolved_at IS NULL)),
    CONSTRAINT ck_service_requests_4 CHECK (resolved_at IS NULL OR resolved_at >= reported_at),
    INDEX ix_service_requests_queue (status, reported_at)
) ENGINE=InnoDB;

-- service_request_technicians: 3 defined fields.
CREATE TABLE service_request_technicians (
    service_request_id INT UNSIGNED NOT NULL,
    technician_id INT UNSIGNED NOT NULL,
    assigned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (service_request_id, technician_id),
    CONSTRAINT fk_service_request_technicians_1 FOREIGN KEY (service_request_id)
        REFERENCES service_requests (service_request_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_service_request_technicians_2 FOREIGN KEY (technician_id)
        REFERENCES technicians (technician_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    INDEX ix_service_request_technicians_technician (technician_id, service_request_id)
) ENGINE=InnoDB;

-- maintenance_records: 7 defined fields.
CREATE TABLE maintenance_records (
    maintenance_record_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    service_request_id INT UNSIGNED NOT NULL,
    technician_id INT UNSIGNED NOT NULL,
    performed_at DATETIME NOT NULL,
    work_done TEXT NOT NULL,
    maintenance_cost DECIMAL(12,2) NOT NULL,
    next_service_date DATE NULL,
    PRIMARY KEY (maintenance_record_id),
    CONSTRAINT fk_maintenance_records_1 FOREIGN KEY (service_request_id, technician_id)
        REFERENCES service_request_technicians (service_request_id, technician_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT ck_maintenance_records_1 CHECK (maintenance_cost >= 0),
    CONSTRAINT ck_maintenance_records_2 CHECK (next_service_date IS NULL OR next_service_date >= DATE(performed_at))
) ENGINE=InnoDB;

-- app_users: 6 defined fields.
CREATE TABLE app_users (
    user_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    username VARCHAR(80) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    role VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (user_id),
    CONSTRAINT uq_app_users_username UNIQUE (username),
    CONSTRAINT ck_app_users_1 CHECK (role IN ('ADMIN','OPERATIONS','ACCOUNTS')),
    CONSTRAINT ck_app_users_2 CHECK (is_active IN (0,1))
) ENGINE=InnoDB;

-- invoices: 7 defined fields.
CREATE TABLE invoices (
    invoice_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    invoice_number VARCHAR(30) NOT NULL,
    customer_id INT UNSIGNED NOT NULL,
    installation_id INT UNSIGNED NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    status VARCHAR(15) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    PRIMARY KEY (invoice_id),
    CONSTRAINT uq_invoices_number UNIQUE (invoice_number),
    CONSTRAINT fk_invoices_1 FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_invoices_2 FOREIGN KEY (installation_id)
        REFERENCES installations (installation_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT ck_invoices_1 CHECK (due_date >= issue_date),
    CONSTRAINT ck_invoices_2 CHECK (status IN ('DRAFT','ISSUED','CANCELLED')),
    INDEX ix_invoices_customer_due (customer_id, status, due_date)
) ENGINE=InnoDB;

-- invoice_items: 7 defined fields.
CREATE TABLE invoice_items (
    invoice_item_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    invoice_id INT UNSIGNED NOT NULL,
    line_number SMALLINT UNSIGNED NOT NULL,
    item_type VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    description VARCHAR(255) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (invoice_item_id),
    CONSTRAINT uq_invoice_items_line UNIQUE (invoice_id, line_number),
    CONSTRAINT fk_invoice_items_1 FOREIGN KEY (invoice_id)
        REFERENCES invoices (invoice_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT ck_invoice_items_1 CHECK (line_number > 0),
    CONSTRAINT ck_invoice_items_2 CHECK (quantity > 0),
    CONSTRAINT ck_invoice_items_3 CHECK (unit_price >= 0),
    CONSTRAINT ck_invoice_items_4 CHECK (item_type IN ('EQUIPMENT','INSTALLATION','MAINTENANCE','OTHER'))
) ENGINE=InnoDB;

-- payments: 8 defined fields.
CREATE TABLE payments (
    payment_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    invoice_id INT UNSIGNED NOT NULL,
    receipt_number VARCHAR(40) NOT NULL,
    paid_at DATETIME NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_method VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    external_reference VARCHAR(100) NULL,
    recorded_by INT UNSIGNED NOT NULL,
    PRIMARY KEY (payment_id),
    CONSTRAINT uq_payments_receipt UNIQUE (receipt_number),
    CONSTRAINT fk_payments_1 FOREIGN KEY (invoice_id)
        REFERENCES invoices (invoice_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_payments_2 FOREIGN KEY (recorded_by)
        REFERENCES app_users (user_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT ck_payments_1 CHECK (amount > 0),
    CONSTRAINT ck_payments_2 CHECK (payment_method IN ('CASH','BANK_TRANSFER','MOBILE_MONEY','CARD')),
    INDEX ix_payments_period (paid_at)
) ENGINE=InnoDB;

-- Additional cross-table checks will belong to controlled workflow procedures:
-- installation completion, equipment status changes, invoice issuance and payment posting.
-- Constraints alone cannot calculate invoice balances or enforce every state transition.
SHOW TABLES;
