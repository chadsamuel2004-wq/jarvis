# Register (or remove) the scheduled task that starts JARVIS at logon.
#
#   powershell -ExecutionPolicy Bypass -File scripts\autostart-install.ps1
#   powershell -ExecutionPolicy Bypass -File scripts\autostart-install.ps1 -Remove
#
# The task runs scripts\autostart.vbs, which starts the bridge and the dev
# server with no console window. No administrator rights are needed: it runs as
# the logged-in user, at that user's own privilege level.

param([switch]$Remove)

$ErrorActionPreference = 'Stop'
$taskName = 'JARVIS'
$launcher = Join-Path $PSScriptRoot 'autostart.vbs'
$user = "$env:USERDOMAIN\$env:USERNAME"

if ($Remove) {
  Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
  Write-Host "Removed the $taskName task. JARVIS no longer starts at logon."
  return
}

if (-not (Test-Path $launcher)) { throw "Launcher not found: $launcher" }

# ExecutionTimeLimit of zero means no limit — the default stops long-running
# tasks after three days, which for this one looks like JARVIS dying at random.
Register-ScheduledTask -TaskName $taskName -Force `
  -Action (New-ScheduledTaskAction -Execute 'wscript.exe' -Argument "`"$launcher`"") `
  -Trigger (New-ScheduledTaskTrigger -AtLogOn -User $user) `
  -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero)) `
  -Principal (New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited) `
  -Description 'Starts the JARVIS voice assistant at logon (safe mode).' | Out-Null

Write-Host "Registered the $taskName task. JARVIS starts at your next logon."
Write-Host "Start it now with:  Start-ScheduledTask -TaskName $taskName"
Write-Host "Then open http://localhost:5173 in Chrome."
