# SolarGrid ERD

![Customer, equipment and installation relationships](SolarGrid-Report-Assets/erd-1.svg)

![Service and billing relationships](SolarGrid-Report-Assets/erd-2.svg)

PK identifies a primary key; FK a foreign key; UQ a unique identifier. 1 means exactly one, 0..* means zero or many, and 0..1 is optional. Some diagram attributes are abbreviated to fit: type_id means equipment_type_id; job_id means installation_id; request_id means service_request_id; unit_id means equipment_unit_id. See the report and DDL for full names and all constraints.
