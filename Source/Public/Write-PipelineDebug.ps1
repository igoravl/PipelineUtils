<#
.SYNOPSIS
Writes a debug message to the Azure Pipelines log.

.DESCRIPTION
The Write-PipelineDebug function outputs a debug message to the Azure Pipelines log using the appropriate logging command. This helps in troubleshooting and provides additional context during pipeline execution.

.EXAMPLE
Write-PipelineDebug -Message "This is a debug message."
Writes the specified debug message to the Azure Pipelines log.

.NOTES
Requires execution within an Azure Pipelines environment to have effect.
#>
Function Write-PipelineDebug {
    Param (
        # Specifies the debug message to write to the Azure Pipelines log.
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Message
    )

    Write-PipelineLog -Message $Message -LogType Debug
}

# Set-Alias -Name 'Write-Debug' -Value 'Write-PipelineDebug' -Force -Scope Global