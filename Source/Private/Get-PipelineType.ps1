# Private helper function to get the current pipeline type
function Get-PipelineType {
    <#
    .SYNOPSIS
    Determines the type of pipeline environment the code is running in.
    
    .DESCRIPTION
    This private function checks for environment variables specific to Azure DevOps
    and GitHub Actions to determine the pipeline type.
    
    .OUTPUTS
    [PipelineType] Returns the detected pipeline type (Unknown, AzureDevOps, or GitHubActions).
    #>
    [CmdletBinding()]
    [OutputType([PipelineType])]
    param()
    
    # Check for Azure DevOps environment variables
    $azureDevOpsVariables = @('TF_BUILD', 'AGENT_ID', 'BUILD_BUILDID')
    
    foreach ($variable in $azureDevOpsVariables) {
        if (Get-Item -Path "Env:$variable" -ErrorAction SilentlyContinue) {
            return [PipelineType]::AzureDevOps
        }
    }
    
    # Check for GitHub Actions environment variables
    $gitHubActionsVariables = @('GITHUB_ACTIONS', 'GITHUB_WORKFLOW', 'GITHUB_RUN_ID')
    
    foreach ($variable in $gitHubActionsVariables) {
        if (Get-Item -Path "Env:$variable" -ErrorAction SilentlyContinue) {
            return [PipelineType]::GitHubActions
        }
    }
    
    return [PipelineType]::Unknown
}
