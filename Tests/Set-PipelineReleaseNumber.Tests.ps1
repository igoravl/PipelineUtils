BeforeAll {
    . $PSScriptRoot/_HelperFunctions.ps1
    Import-Module $PSScriptRoot/../Build/PipelineUtils/PipelineUtils.psd1 -Force
}

Describe 'Set-PipelineReleaseNumber' {
    BeforeEach {
        _ClearEnvironment
    }

    Context 'Azure DevOps' {
        BeforeEach {
            _SetAzureDevOpsEnvironment
        }

        It 'sets release number with Azure DevOps format' {
            $output = Set-PipelineReleaseNumber -ReleaseNumber "1.0.42"
            $output | Should -Be "##vso[release.updatereleasename]1.0.42"
        }

        It 'accepts release number from parameter' {
            $releaseNum = "2024.12.05.1"
            $output = Set-PipelineReleaseNumber -ReleaseNumber $releaseNum
            $output | Should -Be "##vso[release.updatereleasename]$releaseNum"
        }

        It 'accepts release number from positional parameter' {
            $output = Set-PipelineReleaseNumber "3.0.0"
            $output | Should -Be "##vso[release.updatereleasename]3.0.0"
        }
    }

    Context 'GitHub Actions' {
        BeforeEach {
            _SetGitHubActionsEnvironment
        }

        It 'shows warning and returns early when not in Azure DevOps' {
            $output = Set-PipelineReleaseNumber -ReleaseNumber "1.0.42" 3>&1
            $output | Should -Match 'Set-PipelineReleaseNumber is only supported in Azure DevOps pipelines'
        }
    }

    Context 'Console' {
        It 'shows warning and returns early when not in Azure DevOps' {
            $output = Set-PipelineReleaseNumber -ReleaseNumber "1.0.42" 3>&1
            $output | Should -Match 'Set-PipelineReleaseNumber is only supported in Azure DevOps pipelines'
        }
    }
}
