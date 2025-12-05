#requires -module InvokeBuild, ModuleBuilder

#
# WARNING: This file should not be executed directly.
# Use the Build.ps1 script in the project root to execute the build.
#

param(
    [string] $BuildNumber,
    [string] $ModuleName = 'PipelineUtils'
)

# Synopsis: Default build target - runs Build task
task . Build

# Synopsis: Clean build artifacts
task Clean {
    Write-Host 'Cleaning build artifacts...'
    Remove-Item -Path (Join-Path $PSScriptRoot 'out') -Recurse -Force -ErrorAction SilentlyContinue
}

# Synopsis: Build the module using ModuleBuilder
task Build Clean, GetBuildNumber, {
    Write-Host "Building module with ModuleBuilder..."
    
    # Use ModuleBuilder to transpile individual .ps1 files into a single .psm1
    $buildParams = @{
        SourcePath = Join-Path $PSScriptRoot 'Source'
    }
    
    # Add SemVer parameter if BuildNumber is provided
    if ($BuildNumber) {
        Write-Host "Setting module version to $BuildNumber..."
        $buildParams.SemVer = $BuildNumber
    }
    
    Build-Module @buildParams
    Write-Host "Module built successfully using ModuleBuilder with version $BuildNumber"
}

# Synopsis: Get the build number
task GetBuildNumber {
    Write-Host "Getting build number..."

    # Check if GitVersion.Tool is installed
    $gitVersionInstalled = $null -ne (dotnet tool list --global | Where-Object { $_ -match 'gitversion.tool' })

    if (-not $gitVersionInstalled) {
        Write-Error "GitVersion.Tool is not installed. Install it with: dotnet tool install --global GitVersion.Tool"
        throw "Required tool GitVersion.Tool is not installed."
    }

    # Use GitVersion to get the SemVer
    Write-Host "Running GitVersion..."
    $gitVersionOutput = dotnet-gitversion
    $gitVersionInfo = $gitVersionOutput | ConvertFrom-Json

    # Set the build number
    if($gitVersionInfo.PreReleaseLabel) {
        $preReleasePart = "-pre$($gitVersionInfo.WeightedPreReleaseNumber)"
    }
    
    $script:BuildNumber = $gitVersionInfo.MajorMinorPatch + $preReleasePart

    Write-Host "Build number set to: $BuildNumber"

    # If running in GitHub Actions, set the output parameter
    if ($env:GITHUB_ACTIONS -eq 'true') {
        "BUILD_NAME=$BuildNumber" >> $env:GITHUB_OUTPUT
        Write-Host "GitHub Actions build name set as output variable"
    }
}

# Synopsis: Run Pester tests
task Test Build, {
    Write-Host 'Running Pester tests...'

    Test-Path (Join-Path $PSScriptRoot 'out') || (New-Item -ItemType Directory -Path (Join-Path $PSScriptRoot 'out') | Out-Null)
    
    # Create Pester configuration for Pester 5
    $config = New-PesterConfiguration
    $config.Run.Path = Join-Path $PSScriptRoot 'Tests'
    $config.TestResult.Enabled = $true
    $config.TestResult.OutputPath = Join-Path $PSScriptRoot 'out/TestResults.xml'
    $config.TestResult.OutputFormat = 'NUnitXml'
    $config.CodeCoverage.Enabled = $true
    $config.CodeCoverage.Path = (Get-ChildItem -Path (Join-Path $PSScriptRoot 'Build/PipelineUtils') -Include '*.psm1' -Recurse).FullName
    $config.CodeCoverage.OutputPath = Join-Path $PSScriptRoot 'out/CodeCoverage.xml'
    $config.Output.Verbosity = 'Detailed'
    
    $testResult = Invoke-Pester -Configuration $config
    
    if ($testResult.FailedCount -gt 0) {
        Write-Host "Tests failed: $($testResult.FailedCount) of $($testResult.TotalCount)" -ForegroundColor Red
        throw "Tests failed"
    }
    else {
        Write-Host "All tests passed: $($testResult.TotalCount)" -ForegroundColor Green
    }
}

# Synopsis: Create distribution package
task Package Build, {
    Write-Host 'Packing module into zip...'
    $out = Join-Path $PSScriptRoot 'Build/portable'
    if (-not (Test-Path $out)) { New-Item -ItemType Directory -Path $out | Out-Null }
    
    $buildPath = Join-Path $PSScriptRoot 'Build/PipelineUtils'
    $zip = Join-Path $out "$ModuleName-$BuildNumber.zip"

    if (Test-Path $zip) { Remove-Item $zip }
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($buildPath, $zip)
    Write-Host "Created $zip"
}

# Synopsis: Publish module to PowerShell Gallery
task Publish Build, {
    Write-Host 'Publishing module to PowerShell Gallery...'
    
    # Check for API key in environment variable
    $apiKey = $env:PSGALLERY_API_KEY
    if (-not $apiKey) {
        throw "PowerShell Gallery API Key not found. Set the PSGALLERY_API_KEY environment variable."
    }
    
    # Get the module path
    $modulePath = Join-Path $PSScriptRoot "out/module/$ModuleName"

    # Publish the module
    Write-Host "Publishing module version $BuildNumber to PowerShell Gallery..."
    Publish-Module -Path $modulePath -NuGetApiKey $apiKey -Verbose
    
    Write-Host "Module published successfully to PowerShell Gallery" -ForegroundColor Green
}