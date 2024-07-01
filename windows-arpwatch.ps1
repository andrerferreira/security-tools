<#
.SYNOPSIS
    Monitors the ARP translation table for dynamic entries and sends notifications using BurntToast.

.DESCRIPTION
    This script retrieves the current ARP table and logs it to a specified file ($logFile).
    Ensure to update $logFile with the desired file path where ARP logs should be stored.
    If dynamic ARP entries are detected, a BurntToast notification is triggered with details of the entries.
    
    Consider setting up a scheduled task to run this script at regular intervals instead of manually executing it.

    You may need to set the appropriate execution policy or signing the script for security.
    Consider creating a batch file (runArpScan.bat) to alter the current executionPolicy, for example:

    @echo off
    powershell.exe -ExecutionPolicy Bypass -File "C:\Users\YOUR_USERNAME\windows-arpwatch.ps1"


.NOTES
    Author: André Ferreira
    Date: 2024-07-01
    Version: 1.0.1

.EXAMPLE
    .\runArpScan.bat
#>

# Define the log file path (update this path to match your environment)
# Ex: C:\Users\currentUser\arp_log.txt
$logFile = "CHANGE_ME"

# Don't make any changes after this line
if (($logFile -eq "CHANGE_ME") -or -not (Test-Path -Path $logFile)) {
    Write-Host "Log file does not exist: $logFile or is using default value"
    Exit
}

$arpTable = arp -a

Add-Content -Path $logFile -Value "$(Get-Date) - ARP Cache:"
Add-Content -Path $logFile -Value $arpTable

$dynamicEntries = $arpTable | Select-String "dynamic"

if ($dynamicEntries) {  
    $message = "Dynamic ARP entries found: `n"

    $dynamicEntries | ForEach-Object {
        $trimmed_line = $_.Line.Trim()
        $message += "$trimmed_line`n"
    }

    try {
        Import-Module BurntToast -ErrorAction Stop
    } catch {
        Install-Module -Name BurntToast -Force -Scope CurrentUser
        Import-Module BurntToast
    }

    New-BurntToastNotification -Text "ARP Monitoring Alert", $message -Sound 'Alarm2'
}
