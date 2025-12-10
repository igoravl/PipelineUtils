Function Write-PipelineGroupStart($Text) {
    $pipelineType = Get-PipelineType
    
    switch ($pipelineType) {
        ([PipelineType]::AzureDevOps) {
            Write-Host "##[group]$Text"
        }
        ([PipelineType]::GitHubActions) {
            Write-Host "::group::$Text"
        }
        default {
            Write-Host "$Text" -ForegroundColor Cyan
        }
    }
}
