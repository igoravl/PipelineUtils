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
        
        It 'adds a build tag as a notice and output' {
            $output = Add-PipelineBuildTag -Tag 'release' 6>&1
            $output | Should -Be '::notice title=Build Tag::release'
            
            $content = Get-Content $env:GITHUB_OUTPUT -Raw
            $content | Should -BeLike '*build-tag=release*'
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
