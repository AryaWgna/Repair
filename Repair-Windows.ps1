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

# 1. DISM / Windows Image Repair
Invoke-Task -TaskName "Windows Image Repair (DISM)" -Action {
    # Perintah modern PowerShell untuk DISM
    Repair-WindowsImage -Online -RestoreHealth
}

# 2. SFC (System File Checker)
Invoke-Task -TaskName "System File Checker (SFC)" -Action {
    # SFC masih menggunakan eksekusi .exe bawaan karena tidak ada cmdlet khusus, 
    # namun PowerShell akan menangkap outputnya.
    sfc /scannow
}

# 3. Optimize Drive (Defrag / TRIM)
Invoke-Task -TaskName "Optimize System Drive" -Action {
    # Cmdlet PowerShell modern untuk optimasi Drive
    Optimize-Volume -DriveLetter C -ReTrim -Defrag -Verbose
}

# 4. Network Reset
Invoke-Task -TaskName "Network Reset (DNS & Winsock)" -Action {
    # Reset DNS Cache dengan cmdlet modern
    Clear-DnsClientCache
    # IP reset & Winsock (Netsh masih yang paling aman untuk Winsock)
    netsh winsock reset
    netsh int ip reset
}

# 5. Disk Cleanup (Modern Temp Clear)
Invoke-Task -TaskName "Bersihkan Temporary Files" -Action {
    # Membersihkan folder Temp user dan sistem tanpa menyentuh Prefetch!
    $tempPaths = @(
        $env:TEMP,
        "$env:SystemRoot\Temp",
        "$env:SystemRoot\SoftwareDistribution\Download"
    )

    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            Write-Host "Membersihkan: $path" -ForegroundColor DarkGray
            Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# 6. Check Disk (CHKDSK)
Invoke-Task -TaskName "Check Disk (CHKDSK)" -Action {
    Write-Host "Peringatan: CHKDSK akan dijadwalkan pada saat komputer restart." -ForegroundColor Yellow
    # Cmdlet modern PowerShell
    Repair-Volume -DriveLetter C -Scan
    # Jika ingin deep repair saat restart, otomatis jawab 'Y'
    "Y" | chkdsk C: /f /r /x
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host " SEMUA PROSES TELAH SELESAI" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Beberapa aksi mungkin membutuhkan Restart untuk berlaku penuh."

Stop-Transcript
Write-Host "Tekan Enter untuk keluar..."
Read-Host
