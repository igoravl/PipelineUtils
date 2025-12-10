<#
.SYNOPSIS
Writes a command message to the Azure Pipelines log.

.DESCRIPTION
The Write-PipelineCommand function outputs a command message to the Azure Pipelines log using the appropriate logging command. This helps in troubleshooting and provides additional context during pipeline execution.

.EXAMPLE
Write-PipelineCommand -Message "This is a command message."
Writes the specified command message to the Azure Pipelines log.
#>
Function Write-PipelineCommand {
    Param (
        # Specifies the command message to write to the Azure Pipelines log.
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Message
    )
    
    Write-PipelineLog -Message $Message -LogType 'Command'
}