-- SOLARGRID: editor-compatible sample loader (same 332 records).
-- Run once, in the same connection throughout. Tables should be empty.
-- No DELIMITER and no stored procedure are needed.
-- IMPORTANT: changes remain pending. After ZERO errors, run COMMIT separately.
-- If ANY error occurs, run ROLLBACK instead. Do not rerun without checking.
-- Do not change the autocommit setting, reconnect, run DDL, or start another
-- transaction before committing or rolling back this load.
ROLLBACK;
USE solargrid;
SET NAMES utf8mb4;
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,ONLY_FULL_GROUP_BY,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
START TRANSACTION;

-- customers: 12 fictional records.
INSERT INTO customers (customer_id, customer_name, customer_type, phone, email, billing_address, is_active, created_at) VALUES
    (1, 'Chanda Mwila', 'HOUSEHOLD', '+260-000-000-001', 'customer1@solargrid.example', 'Plot 21, Lusaka', 1, '2025-07-09 09:00:00'),
    (2, 'Lillian Phiri', 'HOUSEHOLD', '+260-000-000-002', 'customer2@solargrid.example', 'Plot 22, Ndola', 1, '2025-07-09 09:00:00'),
    (3, 'Muleya Family Farm', 'FARM', '+260-000-000-003', 'customer3@solargrid.example', 'Plot 23, Choma', 1, '2025-07-09 09:00:00'),
    (4, 'Mupapa Learning Centre', 'SCHOOL', '+260-000-000-004', 'customer4@solargrid.example', 'Plot 24, Kitwe', 1, '2025-07-09 09:00:00'),
    (5, 'Kafue Fresh Produce', 'BUSINESS', '+260-000-000-005', 'customer5@solargrid.example', 'Plot 25, Kafue', 1, '2025-07-09 09:00:00'),
    (6, 'Grace Tembo', 'HOUSEHOLD', '+260-000-000-006', 'customer6@solargrid.example', 'Plot 26, Livingstone', 1, '2025-07-09 09:00:00'),
    (7, 'Twalumba Training School', 'SCHOOL', '+260-000-000-007', 'customer7@solargrid.example', 'Plot 27, Monze', 1, '2025-07-09 09:00:00'),
    (8, 'Green Valley Farm', 'FARM', '+260-000-000-008', 'customer8@solargrid.example', 'Plot 28, Mazabuka', 1, '2025-07-09 09:00:00'),
    (9, 'Copperleaf Guesthouse', 'BUSINESS', '+260-000-000-009', 'customer9@solargrid.example', 'Plot 29, Solwezi', 1, '2025-07-09 09:00:00'),
    (10, 'Joseph Banda', 'HOUSEHOLD', '+260-000-000-010', 'customer10@solargrid.example', 'Plot 30, Kabwe', 1, '2025-07-09 09:00:00'),
    (11, 'Lakeside Irrigation Farm', 'FARM', '+260-000-000-011', 'customer11@solargrid.example', 'Plot 31, Siavonga', 1, '2025-07-09 09:00:00'),
    (12, 'Mwezi Community School', 'SCHOOL', '+260-000-000-012', 'customer12@solargrid.example', 'Plot 32, Chipata', 1, '2025-07-09 09:00:00');

-- sites: 16 fictional records.
INSERT INTO sites (site_id, customer_id, site_name, address, town, site_notes) VALUES
    (1, 1, 'Main residence', 'Plot 101, Lusaka', 'Lusaka', NULL),
    (2, 2, 'Family house', 'Plot 102, Ndola', 'Ndola', NULL),
    (3, 3, 'Farmhouse', 'Plot 103, Choma', 'Choma', NULL),
    (4, 4, 'Classroom block', 'Plot 104, Kitwe', 'Kitwe', NULL),
    (5, 5, 'Packing warehouse', 'Plot 105, Kafue', 'Kafue', NULL),
    (6, 6, 'Main residence', 'Plot 106, Livingstone', 'Livingstone', NULL),
    (7, 7, 'Training block', 'Plot 107, Monze', 'Monze', NULL),
    (8, 8, 'Irrigation pump station', 'Plot 108, Mazabuka', 'Mazabuka', NULL),
    (9, 9, 'Guesthouse main wing', 'Plot 109, Solwezi', 'Solwezi', NULL),
    (10, 10, 'Main residence', 'Plot 110, Kabwe', 'Kabwe', NULL),
    (11, 11, 'Pump house', 'Plot 111, Siavonga', 'Siavonga', NULL),
    (12, 12, 'School administration', 'Plot 112, Chipata', 'Chipata', NULL),
    (13, 3, 'Cold storage shed', 'Plot 113, Choma', 'Choma', NULL),
    (14, 5, 'Retail outlet', 'Plot 114, Kafue', 'Kafue', NULL),
    (15, 8, 'Staff housing', 'Plot 115, Mazabuka', 'Mazabuka', NULL),
    (16, 9, 'Guesthouse annex', 'Plot 116, Solwezi', 'Solwezi', NULL);

