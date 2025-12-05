# Import module before any Pester blocks to ensure it's available during discovery phase
Import-Module "$PSScriptRoot\..\Build\PipelineUtils\PipelineUtils.psd1" -Force

Describe 'Add-PipelineBuildTag' {
    Context 'Azure DevOps' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetAzureDevOpsEnvironment
        }
        
        It 'adds a build tag with Azure DevOps format' {
            $output = Add-PipelineBuildTag -Tag 'release' 6>&1
            $output | Should -Be '##vso[build.addbuildtag]release'
        }
    }
    
    Context 'GitHub Actions' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetGitHubActionsEnvironment
        }
        
        It 'warns and returns early when unsupported' {
            $warn = $null
            $output = Add-PipelineBuildTag -Tag 'release' -WarningVariable warn -WarningAction SilentlyContinue
            $warn | Should -BeLike '*Add-PipelineBuildTag is only supported in Azure DevOps pipelines.*'
            $output | Should -BeNullOrEmpty

            $content = if (Test-Path $env:GITHUB_OUTPUT) { Get-Content $env:GITHUB_OUTPUT -Raw } else { '' }
            $content | Should -Not -BeLike '*build-tag=*'
        }
    }
    
    Context 'Console' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _ClearEnvironment
        }
        
        It 'outputs build tag to console' {
            $output = Add-PipelineBuildTag -Tag 'release' 6>&1
            $output | Should -Be 'Build tag: release'
        }
    }
}
