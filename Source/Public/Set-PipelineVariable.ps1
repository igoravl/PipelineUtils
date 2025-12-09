function Set-PipelineVariable {
    <#
    .SYNOPSIS
    Sets a variable in CI/CD pipelines (Azure DevOps or GitHub Actions).
    
    .DESCRIPTION
    This function sets a pipeline variable using the appropriate syntax for the detected pipeline environment.
    For Azure DevOps, it uses logging commands. For GitHub Actions, it writes to $env:GITHUB_ENV.
    The variable can be used in subsequent tasks and jobs.
    
    .PARAMETER Name
    The name of the variable to set.
    
    .PARAMETER Value
    The value to assign to the variable.
    
    .PARAMETER Secret
    Indicates whether the variable should be treated as a secret. (Azure DevOps only)
    
    .PARAMETER Output
    Indicates whether the variable should be available to subsequent jobs or steps.
    For GitHub Actions, writes to $env:GITHUB_OUTPUT instead of $env:GITHUB_ENV.
    
    .EXAMPLE
    Set-PipelineVariable -Name "BuildNumber" -Value "1.0.42"
    
    .EXAMPLE
    Set-PipelineVariable -Name "ApiKey" -Value "secret123" -Secret
    
    .EXAMPLE
    Set-PipelineVariable -Name "DeploymentTarget" -Value "Production" -Output
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [Parameter(Mandatory = $true)]
        [string]$Value,
        
        [Parameter(Mandatory = $false)]
        [switch]$Secret,
        
        [Parameter(Mandatory = $false)]
        [switch]$Output,
        
        [Parameter(Mandatory = $false)]
        [switch]$ReadOnly
    )
    
    $pipelineType = Get-PipelineType
    
    switch ($pipelineType) {
        ([PipelineType]::AzureDevOps) {
            $propList = @()

            if ($Secret) { $propList += 'issecret=true' }
            if ($Output) { $propList += 'isoutput=true' }
            if ($ReadOnly) { $propList += 'isreadonly=true' }

            $properties = if ($propList.Count -gt 0) { ';' + ($propList -join ';') + ';' } else { ';' }

            Write-Output "##vso[task.setvariable variable=$Name$properties]$Value"
        }
        ([PipelineType]::GitHubActions) {
            if ($Output) {
                # For outputs, write to GITHUB_OUTPUT
                Add-Content -Path $env:GITHUB_OUTPUT -Value "$Name=$Value"
            }
            else {
                # For environment variables, write to GITHUB_ENV
                # Support multiline values using delimiter
                if ($Value -match '\r?\n') {
                    $delimiter = "EOF_$(Get-Random)"
                    Add-Content -Path $env:GITHUB_ENV -Value "$Name<<$delimiter"
                    Add-Content -Path $env:GITHUB_ENV -Value $Value
                    Add-Content -Path $env:GITHUB_ENV -Value $delimiter
                }
                else {
                    Add-Content -Path $env:GITHUB_ENV -Value "$Name=$Value"
                }
            }
            
            # Note: GitHub Actions handles secrets differently - they must be defined in repository/organization settings
            if ($Secret) {
                Write-PipelineWarning -Message "Secret flag is not applicable in GitHub Actions. Secrets must be configured in repository settings. Value will be masked in logs, though." 
                Set-PipelineSecretValue -Value $Value
            }
            if ($ReadOnly) {
                Write-PipelineWarning -Message "ReadOnly flag is not applicable in GitHub Actions." 
            }
        }
    }

    Set-Item "env:$Name" = $Value
}
