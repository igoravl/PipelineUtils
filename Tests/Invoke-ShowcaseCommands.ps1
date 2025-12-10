<#
.SYNOPSIS
    Showcases all PipelineUtils commands in action.

.DESCRIPTION
    Demonstrates all available commands from the PipelineUtils module with examples.
    This script is used by both GitHub Actions and Azure Pipelines test workflows.

.PARAMETER WorkspacePath
    The root path of the workspace/repository.

.PARAMETER RunnerOS
    The operating system of the runner (e.g., "Linux", "Windows").

.PARAMETER RunnerName
    The name of the runner executing the pipeline.
#>

[CmdletBinding()]
param(
    # The root path of the workspace/repository
    [Parameter(Mandatory = $true)]
    [string]
    $WorkspacePath,

    # The operating system of the runner
    [Parameter(Mandatory = $false)]
    [string]
    $RunnerOS = 'Unknown',

    # The name of the runner
    [Parameter(Mandatory = $false)]
    [string]
    $RunnerName = 'Unknown'
)

# Find and import the built module
$modulePath = Get-ChildItem -Path $WorkspacePath -Filter "PipelineUtils.psd1" -Recurse | 
    Where-Object { $_.FullName -notlike "*Source*" } | 
    Select-Object -First 1

if (-not $modulePath) {
    Write-Error "Built module not found. Build step may have failed."
    Write-Host "Searching for .psd1 files..."
    Get-ChildItem -Path $WorkspacePath -Filter "*.psd1" -Recurse | ForEach-Object { Write-Host $_.FullName }
    exit 1
}

Write-Host "Loading module from: $($modulePath.FullName)" -ForegroundColor Cyan
Import-Module $modulePath.FullName -Force

Write-PipelineSection -Text "PipelineUtils Command Showcase" -Boxed

# 1. Write-PipelineSection
Write-PipelineSection -Text "1. Section Headers (Write-PipelineSection)" -Boxed
Write-Host "Without boxed parameter:" -ForegroundColor Cyan
Write-PipelineSection -Text "Simple section header"
Write-Host "With boxed parameter:" -ForegroundColor Cyan
Write-PipelineSection -Text "Boxed section header" -Boxed

# 2. Write-PipelineGroupStart/End
Write-PipelineGroupStart "2. Collapsible Groups (Write-PipelineGroupStart/End)"
Write-Host "Creates collapsible/expandable groups in GitHub Actions logs"
Write-PipelineGroupStart "Nested Group Example"
Write-Host "This is a nested group showing hierarchy"
Write-PipelineGroupEnd
Write-PipelineGroupEnd

# 3. Write-PipelineCommand
Write-PipelineSection -Text "3. Command Messages (Write-PipelineCommand)" -Boxed
Write-PipelineCommand "Command message - prefixed output for important operations"

# 4. Write-PipelineDebug
Write-PipelineSection -Text "4. Debug Output (Write-PipelineDebug)" -Boxed
Write-PipelineDebug "Debug message - hidden by default, visible with --debug flag"
Write-PipelineDebug "Workspace: $WorkspacePath"

# 5. Write-PipelineWarning
Write-PipelineSection -Text "5. Warning Messages (Write-PipelineWarning)" -Boxed
Write-PipelineWarning -Message "Warning message - highlighted alert without failing the job" -SourcePath "Source/PipelineUtils.psm1" -LineNumber 42

# 6. Write-PipelineError
Write-PipelineSection -Text "6. Error Messages (Write-PipelineError)" -Boxed
Write-PipelineError -Message "Error message - indicates failure or critical issues" -SourcePath "Source/PipelineUtils.psm1" -LineNumber 42

# 7. Write-PipelineProgress
Write-PipelineSection -Text "7. Progress Tracking (Write-PipelineProgress)" -Boxed
for ($i = 0; $i -le 100; $i += 25) {
    Write-PipelineProgress -Activity "Processing items" -PercentComplete $i
    if ($i -lt 100) { Start-Sleep -Milliseconds 100 }
}