-- equipment_types: 10 fictional records.
INSERT INTO equipment_types (equipment_type_id, sku, category, manufacturer, model_name, description, default_warranty_months, list_price) VALUES
    (1, 'P450', 'PANEL', 'Demo Solar Manufacturing', 'SG-P450', 'Fictional training catalogue item: panel', 24, 2200),
    (2, 'B5', 'BATTERY', 'Demo Solar Manufacturing', 'SG-B5', 'Fictional training catalogue item: battery', 24, 18000),
    (3, 'I5', 'INVERTER', 'Demo Solar Manufacturing', 'SG-I5', 'Fictional training catalogue item: inverter', 24, 12500),
    (4, 'P550', 'PANEL', 'Demo Solar Manufacturing', 'SG-P550', 'Fictional training catalogue item: panel', 24, 2800),
    (5, 'B10', 'BATTERY', 'Demo Solar Manufacturing', 'SG-B10', 'Fictional training catalogue item: battery', 36, 32000),
    (6, 'I8', 'INVERTER', 'Demo Solar Manufacturing', 'SG-I8', 'Fictional training catalogue item: inverter', 24, 19000),
    (7, 'C60', 'OTHER', 'Demo Solar Manufacturing', 'SG-C60', 'Fictional training catalogue item: other', 12, 3500),
    (8, 'M1', 'OTHER', 'Demo Solar Manufacturing', 'SG-M1', 'Fictional training catalogue item: other', 12, 1500),
    (9, 'P400', 'PANEL', 'Demo Solar Manufacturing', 'SG-P400', 'Fictional training catalogue item: panel', 24, 2000),
    (10, 'I3', 'INVERTER', 'Demo Solar Manufacturing', 'SG-I3', 'Fictional training catalogue item: inverter', 12, 8500);

