# Read SN - PowerShell System Toolkit
# A menu-driven tool for system information and management

$script:version = "1.0.0"

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host "         System Toolkit" -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1. System Information" -ForegroundColor Yellow
    Write-Host "  2. CPU Information" -ForegroundColor Yellow
    Write-Host "  3. Memory Information" -ForegroundColor Yellow
    Write-Host "  4. Disk Information" -ForegroundColor Yellow
    Write-Host "  5. Network Information" -ForegroundColor Yellow
    Write-Host "  6. Running Processes" -ForegroundColor Yellow
    Write-Host "  7. Installed Programs" -ForegroundColor Yellow
    Write-Host "  8. Environment Variables" -ForegroundColor Yellow
    Write-Host "  9. Services Status" -ForegroundColor Yellow
    Write-Host "  10. Serial Number / BIOS Info" -ForegroundColor Yellow
    Write-Host "  11. Windows SN" -ForegroundColor Yellow
    Write-Host "  12. Battery Report (Notebook)" -ForegroundColor Yellow
    Write-Host "  13. BitLocker Information" -ForegroundColor Yellow
    Write-Host "  14. WiFi Passwords" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  0. Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host ""
}

function Get-SystemInfo {
    Write-Host "Gathering system information..." -ForegroundColor Green
    Write-Host ""
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    Write-Host "COMPUTER" -ForegroundColor Cyan
    Write-Host "  Name: $($cs.Name)"
    Write-Host "  Manufacturer: $($cs.Manufacturer)"
    Write-Host "  Model: $($cs.Model)"
    Write-Host ""
    Write-Host "DOMAIN / WORKGROUP" -ForegroundColor Cyan
    Write-Host "  Domain: $($cs.Domain)"
    Write-Host "  Workgroup: $($cs.Workgroup)"
    Write-Host "  Part of Domain: $($cs.PartOfDomain)"
    Write-Host "  OEM: $($cs.OEMStringArray)"
    Write-Host ""
    Write-Host "OPERATING SYSTEM" -ForegroundColor Cyan
    Write-Host "  $($os.Caption)"
    Write-Host "  Version: $($os.Version)"
    Write-Host "  Build: $($os.BuildNumber)"
    Write-Host ""
    Write-Host "SYSTEM INFO" -ForegroundColor Cyan
    Write-Host "  Last Boot: $($os.LastBootUpTime)"
    Write-Host "  Status: $($os.Status)"
}

function Get-CPUInfo {
    Write-Host "Gathering CPU information..." -ForegroundColor Green
    Write-Host ""
    $cpu = Get-CimInstance Win32_Processor
    Write-Host "PROCESSOR" -ForegroundColor Cyan
    Write-Host "  Name: $($cpu.Name)"
    Write-Host "  Manufacturer: $($cpu.Manufacturer)"
    Write-Host "  Cores: $($cpu.NumberOfCores)"
    Write-Host "  Logical Processors: $($cpu.NumberOfLogicalProcessors)"
    Write-Host "  Max Speed: $($cpu.MaxClockSpeed) MHz"
    Write-Host "  Current Speed: $($cpu.CurrentClockSpeed) MHz"
    Write-Host "  Processor ID: $($cpu.ProcessorId)"
}

function Get-MemoryInfo {
    Write-Host "Gathering memory information..." -ForegroundColor Green
    Write-Host ""
    $os = Get-CimInstance Win32_OperatingSystem
    $totalMem = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeMem = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedMem = $totalMem - $freeMem
    $percentUsed = [math]::Round(($usedMem / $totalMem) * 100, 1)

    Write-Host "MEMORY" -ForegroundColor Cyan
    Write-Host "  Total: $totalMem GB"
    Write-Host "  Used: $usedMem GB ($percentUsed%)"
    Write-Host "  Free: $freeMem GB"
    Write-Host ""
    Write-Host "PHYSICAL MEMORY" -ForegroundColor Cyan
    $memDevices = Get-CimInstance Win32_PhysicalMemory
    foreach ($mem in $memDevices) {
        $size = [math]::Round($mem.Capacity / 1GB, 2)
        Write-Host "  Bank: $($mem.BankLabel)"
        Write-Host "    Size: $size GB"
        Write-Host "    Type: $($mem.SMBIOSMemoryType)"
        Write-Host "    Speed: $($mem.Speed) MHz"
        Write-Host "    Manufacturer: $($mem.Manufacturer)"
        Write-Host ""
    }
}

