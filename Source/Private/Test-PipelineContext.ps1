# Private helper function to validate pipeline context
function Test-PipelineContext {
    <#
    .SYNOPSIS
    Tests if the current session is running in a CI/CD pipeline (Azure DevOps or GitHub Actions).
    
    .DESCRIPTION
    This private function checks for the presence of environment variables specific to
    Azure DevOps or GitHub Actions to determine if the code is running within a pipeline context.
    
    .OUTPUTS
    [bool] Returns $true if running in a supported pipeline, $false otherwise.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    
    $pipelineType = Get-PipelineType
    return ($pipelineType -ne [PipelineType]::Unknown)
}
