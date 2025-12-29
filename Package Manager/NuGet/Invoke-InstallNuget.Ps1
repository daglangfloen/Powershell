<#
.SYNOPSIS
    Installs NuGet.exe, the command-line package manager for .NET.
.DESCRIPTION
    This script downloads and installs NuGet.exe to user or system, dependeding on the context the script is run in.
.NOTES
    Script Name: Invoke-InstallNuget.ps1
    Author: Dag Langfloen
    Current Version: 1.0.0
    Version History:
        1.0.0 - Initial release
#>

# Find out if the script is running with elevated privileges
$IsElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If context is elevated, then set the scope to AllUsers, else CurrentUser
if ($IsElevated) {
    $Scope = "AllUsers"
} else {
    $Scope = "CurrentUser"
}
Write-Output "Installing NuGet module with scope: $Scope"

#Check if NuGet module is already installed
$NuGetModule = Get-Module -ListAvailable NuGet

# If NuGet module is not found, install it, and if it's installed, check for updates
if (!$NuGetModule) {
    try {
        Write-Output "NuGet module not found. Installing..."
        Install-Module -Name NuGet -Scope $Scope -Force -AllowClobber -ErrorAction Stop
        Write-Output "NuGet module installed successfully."
    }
    catch {
        Write-Error "Failed to install NuGet module. Error: $_"
    }
}
else {
    Write-Output "NuGet module is already installed, checking for updates."
    $LatestVersion = (Find-Module -Name NuGet).Version

    # Find latest version available in the repository
    if ($NuGetModule.Version -lt $LatestVersion) {
        Write-Output "A newer version of NuGet module ($LatestVersion) is available. Updating..."
        try {
            Update-Module -Name NuGet -Scope $Scope -Force -AllowClobber
            Write-Output "NuGet module updated to version $LatestVersion."
        }
        catch {
            Write-Error "Failed to update NuGet module. Error: $_"
        }
    } else {
        Write-Output "NuGet module is up to date."
    }
}