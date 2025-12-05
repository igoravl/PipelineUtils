BeforeAll {
    . $PSScriptRoot/_HelperFunctions.ps1
    Import-Module $PSScriptRoot/../Build/PipelineUtils/PipelineUtils.psd1 -Force
}

Describe 'Complete-PipelineTask' {
    Context 'Azure DevOps' {
        BeforeAll {
            _SetAzureDevOpsEnvironment
        }

        It 'completes successfully without output when status is Succeeded' {
            $output = Complete-PipelineTask -Status 'Succeeded'
            $output | Should -BeNullOrEmpty
        }

        It 'completes with SucceededWithIssues status' {
            $output = Complete-PipelineTask -Status 'SucceededWithIssues' *>&1
            $output | Should -Match '##vso\[task\.complete result=SucceededWithIssues;\]'
        }

        It 'completes with Failed status' {
            $output = Complete-PipelineTask -Status 'Failed' *>&1
            $output | Should -Match '##vso\[task\.complete result=Failed;\]'
        }

        It 'uses global task status when set to SucceededWithIssues' {
            $Global:_task_status = 'SucceededWithIssues'
            try {
                $output = Complete-PipelineTask -Status 'Succeeded' *>&1
                $output | Should -Match '##vso\[task\.complete result=SucceededWithIssues;\]'
            }
            finally {
                $Global:_task_status = 'Succeeded'
            }
        }

        It 'uses global task status when set to Failed' {
            $Global:_task_status = 'Failed'
            try {
                $output = Complete-PipelineTask -Status 'Succeeded' *>&1
                $output | Should -Match '##vso\[task\.complete result=Failed;\]'
            }
            finally {
                $Global:_task_status = 'Succeeded'
            }
        }
    }

    Context 'GitHub Actions' {
        BeforeAll {
            _SetGitHubActionsEnvironment
        }

        It 'shows warning and returns early when not in Azure DevOps' {
            $warn = $null
            $output = Complete-PipelineTask -Status 'Succeeded' -WarningVariable warn -WarningAction SilentlyContinue
            $warn | Should -BeLike '*Complete-PipelineTask is only supported in Azure DevOps pipelines.*'
            $output | Should -BeNullOrEmpty
        }

        It 'shows warning for SucceededWithIssues status' {
            $warn = $null
            $output = Complete-PipelineTask -Status 'SucceededWithIssues' -WarningVariable warn -WarningAction SilentlyContinue
            $warn | Should -BeLike '*Complete-PipelineTask is only supported in Azure DevOps pipelines.*'
            $output | Should -BeNullOrEmpty
        }

        It 'shows warning for Failed status' {
            $warn = $null
            $output = Complete-PipelineTask -Status 'Failed' -WarningVariable warn -WarningAction SilentlyContinue
            $warn | Should -BeLike '*Complete-PipelineTask is only supported in Azure DevOps pipelines.*'
            $output | Should -BeNullOrEmpty
        }

        It 'shows warning even when global task status is set' {
            $Global:_task_status = 'SucceededWithIssues'
            try {
                $warn = $null
                $output = Complete-PipelineTask -Status 'Succeeded' -WarningVariable warn -WarningAction SilentlyContinue
                $warn | Should -BeLike '*Complete-PipelineTask is only supported in Azure DevOps pipelines.*'
                $output | Should -BeNullOrEmpty
            }
            finally {
                $Global:_task_status = 'Succeeded'
            }
        }
    }

    Context 'Console' {
        It 'returns nothing when not in a pipeline context' {
            $warn = $null
            $output = Complete-PipelineTask -Status 'Succeeded' -WarningVariable warn -WarningAction SilentlyContinue
            $output | Should -BeNullOrEmpty
        }

        It 'returns nothing for any status when not in a pipeline context' {
            $warn = $null
            $output = Complete-PipelineTask -Status 'Failed' -WarningVariable warn -WarningAction SilentlyContinue
            $output | Should -BeNullOrEmpty
        }
    }
}