# 8. Set-PipelineVariable
Write-PipelineSection -Text "8. Environment Variables (Set-PipelineVariable)" -Boxed
Write-Host "Sets environment and output variables for subsequent steps" -ForegroundColor Cyan
Set-PipelineVariable -Name "SHOWCASE_VAR" -Value "This is a pipeline variable"
Set-PipelineVariable -Name "OUTPUT_VAR" -Value "This is an output variable" -Output
Write-Host "Variables set: SHOWCASE_VAR (env), OUTPUT_VAR (output)" -ForegroundColor Green

# 9. Set-PipelineSecretValue
Write-PipelineSection -Text "9. Secret Masking (Set-PipelineSecretValue)" -Boxed
$secretValue = "my-secret-api-key-12345"
Write-Host "Before masking: $secretValue" -ForegroundColor Red
Set-PipelineSecretValue -Value $secretValue
Write-Host "After masking: $secretValue - will be replaced with *** in logs" -ForegroundColor Green

# 10. Set-PipelineBuildNumber
Write-PipelineSection -Text "10. Build Number (Set-PipelineBuildNumber)" -Boxed
$buildNumber = "1.0.0-$(Get-Date -Format 'yyyyMMdd.HHmm')"
Set-PipelineBuildNumber -BuildNumber $buildNumber
Write-Host "Build number set to: $buildNumber" -ForegroundColor Green

# 11. Set-PipelineReleaseNumber
Write-PipelineSection -Text "11. Release Number (Set-PipelineReleaseNumber)" -Boxed
$releaseNumber = "v1.0.0"
Set-PipelineReleaseNumber -ReleaseNumber $releaseNumber
Write-Host "Release number set to: $releaseNumber" -ForegroundColor Green

# 12. Add-PipelineBuildTag
Write-PipelineSection -Text "12. Build Tags (Add-PipelineBuildTag)" -Boxed
@("showcase", "automated", "public-commands") | ForEach-Object {
    Add-PipelineBuildTag -Tag $_
}
Write-Host "Build tags added: showcase, automated, public-commands" -ForegroundColor Green

# 13. Add-PipelinePath
Write-PipelineSection -Text "13. PATH Management (Add-PipelinePath)" -Boxed
$toolsPath = Join-Path $WorkspacePath "Build"
Add-PipelinePath -Path $toolsPath
Write-Host "Added to PATH: $toolsPath" -ForegroundColor Green

# 14. Add-PipelineTaskLogFile
Write-PipelineSection -Text "14. Task Log Files (Add-PipelineTaskLogFile)" -Boxed
$logPath = Join-Path $WorkspacePath "test-log.txt"
@"
PipelineUtils Test Log
Generated at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Contains output from showcase commands
"@| Out-File -FilePath $logPath
Add-PipelineTaskLogFile -Path $logPath
Write-Host "Log file attached: test-log.txt" -ForegroundColor Green

# 15. Add-PipelineSummary
Write-PipelineSection -Text "15. Job Summary (Add-PipelineSummary)" -Boxed
$summary = @"
## PipelineUtils Showcase Summary

### Commands Demonstrated
- ✅ Write-PipelineSection
- ✅ Write-PipelineGroupStart/End
- ✅ Write-PipelineCommand
- ✅ Write-PipelineDebug
- ✅ Write-PipelineWarning
- ✅ Write-PipelineError
- ✅ Write-PipelineProgress
- ✅ Set-PipelineVariable
- ✅ Set-PipelineSecretValue
- ✅ Set-PipelineBuildNumber
- ✅ Set-PipelineReleaseNumber
- ✅ Add-PipelineBuildTag
- ✅ Add-PipelinePath
- ✅ Add-PipelineTaskLogFile
- ✅ Add-PipelineSummary
- ✅ Complete-PipelineTask

### Environment
- OS: $RunnerOS
- Runner: $RunnerName
- PowerShell: $($PSVersionTable.PSVersion)
"@
Add-PipelineSummary -Content $summary
Write-Host "Summary added to job summary page" -ForegroundColor Green

# 16. Complete-PipelineTask
Write-PipelineSection -Text "16. Task Completion (Complete-PipelineTask)" -Boxed
Write-Host "Completing task with success status..." -ForegroundColor Cyan
Complete-PipelineTask -Status 'Succeeded'
