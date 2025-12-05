BeforeAll {
    . $PSScriptRoot/_HelperFunctions.ps1
    Import-Module $PSScriptRoot/../Build/PipelineUtils/PipelineUtils.psd1 -Force
}

Describe 'Write-PipelineSection' {
    BeforeEach {
        _ClearEnvironment
    }

    Context 'Azure DevOps' {
        BeforeEach {
            _SetAzureDevOpsEnvironment
        }

        It 'writes a section header with Azure DevOps format' {
            $output = Write-PipelineSection -Text "Build started" 6>&1
            $output | Should -Match '##\[section\]== Build started =='
        }

        It 'writes a boxed section header' {
            $output = Write-PipelineSection -Text "Tests" -Boxed 6>&1
            $output | Should -Match '##\[section\]='
            $output | Should -Match '##\[section\]== Tests =='
        }

        It 'handles long text' {
            $longText = "This is a very long section header text"
            $output = Write-PipelineSection -Text $longText 6>&1
            $output | Should -Match "##\[section\]== $longText =="
        }

        It 'handles text with special characters' {
            $output = Write-PipelineSection -Text "Build & Deploy" 6>&1
            $output | Should -Match '##\[section\]== Build & Deploy =='
        }
    }

    Context 'GitHub Actions' {
        BeforeEach {
            _SetGitHubActionsEnvironment
        }

        It 'writes a section header for GitHub Actions' {
            $output = Write-PipelineSection -Text "Build started" 6>&1
            $output | Should -Match '== Build started =='
        }

        It 'writes a boxed section header for GitHub Actions' {
            $output = Write-PipelineSection -Text "Tests" -Boxed 6>&1
            $output | Should -Match '='
            $output | Should -Match '== Tests =='
        }

        It 'handles different text' {
            $output = Write-PipelineSection -Text "Deployment Phase" 6>&1
            $output | Should -Match '== Deployment Phase =='
        }
    }

    Context 'Console' {
        It 'writes section header to console' {
            $output = Write-PipelineSection -Text "Console Section" 6>&1
            $output | Should -Match '== Console Section =='
        }

        It 'writes boxed section header to console' {
            $output = Write-PipelineSection -Text "Boxed" -Boxed 6>&1
            $output | Should -Match '='
            $output | Should -Match '== Boxed =='
        }

        It 'handles short text' {
            $output = Write-PipelineSection -Text "Go" 6>&1
            $output | Should -Match '== Go =='
        }
    }
}
