# Import module before any Pester blocks to ensure it's available during discovery phase
Import-Module "$PSScriptRoot\..\Build\PipelineUtils\PipelineUtils.psd1" -Force

InModuleScope -ModuleName 'PipelineUtils' {
    BeforeAll {
        . $PSScriptRoot/_HelperFunctions.ps1
    }

    Describe 'Test-PipelineContext' {
        It 'returns false when not in a pipeline context' {
            _ClearEnvironment
            $result = Test-PipelineContext
            $result | Should -Be $false
        }
        
        It 'returns true when in Azure DevOps context' {
            _SetAzureDevOpsEnvironment
            $result = Test-PipelineContext
            $result | Should -Be $true
            _ClearEnvironment
        }
        
        It 'returns true when in GitHub Actions context' {
            _SetGitHubActionsEnvironment
            $result = Test-PipelineContext
            $result | Should -Be $true
            _ClearEnvironment
        }
    }
}
