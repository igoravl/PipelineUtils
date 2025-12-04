Function Complete-PipelineTask {
    Param(
        [Parameter()]
        [string] $Status = 'Succeeded'
    )

    $pipelineType = Get-PipelineType
    
    if($pipelineType -eq [PipelineType]::Unknown) {
        return
    }

    if($Status -eq 'Succeeded' -and ($Global:_task_status -ne 'Succeeded')) {
        $Status = $Global:_task_status
    }

    if ($Status -ne 'Succeeded') {
        switch ($pipelineType) {
            ([PipelineType]::AzureDevOps) {
                Write-Host "##vso[task.complete result=$Status;]"
            }
            ([PipelineType]::GitHubActions) {
                # GitHub Actions uses exit codes to signal failure
                if ($Status -eq 'Failed') {
                    Write-Host "::error::Task completed with status: $Status"
                    exit 1
                }
                else {
                    Write-Host "::warning::Task completed with status: $Status"
                }
            }
        }
    }
}