-- equipment_units: 60 fictional records.
INSERT INTO equipment_units (equipment_unit_id, equipment_type_id, serial_number, received_date, status) VALUES
    (1, 1, 'SG-DEMO-00001', '2025-07-19', 'INSTALLED'),
    (2, 2, 'SG-DEMO-00002', '2025-07-19', 'INSTALLED'),
    (3, 3, 'SG-DEMO-00003', '2025-07-19', 'INSTALLED'),
    (4, 1, 'SG-DEMO-00004', '2025-07-19', 'INSTALLED'),
    (5, 2, 'SG-DEMO-00005', '2025-07-19', 'INSTALLED'),
    (6, 3, 'SG-DEMO-00006', '2025-07-19', 'INSTALLED'),
    (7, 1, 'SG-DEMO-00007', '2025-07-19', 'INSTALLED'),
    (8, 2, 'SG-DEMO-00008', '2025-07-19', 'INSTALLED'),
    (9, 3, 'SG-DEMO-00009', '2025-07-19', 'INSTALLED'),
    (10, 1, 'SG-DEMO-00010', '2025-07-19', 'INSTALLED'),
    (11, 2, 'SG-DEMO-00011', '2025-07-19', 'INSTALLED'),
    (12, 3, 'SG-DEMO-00012', '2025-07-19', 'INSTALLED'),
    (13, 1, 'SG-DEMO-00013', '2025-07-19', 'INSTALLED'),
    (14, 2, 'SG-DEMO-00014', '2025-07-19', 'INSTALLED'),
    (15, 3, 'SG-DEMO-00015', '2025-07-19', 'INSTALLED'),
    (16, 1, 'SG-DEMO-00016', '2025-07-19', 'INSTALLED'),
    (17, 2, 'SG-DEMO-00017', '2025-07-19', 'INSTALLED'),
    (18, 3, 'SG-DEMO-00018', '2025-07-19', 'INSTALLED'),
    (19, 1, 'SG-DEMO-00019', '2025-07-19', 'INSTALLED'),
    (20, 2, 'SG-DEMO-00020', '2025-07-19', 'INSTALLED'),
    (21, 3, 'SG-DEMO-00021', '2025-07-19', 'INSTALLED'),
    (22, 1, 'SG-DEMO-00022', '2025-07-19', 'INSTALLED'),
    (23, 2, 'SG-DEMO-00023', '2025-07-19', 'INSTALLED'),
    (24, 3, 'SG-DEMO-00024', '2025-07-19', 'INSTALLED'),
    (25, 1, 'SG-DEMO-00025', '2025-07-19', 'INSTALLED'),
    (26, 2, 'SG-DEMO-00026', '2025-07-19', 'INSTALLED'),
    (27, 3, 'SG-DEMO-00027', '2025-07-19', 'INSTALLED'),
    (28, 1, 'SG-DEMO-00028', '2025-07-19', 'INSTALLED'),
    (29, 2, 'SG-DEMO-00029', '2025-07-19', 'INSTALLED'),
    (30, 3, 'SG-DEMO-00030', '2025-07-19', 'INSTALLED'),
    (31, 1, 'SG-DEMO-00031', '2025-07-19', 'INSTALLED'),
    (32, 2, 'SG-DEMO-00032', '2025-07-19', 'INSTALLED'),
    (33, 3, 'SG-DEMO-00033', '2025-07-19', 'INSTALLED'),
    (34, 1, 'SG-DEMO-00034', '2025-07-19', 'INSTALLED'),
    (35, 2, 'SG-DEMO-00035', '2025-07-19', 'INSTALLED'),
    (36, 3, 'SG-DEMO-00036', '2025-07-19', 'INSTALLED'),
    (37, 2, 'SG-DEMO-00037', '2025-07-19', 'MAINTENANCE'),
    (38, 2, 'SG-DEMO-00038', '2025-07-19', 'AVAILABLE'),
    (39, 3, 'SG-DEMO-00039', '2025-07-19', 'AVAILABLE'),
    (40, 4, 'SG-DEMO-00040', '2025-07-19', 'AVAILABLE'),
    (41, 5, 'SG-DEMO-00041', '2025-07-19', 'AVAILABLE'),
    (42, 6, 'SG-DEMO-00042', '2025-07-19', 'AVAILABLE'),
    (43, 7, 'SG-DEMO-00043', '2025-07-19', 'AVAILABLE'),
    (44, 8, 'SG-DEMO-00044', '2025-07-19', 'AVAILABLE'),
    (45, 9, 'SG-DEMO-00045', '2025-07-19', 'AVAILABLE'),
    (46, 10, 'SG-DEMO-00046', '2025-07-19', 'AVAILABLE'),
    (47, 1, 'SG-DEMO-00047', '2025-07-19', 'AVAILABLE'),
    (48, 2, 'SG-DEMO-00048', '2025-07-19', 'AVAILABLE'),
    (49, 3, 'SG-DEMO-00049', '2025-07-19', 'AVAILABLE'),
    (50, 4, 'SG-DEMO-00050', '2025-07-19', 'AVAILABLE'),
    (51, 5, 'SG-DEMO-00051', '2025-07-19', 'AVAILABLE'),
    (52, 6, 'SG-DEMO-00052', '2025-07-19', 'AVAILABLE'),
    (53, 7, 'SG-DEMO-00053', '2025-07-19', 'AVAILABLE'),
    (54, 8, 'SG-DEMO-00054', '2025-07-19', 'AVAILABLE'),
    (55, 9, 'SG-DEMO-00055', '2025-07-19', 'AVAILABLE'),
    (56, 10, 'SG-DEMO-00056', '2025-07-19', 'AVAILABLE'),
    (57, 1, 'SG-DEMO-00057', '2025-07-19', 'AVAILABLE'),
    (58, 2, 'SG-DEMO-00058', '2025-07-19', 'AVAILABLE'),
    (59, 3, 'SG-DEMO-00059', '2025-07-19', 'AVAILABLE'),
    (60, 4, 'SG-DEMO-00060', '2025-07-19', 'RETIRED');

-- installations: 16 fictional records.
INSERT INTO installations (installation_id, site_id, scheduled_at, completed_at, status, work_description, completion_notes) VALUES
    (1, 1, '2025-09-12 09:00:00', '2025-09-12 16:00:00', 'COMPLETED', 'Solar power installation for main residence', 'Commissioning and handover completed.'),
    (2, 2, '2025-10-02 09:00:00', '2025-10-02 16:00:00', 'COMPLETED', 'Solar power installation for family house', 'Commissioning and handover completed.'),
    (3, 3, '2025-10-22 09:00:00', '2025-10-22 16:00:00', 'COMPLETED', 'Solar power installation for farmhouse', 'Commissioning and handover completed.'),
    (4, 4, '2025-11-11 09:00:00', '2025-11-11 16:00:00', 'COMPLETED', 'Solar power installation for classroom block', 'Commissioning and handover completed.'),
    (5, 5, '2025-12-01 09:00:00', '2025-12-01 16:00:00', 'COMPLETED', 'Solar power installation for packing warehouse', 'Commissioning and handover completed.'),
    (6, 6, '2025-12-21 09:00:00', '2025-12-21 16:00:00', 'COMPLETED', 'Solar power installation for main residence', 'Commissioning and handover completed.'),
    (7, 7, '2026-01-10 09:00:00', '2026-01-10 16:00:00', 'COMPLETED', 'Solar power installation for training block', 'Commissioning and handover completed.'),
    (8, 8, '2026-01-30 09:00:00', '2026-01-30 16:00:00', 'COMPLETED', 'Solar power installation for irrigation pump station', 'Commissioning and handover completed.'),
    (9, 9, '2026-02-19 09:00:00', '2026-02-19 16:00:00', 'COMPLETED', 'Solar power installation for guesthouse main wing', 'Commissioning and handover completed.'),
    (10, 10, '2026-03-11 09:00:00', '2026-03-11 16:00:00', 'COMPLETED', 'Solar power installation for main residence', 'Commissioning and handover completed.'),
    (11, 11, '2026-03-31 09:00:00', '2026-03-31 16:00:00', 'COMPLETED', 'Solar power installation for pump house', 'Commissioning and handover completed.'),
    (12, 12, '2026-04-20 09:00:00', '2026-04-20 16:00:00', 'COMPLETED', 'Solar power installation for school administration', 'Commissioning and handover completed.'),
    (13, 13, '2026-09-12 09:00:00', NULL, 'SCHEDULED', 'Solar power installation for cold storage shed', NULL),
    (14, 14, '2026-09-11 09:00:00', NULL, 'IN_PROGRESS', 'Solar power installation for retail outlet', NULL),
    (15, 15, '2026-09-26 09:00:00', NULL, 'SCHEDULED', 'Solar power installation for staff housing', NULL),
    (16, 16, '2026-09-02 09:00:00', NULL, 'CANCELLED', 'Solar power installation for guesthouse annex', NULL);

