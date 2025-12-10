Function Write-PipelineGroupEnd() {
    $pipelineType = Get-PipelineType
    
    switch ($pipelineType) {
        ([PipelineType]::AzureDevOps) {
            Write-Host "##[endgroup]"
        }
        ([PipelineType]::GitHubActions) {
            Write-Host "::endgroup::"
        }
        default {
            # No special handling needed for non-pipeline environments
        }
    }
}

