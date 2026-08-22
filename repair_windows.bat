@echo off
title Windows Full Repair & Optimization Tool
color 0A

echo ================================================
echo         WINDOWS FULL REPAIR & OPTIMIZATION
echo ================================================
echo Jalankan file ini sebagai ADMINISTRATOR!
echo.
pause

:: ==================================================
:: 1. DISM
:: ==================================================
echo ================================================
echo [1/8] DISM - Restoring Windows Image Health
echo ================================================
DISM /Online /Cleanup-Image /RestoreHealth
echo.
echo DISM selesai.
pause

:: ==================================================
:: 2. SFC
:: ==================================================
echo ================================================
echo [2/8] SFC - System File Checker
echo ================================================
sfc /scannow
echo.
echo SFC selesai.
pause

:: ==================================================
:: 3. CHKDSK
:: ==================================================
echo ================================================
echo [3/8] CHKDSK - Disk Check (Drive C)
echo ================================================
echo CHKDSK akan dijalankan pada drive C:
echo Jika diminta restart, ketik Y lalu ENTER.
echo.
chkdsk C: /f /r
echo CHKDSK selesai atau dijadwalkan.
pause

:: ==================================================
:: 4. OPTIMIZE DRIVE C
:: ==================================================
echo ================================================
echo [4/8] OPTIMIZE DRIVE C (Defrag / Trim)
echo ================================================
defrag C: /O
echo Drive C selesai dioptimasi.
pause

:: ==================================================
:: 5. OPTIMIZE DRIVE D
:: ==================================================
echo ================================================
echo [5/8] OPTIMIZE DRIVE D (Defrag / Trim)
echo ================================================
defrag D: /O
echo Drive D selesai dioptimasi.
pause

:: ==================================================
:: 6. DISK CLEANUP
:: ==================================================
echo ================================================
echo [6/8] DISK CLEANUP (Silent Mode)
echo ================================================
cleanmgr /sagerun:99
echo Disk Cleanup selesai.
pause

:: ==================================================
:: 7. NETWORK RESET
:: ==================================================
echo ================================================
echo [7/8] NETWORK RESET (Winsock + TCP/IP)
echo ================================================
netsh winsock reset
netsh int ip reset
ipconfig /flushdns
ipconfig /renew
echo Network reset selesai.
pause

:: ==================================================
:: 8. CLEAN TEMP FILES
:: ==================================================
echo ================================================
echo [8/8] CLEAN TEMP FILES
echo ================================================
echo Menghapus file temporary...
del /s /q %temp%\* >nul 2>&1
del /s /q C:\Windows\Temp\* >nul 2>&1
echo Temp folder dibersihkan.
pause

:: ==================================================
:: DONE
:: ==================================================
echo ================================================
echo SEMUA PROSES PERBAIKAN & OPTIMASI SELESAI
echo Silakan restart komputer Anda.
echo ================================================
pause