# Unblock-Computer-Shutdown.ps1
# Re-enables normal shutdown behavior on Windows 11
# Run as Administrator, then reboot

# Remove/Reset all policy keys set by BlockShutdown.ps1
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
    -Name 'ShutdownWithoutLogon' -Value 1  -ErrorAction SilentlyContinue
Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
    -Name 'DisableShutdownOption' -ErrorAction SilentlyContinue

Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' `
    -Name 'NoShutdown' -ErrorAction SilentlyContinue
Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' `
    -Name 'CloseSystemNoShutdown' -ErrorAction SilentlyContinue

Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' `
    -Name 'DisableCACheck' -ErrorAction SilentlyContinue
Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' `
    -Name 'DisableTaskMgr' -ErrorAction SilentlyContinue

# Re-enable sleep and hibernate
powercfg /change standby-timeout-ac  120 | Out-Null
powercfg /change standby-timeout-dc  120 | Out-Null
powercfg /change hibernate-timeout-ac 180 | Out-Null
powercfg /change hibernate-timeout-dc 30  | Out-Null
powercfg /h on

Write-Host "All shutdown restrictions removed. Reboot for changes to take full effect." -ForegroundColor Green