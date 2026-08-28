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

set "LOGFILE=%~dp0repair_log.txt"
echo. >> "%LOGFILE%"
echo ================================================ >> "%LOGFILE%"
echo  WINDOWS FULL REPAIR LOG - %date% %time% >> "%LOGFILE%"
echo ================================================ >> "%LOGFILE%"

echo ================================================
echo         WINDOWS FULL REPAIR ^& OPTIMIZATION
echo ================================================
echo Log aktivitas akan disimpan di: %LOGFILE%
echo ================================================
echo.

:MODE_PROMPT
echo Pilih Mode Eksekusi:
echo [1] Otomatis (Jalankan semua proses tanpa bertanya)
echo [2] Manual (Pilih proses mana yang ingin dijalankan - Yes/No)
echo [3] Batalkan jadwal CHKDSK pada saat restart
set /p mode="Pilih (1/2/3): "
if "%mode%"=="1" goto RUN_AUTO
if "%mode%"=="2" goto RUN_MANUAL
if "%mode%"=="3" goto CANCEL_CHKDSK
echo Pilihan tidak valid. Silakan pilih 1, 2, atau 3.
echo.
goto MODE_PROMPT

:CANCEL_CHKDSK
echo ================================================ >> "%LOGFILE%"
echo [%time%] MEMBATALKAN JADWAL CHKDSK >> "%LOGFILE%"
echo ================================================ >> "%LOGFILE%"
echo.
echo Membatalkan jadwal CHKDSK pada Drive C...
chkntfs /x C:
echo Jadwal CHKDSK telah dibatalkan (jika ada).
echo [%time%] - Batal CHKDSK: BERHASIL >> "%LOGFILE%"
echo.
start "" "%LOGFILE%"
pause
exit /b

:RUN_AUTO
set auto=1
goto START_PROCESS

:RUN_MANUAL
set auto=0
goto START_PROCESS

:START_PROCESS
echo ================================================ >> "%LOGFILE%"
echo         WINDOWS FULL REPAIR ^& OPTIMIZATION >> "%LOGFILE%"
if "%auto%"=="1" (echo Mode: OTOMATIS >> "%LOGFILE%") else (echo Mode: MANUAL >> "%LOGFILE%")
echo ================================================ >> "%LOGFILE%"
echo. >> "%LOGFILE%"

:: ==================================================
:: 1. DISM & COMPONENT CLEANUP
:: ==================================================
if "%auto%"=="1" goto RUN_DISM
set /p run_dism="[1/8] Jalankan DISM (RestoreImageHealth & Cleanup)? (Y/N): "
if /i not "%run_dism%"=="Y" goto SKIP_DISM

:RUN_DISM
echo [1/8] DISM - Restoring Image Health ^& Cleaning Up Old Updates...
echo [%time%] [1/8] DISM - Restoring Image Health ^& Cleaning Up Old Updates... >> "%LOGFILE%"
DISM /Online /Cleanup-Image /RestoreHealth
if %errorlevel% equ 0 (echo [%time%] - DISM RestoreHealth: BERHASIL >> "%LOGFILE%") else (echo [%time%] - DISM RestoreHealth: GAGAL >> "%LOGFILE%")
DISM /Online /Cleanup-Image /StartComponentCleanup
if %errorlevel% equ 0 (echo [%time%] - DISM ComponentCleanup: BERHASIL >> "%LOGFILE%") else (echo [%time%] - DISM ComponentCleanup: GAGAL >> "%LOGFILE%")
echo DISM selesai.
echo.
:SKIP_DISM

:: ==================================================
:: 2. SFC
:: ==================================================
if "%auto%"=="1" goto RUN_SFC
set /p run_sfc="[2/8] Jalankan SFC (System File Checker)? (Y/N): "
if /i not "%run_sfc%"=="Y" goto SKIP_SFC

:RUN_SFC
echo [2/8] SFC - System File Checker...
echo [%time%] [2/8] SFC - System File Checker... >> "%LOGFILE%"
sfc /scannow
if %errorlevel% equ 0 (echo [%time%] - SFC Scan: BERHASIL >> "%LOGFILE%") else (echo [%time%] - SFC Scan: GAGAL >> "%LOGFILE%")
echo SFC selesai.
echo.
:SKIP_SFC

:: ==================================================
:: 3. CHKDSK
:: ==================================================
if "%auto%"=="1" goto RUN_CHKDSK
set /p run_chkdsk="[3/8] Jalankan CHKDSK (Pengecekan Disk Drive C)? (Y/N): "
if /i not "%run_chkdsk%"=="Y" goto SKIP_CHKDSK

