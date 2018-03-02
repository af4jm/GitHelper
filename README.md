# GitHelper

A PowerShell module for working with git.  Install free from the [PowerShell Gallery](https://www.powershellgallery.com/packages/GitHelper/)

Because PowerShell only approves certain verbs, the following mapping is used...

* fetch --> Read
* pull --> Update
* push --> Publish
* pull & push --> Sync

This module can be used as is without dependencies, but to customize it it's recommended to specify the default parent folder for your repositories in `profile.ps1`.

Additionally, because of the way git dumps so much of its output to `STDERR` instead of `STDOUT` which causes many hosts to raise exceptions, it's also recommended to add the following if block to `profile.ps1` to improve the output display.  Setting that flag to `$true` switches `ErrorView` to `'CategoryView'` during git operations, and restores its original value upon completion. If it's not defined, it defaults to `$false`.  I've included my username in the setting simply to avoid conflicting with any other globals that may be defined elsewhere.

```powershell
${global:AF4JMsrcPath} = 'C:\src' # default [System.IO.Path]::Combine(${env:SYSTEMDRIVE}, 'src')
if ($host.Name -eq 'ConsoleHost') {
    ${global:AF4JMgitErrors} = $false
    $PSDefaultParameterValues.Add('Format-Table:AutoSize', $true)
} else {
    ${global:AF4JMgitErrors} = $true
}
```

Suggested usage (in a .ps1 file that gets . sourced from profile, the alias "gall" is a contraction of "get all")...

```powershell
function Update-MyRepos
{
    <#
        .SYNOPSIS
        Get latest on all my git repositories.
        .DESCRIPTION
        Get latest on all my git repositories, rebase all known remote tracking branches.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
    #>
    [CmdletBinding(ConfirmImpact = 'Low', SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('gall')]
    PARAM(
        #path to repositories folder, ${global:AF4JMsrcPath} if not specified
        [Parameter()]
        [Alias('PSPath')]
        [String]$Path = $null,

        #literal path to repositories folder, ${global:AF4JMsrcPath} if not specified
        [Parameter()]
        [String]$LiteralPath = $null
    )

    BEGIN {
        Update-Repository -Name 'myRepo1','myRepo2','myRepo3' -Path $Path -LiteralPath $LiteralPath -Verbose
    }
}
```
