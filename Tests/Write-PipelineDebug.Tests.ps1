BeforeAll {
    . $PSScriptRoot/_HelperFunctions.ps1
    Import-Module $PSScriptRoot/../Build/PipelineUtils/PipelineUtils.psd1 -Force
}

Describe 'Write-PipelineDebug' {
    BeforeEach {
        _ClearEnvironment
    }

    Context 'Azure DevOps' {
        BeforeEach {
            _SetAzureDevOpsEnvironment
        }

        It 'writes a debug message with Azure DevOps format' {
            $output = Write-PipelineDebug -Message "Test debug message" 6>&1
            $output | Should -Match '##\[debug\]Test debug message'
        }

        It 'accepts message from pipeline' {
            $output = "Pipeline debug" | Write-PipelineDebug 6>&1
            $output | Should -Match '##\[debug\]Pipeline debug'
        }

        It 'accepts message from positional parameter' {
            $output = Write-PipelineDebug "Positional debug" 6>&1
            $output | Should -Match '##\[debug\]Positional debug'
        }
    }

    Context 'GitHub Actions' {
        BeforeEach {
            _SetGitHubActionsEnvironment
        }

        It 'writes a debug message with GitHub Actions format' {
            $output = Write-PipelineDebug -Message "Test debug message" 6>&1
            $output | Should -Match '::debug::Test debug message'
        }

        It 'accepts message from pipeline' {
            $output = "GHA debug" | Write-PipelineDebug 6>&1
            $output | Should -Match '::debug::GHA debug'
        }
    }

    Context 'Console' {
        It 'writes debug message to console' {
            $output = Write-PipelineDebug -Message "Console debug" 6>&1
            $output | Should -Match 'Console debug'
        }
    }
}