-- installation_equipment: 37 fictional records.
INSERT INTO installation_equipment (installation_equipment_id, installation_id, equipment_unit_id, installed_at, removed_at, warranty_start, warranty_end, placement_notes) VALUES
    (1, 1, 1, '2025-09-12 12:00:00', NULL, '2025-09-12', '2026-09-07', 'Commissioned and tested.'),
    (2, 1, 2, '2025-12-21 12:00:00', NULL, '2025-09-12', '2026-09-07', 'Replacement battery; original warranty terms retained.'),
    (3, 1, 3, '2025-09-12 12:00:00', NULL, '2025-09-12', '2026-09-07', 'Commissioned and tested.'),
    (4, 2, 4, '2025-10-02 12:00:00', NULL, '2025-10-02', '2026-09-22', 'Commissioned and tested.'),
    (5, 2, 5, '2025-10-02 12:00:00', NULL, '2025-10-02', '2026-09-22', 'Commissioned and tested.'),
    (6, 2, 6, '2025-10-02 12:00:00', NULL, '2025-10-02', '2026-09-22', 'Commissioned and tested.'),
    (7, 3, 7, '2025-10-22 12:00:00', NULL, '2025-10-22', '2026-10-07', 'Commissioned and tested.'),
    (8, 3, 8, '2025-10-22 12:00:00', NULL, '2025-10-22', '2026-10-07', 'Commissioned and tested.'),
    (9, 3, 9, '2025-10-22 12:00:00', NULL, '2025-10-22', '2026-10-07', 'Commissioned and tested.'),
    (10, 4, 10, '2025-11-11 12:00:00', NULL, '2025-11-11', '2026-10-27', 'Commissioned and tested.'),
    (11, 4, 11, '2025-11-11 12:00:00', NULL, '2025-11-11', '2026-10-27', 'Commissioned and tested.'),
    (12, 4, 12, '2025-11-11 12:00:00', NULL, '2025-11-11', '2026-10-27', 'Commissioned and tested.'),
    (13, 5, 13, '2025-12-01 12:00:00', NULL, '2025-12-01', '2026-12-11', 'Commissioned and tested.'),
    (14, 5, 14, '2025-12-01 12:00:00', NULL, '2025-12-01', '2026-12-11', 'Commissioned and tested.'),
    (15, 5, 15, '2025-12-01 12:00:00', NULL, '2025-12-01', '2026-12-11', 'Commissioned and tested.'),
    (16, 6, 16, '2025-12-21 12:00:00', NULL, '2025-12-21', '2027-02-09', 'Commissioned and tested.'),
    (17, 6, 17, '2025-12-21 12:00:00', NULL, '2025-12-21', '2027-02-09', 'Commissioned and tested.'),
    (18, 6, 18, '2025-12-21 12:00:00', NULL, '2025-12-21', '2027-02-09', 'Commissioned and tested.'),
    (19, 7, 19, '2026-01-10 12:00:00', NULL, '2026-01-10', '2027-04-20', 'Commissioned and tested.'),
    (20, 7, 20, '2026-01-10 12:00:00', NULL, '2026-01-10', '2027-04-20', 'Commissioned and tested.'),
    (21, 7, 21, '2026-01-10 12:00:00', NULL, '2026-01-10', '2027-04-20', 'Commissioned and tested.'),
    (22, 8, 22, '2026-01-30 12:00:00', NULL, '2026-01-30', '2027-06-19', 'Commissioned and tested.'),
    (23, 8, 23, '2026-01-30 12:00:00', NULL, '2026-01-30', '2027-06-19', 'Commissioned and tested.'),
    (24, 8, 24, '2026-01-30 12:00:00', NULL, '2026-01-30', '2027-06-19', 'Commissioned and tested.'),
    (25, 9, 25, '2026-02-19 12:00:00', NULL, '2026-02-19', '2027-08-18', 'Commissioned and tested.'),
    (26, 9, 26, '2026-02-19 12:00:00', NULL, '2026-02-19', '2027-08-18', 'Commissioned and tested.'),
    (27, 9, 27, '2026-02-19 12:00:00', NULL, '2026-02-19', '2027-08-18', 'Commissioned and tested.'),
    (28, 10, 28, '2026-03-11 12:00:00', NULL, '2026-03-11', '2027-10-17', 'Commissioned and tested.'),
    (29, 10, 29, '2026-03-11 12:00:00', NULL, '2026-03-11', '2027-10-17', 'Commissioned and tested.'),
    (30, 10, 30, '2026-03-11 12:00:00', NULL, '2026-03-11', '2027-10-17', 'Commissioned and tested.'),
    (31, 11, 31, '2026-03-31 12:00:00', NULL, '2026-03-31', '2027-12-16', 'Commissioned and tested.'),
    (32, 11, 32, '2026-03-31 12:00:00', NULL, '2026-03-31', '2027-12-16', 'Commissioned and tested.'),
    (33, 11, 33, '2026-03-31 12:00:00', NULL, '2026-03-31', '2027-12-16', 'Commissioned and tested.'),
    (34, 12, 34, '2026-04-20 12:00:00', NULL, '2026-04-20', '2028-02-14', 'Commissioned and tested.'),
    (35, 12, 35, '2026-04-20 12:00:00', NULL, '2026-04-20', '2028-02-14', 'Commissioned and tested.'),
    (36, 12, 36, '2026-04-20 12:00:00', NULL, '2026-04-20', '2028-02-14', 'Commissioned and tested.'),
    (37, 1, 37, '2025-09-12 12:00:00', '2025-12-21 10:00:00', '2025-09-12', '2026-09-07', 'Removed faulty battery. Unit awaits inspection.');

