#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'

Update-MpSignature

Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -PUAProtection Enabled
Set-MpPreference -EnableControlledFolderAccess Enabled
Set-MpPreference -EnableNetworkProtection Enabled
