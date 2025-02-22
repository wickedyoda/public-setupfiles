@echo off
setlocal

:: Define Source and Destination
set "SOURCE=C:\Users\yates\AppData\Local\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang"
set "DEST=\\nas\public\game_backups\Minecraft\Brandons-backup"

:: Map Network Drive
net use Z: \\nas\public /user:traver /persistent:yes

:: Check if the network drive was successfully mapped
if %ERRORLEVEL% neq 0 (
    echo Failed to connect to NAS. Check network access and credentials.
    exit /b 1
)

:: Ensure destination exists
if not exist "%DEST%" mkdir "%DEST%"

:: Run Robocopy to Move Files
robocopy "%SOURCE%" "%DEST%" /z /s /r:2 /w:3 /XD

:: Unmap Network Drive
net use Z: /delete /yes

echo Backup completed successfully!
pause
endlocal