@{
    GUID = 'd0a9150d-a325-174b-b6a4-e3a24fed0aa9'
    Author = 'John Meyer, AF4JM'
    Copyright = '(c) John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE'
    Description = 'A PowerShell module for working with git.'
    ModuleVersion = '2.0'
    RootModule = 'GitHelper.psm1'
    NestedModules = @()
    RequiredModules = @()
    CmdletsToExport = @()
    FunctionsToExport = @('Initialize-Repository', 'Get-GitDir', 'Set-Repository', 'Switch-GitBranch', 'Add-TrackingBranch', 'Remove-Branch', 'Read-Repository', 'Publish-Develop', 'Publish-DevelopAlt', 'Sync-Develop', 'Sync-DevelopAlt', 'Sync-Branch', 'Sync-Repository', 'Optimize-Repository', 'Publish-Repository', 'Reset-RepoCache')
    AliasesToExport = @('Init-Repo', 'gitdir', 'Set-Repo', 'repo', 'checkout', 'gittrack', 'gitdrop', 'Read-Repo', 'pushdev', 'pushdeva', 'pulldev', 'pulldeva', 'Sync-Repo', 'Optimize-Repo', 'Pub-Repo', 'gitfix')
    VariablesToExport = @()
    ScriptsToProcess = @()
    FormatsToProcess = @()
    TypesToProcess = @()
    FileList = @('GitHelper.psd1', 'GitHelper.psm1', 'en-US\about_GitHelper.txt')
}
