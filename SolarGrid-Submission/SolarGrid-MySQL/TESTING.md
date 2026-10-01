# Validation record

Tested on 12 September 2026 using MySQL Community Server 26.7.0 on Windows. Tests ran in a separate temporary MySQL instance with networking disabled. The existing MySQL service and its databases were not used or changed.

**Result: 38 checks passed.**

- Created all 15 tables successfully.
- Loaded all 332 sample records and checked each table's exact row count.
- Executed every statement in the supplied report/check script.
- Confirmed issued invoices total K422,400, payments total K255,200 and the balance is K167,200.
- Confirmed six equipment warranties in the demonstration expiry window, twenty-two available units and four unresolved requests.
- Confirmed sample invoice ownership and equipment-status relationships agree.
- Rejected duplicate serial numbers, active equipment placements, technician assignments and payment receipts.
- Rejected missing parent records, unassigned maintenance technicians and deletion of a referenced customer.
- Rejected negative payments, zero invoice quantities, invalid warranty/due dates, invalid statuses and completion without a timestamp.
- Allowed historical equipment placements with multiple NULL active-placement keys, then rolled the test changes back.
- Injected a duplicate receipt near the end of a seed load in a disposable schema. The load failed and every table returned to zero rows.
- Reran the seed against populated tables. It refused to load and all existing row counts remained unchanged.
- Confirmed the temporary seed routine was removed after cleanup.

Tests establish behavior on the stated server version. They do not establish application authentication, business-procedure concurrency, query-performance improvements, backup restoration or compatibility with every other MySQL version. Those belong to later project stages.
