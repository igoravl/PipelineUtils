# Import module before any Pester blocks to ensure it's available during discovery phase
Import-Module "$PSScriptRoot\..\Build\PipelineUtils\PipelineUtils.psd1" -Force

Describe 'Write-PipelineGroupStart' {
    Context 'Azure DevOps' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetAzureDevOpsEnvironment
        }
        
        It 'starts group with Azure DevOps format' {
            $output = Write-PipelineGroupStart 'Test Group' 6>&1
            $output | Should -BeLike '##?group?*'
            $output | Should -BeLike '*Test Group*'
        }
    }
    
    Context 'GitHub Actions' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetGitHubActionsEnvironment
        }
        
        It 'starts group with GitHub Actions format' {
            $output = Write-PipelineGroupStart 'Test Group' 6>&1
            $output | Should -BeLike '::group::*'
            $output | Should -BeLike '*Test Group*'
        }
    }
    
    Context 'Console' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _ClearEnvironment
        }
        
        It 'displays group start in console' {
            $output = Write-PipelineGroupStart 'Test Group' 6>&1
            $output | Should -BeLike '*Test Group*'
        }
    }
}
