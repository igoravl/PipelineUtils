# Import module before any Pester blocks to ensure it's available during discovery phase
Import-Module "$PSScriptRoot\..\Build\PipelineUtils\PipelineUtils.psd1" -Force

Describe 'Set-PipelineSecretValue' {
    Context 'Azure DevOps' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetAzureDevOpsEnvironment
        }
        
        It 'masks secret with Azure DevOps format' {
            $output = Set-PipelineSecretValue -Value 'MySecret123' 6>&1
            $output | Should -Be '##vso[task.setsecret]MySecret123'
        }
    }
    
    Context 'GitHub Actions' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetGitHubActionsEnvironment
        }
        
        It 'masks secret with GitHub Actions format' {
            $output = Set-PipelineSecretValue -Value 'MySecret123' 6>&1
            $output | Should -Be '::add-mask::MySecret123'
        }
    }
    
    Context 'Console' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _ClearEnvironment
        }
        
        It 'shows masked message in console' {
            $output = Set-PipelineSecretValue -Value 'MySecret123' 6>&1
            $output | Should -BeLike '*Secret value has been masked*'
            $output | Should -BeLike '*********'
        }
    }
}
