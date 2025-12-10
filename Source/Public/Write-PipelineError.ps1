function Write-PipelineError {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [string]$SourcePath,
        
        [Parameter(Mandatory = $false)]
        [int]$LineNumber,

        [Parameter()]
        [int]$ColumnNumber,

        [Parameter()]
        [Alias('Code')]
        [string]$IssueCode,

        [Parameter()]
        [switch] $DoNotUpdateJobStatus
    )
    
    Write-PipelineLog -Message $Message -LogType 'Error' -SourcePath $SourcePath -LineNumber $LineNumber -ColumnNumber $ColumnNumber -IssueCode $IssueCode -DoNotUpdateJobStatus:$DoNotUpdateJobStatus
}

# Alias
# Set-Alias -Name 'Write-Error' -Value 'Write-PipelineError' -Force -Scope Global
