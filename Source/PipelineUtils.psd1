@{
    RootModule = 'PipelineUtils.psm1'
    ModuleVersion = '0.2.0'
    GUID = 'a1234567-b890-c123-d456-e789f0123456'
    Author = 'igoravl'
    CompanyName = 'igoravl'
    Copyright = '(c) 2025 igoravl. All rights reserved.'
    Description = 'PowerShell utilities for CI/CD pipelines (Azure DevOps and GitHub Actions)'
    PowerShellVersion = '5.1'
    RequiredModules = @()
    RequiredAssemblies = @()
    ScriptsToProcess = @('init.ps1')
    TypesToProcess = @()
    FormatsToProcess = @()
    NestedModules = @()
    FunctionsToExport = @()
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = '*'
    DscResourcesToExport = @()
    ModuleList = @()
    FileList = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Azure', 'DevOps', 'Pipelines', 'GitHub', 'Actions', 'CI', 'CD', 'Build', 'Automation')
            LicenseUri = 'https://github.com/igoravl/PipelineUtils/blob/main/LICENSE'
            ProjectUri = 'https://github.com/igoravl/PipelineUtils'
            IconUri = ''
            Prerelease = ''
            ReleaseNotes = 'Version 0.2.0: Added support for GitHub Actions alongside Azure DevOps Pipelines'
            RequireLicenseAcceptance = $false
            ExternalModuleDependencies = @()
        }
    }
    HelpInfoURI = 'https://github.com/igoravl/PipelineUtils'
    DefaultCommandPrefix = ''
}