-- technicians: 10 fictional records.
INSERT INTO technicians (technician_id, full_name, phone, email, specialization, is_active) VALUES
    (1, 'Brian Musonda', '+260-000-100-001', 'technician1@solargrid.example', 'Solar installation', 1),
    (2, 'Esther Zulu', '+260-000-100-002', 'technician2@solargrid.example', 'Battery systems', 1),
    (3, 'Peter Chileshe', '+260-000-100-003', 'technician3@solargrid.example', 'Inverter diagnostics', 1),
    (4, 'Naomi Mumba', '+260-000-100-004', 'technician4@solargrid.example', 'Electrical inspection', 1),
    (5, 'Daniel Daka', '+260-000-100-005', 'technician5@solargrid.example', 'Maintenance', 1),
    (6, 'Ruth Lungu', '+260-000-100-006', 'technician6@solargrid.example', 'Solar installation', 1),
    (7, 'Felix Sitali', '+260-000-100-007', 'technician7@solargrid.example', 'Battery systems', 1),
    (8, 'Agnes Mulenga', '+260-000-100-008', 'technician8@solargrid.example', 'Inverter diagnostics', 1),
    (9, 'Samuel Mwanza', '+260-000-100-009', 'technician9@solargrid.example', 'Electrical inspection', 1),
    (10, 'Linda Ngoma', '+260-000-100-010', 'technician10@solargrid.example', 'Maintenance', 1);

