<#
.SYNOPSIS
Sets the build/run number in CI/CD pipelines.

.DESCRIPTION
This function sets the build number in Azure DevOps. GitHub Actions does not support
changing the run name during execution; in that environment the function emits a warning.

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
            Write-Warning "Set-PipelineBuildNumber is only supported in Azure DevOps pipelines."
            return
        }
        default {
            Write-Output "Build number: $BuildNumber"
        }
    }
}