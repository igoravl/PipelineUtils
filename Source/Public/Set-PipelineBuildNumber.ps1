<#
.SYNOPSIS
Sets the build/run number in CI/CD pipelines.

.DESCRIPTION
This function sets the build number in Azure DevOps or the run name in GitHub Actions.
The number/name can be modified during a pipeline run to provide custom versioning.

.PARAMETER BuildNumber
The build number/run name to set for the current pipeline run.

.EXAMPLE
Set-PipelineBuildNumber -BuildNumber "1.0.42"
# Sets the build number to 1.0.42

.EXAMPLE
Set-PipelineBuildNumber -BuildNumber "$(Get-Date -Format 'yyyy.MM.dd').$env:BUILD_BUILDID"
# Sets the build number using a date-based format with the build ID
#>
function Set-PipelineBuildNumber {
    [CmdletBinding()]
    param(
        # The build number to set for the current pipeline
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$BuildNumber
    )

    $pipelineType = Get-PipelineType
    
    switch ($pipelineType) {
        ([PipelineType]::AzureDevOps) {
            Write-Output "##vso[build.updatebuildnumber]$BuildNumber"
        }
        ([PipelineType]::GitHubActions) {
            # GitHub Actions uses workflow_run name
            Write-Output "::notice title=Build Number::$BuildNumber"
            # Also set as environment variable for reference
            if ($env:GITHUB_ENV) {
                Add-Content -Path $env:GITHUB_ENV -Value "BUILD_NUMBER=$BuildNumber"
            }
        }
        default {
            Write-Output "Build number: $BuildNumber"
        }
    }
}