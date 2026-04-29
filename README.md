# System Toolkit

A PowerShell menu-driven system information tool for Windows.

## Features

- System Information
- CPU Information
- Memory Information
- Disk Information
- Network Information
- Running Processes
- Installed Programs
- Environment Variables
- Services Status
- Serial Number / BIOS Info
- Windows SN
- Battery Report (Notebook)
- BitLocker Information
- WiFi Passwords

## Usage

### Direct from GitHub (easiest)
```powershell
irm https://raw.githubusercontent.com/rice818/wininfo/master/wininfo.ps1 | iex
```

### Download and run locally
```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/rice818/wininfo/master/wininfo.ps1 -OutFile wininfo.ps1
.\wininfo.ps1
```

Or with execution policy bypass:

```powershell
powershell -ExecutionPolicy Bypass -File .\wininfo.ps1
```

## Requirements

- Windows PowerShell 5.1 or higher
- Administrator privileges recommended (some features require elevation)

## Screenshot

```
====================================
         System Toolkit
====================================

  1. System Information
  2. CPU Information
  3. Memory Information
  ...

  0. Exit
====================================
```

## License

MIT License