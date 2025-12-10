# PipelineUtils

PowerShell utilities for CI/CD pipelines. This module provides cmdlets to facilitate common actions in **Azure DevOps Pipelines** and **GitHub Actions**, such as logging commands, setting variables, and managing build metadata.

## Features

- **Multi-Platform Support**: Works with both Azure DevOps Pipelines and GitHub Actions
- **Logging Commands**: Write warnings, errors, and progress updates using platform-specific logging commands
- **Variable Management**: Set pipeline variables and outputs using appropriate syntax for each platform
- **Build Management**: Add tags to builds and organize output with collapsible sections
- **Context Detection**: Automatically detect the CI/CD environment and use appropriate commands

## Supported Platforms

- **Azure DevOps Pipelines** - Full support for all Azure DevOps logging commands
- **GitHub Actions** - Full support for GitHub Actions workflow commands

## Installation

### From PowerShell Gallery (when published)

```powershell
Install-Module PipelineUtils -Scope CurrentUser
```

### From Source

```powershell
git clone https://github.com/igoravl/PipelineUtils.git
cd PipelineUtils
# Install dependencies and build
.\Build.ps1 -InstallDependencies
```

## Public Functions (Cmdlets)

| Function | Purpose |
|----------|---------|
| `Add-PipelineBuildTag` | Add a tag to the current build. |
| `Add-PipelinePath` | Prepend a directory to PATH for later steps. |
| `Add-PipelineSummary` | Publish a Markdown summary (string or file). |
| `Add-PipelineTaskLogFile` | Upload one or more files into the task log (visible under Attachments). |
| `Complete-PipelineTask` | Mark current task as completed with a status other than Succeeded (e.g. Failed, Skipped). |
| `Set-PipelineBuildNumber` | Update the build number. |
| `Set-PipelineReleaseNumber` | Update classic release name. |
| `Set-PipelineSecretValue` | Mask a literal value in logs (does not create a variable). |
| `Set-PipelineVariable` | Create/update a pipeline variable (supports `-Secret`, `-Output`, `-ReadOnly`). |
| `Write-PipelineCommand` | Write a generic command/info log entry. |
| `Write-PipelineDebug` | Write a debug message (alias: `Write-Debug`). |
| `Write-PipelineError` | Emit an error log issue (alias: `Write-Error`). |
| `Write-PipelineGroup` | Convenience wrapper executing a script block inside a group. |
| `Write-PipelineGroupEnd` | End the current collapsible group. |
| `Write-PipelineGroupStart` | Begin a collapsible log group. |
| `Write-PipelineProgress` | Generic progress indicator (percent + activity). |
| `Write-PipelineSection` | Output a formatted section header (optionally boxed). |
| `Write-PipelineTaskProgress` | Task progress (operation + optional percent). |
| `Write-PipelineWarning` | Emit a warning log issue (alias: `Write-Warning`). |

### Formatting Commands

- **`Write-PipelineCommand`** - Write command messages to pipeline logs
- **`Write-PipelineDebug`** - Write debug messages to pipeline logs
- **`Write-PipelineError`** - Write error messages to pipeline logs
- **`Write-PipelineProgress`** - Report progress with percentage
- **`Write-PipelineSection`** - Create sections in logs
- **`Write-PipelineTaskProgress`** - Update task progress indicators
- **`Write-PipelineWarning`** - Write warning messages to pipeline logs

### Grouping Commands

- **`Write-PipelineGroup`** - Create a collapsible group with a script block
- **`Write-PipelineGroupEnd`** - End a collapsible group in logs
- **`Write-PipelineGroupStart`** - Start a collapsible group in logs

## Usage Examples

- **`Set-PipelineSecretValue`** - Mask a value as secret in logs
- **`Set-PipelineVariable`** - Set pipeline variables (including secrets and output variables)

### Build Management

- **`Add-PipelineBuildTag`** - Add tags to the current build/run
- **`Add-PipelinePath`** - Add a directory to the PATH environment variable
- **`Add-PipelineSummary`** - Add Markdown summary to the pipeline run
- **`Add-PipelineTaskLogFile`** - Upload a log file (Azure DevOps only)
- **`Complete-PipelineTask`** - Mark task completion with status (Azure DevOps only)
- **`Set-PipelineBuildNumber`** - Set the build/run number
- **`Set-PipelineReleaseNumber`** - Set the release name (Azure DevOps only)

## Examples

### Basic Logging

