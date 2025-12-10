<#
.SYNOPSIS
    Uploads a file to the current pipeline task log.

.DESCRIPTION
    The Add-PipelineTaskLogFile function uploads a specified file to the Azure DevOps pipeline task log.
    This allows you to attach log files or other output files to be visible in the pipeline run logs.

.PARAMETER Path
    The path to the file to be uploaded. This parameter accepts pipeline input.

.EXAMPLE
    Add-PipelineTaskLogFile -Path ".\build.log"
    
    Uploads build.log to the task logs with its original filename.

.EXAMPLE
    Get-ChildItem -Path ".\logs\*.log" | Add-PipelineTaskLogFile
    
    Uploads all log files from the logs directory to the task logs.

.NOTES
    This function requires to be run within an Azure Pipelines task execution context.
#>
Function Add-PipelineTaskLogFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path
    )

    Begin {
        $pipelineType = Get-PipelineType
        
        if($pipelineType -ne [PipelineType]::AzureDevOps) {
            Write-Warning "Add-PipelineTaskLogFile is only supported in Azure DevOps pipelines."
            return
        }
    }

    Process {
        foreach ($filePath in $Path) {
            # Resolve the path to ensure it's absolute
            $resolvedPath = Resolve-Path -Path $filePath -ErrorAction Stop

            # Execute the Azure Pipelines task command
            Write-Host "##vso[task.uploadfile]$resolvedPath"
        }
    }
}