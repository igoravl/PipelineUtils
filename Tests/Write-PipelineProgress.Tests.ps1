BeforeAll {
    . $PSScriptRoot/_HelperFunctions.ps1
    Import-Module $PSScriptRoot/../Build/PipelineUtils/PipelineUtils.psd1 -Force
}

Describe 'Write-PipelineProgress' {
    BeforeEach {
        _ClearEnvironment
    }

    Context 'Azure DevOps' {
        BeforeEach {
            _SetAzureDevOpsEnvironment
        }

        It 'writes progress with Azure DevOps format' {
            $output = Write-PipelineProgress -PercentComplete 50 -Activity "Deployment"
            $output | Should -Be "##vso[task.setprogress value=50;]Deployment - 50%"
        }

        It 'accepts percent and activity from positional parameters' {
            $output = Write-PipelineProgress 75 "Build"
            $output | Should -Be "##vso[task.setprogress value=75;]Build - 75%"
        }

        It 'validates percent complete range' {
            { Write-PipelineProgress -PercentComplete 101 -Activity "Test" } | Should -Throw
            { Write-PipelineProgress -PercentComplete -1 -Activity "Test" } | Should -Throw
        }

        It 'accepts 0 percent' {
            $output = Write-PipelineProgress -PercentComplete 0 -Activity "Starting"
            $output | Should -Be "##vso[task.setprogress value=0;]Starting - 0%"
        }

        It 'accepts 100 percent' {
            $output = Write-PipelineProgress -PercentComplete 100 -Activity "Complete"
            $output | Should -Be "##vso[task.setprogress value=100;]Complete - 100%"
        }
    }

    Context 'GitHub Actions' {
        BeforeEach {
            _SetGitHubActionsEnvironment
        }

        It 'writes progress as notice with GitHub Actions format' {
            $output = Write-PipelineProgress -PercentComplete 50 -Activity "Deployment"
            $output | Should -Be "::notice::Deployment - 50% complete"
        }

        It 'handles different percentages' {
            $output = Write-PipelineProgress -PercentComplete 25 -Activity "Installing"
            $output | Should -Be "::notice::Installing - 25% complete"
        }
    }

    Context 'Console' {
        It 'uses Write-Progress for console' {
            # Write-Progress doesn't return output, so we just ensure it doesn't throw
            { Write-PipelineProgress -PercentComplete 50 -Activity "Test" } | Should -Not -Throw
        }

        It 'validates range in console mode' {
            { Write-PipelineProgress -PercentComplete 150 -Activity "Test" } | Should -Throw
        }
    }
}
