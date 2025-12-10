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
    
    if($pipelineType -ne [PipelineType]::AzureDevOps) {
        Write-Warning "Set-PipelineReleaseNumber is only supported in Azure DevOps pipelines."
        return
    }
    
    # Check if we're in a Release pipeline (not a Build pipeline)
    if (-not $Env:RELEASE_RELEASEID) {
        Write-Warning "Set-PipelineReleaseNumber is only supported in Azure DevOps Release pipelines. Setting the build number instead."
        Set-PipelineBuildNumber -BuildNumber $ReleaseNumber
        return
    }
    
    Write-Output "##vso[release.updatereleasename]$ReleaseNumber"
}