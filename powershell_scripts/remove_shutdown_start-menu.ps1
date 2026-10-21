$ErrorActionPreference = 'Stop'

$explorerPolicyKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
New-Item -Path $explorerPolicyKey -Force | Out-Null
New-ItemProperty -Path $explorerPolicyKey -Name 'NoClose' -PropertyType DWord -Value 1 -Force | Out-Null

$powerSettings = @(
	'standby-timeout-ac',
	'standby-timeout-dc',
	'hibernate-timeout-ac',
	'hibernate-timeout-dc'
)

foreach ($setting in $powerSettings) {
	& powercfg.exe /change $setting 0
	if ($LASTEXITCODE -ne 0) {
		throw "Failed to set power setting '$($setting[0])'."
	}
}

Write-Output 'Shutdown-related Start menu commands are hidden, and automatic sleep/hibernate timeouts are disabled for the current power plan.'
