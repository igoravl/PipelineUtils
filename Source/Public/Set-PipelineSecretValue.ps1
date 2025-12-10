<#
.SYNOPSIS
Marks a value as secret in CI/CD pipelines.

.DESCRIPTION
This function marks a value as secret using Azure DevOps or GitHub Actions logging commands.
Secret values are masked in the pipeline logs to prevent sensitive information from being exposed.

.PARAMETER Value
The value to be marked as secret in the pipeline logs.

.EXAMPLE
Set-PipelineSecretValue -Value "myPassword123"
# Marks "myPassword123" as a secret that will be masked in pipeline logs

.EXAMPLE
$apiKey = "abcd1234efgh5678"
Set-PipelineSecretValue -Value $apiKey
# Marks the API key as a secret that will be masked in pipeline logs
#>
function Set-PipelineSecretValue {
    [CmdletBinding()]
    param(
        # The value to be marked as secret in the pipeline logs
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Value
    )

    $pipelineType = Get-PipelineType
    
    switch ($pipelineType) {
        ([PipelineType]::AzureDevOps) {
            Write-Output "##vso[task.setsecret]$Value"
        }
        ([PipelineType]::GitHubActions) {
            Write-Output "::add-mask::$Value"
        }
        default {
            Write-Output "Secret value has been masked in logs: ********"
        }
    }
}