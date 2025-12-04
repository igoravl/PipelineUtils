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
            $properties = ''

            if ($Secret) {
                $properties += ";issecret=true"
            }
            if ($Output) {
                $properties += ";isoutput=true"
            }
            if ($ReadOnly) {
                $properties += ";isreadonly=true"
            }

            Write-Output "##vso[task.setvariable variable=$Name$properties]$Value"
        }
        ([PipelineType]::GitHubActions) {
            if ($Output) {
                # For outputs, write to GITHUB_OUTPUT
                if ($env:GITHUB_OUTPUT) {
                    Add-Content -Path $env:GITHUB_OUTPUT -Value "$Name=$Value"
                }
                else {
                    Write-Warning "GITHUB_OUTPUT environment variable not found. Cannot set output variable."
                }
            }
            else {
                # For environment variables, write to GITHUB_ENV
                if ($env:GITHUB_ENV) {
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
                else {
                    Write-Warning "GITHUB_ENV environment variable not found. Cannot set environment variable."
                }
            }
            
            # Note: GitHub Actions handles secrets differently - they must be defined in repository/organization settings
            if ($Secret) {
                Write-Warning "Secret flag is not applicable in GitHub Actions. Secrets must be configured in repository settings."
            }
            if ($ReadOnly) {
                Write-Warning "ReadOnly flag is not applicable in GitHub Actions."
            }
        }
        default {
            Write-Warning "Not running in a supported pipeline environment. Variable '$Name' was not set."
        }
    }
}
