
<#
.SYNOPSIS
Writes a section header to the CI/CD pipeline log output.

.DESCRIPTION
This function emits a formatted section header in the pipeline log, optionally boxed, using the appropriate logging command for the detected pipeline. It is useful for visually grouping related log output in pipeline runs.

.EXAMPLE
Write-PipelineSection -Text "Build started"
Writes a section header labeled "Build started" to the pipeline log.

.EXAMPLE
Write-PipelineSection -Text "Tests" -Boxed
Writes a boxed section header labeled "Tests" to the pipeline log.

.NOTES
Requires execution within a supported CI/CD pipeline environment (Azure DevOps or GitHub Actions).
#>
Function Write-PipelineSection {
    [CmdletBinding()]
    Param (
        # The text to display as the section header in the pipeline log.
        [Parameter(Mandatory = $true)]
        [string]$Text,

        # If specified, draws a box around the section header.
        [Parameter(Mandatory = $false)]
        [switch]$Boxed
    )

    $msg = "== $Text =="
    $box = "`n"
    $pipelineType = Get-PipelineType

    if ($pipelineType -ne [PipelineType]::Unknown) {
        $prefix = '##[section]'
    }

    if ($Boxed) {
        $box += ("${prefix}$('=' * $msg.Length)`n")
    }    

    Write-Host "${box}${prefix}$msg${box}" -ForegroundColor Cyan

    if ($pipelineType -eq [PipelineType]::GitHubActions) {
        Write-Host "" -ForegroundColor Cyan
    }
}
