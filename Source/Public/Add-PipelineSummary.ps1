<#
.SYNOPSIS
Adds a Markdown summary to CI/CD pipelines.

.DESCRIPTION
This function adds a Markdown formatted summary to the pipeline run using Azure DevOps or GitHub Actions logging commands.
Summaries appear in the pipeline run details and help provide additional information or context about the build.

.PARAMETER Content
The Markdown content to add as a summary.

.PARAMETER Path
Path to a Markdown file whose content will be added as a summary.

.EXAMPLE
Add-PipelineSummary -Content "## Build Completed Successfully"
# Adds a simple header as a summary to the pipeline

.EXAMPLE
Add-PipelineSummary -Path ".\build-report.md"
# Adds the content of build-report.md file as a summary to the pipeline

.EXAMPLE
"## Test Results: Passed" | Add-PipelineSummary
# Adds summary from pipeline input
#>
function Add-PipelineSummary {
    [CmdletBinding(DefaultParameterSetName = 'Content')]
    param(
        # The Markdown content to add as a summary
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Content', ValueFromPipeline = $true)]
        [string]$Content,

        # Path to a Markdown file whose content will be added as a summary
        [Parameter(Mandatory = $true, ParameterSetName = 'Path')]
        [string]$Path
    )

    Process {
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            if (-not (Test-Path -Path $Path)) {
                throw "The specified path '$Path' does not exist."
            }
            $summaryPath = $Path
        }
        else {
            # Write the content to a temporary file
            $summaryPath = [System.IO.Path]::GetTempFileName() + ".md"
            Set-Content -Path $summaryPath -Value $Content -Encoding UTF8
        }

        $pipelineType = Get-PipelineType
        
        switch ($pipelineType) {
            ([PipelineType]::AzureDevOps) {
                Write-Host "##vso[task.uploadsummary]$summaryPath"
            }
            ([PipelineType]::GitHubActions) {
                # Append to the GitHub Actions step summary
                Get-Content -Path $summaryPath | Add-Content -Path $env:GITHUB_STEP_SUMMARY
            }
            default {
                Get-Content -Path $summaryPath | Write-Host
            }
        }
    }
}