```powershell
Write-PipelineWarning "This is a warning message"
Write-PipelineError "This is an error message"
Write-PipelineDebug "This is a debug message"
```

### Advanced Logging with Source Information

```powershell
Write-PipelineWarning -Message "Deprecated function used" -SourcePath "script.ps1" -LineNumber 42
Write-PipelineError -Message "Compilation failed" -SourcePath "build.ps1" -LineNumber 25 -IssueCode "BUILD001"
```

### Setting Variables

```powershell
# Set a regular variable (Azure DevOps) or environment variable (GitHub Actions)
Set-PipelineVariable -Name "BuildNumber" -Value "1.0.42"

# Set a secret variable (Azure DevOps only - GitHub Actions requires repository secrets)
Set-PipelineVariable -Name "ApiKey" -Value "secret123" -Secret

# Set an output variable (available to subsequent jobs/steps)
Set-PipelineVariable -Name "DeploymentTarget" -Value "Production" -Output

# Mask a secret value in logs
Set-PipelineSecretValue -Value "mySecretPassword"
```

### Build Management Examples

```powershell
# Add tags to the build
Add-PipelineBuildTag -Tag "release"
Add-PipelineBuildTag -Tag "hotfix"

# Set build number
Set-PipelineBuildNumber -BuildNumber "1.0.42"

# Add a summary (markdown)
Add-PipelineSummary -Content "## Build Results`n- Tests Passed: 42`n- Code Coverage: 95%"

# Add path to PATH environment variable
Add-PipelinePath -Path "C:\tools\bin"
```

### Progress Tracking

```powershell
Write-PipelineTaskProgress -CurrentOperation "Installing dependencies" -PercentComplete 25
Write-PipelineProgress -PercentComplete 75 -Activity "Running tests"
```

### Organizing Output with Groups

```powershell
Write-PipelineGroupStart "Build Phase"
# ... build commands ...
Write-PipelineGroupEnd

# Or create sections
Write-PipelineSection -Text "Deployment" -Boxed
```

## Development

### Build / Test / Package

This project uses [ModuleBuilder](https://github.com/PoshCode/ModuleBuilder) and [Invoke-Build](https://github.com/nightroman/Invoke-Build).

```powershell
# Build the module (installs dependencies automatically)
.\Build.ps1 -InstallDependencies

# Run tests
.\Build.ps1 -InstallDependencies Test

# Create distribution package
.\Build.ps1 -InstallDependencies Package

# Or use Invoke-Build directly
Invoke-Build Build
Invoke-Build Test
```

### Project Structure

```text
PipelineUtils/
├── Source/                    # Source files (ModuleBuilder convention)
│   ├── Public/               # Public functions (exported)
│   ├── Private/              # Private functions (internal)
│   ├── Enum/                 # Enums (PipelineType)
│   ├── PipelineUtils.psd1   # Module manifest
│   └── build.psd1            # ModuleBuilder configuration
├── Tests/                    # Pester tests
├── Build/                    # Build output (created by ModuleBuilder)
├── artifacts/                # Distribution packages
└── ib.build.ps1             # Invoke-Build script
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass: `Build.ps1 -Targets Test`
5. Submit a pull request

## License

MIT License. See [LICENSE](LICENSE).

## Platform-Specific Behavior

### Azure DevOps

- Uses `##vso[...]` logging commands
- Supports all advanced features like task completion status, progress tracking, and release management
- Variables set with `-Secret` flag are masked in logs
- Build tags are applied directly to the build
- Supports classic release pipelines with `Set-PipelineReleaseNumber`
- Task log files can be uploaded with `Add-PipelineTaskLogFile`

### GitHub Actions

- Uses `::command::` workflow commands
- Environment variables are written to `$env:GITHUB_ENV`
- Output variables are written to `$env:GITHUB_OUTPUT`
- Secrets must be configured in repository settings (cannot be set dynamically), but can be masked
- Summaries are written to `$env:GITHUB_STEP_SUMMARY`
- Groups use `::group::` and `::endgroup::`
- Some Azure DevOps-specific commands show warnings when used in GitHub Actions

## References

- [Azure DevOps Logging Commands](https://docs.microsoft.com/en-us/azure/devops/pipelines/scripts/logging-commands)
- [GitHub Actions Workflow Commands](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions)
- [ModuleBuilder](https://github.com/PoshCode/ModuleBuilder)
- [Invoke-Build](https://github.com/nightroman/Invoke-Build)
