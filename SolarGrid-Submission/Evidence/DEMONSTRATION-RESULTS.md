# Demonstration results, September 30 2026

The operator confirmed the following results in the guided recording session. Except for the backup-completion screenshot and the pasted MySQL errors and execution plans, these are operator-reported results; the video files have not been independently reviewed for this report. Earlier screenshots in Appendix A remain evidence of the September 13 run.

| Test | Result confirmed by the operator |
|---|---|
| School workflow | Customer 14; site 18; catalogue type 11; equipment unit 62; installation 18 |
| Technician assignments | Agnes Mulenga as lead; Brian Musonda as assistant |
| Completion and service | Installation 18 COMPLETED; unit 62 INSTALLED; request 52 RESOLVED; maintenance cost 0.00 |
| Billing | Invoice 3,000.00; paid 1,000.00; outstanding 2,000.00; PARTIALLY_PAID |
| Overpayment rejection | Attempted 2,500.00 payment rejected; balances unchanged |
| Monthly receipts | September 2026 total 2,200.00, including the new 1,000.00 payment |
| Least privilege | Report SELECT succeeded; UPDATE denied with MySQL error 1142 |
| Index comparison | Index lookup cost 0.7, rows 2; ignored index scan/filter/sort cost 1.95, rows 17 |
| Rollback in restored database | Error 1644; job 13 SCHEDULED with NULL completion; unit 38 AVAILABLE; unit 41 INSTALLED; placements 0 |

Optimizer costs and row counts are estimates, not measured execution times. The rollback test verifies atomicity of this failed operation; it does not establish all concurrency or crash-recovery behaviour.


Backup: solargrid_backup_27282_25735.sql. Restored database: solargrid_restore_demo_20260930. Verification results were confirmed by the operator. Videos have not been reviewed or included.
