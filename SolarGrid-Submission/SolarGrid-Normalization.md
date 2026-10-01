# SolarGrid normalization evidence

IT212 · Group 1 · MySQL

## Purpose and scope

This worked example explains how selected SolarGrid data moves from an unnormalized worksheet to third normal form (3NF). It illustrates the design; it is not a script to rerun against the existing database. The records below are illustrative classroom examples, not claims about current database contents.

The example covers customers, sites, installations, equipment types, equipment units and placement history. Technician assignments are normalized separately to avoid multiplying every equipment item by every technician. Billing and service tables are addressed at the end.

## Business rules and functional dependencies

A functional dependency X → Y means one value of X determines exactly one value of Y in the relation under discussion.

- CustomerID → CustomerName, CustomerPhone.
- SiteID → CustomerID, SiteName.
- InstallationID → SiteID, ScheduledAt.
- EquipmentTypeID → Category, Manufacturer, ModelName.
- EquipmentUnitID → EquipmentTypeID, SerialNumber.
- SerialNumber → EquipmentUnitID: serial numbers are unique in the implemented schema.
- PlacementID → InstallationID, EquipmentUnitID, InstalledAt, RemovedAt, WarrantyStart, WarrantyEnd.

Names and phone numbers are not assumed unique. An installation can contain many equipment units. A unit can have multiple historical placements, but only one active placement at a time. Therefore, (InstallationID, EquipmentUnitID) is not assumed to identify every possible historical placement uniquely.

## UNF — the original worksheet

| InstallationID | Customer | Site | ScheduledAt | Equipment list |
|---|---|---|---|---|
| I01 | C01, Green Farm, 000-001 | S01, North field | 2026-09-13 09:00 | [P01, U01, SN-A, T01, PANEL, SolarCo, Panel-A, installed 2026-09-13 10:00, warranty 2026-09-13 to 2028-09-13]; [P02, U02, SN-B, T02, BATTERY, SolarCo, Battery-B, installed 2026-09-13 10:00, warranty 2026-09-13 to 2027-09-13] |
| I02 | C01, Green Farm, 000-001 | S02, Pump house | 2026-09-14 09:00 | [P03, U03, SN-C, T01, PANEL, SolarCo, Panel-A, installed 2026-09-14 10:00, warranty 2026-09-14 to 2028-09-14] |

This worksheet is not in 1NF: the Customer, Site and Equipment list cells contain multiple facts or repeating groups. InstallationID identifies a job, but does not identify an individual equipment placement.

Problems include inconsistent customer phone updates, repeated equipment model descriptions, inability to register stock before a job exists, and losing information if the only worksheet row containing it is deleted.

## 1NF — atomic values and one row per placement

Split each compound cell into named columns and expand the equipment list into separate rows. Give each placement a unique identifier.

Full relation:

InstallationEquipmentFlat(PlacementID, InstallationID, SiteID, SiteName, CustomerID, CustomerName, CustomerPhone, ScheduledAt, EquipmentUnitID, SerialNumber, EquipmentTypeID, Category, Manufacturer, ModelName, InstalledAt, RemovedAt, WarrantyStart, WarrantyEnd)

For readability, the following two displays show the same three rows split into column groups. At this stage they are one logical relation joined by PlacementID, not two normalized tables.

| PlacementID (PK) | InstallationID | SiteID | SiteName | CustomerID | CustomerName | CustomerPhone | ScheduledAt |
|---|---|---|---|---|---|---|---|
| P01 | I01 | S01 | North field | C01 | Green Farm | 000-001 | 2026-09-13 09:00 |
| P02 | I01 | S01 | North field | C01 | Green Farm | 000-001 | 2026-09-13 09:00 |
| P03 | I02 | S02 | Pump house | C01 | Green Farm | 000-001 | 2026-09-14 09:00 |

