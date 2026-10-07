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
Invoke-Task -TaskName "[1/7] Windows Image Repair (DISM)" -Action {
    # Perintah modern PowerShell untuk DISM
    Repair-WindowsImage -Online -RestoreHealth
    # Membersihkan komponen update lama untuk menghemat ruang disk
    DISM /Online /Cleanup-Image /StartComponentCleanup
}

# 2. SFC (System File Checker)
Invoke-Task -TaskName "[2/7] System File Checker (SFC)" -Action {
    # SFC masih menggunakan eksekusi .exe bawaan karena tidak ada cmdlet khusus, 
    # namun PowerShell akan menangkap outputnya.
    sfc.exe /scannow | Out-String -Stream
}

# 3. CHKDSK (Check Disk)
Invoke-Task -TaskName "[3/7] Check Disk (CHKDSK)" -Action {
    Write-Host "Peringatan: CHKDSK akan dijadwalkan pada saat komputer restart." -ForegroundColor Yellow
    # Cmdlet modern PowerShell untuk scan disk
    Repair-Volume -DriveLetter C -Scan
    # Jika ingin deep repair saat restart, otomatis jawab 'Y'
    "Y" | chkdsk C: /f /r /x
}

# 4. Optimize Drive (Defrag / TRIM)
Invoke-Task -TaskName "[4/7] Optimize System Drive" -Action {
    # Cmdlet PowerShell modern untuk optimasi Drive
    Optimize-Volume -DriveLetter C -ReTrim -Defrag -Verbose
}

# 5. Disk Cleanup (tanpa cleanmgr.exe — langsung via PowerShell agar tidak hang)
Invoke-Task -TaskName "[5/7] Disk Cleanup" -Action {
    $cleanupTargets = @(
        @{ Name = "Windows Temp";               Path = "$env:SystemRoot\Temp" },
        @{ Name = "User Temp";                   Path = $env:TEMP },
        @{ Name = "Windows Update Cache";        Path = "$env:SystemRoot\SoftwareDistribution\Download" },
        @{ Name = "Prefetch";                    Path = "$env:SystemRoot\Prefetch" },
        @{ Name = "Thumbnail Cache";             Path = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" },
        @{ Name = "Windows Error Reports";       Path = "$env:LOCALAPPDATA\Microsoft\Windows\WER" },
        @{ Name = "Delivery Optimization Cache"; Path = "$env:SystemRoot\SoftwareDistribution\DeliveryOptimization" },
        @{ Name = "Windows Log Files";           Path = "$env:SystemRoot\Logs\CBS" },
        @{ Name = "INetCache";                   Path = "$env:LOCALAPPDATA\Microsoft\Windows\INetCache" },
        @{ Name = "Recent Items";                Path = "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations" }
    )

    $totalFreed = 0
    foreach ($target in $cleanupTargets) {
        $name = $target.Name
        $targetPath = $target.Path

        # Handle wildcard paths (e.g. thumbcache_*.db)
        if ($targetPath -match '\*') {
            $items = Get-Item -Path $targetPath -ErrorAction SilentlyContinue
        } elseif (Test-Path $targetPath) {
            $items = Get-ChildItem -Path $targetPath -Recurse -Force -ErrorAction SilentlyContinue
        } else {
            $items = $null
        }

        if ($items) {
            $sizeBefore = ($items | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $items | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            $freedMB = [math]::Round(($sizeBefore / 1MB), 1)
            $totalFreed += $sizeBefore
            Write-Host "  Dibersihkan: $name ($freedMB MB)" -ForegroundColor DarkGray
        } else {
            Write-Host "  Dilewati: $name (kosong/tidak ditemukan)" -ForegroundColor DarkGray
        }
    }

    # Bersihkan Recycle Bin
    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Host "  Dibersihkan: Recycle Bin" -ForegroundColor DarkGray
    } catch {
        Write-Host "  Dilewati: Recycle Bin (gagal atau kosong)" -ForegroundColor DarkGray
    }

    $totalFreedMB = [math]::Round(($totalFreed / 1MB), 1)
    Write-Host "Total ruang yang dibebaskan: ~$totalFreedMB MB" -ForegroundColor Green
}

# 6. Network Reset
Invoke-Task -TaskName "[6/7] Network Reset (DNS & Winsock)" -Action {
    # Reset DNS Cache dengan cmdlet modern
    Clear-DnsClientCache
    # IP reset & Winsock (Netsh masih yang paling aman untuk Winsock)
    netsh winsock reset
    netsh int ip reset
    # Memperbarui IP dari DHCP
    ipconfig /renew
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host " [7/7] SEMUA PROSES YANG DIPILIH TELAH SELESAI" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Beberapa aksi mungkin membutuhkan Restart untuk berlaku penuh."

Stop-Transcript
# Membuka log menggunakan explorer agar Notepad tidak terbuka sebagai proses Administrator yang bisa memblokir shutdown
Start-Process "explorer.exe" -ArgumentList $LogFile
Write-Host "Tekan Enter untuk keluar..."
Read-Host
