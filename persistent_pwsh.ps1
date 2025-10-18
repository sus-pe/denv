while ($true) {
    Write-Host "Starting PowerShell..."
    pwsh   # or powershell.exe depending on your version
    Write-Host "PowerShell exited. Restarting in 2 seconds..."
    Start-Sleep -Seconds 2
}

