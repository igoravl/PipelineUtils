# Import module before any Pester blocks to ensure it's available during discovery phase
Import-Module "$PSScriptRoot\..\Build\PipelineUtils\PipelineUtils.psd1" -Force

Describe 'Add-PipelineSummary' {
    Context 'Azure DevOps' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetAzureDevOpsEnvironment
        }
        
        It 'adds a summary with content' {
            $output = Add-PipelineSummary -Content '## Test Summary' 6>&1
            $output | Should -BeLike '##vso?task.uploadsummary?*'
        }
    }
    
    Context 'GitHub Actions' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetGitHubActionsEnvironment
        }
        
        It 'appends summary to GITHUB_STEP_SUMMARY' {
            Add-PipelineSummary -Content '## Test Summary'
            $content = Get-Content $env:GITHUB_STEP_SUMMARY -Raw
            $content | Should -BeLike '*## Test Summary*'
        }
        
        It 'appends summary from file' {
            $summaryFile = Join-Path $TestDrive 'summary.md'
            '## File Summary' | Out-File $summaryFile
            Add-PipelineSummary -Path $summaryFile
            $content = Get-Content $env:GITHUB_STEP_SUMMARY -Raw
            $content | Should -BeLike '*## File Summary*'
        }
    }
    
    Context 'Console' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _ClearEnvironment
        }
        
        It 'displays summary to console' {
            $output = Add-PipelineSummary -Content '## Console Summary' 6>&1
            $output | Should -BeLike '*## Console Summary*'
        }
    }

    Context 'Error Handling' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _ClearEnvironment
        }

        It 'throws error when file path does not exist' {
            $nonExistentPath = Join-Path $TestDrive 'nonexistent.md'
            { Add-PipelineSummary -Path $nonExistentPath } | Should -Throw "*does not exist*"
        }
    }

}