-- installation_technicians: 32 fictional records.
INSERT INTO installation_technicians (installation_id, technician_id, assigned_at, assignment_role) VALUES
    (1, 1, '2025-09-05 09:00:00', 'LEAD'),
    (1, 2, '2025-09-05 09:00:00', 'ASSISTANT'),
    (2, 2, '2025-09-25 09:00:00', 'LEAD'),
    (2, 3, '2025-09-25 09:00:00', 'ASSISTANT'),
    (3, 3, '2025-10-15 09:00:00', 'LEAD'),
    (3, 4, '2025-10-15 09:00:00', 'ASSISTANT'),
    (4, 4, '2025-11-04 09:00:00', 'LEAD'),
    (4, 5, '2025-11-04 09:00:00', 'ASSISTANT'),
    (5, 5, '2025-11-24 09:00:00', 'LEAD'),
    (5, 6, '2025-11-24 09:00:00', 'ASSISTANT'),
    (6, 6, '2025-12-14 09:00:00', 'LEAD'),
    (6, 7, '2025-12-14 09:00:00', 'ASSISTANT'),
    (7, 7, '2026-01-03 09:00:00', 'LEAD'),
    (7, 8, '2026-01-03 09:00:00', 'ASSISTANT'),
    (8, 8, '2026-01-23 09:00:00', 'LEAD'),
    (8, 9, '2026-01-23 09:00:00', 'ASSISTANT'),
    (9, 9, '2026-02-12 09:00:00', 'LEAD'),
    (9, 10, '2026-02-12 09:00:00', 'ASSISTANT'),
    (10, 10, '2026-03-04 09:00:00', 'LEAD'),
    (10, 1, '2026-03-04 09:00:00', 'ASSISTANT'),
    (11, 1, '2026-03-24 09:00:00', 'LEAD'),
    (11, 2, '2026-03-24 09:00:00', 'ASSISTANT'),
    (12, 2, '2026-04-13 09:00:00', 'LEAD'),
    (12, 3, '2026-04-13 09:00:00', 'ASSISTANT'),
    (13, 3, '2026-08-21 09:00:00', 'LEAD'),
    (13, 4, '2026-08-21 09:00:00', 'ASSISTANT'),
    (14, 4, '2026-08-21 09:00:00', 'LEAD'),
    (14, 5, '2026-08-21 09:00:00', 'ASSISTANT'),
    (15, 5, '2026-08-21 09:00:00', 'LEAD'),
    (15, 6, '2026-08-21 09:00:00', 'ASSISTANT'),
    (16, 6, '2026-08-21 09:00:00', 'LEAD'),
    (16, 7, '2026-08-21 09:00:00', 'ASSISTANT');

-- service_requests: 12 fictional records.
INSERT INTO service_requests (service_request_id, installation_id, reported_at, problem_description, priority, status, resolved_at) VALUES
    (1, 1, '2026-07-26 09:00:00', 'Battery capacity below expected level', 'LOW', 'RESOLVED', '2026-07-30 15:00:00'),
    (2, 2, '2026-07-28 09:00:00', 'Panel cleaning and inspection', 'MEDIUM', 'RESOLVED', '2026-08-01 15:00:00'),
    (3, 3, '2026-07-30 09:00:00', 'Inverter alarm investigation', 'HIGH', 'RESOLVED', '2026-08-03 15:00:00'),
    (4, 4, '2026-08-01 09:00:00', 'Loose mounting bracket', 'URGENT', 'RESOLVED', '2026-08-05 15:00:00'),
    (5, 5, '2026-08-03 09:00:00', 'Routine electrical inspection', 'LOW', 'RESOLVED', '2026-08-07 15:00:00'),
    (6, 6, '2026-08-05 09:00:00', 'Battery monitoring fault', 'MEDIUM', 'RESOLVED', '2026-08-09 15:00:00'),
    (7, 7, '2026-08-07 09:00:00', 'Cable inspection', 'HIGH', 'RESOLVED', '2026-08-11 15:00:00'),
    (8, 8, '2026-08-09 09:00:00', 'Controller settings review', 'URGENT', 'RESOLVED', '2026-08-13 15:00:00'),
    (9, 9, '2026-09-04 09:00:00', 'Intermittent inverter shutdown', 'LOW', 'OPEN', NULL),
    (10, 10, '2026-09-05 09:00:00', 'Reduced charging output', 'MEDIUM', 'ASSIGNED', NULL),
    (11, 11, '2026-09-06 09:00:00', 'Pump power interruption', 'HIGH', 'IN_PROGRESS', NULL),
    (12, 12, '2026-09-07 09:00:00', 'Annual system inspection', 'URGENT', 'OPEN', NULL);

-- service_request_technicians: 14 fictional records.
INSERT INTO service_request_technicians (service_request_id, technician_id, assigned_at) VALUES
    (1, 1, '2026-07-27 09:00:00'),
    (1, 2, '2026-07-27 09:00:00'),
    (2, 2, '2026-07-29 09:00:00'),
    (2, 3, '2026-07-29 09:00:00'),
    (3, 3, '2026-07-31 09:00:00'),
    (3, 4, '2026-07-31 09:00:00'),
    (4, 4, '2026-08-02 09:00:00'),
    (4, 5, '2026-08-02 09:00:00'),
    (5, 5, '2026-08-04 09:00:00'),
    (6, 6, '2026-08-06 09:00:00'),
    (7, 7, '2026-08-08 09:00:00'),
    (8, 8, '2026-08-10 09:00:00'),
    (10, 10, '2026-09-06 09:00:00'),
    (11, 1, '2026-09-07 09:00:00');

