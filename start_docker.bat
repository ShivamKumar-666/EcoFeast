@echo off
echo ==================================================
echo Starting EcoFeast 2.0 (Docker Environment)
echo ==================================================
echo.

echo 1. Checking if Docker Desktop is running...
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker is not running! Please open Docker Desktop and try again.
    pause
    exit /b 1
)

echo.
echo 2. Starting background containers (Database, Redis, VectorDB, Web)...
docker-compose up --build -d
echo.

echo 3. Running migrations...
docker-compose exec web python manage.py migrate
echo.

echo 4. Syncing mock NGO data (RAG profiles)...
docker-compose exec web python manage.py shell -c "from rag_service.matcher import sync_all_ngos; sync_all_ngos()"
echo.

echo ==================================================
echo SUCCESS! The application is running at:
echo http://localhost:8000
echo.
echo To view live logs, run: docker-compose logs -f web
echo To shut down, run: docker-compose down
echo ==================================================
pause
