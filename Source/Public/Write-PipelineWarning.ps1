function Write-PipelineWarning {
    <#
    .SYNOPSIS
    Writes a warning message to Azure DevOps Pipelines output.
    
    .DESCRIPTION
    This function writes a warning message using Azure DevOps Pipelines logging commands.
    The message will appear as a warning in the pipeline logs.
    
    .PARAMETER Message
    The warning message to display.
    
    .PARAMETER SourcePath
    Optional source file path where the warning occurred.
    
    .PARAMETER LineNumber
    Optional line number where the warning occurred.
    
    .EXAMPLE
    Write-PipelineWarning -Message "This is a warning"
    
    .EXAMPLE
    Write-PipelineWarning -Message "Deprecated function used" -SourcePath "script.ps1" -LineNumber 42
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message,
        
        [Parameter()]
        [string]$SourcePath,
        
        [Parameter()]
        [int]$LineNumber,

        [Parameter()]
        [int]$ColumnNumber,

        [Parameter()]
        [Alias('Code')]
        [string]$IssueCode,

        [Parameter()]
        [switch] $DoNotUpdateJobStatus
    )
    
    Write-PipelineLog -Message $Message -LogType 'Warning' -SourcePath $SourcePath -LineNumber $LineNumber -ColumnNumber $ColumnNumber -IssueCode $IssueCode -DoNotUpdateJobStatus:$DoNotUpdateJobStatus
}

# Alias
# Set-Alias -Name 'Write-Warning' -Value 'Write-PipelineWarning' -Force -Scope Global