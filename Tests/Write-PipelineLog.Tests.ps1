# Import module before any Pester blocks to ensure it's available during discovery phase
Import-Module "$PSScriptRoot\..\Build\PipelineUtils\PipelineUtils.psd1" -Force

InModuleScope -ModuleName 'PipelineUtils' {
    BeforeAll {
        . $PSScriptRoot/_HelperFunctions.ps1
    }

    Describe 'Write-PipelineLog (Private Function)' {
        Context 'Azure DevOps - Extended Metadata' {
            BeforeAll {
                _SetAzureDevOpsEnvironment
            }
        
            It 'includes column number for errors' {
                $output = Write-PipelineLog -Message 'Test error' -LogType Error -SourcePath 'test.ps1' -LineNumber 10 -ColumnNumber 5 6>&1
                $output | Should -Be '##vso[task.logissue type=error;sourcepath=test.ps1;linenumber=10;columnnumber=5;]Test error'
            }
        
            It 'includes issue code for errors' {
                $output = Write-PipelineLog -Message 'Test error' -LogType Error -IssueCode 'ERR001' 6>&1
                $output | Should -Be '##vso[task.logissue type=error;code=ERR001;]Test error'
            }
        
            It 'includes all metadata parameters for warnings' {
                $output = Write-PipelineLog -Message 'Test warning' -LogType Warning -SourcePath 'test.ps1' -LineNumber 10 -ColumnNumber 5 -IssueCode 'WARN001' 6>&1
                $output | Should -Be '##vso[task.logissue type=warning;sourcepath=test.ps1;linenumber=10;columnnumber=5;code=WARN001;]Test warning'
            }
        
            It 'writes info messages with correct format' {
                $output = Write-PipelineLog -Message 'Test info' -LogType Info 6>&1
                $output | Should -Be 'Test info'
            }
        
            It 'writes debug messages with correct format' {
                $output = Write-PipelineLog -Message 'Test debug' -LogType Debug 6>&1
                $output | Should -Be '##[debug]Test debug'
            }
        
            It 'writes command messages with correct format' {
                $output = Write-PipelineLog -Message 'Test command' -LogType Command 6>&1
                $output | Should -Be '##[command]Test command'
            }
        }
    
        Context 'GitHub Actions - Extended Metadata' {
            BeforeAll {
                _SetGitHubActionsEnvironment
            }
        
            It 'includes end line number for errors' {
                $output = Write-PipelineLog -Message 'Test error' -LogType Error -SourcePath 'test.ps1' -LineNumber 10 -EndLineNumber 15 6>&1
                $output | Should -Be '::error file=test.ps1,line=10,endLine=15::Test error'
            }
        
            It 'includes column number for warnings' {
                $output = Write-PipelineLog -Message 'Test warning' -LogType Warning -SourcePath 'test.ps1' -LineNumber 10 -ColumnNumber 5 6>&1
                $output | Should -Be '::warning file=test.ps1,line=10,col=5::Test warning'
            }
        
            It 'includes end column number for errors' {
                $output = Write-PipelineLog -Message 'Test error' -LogType Error -SourcePath 'test.ps1' -LineNumber 10 -ColumnNumber 5 -EndColumnNumber 20 6>&1
                $output | Should -Be '::error file=test.ps1,line=10,col=5,endColumn=20::Test error'
            }
        
            It 'includes issue title for errors' {
                $output = Write-PipelineLog -Message 'Test error' -LogType Error -IssueTitle 'Error Title' 6>&1
                $output | Should -Be '::error title=Error Title::Test error'
            }
        
            It 'includes issue title and code for warnings' {
                $output = Write-PipelineLog -Message 'Test warning' -LogType Warning -IssueTitle 'Warning Title' -IssueCode 'WARN001' 6>&1
                $output | Should -Be '::warning title=Warning Title (code WARN001)::Test warning'
            }
        
            It 'includes only issue code when no title provided' {
                $output = Write-PipelineLog -Message 'Test error' -LogType Error -IssueCode 'ERR001' 6>&1
                $output | Should -Be '::error title=ERR001::Test error'
            }
        
            It 'includes all metadata parameters' {
                $output = Write-PipelineLog -Message 'Test error' -LogType Error -SourcePath 'test.ps1' -LineNumber 10 -EndLineNumber 15 -ColumnNumber 5 -EndColumnNumber 20 -IssueTitle 'Full Error' -IssueCode 'ERR001' 6>&1
                $output | Should -Be '::error file=test.ps1,line=10,endLine=15,col=5,endColumn=20,title=Full Error (code ERR001)::Test error'
            }
        
            It 'writes info messages as notice' {
                $output = Write-PipelineLog -Message 'Test info' -LogType Info 6>&1
                $output | Should -Be '::notice::Test info'
            }
        
            It 'writes debug messages with correct format' {
                $output = Write-PipelineLog -Message 'Test debug' -LogType Debug 6>&1
                $output | Should -Be '::debug::Test debug'
            }
        
            It 'writes command messages with correct format' {
                $output = Write-PipelineLog -Message 'Test command' -LogType Command 6>&1
                $output | Should -Be '::notice title=command::Test command'
            }
        }
    
        Context 'Console - Color Output' {
            BeforeAll {
                _ClearEnvironment
            }
        
            It 'writes error messages in red' {
                $output = Write-PipelineLog -Message 'Test error' -LogType Error 6>&1
                $output | Should -BeLike '*Test error*'
            }
        
            It 'writes warning messages in yellow' {
                $output = Write-PipelineLog -Message 'Test warning' -LogType Warning 6>&1
                $output | Should -BeLike '*Test warning*'
            }
        
            It 'writes info messages in light gray' {
                $output = Write-PipelineLog -Message 'Test info' -LogType Info 6>&1
                $output | Should -BeLike '*Test info*'
            }
        
            It 'writes debug messages in dark gray' {
                $output = Write-PipelineLog -Message 'Test debug' -LogType Debug 6>&1
                $output | Should -BeLike '*Test debug*'
            }
        
            It 'writes command messages in cyan' {
                $output = Write-PipelineLog -Message 'Test command' -LogType Command 6>&1
                $output | Should -BeLike '*Test command*'
            }
        }
    
        Context 'Job Status Updates' {
            BeforeAll {
                _SetAzureDevOpsEnvironment
            }
        
            BeforeEach {
                $global:_task_status = $null
            }
        
            It 'sets job status to SucceededWithIssues on error' {
                Write-PipelineLog -Message 'Test error' -LogType Error 6>&1 | Out-Null
                $global:_task_status | Should -Be 'SucceededWithIssues'
            }
        
            It 'sets job status to SucceededWithIssues on warning' {
                Write-PipelineLog -Message 'Test warning' -LogType Warning 6>&1 | Out-Null
                $global:_task_status | Should -Be 'SucceededWithIssues'
            }
        
            It 'does not update job status when DoNotUpdateJobStatus is set' {
                Write-PipelineLog -Message 'Test error' -LogType Error -DoNotUpdateJobStatus 6>&1 | Out-Null
                $global:_task_status | Should -BeNullOrEmpty
            }
        
            It 'does not update job status for info messages' {
                Write-PipelineLog -Message 'Test info' -LogType Info 6>&1 | Out-Null
                $global:_task_status | Should -BeNullOrEmpty
            }
        
            It 'does not update job status for debug messages' {
                Write-PipelineLog -Message 'Test debug' -LogType Debug 6>&1 | Out-Null
                $global:_task_status | Should -BeNullOrEmpty
            }
        
            It 'does not update job status for command messages' {
                Write-PipelineLog -Message 'Test command' -LogType Command 6>&1 | Out-Null
                $global:_task_status | Should -BeNullOrEmpty
            }
        }
    }
}
