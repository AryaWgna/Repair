# Windows Full Repair & Optimization Tool

*(Scroll down for Bahasa Indonesia version / Gulir ke bawah untuk versi Bahasa Indonesia)*

This is a comprehensive Windows batch script designed to automatically run various built-in system repair, cleanup, and optimization utilities. It helps maintain system health, fix corrupted files, free up disk space, and resolve common network issues.

## Features

The script performs the following 8 operations sequentially:

1. **DISM & Component Cleanup**: Uses Deployment Image Servicing and Management (DISM) to repair the Windows system image and clean up superseded updates.
2. **System File Checker (SFC)**: Scans and repairs corrupted or missing Windows system files.
3. **Check Disk (CHKDSK)**: Checks the C: drive for file system errors and bad sectors. *Note: If the drive is in use, it will schedule a scan for the next restart.*
4. **Drive Optimization**: Runs Defragmentation and TRIM operations on all local volumes to optimize drive performance.
5. **Disk Cleanup**: Runs `cleanmgr` in silent mode to free up disk space by removing unnecessary files.
6. **Network Reset**: Resets Winsock catalog, TCP/IP stack, flushes DNS cache, and renews IP configuration to fix common network connectivity issues.
7. **Clean Temp & Junk Files**: Empties temporary folders (`%temp%` and `C:\Windows\Temp`), Prefetch data, and Windows Update download cache (`SoftwareDistribution\Download`).
8. **Completion**: Displays a completion message reminding the user that a restart may be required.

## How to Use

1. Double-click the `repair_windows.bat` file.
2. The script will automatically check if it has Administrator privileges. If not, it will prompt you with a User Account Control (UAC) dialog to run as Administrator. Click **Yes**.
3. Wait for the script to finish all operations. This process may take some time depending on your system's condition and hardware speed.
4. Once completed, press any key to close the window.
5. **Restart your computer** for all changes and scheduled disk checks (CHKDSK) to take full effect.

## Warning
- Running CHKDSK and DISM can take a considerable amount of time. Do not interrupt the process once it has started.
- Make sure to save your work before running this script, as you will be advised to restart your computer afterwards.

---

# Alat Perbaikan & Optimasi Windows Lengkap

Ini adalah skrip batch Windows komprehensif yang dirancang untuk secara otomatis menjalankan berbagai utilitas bawaan sistem untuk perbaikan, pembersihan, dan optimasi. Skrip ini membantu menjaga kesehatan sistem, memperbaiki file yang rusak, membebaskan ruang disk, dan menyelesaikan masalah jaringan umum.

## Fitur

Skrip ini menjalankan 8 operasi berikut secara berurutan:

1. **DISM & Component Cleanup**: Menggunakan Deployment Image Servicing and Management (DISM) untuk memperbaiki image sistem Windows dan membersihkan pembaruan yang sudah usang.
2. **System File Checker (SFC)**: Memindai dan memperbaiki file sistem Windows yang rusak atau hilang.
3. **Check Disk (CHKDSK)**: Memeriksa drive C: dari kesalahan sistem file dan bad sector. *Catatan: Jika drive sedang digunakan, pemindaian akan dijadwalkan pada saat restart berikutnya.*
4. **Optimasi Drive**: Menjalankan operasi Defragmentasi dan TRIM pada semua volume lokal untuk mengoptimalkan kinerja drive.
5. **Disk Cleanup**: Menjalankan `cleanmgr` dalam mode senyap untuk membebaskan ruang disk dengan menghapus file yang tidak diperlukan.
6. **Reset Jaringan**: Mereset katalog Winsock, tumpukan TCP/IP, menghapus cache DNS, dan memperbarui konfigurasi IP untuk memperbaiki masalah konektivitas jaringan umum.
7. **Pembersihan File Temp & Sampah**: Mengosongkan folder sementara (`%temp%` dan `C:\Windows\Temp`), data Prefetch, dan cache unduhan Windows Update (`SoftwareDistribution\Download`).
8. **Selesai**: Menampilkan pesan penyelesaian yang mengingatkan pengguna bahwa restart mungkin diperlukan.

## Cara Menggunakan

1. Klik ganda pada file `repair_windows.bat`.
2. Skrip akan secara otomatis memeriksa apakah memiliki hak akses Administrator. Jika tidak, ia akan meminta Anda melalui dialog User Account Control (UAC) untuk menjalankan sebagai Administrator. Klik **Yes** (Ya).
3. Tunggu hingga skrip menyelesaikan semua operasi. Proses ini mungkin memakan waktu tergantung pada kondisi sistem dan kecepatan perangkat keras Anda.
4. Setelah selesai, tekan tombol apa saja untuk menutup jendela.
5. **Restart komputer Anda** agar semua perubahan dan pemeriksaan disk yang dijadwalkan (CHKDSK) dapat berlaku sepenuhnya.

## Peringatan
- Menjalankan CHKDSK dan DISM bisa memakan waktu yang cukup lama. Jangan hentikan proses setelah dimulai.
- Pastikan untuk menyimpan pekerjaan Anda sebelum menjalankan skrip ini, karena Anda akan disarankan untuk me-restart komputer setelahnya.
