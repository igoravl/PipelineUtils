#
# Module Build Script
#
# This script checks for required build dependencies
# and invokes Invoke-Build with the appropriate parameters.
#

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string[]]$Targets = @('.'),

    [Parameter()]
    [string]$BuildNumber,

    [Parameter()]
    [switch]$InstallDependencies
)

if($Verbose.IsPresent) {
    $VerbosePreference = 'Continue'
}
else {
    $VerbosePreference = 'SilentlyContinue'
}

# Ensure dotnet global tool paths are available in the current session
$dotnetToolPaths = @(
    Join-Path $env:USERPROFILE '.dotnet\tools'
    (Join-Path $env:LOCALAPPDATA 'Microsoft\dotnet\tools')
) | Where-Object { $_ -and (Test-Path $_) }

foreach ($path in $dotnetToolPaths) {
    if (-not ($env:PATH -split ';' | Where-Object { $_ -eq $path })) {
        $env:PATH = "$path;$env:PATH"
        Write-Verbose "Added dotnet tool path to PATH: $path"
    }
}

# Verifies InvokeBuild module
if (-not (Get-Module -ListAvailable -Name InvokeBuild)) {
    Write-Warning "InvokeBuild module not found."
    
    if ($InstallDependencies -or $PSCmdlet.ShouldContinue("The InvokeBuild module is required for building. Would you like to install it?", "Install InvokeBuild")) {
        Write-Host "Installing InvokeBuild module..." -ForegroundColor Cyan
        Install-Module -Name InvokeBuild -Scope CurrentUser -Force -AllowClobber -Verbose:$Verbose.IsPresent
        Write-Host "InvokeBuild module installed successfully." -ForegroundColor Green
    }
    else {
        Write-Error "The InvokeBuild module is required to continue. Run the script again with the -InstallDependencies parameter to install automatically."
        return
    }
}

# Verifies ModuleBuilder module
if (-not (Get-Module -ListAvailable -Name ModuleBuilder)) {
    Write-Warning "ModuleBuilder module not found."
    
    if ($InstallDependencies -or $PSCmdlet.ShouldContinue("The ModuleBuilder module is required for building. Would you like to install it?", "Install ModuleBuilder")) {
        Write-Host "Installing ModuleBuilder module..." -ForegroundColor Cyan
        Install-Module -Name ModuleBuilder -Scope CurrentUser -Force -AllowClobber -Verbose:$Verbose.IsPresent
        Write-Host "ModuleBuilder module installed successfully." -ForegroundColor Green
    }
    else {
        Write-Error "The ModuleBuilder module is required to continue. Run the script again with the -InstallDependencies parameter to install automatically."
        return
    }
}

# Verifies Pester module
if (-not (Get-Module -ListAvailable -Name Pester | Where-Object Version -ge '5.0.0')) {
    Write-Warning "Pester module version 5.0.0 or higher not found."
    
    if ($InstallDependencies -or $PSCmdlet.ShouldContinue("Pester module version 5.0.0 or higher is required for building. Would you like to install it?", "Install Pester")) {
        Write-Host "Installing Pester module..." -ForegroundColor Cyan
        Install-Module -Name Pester -Scope CurrentUser -Force -AllowClobber -Verbose:$Verbose.IsPresent
        Write-Host "Pester module installed successfully." -ForegroundColor Green
    }
    else {
        Write-Error "The Pester module version 5.0.0 or higher is required to continue. Run the script again with the -InstallDependencies parameter to install automatically."
        return
    }
}

# Verifies GitVersion.Tool installation
$gitVersionInstalled = $null -ne (Get-Command 'dotnet-gitversion' -ErrorAction SilentlyContinue)
if (-not $gitVersionInstalled) {
    Write-Warning "GitVersion.Tool not found."
    
    if ($InstallDependencies -or $PSCmdlet.ShouldContinue("GitVersion.Tool is required for building. Would you like to install it?", "Install GitVersion.Tool")) {
        Write-Host "Installing GitVersion.Tool..." -ForegroundColor Cyan
        dotnet tool install --global GitVersion.Tool 
        Write-Host "GitVersion.Tool installed successfully." -ForegroundColor Green
    }
    else {
        Write-Error "GitVersion.Tool is required to continue. Run the script again with the -InstallDependencies parameter to install automatically."
        return
    }
}

# Verifies Pester module (ensure >= 5.0.0)
$pesterAvailable = Get-Module -ListAvailable -Name Pester | Sort-Object Version -Descending | Select-Object -First 1
if (-not $pesterAvailable -or $pesterAvailable.Version -lt [Version]'5.0.0') {
    if ($pesterAvailable) { Write-Warning ("Pester version {0} found but >=5.0.0 required." -f $pesterAvailable.Version) } else { Write-Warning "Pester module not found." }
    if ($InstallDependencies -or $PSCmdlet.ShouldContinue("Pester 5 is required for testing. Install/upgrade now?", "Install Pester 5")) {
        Write-Host "Installing/Updating Pester module to latest (>=5)..." -ForegroundColor Cyan
        Install-Module -Name Pester -Scope CurrentUser -Force -AllowClobber -Verbose:$Verbose.IsPresent
        Write-Host "Pester module installed/updated successfully." -ForegroundColor Green
    }
    else {
        Write-Error "Pester >=5.0.0 is required to run tests. Run again with -InstallDependencies to install automatically."; return
    }
}

# Preparing arguments for Invoke-Build
$ibArgs = @{
    File = (Join-Path $PSScriptRoot 'ib.build.ps1')
    Task = $Targets
}

# Adds the BuildNumber if provided
if ($BuildNumber) {
    $ibArgs['BuildNumber'] = $BuildNumber
    $ibArgs['Verbose'] = $Verbose.IsPresent
    Write-Verbose "Build number set to: $BuildNumber"
}

# Executes Invoke-Build
try {
    Write-Host "Starting build with Invoke-Build..." -ForegroundColor Cyan
    Write-Verbose "Invoke-Build parameters: $($ibArgs | ConvertTo-Json -Depth 3 -Compress)"
    Invoke-Build @ibArgs
    Write-Host "Build completed successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Error during build: $_"
    exit 1
}
