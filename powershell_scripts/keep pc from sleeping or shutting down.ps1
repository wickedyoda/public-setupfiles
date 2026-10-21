$ErrorActionPreference = 'Stop'

foreach ($setting in @('standby-timeout-ac', 'standby-timeout-dc')) {
	& powercfg.exe /change $setting 0
	if ($LASTEXITCODE -ne 0) {
		throw "Failed to set power setting '$setting'."
	}
}

Write-Output 'Automatic sleep is disabled for the current power plan on AC and battery.'