-- maintenance_records: 12 fictional records.
INSERT INTO maintenance_records (maintenance_record_id, service_request_id, technician_id, performed_at, work_done, maintenance_cost, next_service_date) VALUES
    (1, 1, 1, '2026-07-29 11:00:00', 'Inspection and diagnosis completed.', 175, '2027-01-25'),
    (2, 1, 2, '2026-07-29 12:00:00', 'Repair, adjustment and final testing completed.', 225, '2027-01-25'),
    (3, 2, 2, '2026-07-31 11:00:00', 'Inspection and diagnosis completed.', 200, '2027-01-27'),
    (4, 2, 3, '2026-07-31 12:00:00', 'Repair, adjustment and final testing completed.', 250, '2027-01-27'),
    (5, 3, 3, '2026-08-02 11:00:00', 'Inspection and diagnosis completed.', 225, '2027-01-29'),
    (6, 3, 4, '2026-08-02 12:00:00', 'Repair, adjustment and final testing completed.', 275, '2027-01-29'),
    (7, 4, 4, '2026-08-04 11:00:00', 'Inspection and diagnosis completed.', 250, '2027-01-31'),
    (8, 4, 5, '2026-08-04 12:00:00', 'Repair, adjustment and final testing completed.', 300, '2027-01-31'),
    (9, 5, 5, '2026-08-06 11:00:00', 'Inspection and diagnosis completed.', 275, '2027-02-02'),
    (10, 6, 6, '2026-08-08 11:00:00', 'Inspection and diagnosis completed.', 300, '2027-02-04'),
    (11, 7, 7, '2026-08-10 11:00:00', 'Inspection and diagnosis completed.', 325, '2027-02-06'),
    (12, 8, 8, '2026-08-12 11:00:00', 'Inspection and diagnosis completed.', 350, '2027-02-08');

-- app_users: 3 fictional records.
INSERT INTO app_users (user_id, username, password_hash, full_name, role, is_active) VALUES
    (1, 'demo_admin', 'pbkdf2_sha256$600000$+l5Yb+d7gmeVQ/ds4nWOUg==$A2O0GfWGTKyNltahGM1a8YLWQftcZM0/3yGihI2ovdQ=', 'Demo Administrator', 'ADMIN', 0),
    (2, 'demo_operations', 'pbkdf2_sha256$600000$i2mz0Eyq3l/+I6beaXSswA==$vd4cm1aLpDptnEf735gPdhol83xZ7JqtN3zL1e9Cfj0=', 'Demo Operations Officer', 'OPERATIONS', 0),
    (3, 'demo_accounts', 'pbkdf2_sha256$600000$1AFEFTHGq/GUI7GzfStDTw==$3d/p0bZCzZrv/qp8A7o2gFLNn0phb430rc9LjpHYr0U=', 'Demo Accounts Officer', 'ACCOUNTS', 0);

-- invoices: 16 fictional records.
INSERT INTO invoices (invoice_id, invoice_number, customer_id, installation_id, issue_date, due_date, status) VALUES
    (1, 'SG-2026-0001', 1, 1, '2025-09-13', '2025-10-13', 'ISSUED'),
    (2, 'SG-2026-0002', 2, 2, '2025-10-03', '2025-11-02', 'ISSUED'),
    (3, 'SG-2026-0003', 3, 3, '2025-10-23', '2025-11-22', 'ISSUED'),
    (4, 'SG-2026-0004', 4, 4, '2025-11-12', '2025-12-12', 'ISSUED'),
    (5, 'SG-2026-0005', 5, 5, '2025-12-02', '2026-01-01', 'ISSUED'),
    (6, 'SG-2026-0006', 6, 6, '2025-12-22', '2026-01-21', 'ISSUED'),
    (7, 'SG-2026-0007', 7, 7, '2026-01-11', '2026-02-10', 'ISSUED'),
    (8, 'SG-2026-0008', 8, 8, '2026-01-31', '2026-03-02', 'ISSUED'),
    (9, 'SG-2026-0009', 9, 9, '2026-02-20', '2026-03-22', 'ISSUED'),
    (10, 'SG-2026-0010', 10, 10, '2026-03-12', '2026-04-11', 'ISSUED'),
    (11, 'SG-2026-0011', 11, 11, '2026-04-01', '2026-05-01', 'ISSUED'),
    (12, 'SG-2026-0012', 12, 12, '2026-04-21', '2026-05-21', 'ISSUED'),
    (13, 'SG-2026-0013', 3, 13, '2026-09-02', '2026-10-02', 'DRAFT'),
    (14, 'SG-2026-0014', 5, 14, '2026-09-03', '2026-10-03', 'DRAFT'),
    (15, 'SG-2026-0015', 8, 15, '2026-09-04', '2026-10-04', 'CANCELLED'),
    (16, 'SG-2026-0016', 9, 16, '2026-09-05', '2026-10-05', 'CANCELLED');

