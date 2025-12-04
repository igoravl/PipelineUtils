Function Write-PipelineGroupStart($Text) {
    $pipelineType = Get-PipelineType
    
    if (-not [string]::IsNullOrWhiteSpace($Text)) {
        $timestamp = "[$(Get-Date -Format 'HH:mm:ss.fff')] "
    }
    
    switch ($pipelineType) {
        ([PipelineType]::AzureDevOps) {
            Write-Host "##[group]${timestamp}$Text"
        }
        ([PipelineType]::GitHubActions) {
            Write-Host "::group::${timestamp}$Text"
        }
        default {
            Write-Host "${timestamp}$Text" -ForegroundColor Cyan
        }
    }
}
