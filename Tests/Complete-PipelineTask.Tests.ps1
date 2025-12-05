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
            $output = Complete-PipelineTask -Status 'Succeeded' 3>&1
            $output | Should -Match 'Complete-PipelineTask is only supported in Azure DevOps pipelines'
        }

        It 'shows warning for SucceededWithIssues status' {
            $output = Complete-PipelineTask -Status 'SucceededWithIssues' 3>&1
            $output | Should -Match 'Complete-PipelineTask is only supported in Azure DevOps pipelines'
        }

        It 'shows warning for Failed status' {
            $output = Complete-PipelineTask -Status 'Failed' 3>&1
            $output | Should -Match 'Complete-PipelineTask is only supported in Azure DevOps pipelines'
        }

        It 'shows warning even when global task status is set' {
            $Global:_task_status = 'SucceededWithIssues'
            try {
                $output = Complete-PipelineTask -Status 'Succeeded' 3>&1
                $output | Should -Match 'Complete-PipelineTask is only supported in Azure DevOps pipelines'
            }
            finally {
                $Global:_task_status = 'Succeeded'
            }
        }
    }

    Context 'Console' {
        It 'returns nothing when not in a pipeline context' {
            $output = Complete-PipelineTask -Status 'Succeeded'
            $output | Should -BeNullOrEmpty
        }

        It 'returns nothing for any status when not in a pipeline context' {
            $output = Complete-PipelineTask -Status 'Failed'
            $output | Should -BeNullOrEmpty
        }
    }
}
