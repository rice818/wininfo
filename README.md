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
- Battery Report (Notebook)
- BitLocker Information
- WiFi Passwords

## Usage

```powershell
.\read-sn.ps1
```

Or with execution policy bypass:

```powershell
powershell -ExecutionPolicy Bypass -File .\read-sn.ps1
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