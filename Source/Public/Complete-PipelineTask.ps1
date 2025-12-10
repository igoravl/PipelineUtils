<#
.SYNOPSIS
    Completes the pipeline task with the specified status.
.DESCRIPTION
    This function emits the appropriate logging command to mark the current task as complete in Azure DevOps Pipelines.
.NOTES
    A task may have one of the three following outcomes: Succeeded, SucceededWithIssues, Failed.
    The cmdlets Write-PipelineError and Write-PipelineWarning automatically set the task status to Failed and SucceededWithIssues (respectively) when the UpdateTaskStatus argument is specified.
#>
Function Complete-PipelineTask {
    Param(
        # The status to set for the completed task. Defaults to 'Succeeded', unless the cmdlets Write-PipelineError or Write-PipelineWarning have set a different status (via the UpdateTaskStatus argument), in which case that status is used.
        [Parameter()]
        [string] $Status = 'Succeeded'
    )

    $pipelineType = Get-PipelineType
    
    if($pipelineType -ne [PipelineType]::AzureDevOps) {
        Write-Warning "Complete-PipelineTask is only supported in Azure DevOps pipelines."
        return
    }

    if($Status -eq 'Succeeded' -and ($Global:_task_status -ne 'Succeeded')) {
        $Status = $Global:_task_status
    }

    if ($Status -ne 'Succeeded') {
        Write-Host "##vso[task.complete result=$Status;]"
    }
}
