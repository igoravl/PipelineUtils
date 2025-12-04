<#
.SYNOPSIS
Writes a progress message in CI/CD pipelines.

.DESCRIPTION
This function writes a progress message using the appropriate logging commands for the detected pipeline.
It can be used to show progress status during pipeline execution, including 
percentage completion values.

.PARAMETER PercentComplete
The percentage of completion (0-100) for the current operation.

.PARAMETER Activity
The name of the activity for which progress is being reported.

.PARAMETER Status
The current status message for the activity.

.PARAMETER Id
A unique identifier for the progress bar. Useful when tracking multiple 
concurrent operations.

.EXAMPLE
Write-PipelineProgress -PercentComplete 50 -Activity "Deployment" -Status "Installing components"
# Reports 50% completion for the "Deployment" activity

.EXAMPLE
Write-PipelineProgress -PercentComplete 75 -Activity "Build" -Status "Compiling sources" -Id 1
# Reports 75% completion for the "Build" activity with ID 1
#>
function Write-PipelineProgress {
    [CmdletBinding()]
    param(
        # The percentage of completion (0-100)
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateRange(0, 100)]
        [int]$PercentComplete,

        # The name of the activity for which progress is being reported
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Activity
    )

    $pipelineType = Get-PipelineType
    
    switch ($pipelineType) {
        ([PipelineType]::AzureDevOps) {
            Write-Output "##vso[task.setprogress value=$PercentComplete;]$Activity - $PercentComplete%"
        }
        ([PipelineType]::GitHubActions) {
            # GitHub Actions doesn't have native progress bars, use notice
            Write-Output "::notice::$Activity - $PercentComplete% complete"
        }
        default {
            # If not in a pipeline, use standard PowerShell Write-Progress
            Write-Progress -Activity $Activity -PercentComplete $PercentComplete
        }
    }
}