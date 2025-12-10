<#
.SYNOPSIS
    Writes a log message to the pipeline log or console.

.DESCRIPTION
    This advanced function logs messages of type Warning, Error, Info, or Debug to Azure Pipelines, GitHub Actions, or the console. It supports additional metadata such as source file, line, column, and issue code, and can optionally prevent updating the job status. The function is intended for use in CI/CD scenarios to provide rich, contextual logging.

.EXAMPLE
    Write-PipelineLog -Message "An error occurred." -LogType Error
    # Logs an error message to the pipeline log.

.EXAMPLE
    Write-PipelineLog -Message "File not found." -LogType Warning -SourcePath "src/app.ps1" -LineNumber 42
    # Logs a warning message with source file and line number metadata.

.EXAMPLE
    Write-PipelineLog -Message "Debugging info." -LogType Debug -DoNotUpdateJobStatus
    # Logs a debug message and does not update the job status.

.NOTES
    Author: igoravl
    Date: August 29, 2025
    This function is intended for use in CI/CD pipelines and supports rich logging features for automation.
#>
function Write-PipelineLog {
    [CmdletBinding()]
    param(
        # The message to log in the pipeline.
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message,

        # The type of log message (Warning, Error, Info, Debug).
        [Parameter(Mandatory = $true)]
        [ValidateSet("Warning", "Error", "Info", "Debug", "Command")]
        [string]$LogType,

        # The source file path related to the log message (optional).
        [Parameter()]
        [string]$SourcePath,
        
        # The line number in the source file where the log message applies (optional).
        [Parameter()]
        [int]$LineNumber,

        # The ending line number in the source file where the log message applies (optional). Appplies only to GitHub Actions.
        [Parameter()]
        [int]$EndLineNumber,

        # The column number in the source file where the log message applies (optional).
        [Parameter()]
        [int]$ColumnNumber,

        # The ending line number in the source file where the log message applies (optional). Appplies only to GitHub Actions.
        [Parameter()]
        [int]$EndColumnNumber,

        # The issue code associated with the log message (optional).
        [Parameter()]
        [Alias('Code')]
        [string]$IssueCode,

        # The issue code associated with the log message (optional). Applies only to GitHub Actions.
        [Parameter()]
        [Alias('Title')]
        [string]$IssueTitle,

        # If set, does not update the job status (optional).
        [Parameter()]
        [switch] $DoNotUpdateJobStatus
    )

    $LogType = $LogType.ToLower()
    $pipelineType = Get-PipelineType
    $color = 'White'

    switch ($pipelineType) {
        ([PipelineType]::AzureDevOps) {
            switch ($LogType) {
                'error'   { $prefix = '##vso[task.logissue type=error'; $suffix = ';]'; $useVso = $true }
                'warning' { $prefix = '##vso[task.logissue type=warning'; $suffix = ';]'; $useVso = $true }
                'debug'   { $prefix = '##[debug]'; $suffix = '' }
                'command' { $prefix = '##[command]'; $suffix = '' }
                'info'    { $prefix = ''; $suffix = '' } # no official info command
            }
        }
        ([PipelineType]::GitHubActions) {
            switch ($LogType) {
                'error'   { $prefix = '::error'; $suffix = '::'; $ghaSupportsProps = $true }
                'warning' { $prefix = '::warning'; $suffix = '::'; $ghaSupportsProps = $true }
                'debug'   { $prefix = '::debug::'; $suffix = '' }
                'command' { $prefix = '##[command]'; $suffix = '' }
                'info'    { $prefix = '::notice'; $suffix = '::'; $ghaSupportsProps = $true }
            }
        }
        else {
            switch ($LogType) {
                'error'   { $color = 'Red' }
                'warning' { $color = 'Yellow' }
                'info'    { $color = 'LightGray' }
                'debug'   { $color = 'DarkGray' }
                'command' { $color = 'Cyan' }
            }
        }
    }

    $isIssue = ($LogType -eq 'error' -or $LogType -eq 'warning')

    if ((-not $DoNotUpdateJobStatus.IsPresent) -and $isIssue) {
        $global:_task_status = 'SucceededWithIssues'
    }

    if ($pipelineType -eq [PipelineType]::AzureDevOps -and $useVso) {
        $properties = ''
        if ($SourcePath) { $properties += ";sourcepath=$SourcePath" }
        if ($LineNumber) { $properties += ";linenumber=$LineNumber" }
        if ($ColumnNumber) { $properties += ";columnnumber=$ColumnNumber" }
        if ($IssueCode) { $properties += ";code=$IssueCode" }

        Write-Host "${prefix}${properties}${suffix}$Message"
        return
    }

    if ($pipelineType -eq [PipelineType]::GitHubActions -and $ghaSupportsProps) {
        # GitHub Actions supports properties only for error/warning/notice
        $props = [System.Collections.Generic.List[string]]::new()
        if ($SourcePath) { $props.Add("file=$SourcePath") }
        if ($LineNumber) { $props.Add("line=$LineNumber") }
        if ($EndLineNumber) { $props.Add("endLine=$EndLineNumber") }
        if ($ColumnNumber) { $props.Add("col=$ColumnNumber") }
        if ($EndColumnNumber) { $props.Add("endColumn=$EndColumnNumber") }
        if ($IssueTitle) { $props.Add("title=$IssueTitle$(if ($IssueCode) { " (code $IssueCode)" })") }
        elseif ($IssueCode) { $props.Add("title=$IssueCode") }
        $properties = if ($props.Count -gt 0) { " $($props -join ',')" } else { '' }

        Write-Host "${prefix}${properties}${suffix}$Message"
        return
    }

    Write-Host "${prefix}${Message}${suffix}" -ForegroundColor $color
}
