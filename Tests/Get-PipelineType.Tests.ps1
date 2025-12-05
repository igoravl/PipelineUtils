# Import module before any Pester blocks to ensure it's available during discovery phase
Import-Module "$PSScriptRoot\..\Build\PipelineUtils\PipelineUtils.psd1" -Force

InModuleScope -ModuleName 'PipelineUtils' {
    BeforeAll {
        . $PSScriptRoot/_HelperFunctions.ps1
    }

    Describe 'Get-PipelineType' {
        It 'returns Unknown when not in a pipeline' {
            _ClearEnvironment
            $result = Get-PipelineType
            $result | Should -Be ([PipelineType]::Unknown)
        }
        
        It 'returns AzureDevOps when in Azure DevOps context' {
            _SetAzureDevOpsEnvironment
            $result = Get-PipelineType
            $result | Should -Be ([PipelineType]::AzureDevOps)
        }
        
        It 'returns GitHubActions when in GitHub Actions context' {
            _SetGitHubActionsEnvironment
            $result = Get-PipelineType
            $result | Should -Be ([PipelineType]::GitHubActions)
        }
    }
}
