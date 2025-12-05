function Write-PipelineTaskProgress {
    <#
    .SYNOPSIS
    Updates the progress of the current pipeline task/step.
    
    .DESCRIPTION
    This function updates the progress indicator for the current task using the appropriate
    logging commands for the detected pipeline environment.
    
    .PARAMETER CurrentOperation
    The current operation being performed.
    
    .PARAMETER PercentComplete
    The percentage of completion (0-100).
    
    .EXAMPLE
    Write-PipelineTaskProgress -CurrentOperation "Installing dependencies" -PercentComplete 25
    
    .EXAMPLE
    Write-PipelineTaskProgress -CurrentOperation "Running tests" -PercentComplete 75
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$CurrentOperation,
        
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 100)]
        [int]$PercentComplete
    )
    
    $pipelineType = Get-PipelineType
    
    switch ($pipelineType) {
        ([PipelineType]::AzureDevOps) {
            if ($PSBoundParameters.ContainsKey('PercentComplete')) {
                Write-Output "##vso[task.setprogress value=$PercentComplete;]$CurrentOperation"
            }
            else {
                Write-Output "##vso[task.setprogress value=0;]$CurrentOperation"
            }
        }
        ([PipelineType]::GitHubActions) {
            # GitHub Actions doesn't have native task progress, use notice
            $message = $CurrentOperation
            if ($PSBoundParameters.ContainsKey('PercentComplete')) {
                $message += " - $PercentComplete% complete"
            }
            Write-Output "::notice::$message"
        }
        default {
            Write-Host "$CurrentOperation" -ForegroundColor Cyan
        }
    }
}