function Get-DiskInfo {
    Write-Host "Gathering disk information..." -ForegroundColor Green
    Write-Host ""
    $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
    foreach ($disk in $disks) {
        $total = [math]::Round($disk.Size / 1GB, 2)
        $free = [math]::Round($disk.FreeSpace / 1GB, 2)
        $used = $total - $free
        $percentUsed = [math]::Round(($used / $total) * 100, 1)
        Write-Host "DRIVE $($disk.DeviceID)" -ForegroundColor Cyan
        Write-Host "  Total: $total GB"
        Write-Host "  Used: $used GB ($percentUsed%)"
        Write-Host "  Free: $free GB"
        Write-Host "  File System: $($disk.FileSystem)"
        Write-Host "  Volume Name: $($disk.VolumeName)"
        Write-Host ""
    }
    $cdrom = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=4"
    foreach ($cd in $cdrom) {
        Write-Host "CD/DVD $($cd.DeviceID)" -ForegroundColor Cyan
        Write-Host "  Volume: $($cd.VolumeName)"
        Write-Host ""
    }
}

function Get-NetworkInfo {
    Write-Host "Gathering network information..." -ForegroundColor Green
    Write-Host ""
    $adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }
    foreach ($adapter in $adapters) {
        Write-Host "ADAPTER: $($adapter.Description)" -ForegroundColor Cyan
        Write-Host "  MAC: $($adapter.MACAddress)"
        if ($adapter.IPAddress) {
            Write-Host "  IP Addresses: $($adapter.IPAddress -join ', ')"
        }
        if ($adapter.IPSubnet) {
            Write-Host "  Subnet Masks: $($adapter.IPSubnet -join ', ')"
        }
        if ($adapter.DefaultIPGateway) {
            Write-Host "  Gateway: $($adapter.DefaultIPGateway -join ', ')"
        }
        if ($adapter.DNSServerSearchOrder) {
            Write-Host "  DNS Servers: $($adapter.DNSServerSearchOrder -join ', ')"
        }
        Write-Host ""
    }
}

function Get-ProcessInfo {
    Write-Host "Gathering process information..." -ForegroundColor Green
    Write-Host ""
    $processes = Get-Process | Sort-Object -Property WorkingSet -Descending | Select-Object -First 20
    Write-Host "TOP 20 PROCESSES (by memory usage)" -ForegroundColor Cyan
    Write-Host ("{0,-30} {1,10} {2,15}" -f "Name", "PID", "Memory (MB)")
    Write-Host ("-" * 55)
    foreach ($proc in $processes) {
        $memMB = [math]::Round($proc.WorkingSet / 1MB, 2)
        Write-Host ("{0,-30} {1,10} {2,15}" -f $proc.Name, $proc.Id, $memMB)
    }
}

function Get-InstalledPrograms {
    Write-Host "Gathering installed programs..." -ForegroundColor Green
    Write-Host ""
    $regPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $programs = @()
    foreach ($path in $regPaths) {
        $programs += Get-ItemProperty $path -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName } |
            Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
    }
    $programs = $programs | Sort-Object DisplayName | Select-Object -First 50
    Write-Host "INSTALLED PROGRAMS (First 50)" -ForegroundColor Cyan
    Write-Host ("{0,-40} {1,15} {2,-30}" -f "Name", "Version", "Publisher")
    Write-Host ("-" * 85)
    foreach ($prog in $programs) {
        $pub = if ($prog.Publisher) { $prog.Publisher.Substring(0, [Math]::Min(30, $prog.Publisher.Length)) } else { "" }
        $ver = if ($prog.DisplayVersion) { $prog.DisplayVersion } else { "" }
        Write-Host ("{0,-40} {1,15} {2,-30}" -f $prog.DisplayName, $ver, $pub)
    }
}

function Get-EnvironmentVars {
    Write-Host "Environment Variables" -ForegroundColor Green
    Write-Host ""
    Write-Host "USER VARIABLES" -ForegroundColor Cyan
    $userVars = [Environment]::GetEnvironmentVariables([EnvironmentVariableTarget]::User)
    foreach ($key in $userVars.Keys | Sort-Object) {
        Write-Host ("  {0,-30} = {1}" -f $key, $userVars.$key)
    }
    Write-Host ""
    Write-Host "SYSTEM VARIABLES" -ForegroundColor Cyan
    $sysVars = [Environment]::GetEnvironmentVariables([EnvironmentVariableTarget]::Machine)
    foreach ($key in $sysVars.Keys | Sort-Object) {
        Write-Host ("  {0,-30} = {1}" -f $key, $sysVars.$key)
    }
}

