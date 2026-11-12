@echo off
setlocal

if not exist backups mkdir backups

set FILENAME=backups\library_backup.dump

echo Starting Database Backup...
docker exec -i library_postgres pg_dump -U postgres -Fc library_db > "%FILENAME%"

if errorlevel 1 (
    echo ERROR: backup failed. Is the container running?
    del "%FILENAME%" 2>nul
    pause
    exit /b 1
)

echo Backup successfully created: %FILENAME%
pause