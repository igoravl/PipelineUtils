# Import module before any Pester blocks to ensure it's available during discovery phase
Import-Module "$PSScriptRoot\..\Build\PipelineUtils\PipelineUtils.psd1" -Force

Describe 'Write-PipelineError' {
    Context 'Azure DevOps' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetAzureDevOpsEnvironment
        }
        
        It 'writes an error with Azure DevOps format' {
            $output = Write-PipelineError -Message 'Test error' 6>&1
            $output | Should -Be '##vso[task.logissue type=error;]Test error'
        }
        
        It 'includes source path when provided' {
            $output = Write-PipelineError -Message 'Test error' -SourcePath 'test.ps1' 6>&1
            $output | Should -Be '##vso[task.logissue type=error;sourcepath=test.ps1;]Test error'
        }
    }
    
    Context 'GitHub Actions' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetGitHubActionsEnvironment
        }
        
        It 'writes an error with GitHub Actions format' {
            $output = Write-PipelineError -Message 'Test error' 6>&1
            $output | Should -Be '::error::Test error'
        }
        
        It 'includes file annotation when provided' {
            $output = Write-PipelineError -Message 'Test error' -SourcePath 'test.ps1' -LineNumber 10 -IssueCode 'ERR001' 6>&1
            $output | Should -Be '::error file=test.ps1,line=10,title=ERR001::Test error'
        }
    }
    
    Context 'Console' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _ClearEnvironment
        }
        
        It 'writes an error to console' {
            $output = Write-PipelineError -Message 'Test error' 6>&1
            $output | Should -BeLike '*Test error*'
        }
    }
}
