@echo off
title Windows Full Repair ^& Optimization Tool
color 0A

:: ==================================================
:: CEK HAK AKSES ADMINISTRATOR
:: ==================================================
openfiles >nul 2>&1
if '%errorlevel%' NEQ '0' (
    echo Meminta hak akses Administrator...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ================================================
echo         WINDOWS FULL REPAIR ^& OPTIMIZATION
echo ================================================
echo Proses akan berjalan otomatis. Mohon tunggu...
echo ================================================
echo.

:: ==================================================
:: 1. DISM
:: ==================================================
echo [1/8] DISM - Restoring Windows Image Health...
DISM /Online /Cleanup-Image /RestoreHealth
echo DISM selesai.
echo.

:: ==================================================
:: 2. SFC
:: ==================================================
echo [2/8] SFC - System File Checker...
sfc /scannow
echo SFC selesai.
echo.

:: ==================================================
:: 3. CHKDSK
:: ==================================================
echo [3/8] CHKDSK - Disk Check (Drive C)...
echo Menjadwalkan chkdsk saat restart jika drive sedang digunakan...
echo y | chkdsk C: /f /r
echo CHKDSK selesai/dijadwalkan.
echo.

:: ==================================================
:: 4. OPTIMIZE SEMUA DRIVE LOKAL
:: ==================================================
echo [4/8] OPTIMIZE DRIVE (Defrag / Trim semua volume)...
defrag /C /O
echo Optimasi drive selesai.
echo.

:: ==================================================
:: 5. DISK CLEANUP
:: ==================================================
echo [5/8] DISK CLEANUP (Silent Mode)...
cleanmgr /sagerun:99
echo Disk Cleanup diproses.
echo.

:: ==================================================
:: 6. NETWORK RESET
:: ==================================================
echo [6/8] NETWORK RESET (Winsock + TCP/IP)...
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
ipconfig /flushdns >nul 2>&1
ipconfig /renew >nul 2>&1
echo Network reset selesai.
echo.

:: ==================================================
:: 7. CLEAN TEMP FILES & PREFETCH
:: ==================================================
echo [7/8] CLEAN TEMP ^& JUNK FILES...
echo Menghapus temporary files...
del /s /q /f "%temp%\*" >nul 2>&1
del /s /q /f "C:\Windows\Temp\*" >nul 2>&1
del /s /q /f "C:\Windows\Prefetch\*" >nul 2>&1
del /s /q /f "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
rd /s /q "%temp%" 2>nul
rd /s /q "C:\Windows\Temp" 2>nul
md "%temp%" 2>nul
md "C:\Windows\Temp" 2>nul
echo Folder junk dibersihkan.
echo.

:: ==================================================
:: DONE
:: ==================================================
echo ================================================
echo [8/8] SEMUA PROSES PERBAIKAN ^& OPTIMASI SELESAI
echo ================================================
echo Catatan: Beberapa perubahan dan chkdsk mungkin 
echo membutuhkan restart komputer untuk berlaku penuh.
echo ================================================
echo.
pause