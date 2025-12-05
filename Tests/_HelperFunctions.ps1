    function _ClearEnvironment {
        $env:TF_BUILD = $null
        $env:AGENT_ID = $null
        $env:BUILD_BUILDID = $null
        $env:GITHUB_ACTIONS = $null
        $env:GITHUB_WORKFLOW = $null
        $env:GITHUB_RUN_ID = $null
        $env:GITHUB_ENV = $null
        $env:GITHUB_OUTPUT = $null
        $env:GITHUB_PATH = $null
        $env:GITHUB_STEP_SUMMARY = $null
    }
    
    # Helper function to set Azure DevOps environment
    function _SetAzureDevOpsEnvironment {
        _ClearEnvironment
        $env:TF_BUILD = 'true'
    }
    
    # Helper function to set GitHub Actions environment
    function _SetGitHubActionsEnvironment {
        _ClearEnvironment
        $TestDrivePath = 'TestDrive:\GitHubActions'
        New-Item -Path $TestDrivePath -ItemType Directory -Force | Out-Null
        $env:GITHUB_ACTIONS = 'true'
        $env:GITHUB_ENV = Join-Path $TestDrivePath 'github_env'
        $env:GITHUB_OUTPUT = Join-Path $TestDrivePath 'github_output'
        $env:GITHUB_PATH = Join-Path $TestDrivePath 'github_path'
        $env:GITHUB_STEP_SUMMARY = Join-Path $TestDrivePath 'github_step_summary'
    }
