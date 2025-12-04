function Add-PipelineBuildTag {
    <#
    .SYNOPSIS
    Adds a tag to the current pipeline build/run.
    
    .DESCRIPTION
    This function adds a tag to the current build in Azure DevOps or GitHub Actions.
    Tags can be used to categorize and filter builds/runs.
    Note: In GitHub Actions, this sets an output variable as tags are not directly supported.
    
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
            # GitHub Actions doesn't have direct tag support, but we can use labels via API
            # For now, we'll just output it as a notice
            Write-Output "::notice title=Build Tag::$Tag"
            # Store in output for potential API usage
            if ($env:GITHUB_OUTPUT) {
                Add-Content -Path $env:GITHUB_OUTPUT -Value "build-tag=$Tag"
            }
        }
        default {
            Write-Output "Build tag: $Tag"
        }
    }
}
