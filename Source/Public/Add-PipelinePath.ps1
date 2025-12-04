<#
.SYNOPSIS
    Adds a path to the PATH environment variable in CI/CD pipelines.

.DESCRIPTION
    The Add-PipelinePath function adds a specified path to the PATH environment variable
    in Azure DevOps or GitHub Actions. It uses the appropriate command for each platform
    to ensure the path is properly set for subsequent tasks/steps.

.PARAMETER Path
    The path to add to the PATH environment variable.

.EXAMPLE
    Add-PipelinePath -Path "C:\tools\bin"
    
    Adds the "C:\tools\bin" directory to the beginning of the PATH environment variable.

.EXAMPLE
    Add-PipelinePath "$(Build.SourcesDirectory)\tools"

    Adds the tools directory from the source repository to the beginning of the PATH environment variable.
#>
function Add-PipelinePath {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Path
    )
    
    $Path = (Resolve-Path -Path $Path).Path

    if (-not (Test-Path -Path $Path -PathType Container)) {
        Write-Error "The specified path '$Path' does not exist or is not a directory."
        return
    }

    $pipelineType = Get-PipelineType
    
    switch ($pipelineType) {
        ([PipelineType]::AzureDevOps) {
            Write-Host "##vso[task.prependpath]$Path"
        }
        ([PipelineType]::GitHubActions) {
            if ($env:GITHUB_PATH) {
                Add-Content -Path $env:GITHUB_PATH -Value $Path
            }
            else {
                Write-Warning "GITHUB_PATH environment variable not found. Cannot add path to PATH."
            }
        }
        default {
            $env:PATH = "$Path$([System.IO.Path]::PathSeparator)$env:PATH"
        }
    }
}