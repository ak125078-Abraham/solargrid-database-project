@echo off
cd /d "%~dp0"
if not exist .venv\Scripts\python.exe (
    python -m venv .venv
    if errorlevel 1 goto failed
)
.venv\Scripts\python.exe -m pip install -r requirements.txt
if errorlevel 1 goto failed
.venv\Scripts\python.exe app.py
pause
exit /b
:failed
echo Setup could not finish. Send the error message to your project assistant.
pause
