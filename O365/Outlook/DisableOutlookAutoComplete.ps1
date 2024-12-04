# Define the registry path
$regKeyPath = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences"

# Check if the Preferences key exists
if (-not (Test-Path $regKeyPath)) {
    # Create the Preferences key if it doesn't exist
    New-Item -Path $regKeyPath -Force
}

# Set the ShowAutoSug registry value to 0 (if it doesn't exist or update it)
Set-ItemProperty -Path $regKeyPath -Name "ShowAutoSug" -Value 0 -Type DWord

Write-Host "Registry key 'ShowAutoSug' has been set to 0."