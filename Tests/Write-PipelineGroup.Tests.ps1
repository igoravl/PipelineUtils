BeforeAll {
    . $PSScriptRoot/_HelperFunctions.ps1
    Import-Module $PSScriptRoot/../Build/PipelineUtils/PipelineUtils.psd1 -Force
}

Describe 'Write-PipelineGroup' {
    BeforeEach {
        _ClearEnvironment
    }

    Context 'Azure DevOps' {
        BeforeEach {
            _SetAzureDevOpsEnvironment
        }

        It 'writes a group with begin and end markers' {
            $output = Write-PipelineGroup -Header "Test Group" -Body {
                "Line 1"
                "Line 2"
            } 6>&1
            $output | Should -HaveCount 4
            $output[0] | Should -Match '##\[group\]Test Group'
            $output[1] | Should -Be "Line 1"
            $output[2] | Should -Be "Line 2"
            $output[3] | Should -Match '##\[endgroup\]'
        }

        It 'handles empty body' {
            $output = Write-PipelineGroup -Header "Empty Group" -Body {} 6>&1
            $output | Should -HaveCount 2
            $output[0] | Should -Match '##\[group\]Empty Group'
            $output[1] | Should -Match '##\[endgroup\]'
        }

        It 'handles scriptblock with single output' {
            $output = Write-PipelineGroup -Header "Single Line" -Body {
                "Only one line"
            } 6>&1
            $output | Should -HaveCount 3
            $output[0] | Should -Match '##\[group\]Single Line'
            $output[1] | Should -Be "Only one line"
            $output[2] | Should -Match '##\[endgroup\]'
        }
    }

    Context 'GitHub Actions' {
        BeforeEach {
            _SetGitHubActionsEnvironment
        }

        It 'writes a group with GitHub Actions format' {
            $output = Write-PipelineGroup -Header "Test Group" -Body {
                "Line 1"
                "Line 2"
            } 6>&1
            $output | Should -HaveCount 4
            $output[0] | Should -Match '::group::Test Group'
            $output[1] | Should -Be "Line 1"
            $output[2] | Should -Be "Line 2"
            $output[3] | Should -Match '::endgroup::'
        }

        It 'handles body with commands' {
            $output = Write-PipelineGroup -Header "Command Group" -Body {
                Get-Date -Format "yyyy-MM-dd"
                "Static text"
            } 6>&1
            $output | Should -HaveCount 4
            $output[0] | Should -Match '::group::Command Group'
            $output[1] | Should -Match '\d{4}-\d{2}-\d{2}'
            $output[2] | Should -Be "Static text"
            $output[3] | Should -Match '::endgroup::'
        }
    }

    Context 'Console' {
        It 'writes a group for console output' {
            $output = Write-PipelineGroup -Header "Console Group" -Body {
                "Console line 1"
                "Console line 2"
            } 6>&1
            $output | Should -HaveCount 3
            $output[0] | Should -Be "Console Group"
            $output[1] | Should -Be "Console line 1"
            $output[2] | Should -Be "Console line 2"
        }
    }
}
