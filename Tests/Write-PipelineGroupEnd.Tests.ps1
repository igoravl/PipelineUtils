# Import module before any Pester blocks to ensure it's available during discovery phase
Import-Module "$PSScriptRoot\..\Build\PipelineUtils\PipelineUtils.psd1" -Force

Describe 'Write-PipelineGroupEnd' {
    Context 'Azure DevOps' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetAzureDevOpsEnvironment
        }
        
        It 'ends group with Azure DevOps format' {
            $output = Write-PipelineGroupEnd 6>&1
            $output | Should -Be '##[endgroup]'
        }
    }
    
    Context 'GitHub Actions' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetGitHubActionsEnvironment
        }
        
        It 'ends group with GitHub Actions format' {
            $output = Write-PipelineGroupEnd 6>&1
            $output | Should -Be '::endgroup::'
        }
    }
    
    Context 'Console' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _ClearEnvironment
        }
        
        It 'displays group end in console' {
            $output = Write-PipelineGroupEnd 6>&1
            $output | Should -BeLike '*'
        }
    }
}
