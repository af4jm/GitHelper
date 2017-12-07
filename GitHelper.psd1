@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'GitHelper.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.1'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID = '2edc8277-948b-4027-b28f-9b8b73f51acb'

    # Author of this module
    Author = 'John Meyer, AF4JM'

    # Company or vendor of this module
    # CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE'

    # Description of the functionality provided by this module
    Description = 'A PowerShell module for working with git.'

    # Minimum version of the Windows PowerShell engine required by this module
    # PowerShellVersion = ''

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @('Initialize-Repository', 'Get-GitDir', 'Set-Repository', 'Switch-GitBranch', 'Add-TrackingBranch', 'Remove-Branch', 'Read-Repository', 'Publish-Develop', 'Publish-DevelopAlt', 'Sync-Develop', 'Sync-DevelopAlt', 'Sync-Branch', 'Sync-Repository', 'Optimize-Repository', 'Publish-Repository', 'Reset-RepoCache')

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @('Init-Repo', 'gitdir', 'Set-Repo', 'repo', 'checkout', 'gittrack', 'gitdrop', 'Read-Repo', 'pushdev', 'pushdeva', 'pulldev', 'pulldeva', 'Sync-Repo', 'Optimize-Repo', 'Pub-Repo', 'gitfix')

    # DSC resources to export from this module
    DscResourcesToExport = @()

    # List of all modules packaged with this module
    ModuleList = @()

    # List of all files packaged with this module
    FileList = @('GitHelper.psd1', 'GitHelper.psm1', 'en-US\about_GitHelper.help.txt')

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('git')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/af4jm/GitHelper/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/af4jm/GitHelper'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/af4jm/GitHelper/blob/master/CHANGELOG.md'

        } # End of PSData hashtable
    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}
