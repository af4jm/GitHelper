# GitHelper
A PowerShell module for working with git.

This module can be used as is without dependencies, but to customize it it's recommended to specify the default parent folder for your repositories in `profile.ps1`.

Additionally, because of the way git dumps so much of its output to `STDERR` instead of `STDOUT`, it's also recommended to add the following if block to profile top improve the output display.  Setting that flag to `$true` switches `ErrorView` to `'CategorytView'` during git operations, and restores its original value upon completion. If it's not defined, it defaults to `$false`.

```powershell
${global:AF4JMsrcPath} = "C:\src" # default [System.IO.Path]::Combine(${env:SYSTEMDRIVE}, 'src')
if ($host.Name -eq 'ConsoleHost') {
    ${global:AF4JMgitErrors} = $false
    $PSDefaultParameterValues.Add('Format-Table:AutoSize', $true)
} else {
    ${global:AF4JMgitErrors} = $true
}
```