function Get-ServicesStatus {
    Write-Host "Gathering services status..." -ForegroundColor Green
    Write-Host ""
    $services = Get-Service | Sort-Object Status, Name
    $running = ($services | Where-Object { $_.Status -eq "Running" }).Count
    $stopped = ($services | Where-Object { $_.Status -eq "Stopped" }).Count
    Write-Host "SERVICES SUMMARY" -ForegroundColor Cyan
    Write-Host "  Running: $running"
    Write-Host "  Stopped: $stopped"
    Write-Host ""
    Write-Host "STOPPED SERVICES" -ForegroundColor Yellow
    $services | Where-Object { $_.Status -eq "Stopped" } | Select-Object -First 20 | Format-Table -AutoSize Name, DisplayName, StartType
    Write-Host ""
    Write-Host "RUNNING SERVICES" -ForegroundColor Green
    $services | Where-Object { $_.Status -eq "Running" } | Select-Object -First 20 | Format-Table -AutoSize Name, DisplayName
}

function Get-SerialInfo {
    Write-Host "Gathering serial number and BIOS information..." -ForegroundColor Green
    Write-Host ""

    $cs = Get-CimInstance Win32_ComputerSystem
    $bios = Get-CimInstance Win32_BIOS
    $baseboard = Get-CimInstance Win32_BaseBoard

    Write-Host "COMPUTER SERIAL" -ForegroundColor Cyan
    Write-Host "  Serial Number: $($cs.SerialNumber)"
    Write-Host "  OEM: $($cs.OEMStringArray)"
    Write-Host ""

    Write-Host "BIOS INFORMATION" -ForegroundColor Cyan
    Write-Host "  Manufacturer: $($bios.Manufacturer)"
    Write-Host "  Version: $($bios.SMBIOSBIOSVersion)"
    Write-Host "  Release Date: $($bios.ReleaseDate)"
    Write-Host "  Serial Number: $($bios.SerialNumber)"
    Write-Host "  SMBIOS Version: $($bios.SMBIOSMajorVersion).$($bios.SMBIOSMinorVersion)"
    Write-Host ""

    Write-Host "BASEBOARD (MOTHERBOARD)" -ForegroundColor Cyan
    Write-Host "  Manufacturer: $($baseboard.Manufacturer)"
    Write-Host "  Product: $($baseboard.Product)"
    Write-Host "  Serial Number: $($baseboard.SerialNumber)"
    Write-Host "  Version: $($baseboard.Version)"
}

