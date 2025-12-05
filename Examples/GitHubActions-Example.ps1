# Example usage of PipelineUtils in GitHub Actions

# This script demonstrates using PipelineUtils in a GitHub Actions workflow

# Import the module
Import-Module PipelineUtils

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

# Set environment variables (will be available in subsequent steps)
Set-PipelineVariable -Name "BUILD_VERSION" -Value "1.0.42"

# Set output variables (will be available in subsequent jobs)
Set-PipelineVariable -Name "commit_hash" -Value $env:GITHUB_SHA -Output
Set-PipelineVariable -Name "build_status" -Value "success" -Output

# Add tags (GitHub Actions doesn't have direct tags, but this creates a notice and output)
Add-PipelineBuildTag -Tag "automated"
Add-PipelineBuildTag -Tag "release-candidate"

# Section: Test
Write-PipelineSection -Text "Test Phase" -Boxed

Write-PipelineGroupStart "Unit Tests"
Write-PipelineTaskProgress -CurrentOperation "Running unit tests" -PercentComplete 50
# ... test commands ...

# Example: Report a warning with file annotation
Write-PipelineWarning -Message "Test coverage is below 80%" -SourcePath "tests/coverage.xml" -LineNumber 1

Write-PipelineGroupEnd

# Section: Summary (will appear in the GitHub Actions job summary)
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

### Commit
- SHA: $env:GITHUB_SHA
- Author: $env:GITHUB_ACTOR
- Ref: $env:GITHUB_REF
"@

Add-PipelineSummary -Content $summary

# Set build number (creates a notice and environment variable)
Set-PipelineBuildNumber -BuildNumber "1.0.42-$(Get-Date -Format 'yyyyMMdd')"

# Mask sensitive data in logs
$apiKey = "secret-api-key-12345"
Set-PipelineSecretValue -Value $apiKey

# Add a directory to PATH
Add-PipelinePath -Path "$env:GITHUB_WORKSPACE\tools\bin"

# Debug information
Write-PipelineDebug "Workflow: $env:GITHUB_WORKFLOW"
Write-PipelineDebug "Run ID: $env:GITHUB_RUN_ID"
Write-PipelineDebug "Run Number: $env:GITHUB_RUN_NUMBER"

# Complete the task (on failure, this would exit with code 1)
Complete-PipelineTask -Status 'Succeeded'
