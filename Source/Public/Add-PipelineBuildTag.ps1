function Add-PipelineBuildTag {
    <#
    .SYNOPSIS
    Adds a tag to the current pipeline build/run.
    
    .DESCRIPTION
    This function adds a tag to the current build in Azure DevOps. GitHub Actions does not
    support adding build/run tags via workflow commands; in that environment the function
    emits a warning and returns.
    
    .PARAMETER Tag
    The tag to add to the build.
    
    .EXAMPLE
    Add-PipelineBuildTag -Tag "release"
    
    .EXAMPLE
    Add-PipelineBuildTag -Tag "hotfix"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Tag
    )
    
    $pipelineType = Get-PipelineType
    
    switch ($pipelineType) {
        ([PipelineType]::AzureDevOps) {
            Write-Output "##vso[build.addbuildtag]$Tag"
        }
        ([PipelineType]::GitHubActions) {
            Write-Warning "Add-PipelineBuildTag is only supported in Azure DevOps pipelines."
            return
        }
        default {
            Write-Output "Build tag: $Tag"
        }
    }
}