function Get-WindowsSN {
    Write-Host "Gathering Windows Serial Number..." -ForegroundColor Green
    Write-Host ""

    try {
        $os = Get-CimInstance SoftwareLicensingProduct -Filter "ApplicationID='55c92734-d682-4d71-983e-d847bd45f7a2' AND PartialProductKey IS NOT NULL" -ErrorAction Stop
        $windowsSN = $os | Where-Object { $_.Name -like "*Windows*" -or $_.Description -like "*Windows*" } | Select-Object -First 1
        if ($windowsSN) {
            Write-Host "WINDOWS PRODUCT INFORMATION" -ForegroundColor Cyan
            Write-Host "  Product: $($windowsSN.Name)"
            Write-Host "  Partial Product Key: $($windowsSN.PartialProductKey)"
            Write-Host "  Description: $($windowsSN.Description)"
            Write-Host "  Product Key ID: $($windowsSN.ProductKeyID)"
        } else {
            Write-Host "Could not retrieve Windows SN from software licensing." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Note: Run as Administrator for full license details." -ForegroundColor Yellow
    }

    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    try {
        $regKey = Get-ItemProperty -Path $regPath -ErrorAction Stop
        Write-Host ""
        Write-Host "REGISTRY PRODUCT INFORMATION" -ForegroundColor Cyan
        Write-Host "  Product Name: $($regKey.ProductName)"
        Write-Host "  Edition: $($regKey.EditionID)"
        Write-Host "  Display Version: $($regKey.DisplayVersion)"
        Write-Host "  Current Build: $($regKey.CurrentBuild)"
        Write-Host "  Install Date: $([datetime]::FromFileTime($regKey.InstallTime))"
        if ($regKey.ProductId) {
            Write-Host "  Product ID: $($regKey.ProductId)"
        }
    } catch {
        Write-Host "Could not read registry information." -ForegroundColor Red
    }
}

function Get-BatteryReport {
    Write-Host "Checking battery status..." -ForegroundColor Green
    Write-Host ""

    $battery = Get-CimInstance Win32_Battery
    if ($null -eq $battery) {
        Write-Host "No battery detected - this is a desktop or non-notebook system." -ForegroundColor Yellow
        return
    }

    Write-Host "BATTERY STATUS" -ForegroundColor Cyan
    Write-Host "  Device Status: $($battery.BatteryStatus)"
    Write-Host "  Charge: $($battery.EstimatedChargeRemaining)%"
    Write-Host "  Runtime: $($battery.EstimatedRunTime) minutes"

    switch ($battery.BatteryStatus) {
        1 { Write-Host "  Status: Battery is discharging" -ForegroundColor Yellow }
        2 { Write-Host "  Status: On AC power" -ForegroundColor Green }
        3 { Write-Host "  Status: Fully charged" -ForegroundColor Green }
        4 { Write-Host "  Status: Low" -ForegroundColor Red }
        5 { Write-Host "  Status: Critical" -ForegroundColor Red }
        6 { Write-Host "  Status: Charging" -ForegroundColor Yellow }
        7 { Write-Host "  Status: Charging high" -ForegroundColor Yellow }
        8 { Write-Host "  Status: Charging low" -ForegroundColor Yellow }
        9 { Write-Host "  Status: Charging medium" -ForegroundColor Yellow }
        10 { Write-Host "  Status: Unknown" -ForegroundColor Gray }
        default { Write-Host "  Status: Unknown ($($battery.BatteryStatus))" -ForegroundColor Gray }
    }

    Write-Host ""
    Write-Host "GENERATING BATTERY REPORT (HTML)..." -ForegroundColor Green
    $outputPath = "$env:TEMP\battery-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
    try {
        powercfg /batteryreport /output $outputPath /xml $false 2>&1 | Out-Null
        if (Test-Path $outputPath) {
            Write-Host "Battery report saved to:" -ForegroundColor Cyan
            Write-Host "  $outputPath"
            Write-Host ""
            Write-Host "Opening battery report in browser..." -ForegroundColor Green
            Start-Process $outputPath
        }
    } catch {
        Write-Host "Could not generate battery report: $_" -ForegroundColor Red
    }
}

function Get-BitLockerInfo {
    Write-Host "Gathering BitLocker information..." -ForegroundColor Green
    Write-Host ""

    try {
        $bitlocker = Get-BitLockerVolume -ErrorAction Stop
        foreach ($vol in $bitlocker) {
            Write-Host "DRIVE: $($vol.MountPoint)" -ForegroundColor Cyan
            Write-Host "  Protection Status: $($vol.ProtectionStatus)"
            Write-Host "  Encryption Method: $($vol.EncryptionMethod)"
            Write-Host "  Encryption Percentage: $($vol.EncryptionPercentage)%"
            Write-Host "  Auto Unlock Enabled: $($vol.AutoUnlockEnabled)"
            Write-Host "  Volume Status: $($vol.VolumeStatus)"
            if ($vol.KeyProtectors) {
                Write-Host "  Key Protectors:"
                foreach ($kp in $vol.KeyProtectors) {
                    Write-Host "    - $($kp.KeyProtectorType)"
                }
            }
            Write-Host ""
        }
    } catch {
        Write-Host "BitLocker is not available or not enabled on this system." -ForegroundColor Yellow
        Write-Host "Error: $_" -ForegroundColor Gray
    }
}

function Get-WiFiPasswords {
    Write-Host "Gathering WiFi passwords..." -ForegroundColor Green
    Write-Host ""
    $profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {
        $_.Line.Trim().Replace("All User Profile     : ", "")
    }
    if ($profiles.Count -eq 0) {
        Write-Host "No WiFi profiles found." -ForegroundColor Yellow
        return
    }
    Write-Host "SAVED WI-FI PROFILES WITH PASSWORDS" -ForegroundColor Cyan
    Write-Host ("-{0,-30} | {1}" -f "Network Name", "Password")
    Write-Host ("-" * 60)
    foreach ($prof in $profiles) {
        $output = netsh wlan show profile name="$prof" key=clear | Select-String "Key Content"
        $password = "N/A"
        if ($output) {
            $password = $output.Line.Trim().Replace("Key Content            : ", "")
        }
        Write-Host ("-{0,-30} | {1}" -f $prof, $password)
    }
}

function Main {
    do {
        Show-Menu
        $choice = Read-Host "Select an option"
        Write-Host ""

        switch ($choice) {
            "1" { Get-SystemInfo }
            "2" { Get-CPUInfo }
            "3" { Get-MemoryInfo }
            "4" { Get-DiskInfo }
            "5" { Get-NetworkInfo }
            "6" { Get-ProcessInfo }
            "7" { Get-InstalledPrograms }
            "8" { Get-EnvironmentVars }
            "9" { Get-ServicesStatus }
            "10" { Get-SerialInfo }
            "11" { Get-WindowsSN }
            "12" { Get-BatteryReport }
            "13" { Get-BitLockerInfo }
            "14" { Get-WiFiPasswords }
            "0" {
                Write-Host "Goodbye!" -ForegroundColor Green
                return
            }
            default {
                Write-Host "Invalid option. Press Enter to continue..." -ForegroundColor Red
                Read-Host
            }
        }

        if ($choice -ne "0") {
            Write-Host ""
            Write-Host "Press Enter to continue..." -ForegroundColor Gray
            Read-Host
        }
    } while ($choice -ne "0")
}

Main