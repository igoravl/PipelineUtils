# Import module before any Pester blocks to ensure it's available during discovery phase
Import-Module "$PSScriptRoot\..\Build\PipelineUtils\PipelineUtils.psd1" -Force

Describe 'Set-PipelineBuildNumber' {
    Context 'Azure DevOps' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetAzureDevOpsEnvironment
        }
        
        It 'sets build number with Azure DevOps format' {
            $output = Set-PipelineBuildNumber -BuildNumber '1.0.42' 6>&1
            $output | Should -Be '##vso[build.updatebuildnumber]1.0.42'
        }
    }
    
    Context 'GitHub Actions' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetGitHubActionsEnvironment
        }
        
        It 'warns and returns early when unsupported' {
            $warn = $null
            $output = Set-PipelineBuildNumber -BuildNumber '1.0.42' -WarningVariable warn -WarningAction SilentlyContinue
            $warn | Should -BeLike '*Set-PipelineBuildNumber is only supported in Azure DevOps pipelines.*'
            $output | Should -BeNullOrEmpty

            $content = if (Test-Path $env:GITHUB_ENV) { Get-Content $env:GITHUB_ENV -Raw } else { '' }
            $content | Should -Not -BeLike '*BUILD_NUMBER=*'
        }
    }
    
    Context 'Console' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _ClearEnvironment
        }
        
        It 'displays build number to console' {
            $output = Set-PipelineBuildNumber -BuildNumber '1.0.42' 6>&1
            $output | Should -Be 'Build number: 1.0.42'
        }
    }
}
