# Example usage of PipelinesUtils in Azure DevOps

# This script demonstrates using PipelinesUtils in an Azure DevOps Pipeline

# Import the module
Import-Module PipelinesUtils

# Section: Build
Write-PipelineSection -Text "Build Phase" -Boxed

Write-PipelineGroupStart "Restore Dependencies"
Write-PipelineCommand "Restoring NuGet packages..."
# ... restore commands ...
Write-PipelineGroupEnd

Write-PipelineGroupStart "Compile"
Write-PipelineCommand "Compiling solution..."
Write-PipelineProgress -PercentComplete 25 -Activity "Compilation"
# ... compile commands ...
Write-PipelineProgress -PercentComplete 100 -Activity "Compilation"
Write-PipelineGroupEnd

# Set variables
Set-PipelineVariable -Name "BuildVersion" -Value "1.0.42"
Set-PipelineVariable -Name "CommitHash" -Value $env:BUILD_SOURCEVERSION -Output

# Add tags
Add-PipelineBuildTag -Tag "automated"
Add-PipelineBuildTag -Tag "release-candidate"

# Section: Test
Write-PipelineSection -Text "Test Phase" -Boxed

Write-PipelineGroupStart "Unit Tests"
Write-PipelineTaskProgress -CurrentOperation "Running unit tests" -PercentComplete 50
# ... test commands ...

# Example: Report a warning
Write-PipelineWarning -Message "Test coverage is below 80%" -SourcePath "tests/coverage.xml" -LineNumber 1

Write-PipelineGroupEnd

# Section: Summary
$summary = @"
## Build Summary

### Results
- Build Version: 1.0.42
- Tests Passed: 42/42
- Code Coverage: 75%
- Build Status: ✅ Success

### Artifacts
- Binary: MyApp.dll
- Package: MyApp.nupkg
"@

Add-PipelineSummary -Content $summary

# Set build number
Set-PipelineBuildNumber -BuildNumber "1.0.42-$(Get-Date -Format 'yyyyMMdd')"

# Mark sensitive data
$apiKey = "secret-api-key-12345"
Set-PipelineSecretValue -Value $apiKey

# Complete the task
Complete-PipelineTask -Status 'Succeeded'