| PlacementID | EquipmentUnitID | SerialNumber | EquipmentTypeID | Category | Manufacturer | ModelName | InstalledAt | RemovedAt | WarrantyStart | WarrantyEnd |
|---|---|---|---|---|---|---|---|---|---|---|
| P01 | U01 | SN-A | T01 | PANEL | SolarCo | Panel-A | 2026-09-13 10:00 | NULL | 2026-09-13 | 2028-09-13 |
| P02 | U02 | SN-B | T02 | BATTERY | SolarCo | Battery-B | 2026-09-13 10:00 | NULL | 2026-09-13 | 2027-09-13 |
| P03 | U03 | SN-C | T01 | PANEL | SolarCo | Panel-A | 2026-09-14 10:00 | NULL | 2026-09-14 | 2028-09-14 |

Candidate key: PlacementID, under the stated rules. No other key is inferred just because values happen to be unique in this tiny sample. Each cell now holds one value, and each row describes one placement. Repetition of customer and equipment-type facts remains.

## 2NF — no partial dependencies

2NF requires 1NF and that each non-prime attribute depend on the whole of every candidate key, rather than a proper subset of one.

In the placement example, the only established candidate key is the single attribute PlacementID. Consequently there can be no partial dependency on part of that key: the 1NF relation is already in 2NF. This does NOT make it 3NF; transitive dependencies still cause repeated facts.

To demonstrate a real 2NF decomposition, consider this separate technician-assignment relation:

| InstallationID (PK part) | TechnicianID (PK part) | SiteID | TechnicianName | AssignedAt | AssignmentRole |
|---|---|---|---|---|---|
| I01 | TCH01 | S01 | Alex Banda | 2026-09-12 08:00 | LEAD |
| I01 | TCH02 | S01 | Mary Phiri | 2026-09-12 08:10 | ASSISTANT |
| I02 | TCH01 | S02 | Alex Banda | 2026-09-13 08:00 | LEAD |

Candidate key: (InstallationID, TechnicianID), because a technician has one assignment row per installation in this design.

- InstallationID → SiteID: depends on only part of the key.
- TechnicianID → TechnicianName: depends on only part of the key.
- (InstallationID, TechnicianID) → AssignedAt, AssignmentRole: describes the whole assignment.

Remove the partial dependencies by decomposing into:

- Installations(InstallationID PK, SiteID FK).
- Technicians(TechnicianID PK, TechnicianName).
- InstallationTechnicians(InstallationID PK/FK, TechnicianID PK/FK, AssignedAt, AssignmentRole).

Now the assignment table contains only facts about the technician's assignment to that job. A technician's name is stored once. SiteID is stored once per installation. These tables are combined with the fuller final schema below, not created again as duplicate tables.

## 3NF — remove transitive dependencies

In the flat placement relation, non-key facts depend on other non-key identifiers:

- PlacementID → InstallationID → ScheduledAt, SiteID.
- PlacementID → InstallationID → SiteID → SiteName, CustomerID.
- PlacementID → InstallationID → SiteID → CustomerID → CustomerName, CustomerPhone.
- PlacementID → EquipmentUnitID → SerialNumber, EquipmentTypeID.
- PlacementID → EquipmentUnitID → EquipmentTypeID → Category, Manufacturer, ModelName.

Extract the facts into relations keyed by their own determining identifiers. The final sample is:

### Customers

| CustomerID (PK) | CustomerName | CustomerPhone |
|---|---|---|
| C01 | Green Farm | 000-001 |

### Sites

| SiteID (PK) | CustomerID (FK) | SiteName |
|---|---|---|
| S01 | C01 | North field |
| S02 | C01 | Pump house |

### Installations

| InstallationID (PK) | SiteID (FK) | ScheduledAt |
|---|---|---|
| I01 | S01 | 2026-09-13 09:00 |
| I02 | S02 | 2026-09-14 09:00 |

### Equipment types

| EquipmentTypeID (PK) | Category | Manufacturer | ModelName |
|---|---|---|---|
| T01 | PANEL | SolarCo | Panel-A |
| T02 | BATTERY | SolarCo | Battery-B |

### Equipment units

