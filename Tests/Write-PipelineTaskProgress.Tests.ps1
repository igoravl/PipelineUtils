BeforeAll {
    . $PSScriptRoot/_HelperFunctions.ps1
    Import-Module $PSScriptRoot/../Build/PipelineUtils/PipelineUtils.psd1 -Force
}

Describe 'Write-PipelineTaskProgress' {
    BeforeEach {
        _ClearEnvironment
    }

    Context 'Azure DevOps' {
        BeforeEach {
            _SetAzureDevOpsEnvironment
        }

        It 'writes task progress with Azure DevOps format' {
            $output = Write-PipelineTaskProgress -CurrentOperation "Installing dependencies"
            $output | Should -Be "##vso[task.setprogress currentoperation=Installing dependencies]"
        }

        It 'includes percentage when provided' {
            $output = Write-PipelineTaskProgress -CurrentOperation "Running tests" -PercentComplete 75
            $output | Should -Be "##vso[task.setprogress currentoperation=Running tests;percentcomplete=75]"
        }

        It 'validates percent complete range' {
            { Write-PipelineTaskProgress -CurrentOperation "Test" -PercentComplete 101 } | Should -Throw
            { Write-PipelineTaskProgress -CurrentOperation "Test" -PercentComplete -1 } | Should -Throw
        }

        It 'accepts 0 percent' {
            $output = Write-PipelineTaskProgress -CurrentOperation "Starting" -PercentComplete 0
            $output | Should -Be "##vso[task.setprogress currentoperation=Starting;percentcomplete=0]"
        }

        It 'accepts 100 percent' {
            $output = Write-PipelineTaskProgress -CurrentOperation "Complete" -PercentComplete 100
            $output | Should -Be "##vso[task.setprogress currentoperation=Complete;percentcomplete=100]"
        }
    }

    Context 'GitHub Actions' {
        BeforeEach {
            _SetGitHubActionsEnvironment
        }

        It 'writes task progress as notice' {
            $output = Write-PipelineTaskProgress -CurrentOperation "Installing dependencies"
            $output | Should -Be "::notice::Installing dependencies"
        }

        It 'includes percentage in message when provided' {
            $output = Write-PipelineTaskProgress -CurrentOperation "Running tests" -PercentComplete 75
            $output | Should -Be "::notice::Running tests - 75% complete"
        }

        It 'handles various percentages' {
            $output = Write-PipelineTaskProgress -CurrentOperation "Building" -PercentComplete 50
            $output | Should -Be "::notice::Building - 50% complete"
        }
    }

    Context 'Console' {
        It 'writes task progress to console' {
            $output = Write-PipelineTaskProgress -CurrentOperation "Processing files" 6>&1
            $output | Should -Match 'Processing files'
        }

        It 'writes progress with percentage to console' {
            $output = Write-PipelineTaskProgress -CurrentOperation "Compiling" -PercentComplete 80 6>&1
            $output | Should -Match 'Compiling'
        }

        It 'validates range in console mode' {
            { Write-PipelineTaskProgress -CurrentOperation "Test" -PercentComplete 150 } | Should -Throw
        }
    }
}
