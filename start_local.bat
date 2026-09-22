@echo off
echo ==================================================
echo Starting EcoFeast 2.0 (Local Development Server)
echo ==================================================
echo.

echo 1. Ensuring dependencies are installed...
uv pip install -r requirements.txt
if %ERRORLEVEL% NEQ 0 (
    echo Failed to install dependencies! Please check the errors above.
    pause
    exit /b 1
)
echo.

echo 2. Running database migrations...
uv run python manage.py migrate
echo.

echo 3. Starting the development server...
uv run python manage.py runserver
