# Import module before any Pester blocks to ensure it's available during discovery phase
Import-Module "$PSScriptRoot\..\Build\PipelineUtils\PipelineUtils.psd1" -Force

Describe 'Set-PipelineVariable' {
    Context 'Azure DevOps' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetAzureDevOpsEnvironment
        }
        
        It 'sets a variable with Azure DevOps format' {
            $output = Set-PipelineVariable -Name 'TestVar' -Value 'TestValue' 6>&1
            $output | Should -Be '##vso[task.setvariable variable=TestVar;]TestValue'
        }
        
        It 'sets a secret variable when Secret switch is used' {
            $output = Set-PipelineVariable -Name 'SecretVar' -Value 'SecretValue' -Secret 6>&1
            $output | Should -Be '##vso[task.setvariable variable=SecretVar;issecret=true;]SecretValue'
        }
        
        It 'sets an output variable when Output switch is used' {
            $output = Set-PipelineVariable -Name 'OutputVar' -Value 'OutputValue' -Output 6>&1
            $output | Should -Be '##vso[task.setvariable variable=OutputVar;isoutput=true;]OutputValue'
        }

        It 'sets a readonly variable when ReadOnly switch is used' {
            $output = Set-PipelineVariable -Name 'ReadOnlyVar' -Value 'ReadOnlyValue' -ReadOnly 6>&1
            $output | Should -Be '##vso[task.setvariable variable=ReadOnlyVar;isreadonly=true;]ReadOnlyValue'
        }

        It 'sets a variable with multiple flags' {
            $output = Set-PipelineVariable -Name 'ComplexVar' -Value 'ComplexValue' -Secret -Output 6>&1
            $output | Should -Be '##vso[task.setvariable variable=ComplexVar;issecret=true;isoutput=true;]ComplexValue'
        }
    }
    
    Context 'GitHub Actions' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetGitHubActionsEnvironment
        }
        
        It 'sets an environment variable by writing to GITHUB_ENV' {
            Set-PipelineVariable -Name 'TestVar' -Value 'TestValue'
            $content = Get-Content $env:GITHUB_ENV -Raw
            $content | Should -BeLike '*TestVar=TestValue*'
        }
        
        It 'sets a multiline variable with heredoc syntax' {
            $multilineValue = "Line1`nLine2`nLine3"
            Set-PipelineVariable -Name 'MultiVar' -Value $multilineValue
            $content = Get-Content $env:GITHUB_ENV -Raw
            $content | Should -BeLike '*MultiVar<<EOF_*'
            $content | Should -BeLike '*Line1*'
            $content | Should -BeLike '*Line2*'
            $content | Should -BeLike '*Line3*'
        }
        
        It 'sets an output variable by writing to GITHUB_OUTPUT' {
            Set-PipelineVariable -Name 'OutputVar' -Value 'OutputValue' -Output
            $content = Get-Content $env:GITHUB_OUTPUT -Raw
            $content | Should -BeLike '*OutputVar=OutputValue*'
        }
        
        It 'warns about secret flag not being applicable' {
            $output = Set-PipelineVariable -Name 'SecretVar' -Value 'SecretValue' -Secret 6>&1
            $output -join ' ' | Should -BeLike '*Secret flag is not applicable in GitHub Actions*'
        }

        It 'warns about readonly flag not being applicable' {
            $output = Set-PipelineVariable -Name 'ReadOnlyVar' -Value 'ReadOnlyValue' -ReadOnly 6>&1
            $output | Should -BeLike '*ReadOnly flag is not applicable in GitHub Actions*'
        }


    }
    
    Context 'Console' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _ClearEnvironment
        }
        
        It 'sets variable in environment when not in a pipeline context' {
            Set-PipelineVariable -Name 'TestVar' -Value 'TestValue'
            $env:TestVar | Should -Be 'TestValue'
        }
    }
}