:RUN_CHKDSK
echo [3/8] CHKDSK - Disk Check (Drive C)...
echo [%time%] [3/8] CHKDSK - Disk Check (Drive C)... >> "%LOGFILE%"
echo Menjadwalkan chkdsk saat restart jika drive sedang digunakan...
echo y | chkdsk C: /f /r
echo [%time%] - CHKDSK Dijadwalkan/Selesai >> "%LOGFILE%"
echo CHKDSK selesai/dijadwalkan.
echo.
:SKIP_CHKDSK

:: ==================================================
:: 4. OPTIMIZE SEMUA DRIVE LOKAL
:: ==================================================
if "%auto%"=="1" goto RUN_OPT
set /p run_opt="[4/8] Jalankan Optimasi Drive (Defrag/TRIM untuk semua drive)? (Y/N): "
if /i not "%run_opt%"=="Y" goto SKIP_OPT

:RUN_OPT
echo [4/8] OPTIMIZE DRIVE (Defrag / Trim semua volume)...
echo [%time%] [4/8] OPTIMIZE DRIVE (Defrag / Trim semua volume)... >> "%LOGFILE%"
defrag /C /O
if %errorlevel% equ 0 (echo [%time%] - Optimasi Drive: BERHASIL >> "%LOGFILE%") else (echo [%time%] - Optimasi Drive: GAGAL >> "%LOGFILE%")
echo Optimasi drive selesai.
echo.
:SKIP_OPT

:: ==================================================
:: 5. DISK CLEANUP
:: ==================================================
if "%auto%"=="1" goto RUN_CLEANMGR
set /p run_cleanmgr="[5/8] Jalankan Disk Cleanup? (Y/N): "
if /i not "%run_cleanmgr%"=="Y" goto SKIP_CLEANMGR

:RUN_CLEANMGR
echo [5/8] DISK CLEANUP (Silent Mode)...
echo [%time%] [5/8] DISK CLEANUP (Silent Mode)... >> "%LOGFILE%"
cleanmgr /sagerun:99
echo [%time%] - Disk Cleanup: DIPROSES >> "%LOGFILE%"
echo Disk Cleanup diproses.
echo.
:SKIP_CLEANMGR

:: ==================================================
:: 6. NETWORK RESET
:: ==================================================
if "%auto%"=="1" goto RUN_NET
set /p run_net="[6/8] Jalankan Network Reset (Winsock + TCP/IP)? (Y/N): "
if /i not "%run_net%"=="Y" goto SKIP_NET

:RUN_NET
echo [6/8] NETWORK RESET (Winsock + TCP/IP)...
echo [%time%] [6/8] NETWORK RESET (Winsock + TCP/IP)... >> "%LOGFILE%"
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
ipconfig /flushdns >nul 2>&1
ipconfig /renew >nul 2>&1
echo [%time%] - Network Reset: BERHASIL >> "%LOGFILE%"
echo Network reset selesai.
echo.
:SKIP_NET

:: ==================================================
:: 7. CLEAN TEMP FILES & PREFETCH
:: ==================================================
if "%auto%"=="1" goto RUN_TEMP
set /p run_temp="[7/8] Bersihkan Temp Files & Prefetch? (Y/N): "
if /i not "%run_temp%"=="Y" goto SKIP_TEMP

:RUN_TEMP
echo [7/8] CLEAN TEMP ^& JUNK FILES...
echo [%time%] [7/8] CLEAN TEMP ^& JUNK FILES... >> "%LOGFILE%"
echo Menghapus temporary files...
del /s /q /f "%temp%\*" >nul 2>&1
del /s /q /f "C:\Windows\Temp\*" >nul 2>&1
del /s /q /f "C:\Windows\Prefetch\*" >nul 2>&1
del /s /q /f "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
rd /s /q "%temp%" 2>nul
rd /s /q "C:\Windows\Temp" 2>nul
md "%temp%" 2>nul
md "C:\Windows\Temp" 2>nul
echo [%time%] - Clean Temp ^& Junk Files: BERHASIL >> "%LOGFILE%"
echo Folder junk dibersihkan.
echo.
:SKIP_TEMP

:: ==================================================
:: DONE
:: ==================================================
echo ================================================
echo [8/8] SEMUA PROSES YANG DIPILIH TELAH SELESAI
echo ================================================
echo Catatan: Beberapa perubahan dan chkdsk mungkin 
echo membutuhkan restart komputer untuk berlaku penuh.
echo ================================================
echo.

echo ================================================ >> "%LOGFILE%"
echo [%time%] [8/8] SEMUA PROSES YANG DIPILIH TELAH SELESAI >> "%LOGFILE%"
echo ================================================ >> "%LOGFILE%"
echo. >> "%LOGFILE%"
start "" "%LOGFILE%"
pause