| EquipmentUnitID (PK) | EquipmentTypeID (FK) | SerialNumber (alternate key) |
|---|---|---|
| U01 | T01 | SN-A |
| U02 | T02 | SN-B |
| U03 | T01 | SN-C |

### Installation equipment

| PlacementID (PK) | InstallationID (FK) | EquipmentUnitID (FK) | InstalledAt | RemovedAt | WarrantyStart | WarrantyEnd |
|---|---|---|---|---|---|---|---|
| P01 | I01 | U01 | 2026-09-13 10:00 | NULL | 2026-09-13 | 2028-09-13 |
| P02 | I01 | U02 | 2026-09-13 10:00 | NULL | 2026-09-13 | 2027-09-13 |
| P03 | I02 | U03 | 2026-09-14 10:00 | NULL | 2026-09-14 | 2028-09-14 |

The placement table records dates for a particular placement; warranty dates are not inferred from equipment type. This allows historical placements and different applicable warranty terms.

### Technicians and assignments

| TechnicianID (PK) | TechnicianName |
|---|---|
| TCH01 | Alex Banda |
| TCH02 | Mary Phiri |

| InstallationID (PK/FK) | TechnicianID (PK/FK) | AssignedAt | AssignmentRole |
|---|---|---|---|
| I01 | TCH01 | 2026-09-12 08:00 | LEAD |
| I01 | TCH02 | 2026-09-12 08:10 | ASSISTANT |
| I02 | TCH01 | 2026-09-13 08:00 | LEAD |

Under the stated dependencies, each nontrivial dependency in these projected relations has a candidate-key determinant, so they satisfy 3NF. Splits are lossless because each extracted identifier is a key in its own table and is retained as a foreign key in the dependent table. The listed dependencies can be enforced in their corresponding relations. Inner joins along those keys reconstruct the original placement facts without multiplying technician and equipment lists together.

## Mapping to the implemented MySQL schema

| Example name | Implemented column/table |
|---|---|
| PlacementID | installation_equipment.installation_equipment_id |
| CustomerID, CustomerName, CustomerPhone | customers.customer_id, customer_name, phone |
| SiteID | sites.site_id |
| InstallationID | installations.installation_id |
| EquipmentTypeID | equipment_types.equipment_type_id |
| EquipmentUnitID, SerialNumber | equipment_units.equipment_unit_id, serial_number |
| TechnicianID, TechnicianName | technicians.technician_id, full_name |
| InstallationTechnicians | installation_technicians |

The real schema uses integer IDs and includes additional attributes, constraints and indexes. Its generated active_equipment_unit_id is an implementation mechanism for enforcing one active placement per equipment unit; it is not an independently maintained business fact in the conceptual normalization example.

## Other schema decisions to explain

- invoice_items and payments are separate child tables: one invoice can have many lines and many payments. Joining both sets directly before aggregation multiplies amounts, so the invoice view aggregates each set separately.
- invoice_items.unit_price records the historical agreed price. It is not a copy that must follow the current equipment catalogue price.
- Invoice totals and balances are calculated by the view rather than manually stored in multiple places.
- service_request_technicians resolves the many-to-many relationship between requests and technicians. maintenance_records references an existing assignment.
- Normalization alone does not enforce all business rules. For example, avoiding overpayment and completing several related updates atomically requires validated transactions.
- This is normalization evidence for selected data, as requested by the brief, not a claim that every dependency of the entire 15-table schema has been formally proved here. The optional installation/customer link on invoices is a business consistency rule that must also be validated when issuing invoices.

## Oral-defence notes

1. UNF has repeating equipment lists; 1NF gives each placement a row and each fact a column.
2. The placement relation with a single-column candidate key is already 2NF. The assignment example demonstrates removing actual partial dependencies from a composite key.
3. 3NF moves customer, site, job and equipment-type facts to their own keyed tables to remove transitive dependencies.
4. Updating a phone number now changes one customer row, and equipment can be registered before installation.
5. Keys and foreign keys preserve relationships; procedures enforce workflow rules and transaction consistency.

This normalization document does not change the live database or the restored test database.
