Function Complete-PipelineTask {
    Param(
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
