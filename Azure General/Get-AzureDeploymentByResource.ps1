$LogPath = "$env:SystemDrive\Get-AzureDeploymentByResource\logs\$(get-date -Format MM-dd-yyyy-hh-mm-ss)__log.txt"
$host.UI.RawUI.BackgroundColor = "black" 
Start-Transcript -Path $LogPath  -Append -Force
#$ErrorActionPreference = 'SilentlyContinue'

#Install required Powershell Module
if(-not (Get-Module PSMenu -ListAvailable)){
    Write-Host -ForegroundColor Magenta "PSMenu module not installed. Performing installation now..."
    Install-Module PSMenu -Scope CurrentUser -Force
    }