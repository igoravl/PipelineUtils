BeforeAll {
    . $PSScriptRoot/_HelperFunctions.ps1
    Import-Module $PSScriptRoot/../Build/PipelineUtils/PipelineUtils.psd1 -Force
}

Describe 'Add-PipelineTaskLogFile' {
    BeforeEach {
        _ClearEnvironment
    }

    Context 'Azure DevOps' {
        BeforeEach {
            _SetAzureDevOpsEnvironment
            # Create a temporary test file
            $script:testFile = New-TemporaryFile
            "Test log content" | Out-File -FilePath $script:testFile -Force
        }

        AfterEach {
            if (Test-Path $script:testFile) {
                Remove-Item $script:testFile -Force
            }
        }

        It 'uploads a log file with Azure DevOps format' {
            $output = Add-PipelineTaskLogFile -Path $script:testFile.FullName 6>&1
            $output | Should -Match '##vso\[task\.uploadfile\]'
            $output | Should -Match ([regex]::Escape($script:testFile.FullName))
        }

        It 'accepts pipeline input' {
            $output = $script:testFile.FullName | Add-PipelineTaskLogFile 6>&1
            $output | Should -Match '##vso\[task\.uploadfile\]'
        }

        It 'handles multiple files' {
            $testFile2 = New-TemporaryFile
            try {
                $output = Add-PipelineTaskLogFile -Path $script:testFile.FullName, $testFile2.FullName 6>&1
                $output | Should -HaveCount 2
                $output[0] | Should -Match '##vso\[task\.uploadfile\]'
                $output[1] | Should -Match '##vso\[task\.uploadfile\]'
            }
            finally {
                Remove-Item $testFile2 -Force
            }
        }
    }

    Context 'GitHub Actions' {
        BeforeEach {
            _SetGitHubActionsEnvironment
            $script:testFile = New-TemporaryFile
            "Test log content" | Out-File -FilePath $script:testFile -Force
        }

        AfterEach {
            if (Test-Path $script:testFile) {
                Remove-Item $script:testFile -Force
            }
        }

        It 'shows warning and returns early when not in Azure DevOps' {
            $output = Add-PipelineTaskLogFile -Path $script:testFile.FullName 3>&1
            $output | Should -Match 'Add-PipelineTaskLogFile is only supported in Azure DevOps pipelines'
        }
    }

    Context 'Console' {
        BeforeEach {
            $script:testFile = New-TemporaryFile
            "Test log content" | Out-File -FilePath $script:testFile -Force
        }

        AfterEach {
            if (Test-Path $script:testFile) {
                Remove-Item $script:testFile -Force
            }
        }

        It 'shows warning and returns early when not in Azure DevOps' {
            $output = Add-PipelineTaskLogFile -Path $script:testFile.FullName 3>&1
            $output | Should -Match 'Add-PipelineTaskLogFile is only supported in Azure DevOps pipelines'
        }
    }
}
