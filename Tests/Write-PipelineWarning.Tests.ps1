# Import module before any Pester blocks to ensure it's available during discovery phase
Import-Module "$PSScriptRoot\..\Build\PipelineUtils\PipelineUtils.psd1" -Force

Describe 'Write-PipelineWarning' {
    Context 'Azure DevOps' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetAzureDevOpsEnvironment
        }
        
        It 'writes a warning with Azure DevOps format' {
            $output = Write-PipelineWarning -Message 'Test warning' 6>&1
            $output | Should -Be '##vso[task.logissue type=warning;]Test warning'
        }
        
        It 'includes source path when provided' {
            $output = Write-PipelineWarning -Message 'Test warning' -SourcePath 'test.ps1' 6>&1
            $output | Should -Be '##vso[task.logissue type=warning;sourcepath=test.ps1;]Test warning'
        }
        
        It 'includes line number when provided' {
            $output = Write-PipelineWarning -Message 'Test warning' -LineNumber 42 6>&1
            $output | Should -Be '##vso[task.logissue type=warning;linenumber=42;]Test warning'
        }
        
        It 'includes source path and line number when provided' {
            $output = Write-PipelineWarning -Message 'Test warning' -SourcePath 'test.ps1' -LineNumber 42 6>&1
            $output | Should -Be '##vso[task.logissue type=warning;sourcepath=test.ps1;linenumber=42;]Test warning'
        }
    }
    
    Context 'GitHub Actions' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetGitHubActionsEnvironment
        }
        
        It 'writes a warning with GitHub Actions format' {
            $output = Write-PipelineWarning -Message 'Test warning' 6>&1
            $output | Should -Be '::warning::Test warning'
        }
        
        It 'includes file annotation when provided' {
            $output = Write-PipelineWarning -Message 'Test warning' -SourcePath 'test.ps1' -LineNumber 42 6>&1
            $output | Should -Be '::warning file=test.ps1,line=42::Test warning'
        }
    }
    
    Context 'Console' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _ClearEnvironment
        }
        
        It 'writes a warning to console' {
            $output = Write-PipelineWarning -Message 'Test warning' 6>&1
            $output | Should -BeLike '*Test warning*'
        }
    }
}
