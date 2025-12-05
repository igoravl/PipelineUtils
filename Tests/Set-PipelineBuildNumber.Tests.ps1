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
        
        It 'sets build number as notice and environment variable' {
            $output = Set-PipelineBuildNumber -BuildNumber '1.0.42' 6>&1
            $output | Should -Be '::notice title=Build Number::1.0.42'
            
            $content = Get-Content $env:GITHUB_ENV -Raw
            $content | Should -BeLike '*BUILD_NUMBER=1.0.42*'
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
