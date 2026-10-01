# Login and customer management

Stop the old server with Ctrl+C, then close its window. Double-click START.bat again. Enter your MySQL details as before. On the first upgraded start, choose a NEW application username (for example solar_admin) and a password of at least 12 characters, then repeat it. Do not reuse demo_admin: sample usernames already exist. The password is stored as a salted hash. Later starts skip account creation when an active hashed administrator exists.

Open http://127.0.0.1:5000 and sign in with the application account you just created, not your MySQL credentials. Accounts persist in app_users. Restarting the server expires browser sessions.

Permissions: ADMIN can view, add, edit and delete customers. OPERATIONS can view, add and edit. ACCOUNTS can view/search only. Existing demo accounts still have placeholder passwords and cannot sign in. This milestone does not include account administration or password recovery.

To demonstrate CRUD: add a customer named Classroom CRUD Test, search for it, edit its phone, then delete that test customer using the confirmation page. Delete is restricted by existing foreign keys: customers with sites or invoices must be marked inactive instead. Do not delete your real sample customers as a demonstration.

Security: each request checks active account status and permissions; POST forms require a session token; login attempts are limited to five failures per five minutes per client address. Secrets are not embedded in source. This remains a localhost classroom app using your current database connection. The configured solargrid_app account has limited database privileges. Production HTTPS hosting remains outside this classroom implementation.
