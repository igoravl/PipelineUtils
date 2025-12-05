# Import module before any Pester blocks to ensure it's available during discovery phase
Import-Module "$PSScriptRoot\..\Build\PipelineUtils\PipelineUtils.psd1" -Force

Describe 'Add-PipelinePath' {
    Context 'Azure DevOps' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetAzureDevOpsEnvironment
            New-Item -Path (Join-Path $TestDrive 'testpath') -ItemType Directory -Force
        }
        
        It 'adds path with Azure DevOps format' {
            $testPath = Join-Path $TestDrive 'testpath'
            $output = Add-PipelinePath -Path $testPath 6>&1
            $output | Should -BeLike '##vso?task.prependpath?*'
        }
    }
    
    Context 'GitHub Actions' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _SetGitHubActionsEnvironment
            New-Item -Path (Join-Path $TestDrive 'testpath') -ItemType Directory -Force
        }
        
        It 'appends path to GITHUB_PATH' {
            $testPath = Join-Path $TestDrive 'testpath'
            Add-PipelinePath -Path $testPath
            $content = Get-Content $env:GITHUB_PATH -Raw
            $content | Should -BeLike "*$testPath*"
        }
    }
    
    Context 'Console' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _ClearEnvironment
            New-Item -Path (Join-Path $TestDrive 'testpath') -ItemType Directory -Force
        }
        
        It 'adds path to current session PATH' {
            $testPath = Join-Path $TestDrive 'testpath'
            $originalPath = $env:PATH
            Add-PipelinePath -Path $testPath
            $env:PATH | Should -BeLike "*$testPath*"
            $env:PATH = $originalPath
        }
    }

    Context 'Error Handling' {
        BeforeAll {
            . $PSScriptRoot/_HelperFunctions.ps1
            _ClearEnvironment
        }

        It 'throws error when path does not exist' {
            $nonExistentPath = Join-Path $TestDrive 'nonexistent'
            { Add-PipelinePath -Path $nonExistentPath -ErrorAction Stop } | Should -Throw
        }

        It 'throws error when path is a file, not a directory' {
            $filePath = Join-Path $TestDrive 'testfile.txt'
            New-Item -Path $filePath -ItemType File -Force
            $output = Add-PipelinePath -Path $filePath 2>&1 6>&1
            $output -join ' ' | Should -Match 'not a directory'
        }
    }

}
