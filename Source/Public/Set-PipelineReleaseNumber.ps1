<#
.SYNOPSIS
Sets the release name in CI/CD pipelines.

.DESCRIPTION
This function sets the release name using the appropriate logging commands for the detected pipeline.
The release name can be modified during a release run to provide custom naming.

.EXAMPLE
Set-PipelineReleaseNumber -ReleaseNumber "1.0.42"
# Sets the release name to 1.0.42

.EXAMPLE
Set-PipelineReleaseNumber -ReleaseNumber "$(Get-Date -Format 'yyyy.MM.dd').$env:RELEASE_RELEASEID"
# Sets the release name using a date-based format with the release ID
#>
function Set-PipelineReleaseNumber {
    [CmdletBinding()]
    param(
        # The release number to set for the current release
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$ReleaseNumber
    )

    $pipelineType = Get-PipelineType
    
    switch ($pipelineType) {
        ([PipelineType]::AzureDevOps) {
            Write-Output "##vso[release.updatereleasename]$ReleaseNumber"
        }
        ([PipelineType]::GitHubActions) {
            # GitHub Actions doesn't have classic releases, but we can set as notice and env var
            Write-Output "::notice title=Release Number::$ReleaseNumber"
            if ($env:GITHUB_ENV) {
                Add-Content -Path $env:GITHUB_ENV -Value "RELEASE_NUMBER=$ReleaseNumber"
            }
        }
        default {
            Write-Output "Release name: $ReleaseNumber"
        }
    }
}