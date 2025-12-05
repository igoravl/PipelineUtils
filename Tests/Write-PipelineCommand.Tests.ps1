BeforeAll {
    . $PSScriptRoot/_HelperFunctions.ps1
    Import-Module $PSScriptRoot/../Build/PipelineUtils/PipelineUtils.psd1 -Force
}

Describe 'Write-PipelineCommand' {
    BeforeEach {
        _ClearEnvironment
    }

    Context 'Azure DevOps' {
        BeforeEach {
            _SetAzureDevOpsEnvironment
        }

        It 'writes a command message with Azure DevOps format' {
            $output = Write-PipelineCommand -Message "Test command message" 6>&1
            $output | Should -Match 'Test command message'
        }

        It 'accepts message from pipeline' {
            $output = "Pipeline command" | Write-PipelineCommand 6>&1
            $output | Should -Match 'Pipeline command'
        }

        It 'accepts message from positional parameter' {
            $output = Write-PipelineCommand "Positional command" 6>&1
            $output | Should -Match 'Positional command'
        }
    }

    Context 'GitHub Actions' {
        BeforeEach {
            _SetGitHubActionsEnvironment
        }

        It 'writes a command message with GitHub Actions format' {
            $output = Write-PipelineCommand -Message "Test command message" 6>&1
            $output | Should -Match 'Test command message'
        }

        It 'accepts message from pipeline' {
            $output = "GHA command" | Write-PipelineCommand 6>&1
            $output | Should -Match 'GHA command'
        }
    }

    Context 'Console' {
        It 'writes command message to console' {
            $output = Write-PipelineCommand -Message "Console command" 6>&1
            $output | Should -Match 'Console command'
        }
    }
}