-- invoice_items: 64 fictional records.
INSERT INTO invoice_items (invoice_item_id, invoice_id, line_number, item_type, description, quantity, unit_price) VALUES
    (1, 1, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (2, 1, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (3, 1, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (4, 1, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500),
    (5, 2, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (6, 2, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (7, 2, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (8, 2, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500),
    (9, 3, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (10, 3, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (11, 3, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (12, 3, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500),
    (13, 4, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (14, 4, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (15, 4, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (16, 4, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500),
    (17, 5, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (18, 5, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (19, 5, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (20, 5, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500),
    (21, 6, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (22, 6, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (23, 6, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (24, 6, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500),
    (25, 7, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (26, 7, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (27, 7, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (28, 7, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500),
    (29, 8, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (30, 8, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (31, 8, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (32, 8, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500),
    (33, 9, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (34, 9, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (35, 9, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (36, 9, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500),
    (37, 10, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (38, 10, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (39, 10, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (40, 10, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500),
    (41, 11, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (42, 11, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (43, 11, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (44, 11, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500),
    (45, 12, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (46, 12, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (47, 12, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (48, 12, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500),
    (49, 13, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (50, 13, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (51, 13, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (52, 13, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500),
    (53, 14, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (54, 14, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (55, 14, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (56, 14, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500),
    (57, 15, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (58, 15, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (59, 15, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (60, 15, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500),
    (61, 16, 1, 'EQUIPMENT', '450 W solar panel', 1, 2200),
    (62, 16, 2, 'EQUIPMENT', '5 kWh battery', 1, 18000),
    (63, 16, 3, 'EQUIPMENT', '5 kW inverter', 1, 12500),
    (64, 16, 4, 'INSTALLATION', 'Installation, testing and handover', 1, 2500);

-- payments: 18 fictional records.
INSERT INTO payments (payment_id, invoice_id, receipt_number, paid_at, amount, payment_method, external_reference, recorded_by) VALUES
    (1, 1, 'RCT-DEMO-0001', '2025-09-17 10:00:00', 10000.00, 'MOBILE_MONEY', 'DEMO-REF-00001', 3),
    (2, 1, 'RCT-DEMO-0002', '2025-10-02 10:00:00', 25200.00, 'CASH', NULL, 3),
    (3, 2, 'RCT-DEMO-0003', '2025-10-07 10:00:00', 10000.00, 'CASH', NULL, 3),
    (4, 2, 'RCT-DEMO-0004', '2025-10-22 10:00:00', 25200.00, 'BANK_TRANSFER', 'DEMO-REF-00004', 3),
    (5, 3, 'RCT-DEMO-0005', '2025-10-27 10:00:00', 10000.00, 'BANK_TRANSFER', 'DEMO-REF-00005', 3),
    (6, 3, 'RCT-DEMO-0006', '2025-11-11 10:00:00', 25200.00, 'MOBILE_MONEY', 'DEMO-REF-00006', 3),
    (7, 4, 'RCT-DEMO-0007', '2025-11-16 10:00:00', 10000.00, 'MOBILE_MONEY', 'DEMO-REF-00007', 3),
    (8, 4, 'RCT-DEMO-0008', '2025-12-01 10:00:00', 25200.00, 'CASH', NULL, 3),
    (9, 5, 'RCT-DEMO-0009', '2025-12-06 10:00:00', 10000.00, 'CASH', NULL, 3),
    (10, 5, 'RCT-DEMO-0010', '2025-12-21 10:00:00', 25200.00, 'BANK_TRANSFER', 'DEMO-REF-00010', 3),
    (11, 6, 'RCT-DEMO-0011', '2025-12-26 10:00:00', 10000.00, 'BANK_TRANSFER', 'DEMO-REF-00011', 3),
    (12, 6, 'RCT-DEMO-0012', '2026-01-10 10:00:00', 25200.00, 'MOBILE_MONEY', 'DEMO-REF-00012', 3),
    (13, 7, 'RCT-DEMO-0013', '2026-01-15 10:00:00', 8000.00, 'MOBILE_MONEY', 'DEMO-REF-00013', 3),
    (14, 7, 'RCT-DEMO-0014', '2026-01-30 10:00:00', 4000.00, 'CASH', NULL, 3),
    (15, 8, 'RCT-DEMO-0015', '2026-02-04 10:00:00', 8000.00, 'CASH', NULL, 3),
    (16, 8, 'RCT-DEMO-0016', '2026-02-19 10:00:00', 4000.00, 'BANK_TRANSFER', 'DEMO-REF-00016', 3),
    (17, 9, 'RCT-DEMO-0017', '2026-02-24 10:00:00', 10000.00, 'BANK_TRANSFER', 'DEMO-REF-00017', 3),
    (18, 10, 'RCT-DEMO-0018', '2026-03-16 10:00:00', 10000.00, 'MOBILE_MONEY', 'DEMO-REF-00018', 3);


-- Verify all 15 actual_rows equal expected_rows before COMMIT.
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


-- Leave this connection open and review Output for errors.
