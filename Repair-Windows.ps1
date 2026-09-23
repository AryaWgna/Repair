<#
.SYNOPSIS
    Modern Windows Repair & Optimization Script (PowerShell)
.DESCRIPTION
    Skrip ini adalah versi modern dari repair_windows.bat yang diperbarui
    menggunakan standar administrasi Windows terbaru.
#>

# Meminta hak akses Administrator jika belum ada
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Meminta akses Administrator..."
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$LogFile = Join-Path -Path $PSScriptRoot -ChildPath "Repair-Windows-Log.txt"
Start-Transcript -Path $LogFile -Append -Force

Clear-Host
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "     WINDOWS FULL REPAIR & OPTIMIZATION (MODERN)" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Log aktivitas disimpan di: $LogFile"
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Pilihan Mode
Write-Host "Pilih Mode Eksekusi:"
Write-Host "[1] Otomatis (Jalankan semua tanpa bertanya)"
Write-Host "[2] Manual (Pilih proses mana yang ingin dijalankan)"
Write-Host "[3] Batalkan jadwal CHKDSK pada saat restart"
$mode = Read-Host "Pilih (1/2/3)"

if ($mode -eq '3') {
    Write-Host "`n[*] Membatalkan jadwal CHKDSK untuk Drive C..." -ForegroundColor Yellow
    chkntfs /x C:
    Write-Host "[+] Jadwal CHKDSK telah dibatalkan (jika ada)." -ForegroundColor Green
    Stop-Transcript
    Write-Host "Tekan Enter untuk keluar..."
    Read-Host
    exit
}

$isAuto = ($mode -eq '1')

function Invoke-Task {
    param (
        [string]$TaskName,
        [scriptblock]$Action
    )
    $run = $true
    if (-not $isAuto) {
        $choice = Read-Host "Jalankan $TaskName? (Y/N)"
        if ($choice -notmatch "^[Yy]") {
            $run = $false
        }
    }

    if ($run) {
        Write-Host "`n[*] Menjalankan: $TaskName..." -ForegroundColor Yellow
        try {
            & $Action
            Write-Host "[+] $TaskName BERHASIL." -ForegroundColor Green
        } catch {
            Write-Host "[-] $TaskName GAGAL. Error: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "`n[-] Melewati: $TaskName." -ForegroundColor Gray
    }
}

# 1. DISM / Windows Image Repair + Component Cleanup
Invoke-Task -TaskName "[1/8] Windows Image Repair (DISM)" -Action {
    # Perintah modern PowerShell untuk DISM
    Repair-WindowsImage -Online -RestoreHealth
    # Membersihkan komponen update lama untuk menghemat ruang disk
    DISM /Online /Cleanup-Image /StartComponentCleanup
}

# 2. SFC (System File Checker)
Invoke-Task -TaskName "[2/8] System File Checker (SFC)" -Action {
    # SFC masih menggunakan eksekusi .exe bawaan karena tidak ada cmdlet khusus, 
    # namun PowerShell akan menangkap outputnya.
    sfc.exe /scannow | Out-String -Stream
}

# 3. CHKDSK (Check Disk)
Invoke-Task -TaskName "[3/8] Check Disk (CHKDSK)" -Action {
    Write-Host "Peringatan: CHKDSK akan dijadwalkan pada saat komputer restart." -ForegroundColor Yellow
    # Cmdlet modern PowerShell untuk scan disk
    Repair-Volume -DriveLetter C -Scan
    # Jika ingin deep repair saat restart, otomatis jawab 'Y'
    "Y" | chkdsk C: /f /r /x
}

# 4. Optimize Drive (Defrag / TRIM)
Invoke-Task -TaskName "[4/8] Optimize System Drive" -Action {
    # Cmdlet PowerShell modern untuk optimasi Drive
    Optimize-Volume -DriveLetter C -ReTrim -Defrag -Verbose
}

# 5. Disk Cleanup
Invoke-Task -TaskName "[5/8] Disk Cleanup" -Action {
    # Menjalankan Disk Cleanup otomatis (sama seperti cleanmgr /sagerun:99)
    cleanmgr /sagerun:99
}

# 6. Network Reset
Invoke-Task -TaskName "[6/8] Network Reset (DNS & Winsock)" -Action {
    # Reset DNS Cache dengan cmdlet modern
    Clear-DnsClientCache
    # IP reset & Winsock (Netsh masih yang paling aman untuk Winsock)
    netsh winsock reset
    netsh int ip reset
    # Memperbarui IP dari DHCP
    ipconfig /renew
}

# 7. Clean Temp Files & Prefetch
Invoke-Task -TaskName "[7/8] Bersihkan Temporary Files & Prefetch" -Action {
    # Membersihkan folder Temp user, sistem, Prefetch, dan cache update
    $tempPaths = @(
        $env:TEMP,
        "$env:SystemRoot\Temp",
        "$env:SystemRoot\Prefetch",
        "$env:SystemRoot\SoftwareDistribution\Download"
    )

    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            Write-Host "Membersihkan: $path" -ForegroundColor DarkGray
            Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host " [8/8] SEMUA PROSES YANG DIPILIH TELAH SELESAI" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Beberapa aksi mungkin membutuhkan Restart untuk berlaku penuh."

Stop-Transcript
Start-Process $LogFile
Write-Host "Tekan Enter untuk keluar..."
Read-Host
