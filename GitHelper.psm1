using namespace System
using namespace System.IO
using namespace System.Management.Automation
Set-StrictMode -Version Latest

if (Get-Module -Name 'GetLatest') {
    return
}

if (-not (Test-Path -Path 'variable:\global:AF4JMgitErrors')) {
    Set-Variable -Name 'AF4JMgitErrors' -Value $false -Scope 'Global'
}

if (-not (Test-Path -Path 'variable:\global:AF4JMsrcPath')) {
    Set-Variable -Name 'AF4JMsrcPath' -Value ([Path]::Combine(${env:SYSTEMDRIVE}, 'src')) -Scope 'Global'
}


function Initialize-Repository {
    <#
        .SYNOPSIS
        Initialize the current repository with a "master" branch tracking "origin/master" and an untracked "develop" branch.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(SupportsPaging = $false, SupportsShouldProcess = $false)]
    [Alias('Init-Repo')]
    PARAM()

    BEGIN {
        git branch --track 'master' 'origin/master'
        git branch --no-track 'develop' 'master'
        #git remote set-head 'origin' 'master' # fixes the remote having the wrong default branch
        npm install --global-style
        nuget restore -Recursive -NonInteractive
    }
}


function Get-GitDir {
    <#
        .SYNOPSIS
        Get the parent directory of the root of the current git repository.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        If the current location is in a git repository, the name of the parent folder; otherwise, $null.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(SupportsPaging = $false, SupportsShouldProcess = $false)]
    [Alias('gitdir')]
    [OutputType([String])]
    PARAM()

    BEGIN {
        $gitStatus = (Get-GitStatus)
        if (-not $gitStatus) {
            return $null
        }

        # (Get-GitStatus).GitDir is a string like 'C:\src\AF4JM\.git'
        # Split-Path -Parent strips off the trailing '\.git'
        # Split-Path -Leaf gets whatever is after the last remaining '\'
        Split-Path -Path (Split-Path -Path ($gitStatus.GitDir) -Parent) -Leaf
    }
}


function Set-Repository
{
    <#
        .SYNOPSIS
        Set the current location to the root of the specified repository.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Path', PositionalBinding = $true, SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('Set-Repo','repo')]
    PARAM(
        #repository to set current location to
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Repository must be specified')]
        [Alias('RepositoryName', 'RepoName')]
        [String]$Name,

        #path to repositories folder, ${global:AF4JMsrcPath} if not specified
        [Parameter(ParameterSetName = 'Path')]
        [Alias('PSPath')]
        [String]$Path = $null,

        #literal path to repositories folder, ${global:AF4JMsrcPath} if not specified
        [Parameter(ParameterSetName = 'LiteralPath')]
        [String]$LiteralPath = $null
    )

    BEGIN {
        $ThePath = $AF4JMsrcPath
        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                if ($Path) {
                    $ThePath = $Path
                }

                Set-Location -Path ([Path]::Combine($ThePath, $Name))
            }
            'LiteralPath' {
                if ($LiteralPath) {
                    $ThePath = $LiteralPath
                }

                Set-Location -LiteralPath ([Path]::Combine($ThePath, $Name))
            }
        }
    }
}


function Switch-GitBranch {
    <#
        .SYNOPSIS
        Set the current location to the root of the specified repository.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(PositionalBinding = $true, SupportsPaging = $false, SupportsShouldProcess = $false)]
    [Alias('checkout')]
    PARAM(
        #name of the branch to checkout
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Branch name must be specified')]
        [Alias('BranchName')]
        [String]$Name,

        #passed to git checkout
        [Parameter()]
        [Switch]$Force
    )

    BEGIN {
        $command = "git checkout $(IIf { $Force } '--force ' '') `"${Name}`""
        git checkout $(IIf { $Force } '--force' $null) $Name 2>&1 |
            ForEach-Object -Process { Show-GitProgress -Id 1 -command $command -theItem $PSItem -Verbose:$false }
    }
}


function Add-TrackingBranch {
    <#
        .SYNOPSIS
        Create a remote tracking branch in the current git repository.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(PositionalBinding = $true, SupportsPaging = $false, SupportsShouldProcess = $false)]
    [Alias('gittrack')]
    PARAM(
        #Name of the remote branch to track. Will also be used as the name of the local tracking branch.
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Branch must be specified')]
        [String]$Branch
    )

    BEGIN {
        git branch --track $Branch "origin/${Branch}"
    }
}


function Remove-Branch {
    <#
        .SYNOPSIS
        Drop the specified local branch from the current git repository.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', PositionalBinding = $true, SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('gitdrop')]
    PARAM(
        #Name of the local branch to drop.
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Branch must be specified')]
        [String]$Branch
    )

    BEGIN {
        if ($PSCmdlet.ShouldProcess($Branch, 'git branch -d')) {
            git branch -d $Branch
        }
    }
}


function Publish-Develop {
    <#
        .SYNOPSIS
        Rebase 'master' on 'develop' and push 'master'.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(SupportsPaging = $false, SupportsShouldProcess = $false)]
    [Alias('pushdev')]
    PARAM()

    BEGIN {
        $gitStatus = Get-GitStatus -Verbose:$false
        if (-not $gitStatus) {
            throw 'Not a git repository!'
        }

        $branch = $gitStatus.Branch
        if (-not ($branch -eq 'master')) {
            Switch-GitBranch -Name 'master' -Verbose:$false
        }
        git rebase 'develop' --stat 2>&1 |
            ForEach-Object -Process { Show-GitProgress -Id 2 -command 'git rebase "develop"' -theItem $PSItem -Verbose:$false }
        git push 2>&1 |
            ForEach-Object -Process { Show-GitProgress -Id 3 -command 'git push' -theItem $PSItem -Verbose:$false }
        if (-not ($branch -eq 'master')) {
            Switch-GitBranch -Name $branch -Verbose:$false
        }
    }
}


function Publish-DevelopAlt {
    <#
        .SYNOPSIS
        Rebase 'development' on 'develop' and push 'development'.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(SupportsPaging = $false, SupportsShouldProcess = $false)]
    [Alias('pushdeva')]
    PARAM()

    BEGIN {
        $gitStatus = Get-GitStatus -Verbose:$false
        if (-not $gitStatus) {
            throw 'Not a git repository!'
        }

        $branch = $gitStatus.Branch
        if (-not ($branch -eq 'development')) {
            Switch-GitBranch -Name 'development' -Verbose:$false
        }
        git rebase 'develop' --stat 2>&1 |
            ForEach-Object -Process { Show-GitProgress -Id 2 -command 'git rebase "develop"' -theItem $PSItem -Verbose:$false }
        git push 2>&1 |
            ForEach-Object -Process { Show-GitProgress -Id 3 -command 'git push' -theItem $PSItem -Verbose:$false }
        if (-not ($branch -eq 'development')) {
            Switch-GitBranch -Name $branch -Verbose:$false
        }
    }
}


function Update-Develop {
    <#
        .SYNOPSIS
        Pull 'master' and rebase 'develop'.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(SupportsPaging = $false, SupportsShouldProcess = $false)]
    [Alias('pulldev')]
    PARAM()

    BEGIN {
        $gitStatus = Get-GitStatus -Verbose:$false
        if (-not $gitStatus) {
            throw 'Not a git repository!'
        }

        $branch = $gitStatus.Branch
        if (-not ($branch -eq 'master')) {
            Switch-GitBranch -Name 'master' -Verbose:$false
        }
        Read-Repository
        git rebase --stat 2>&1 |
            ForEach-Object -Process { Show-GitProgress -Id 4 -command 'git rebase' -theItem $PSItem -Verbose:$false }
        Switch-GitBranch -Name 'develop' -Verbose:$false
        git rebase 'master' --stat 2>&1 |
            ForEach-Object -Process { Show-GitProgress -Id 5 -command 'git rebase "master"' -theItem $PSItem -Verbose:$false }
        if (-not ($branch -eq 'develop')) {
            Switch-GitBranch -Name $branch -Verbose:$false
        }
    }
}


function Update-DevelopAlt {
    <#
        .SYNOPSIS
        Pull 'development' and rebase 'develop'.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(SupportsPaging = $false, SupportsShouldProcess = $false)]
    [Alias('pulldeva')]
    PARAM()

    BEGIN {
        $gitStatus = Get-GitStatus -Verbose:$false
        if (-not $gitStatus) {
            throw 'Not a git repository!'
        }

        $branch = $gitStatus.Branch
        if (-not ($branch -eq 'master')) {
            Switch-GitBranch -Name 'master' -Verbose:$false
        }
        Read-Repository
        git rebase --stat 2>&1 |
            ForEach-Object -Process { Show-GitProgress -Id 6 -command 'git rebase' -theItem $PSItem -Verbose:$false }
        Switch-GitBranch -Name 'development' -Verbose:$false
        git rebase --stat 2>&1 |
            ForEach-Object -Process { Show-GitProgress -Id 7 -command 'git rebase' -theItem $PSItem -Verbose:$false }
        Switch-GitBranch -Name 'develop' -Verbose:$false
        git rebase 'development' --stat 2>&1 |
            ForEach-Object -Process { Show-GitProgress -Id 8 -command 'git rebase "development"' -theItem $PSItem -Verbose:$false }
        if (-not ($branch -eq 'develop')) {
            Switch-GitBranch -Name $branch -Verbose:$false
        }
    }
}


function Read-Repository {
    <#
        .SYNOPSIS
        Fetch the current git repository.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .EXAMPLE
        Read-Repository -Name 'myRepo'
        .EXAMPLE
        'myRepo1','myRepo2','myRepo3' | Read-Repo
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('Read-Repo')]
    PARAM()

    BEGIN {
        $gitDir = (Get-GitDir)
        if (($gitDir) -and $PSCmdlet.ShouldProcess($gitDir, 'git fetch --all --tags --prune')) {
            $command = "${gitDir}: git fetch --all --tags --prune"
            git fetch --all --tags --prune --progress 2>&1 |
                ForEach-Object -Process { Show-GitProgress -Id 9 -command $command -theItem $PSItem -Verbose:$false }
        }
    }
}


function Update-Branch {
    <#
        .SYNOPSIS
        Git checkout & rebase the current or specified branch.
        .DESCRIPTION
        Checks out the local tracking branch and rebases it on the origin branch of the same name, for each branch specified, assumes the current directory is in the git repository.
        .INPUTS
        The branch name.
        .OUTPUTS
        Pipeline input, if -PassThru is $true; otherwise this function does not generate any output.
        .EXAMPLE
        git for-each-ref refs/heads --format="%(refname:short)" --sort=-committerdate | Update-Branch
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', PositionalBinding = $false, SupportsPaging = $false, SupportsShouldProcess = $true)]
    PARAM(
        #string array of local tracking branches. If omitted rebases the current branch only
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [Alias('BranchName')]
        [String[]]$Name = $null,

        #Indicates whether the output of this function should be the function input or nothing.
        [Parameter()]
        [Switch]$PassThru
    )

    BEGIN {
        if (($null -eq $Name) -or ($Name.Length -le 0)) {
            $Name = ,((Get-GitStatus).Branch)
        }

        if ($AF4JMgitErrors) {
            ${local:ErrorView} = ${global:ErrorView}
            ${global:ErrorView} = 'CategoryView' # better display in alternate shells for git dumping status to stderr instead of stdout
        }
    }

    PROCESS {
        foreach ($refname in $Name) {
            if ($PSCmdlet.ShouldProcess($refname, 'git checkout --force')) {
                Switch-GitBranch -Name $refname -Force -Verbose:$false
            }

            $gitStatus = (Get-GitStatus)
            if ((($gitStatus.AheadBy -gt 0) -or ($gitStatus.BehindBy -gt 0)) -and $PSCmdlet.ShouldProcess("origin/${refname}", 'git rebase')) {
                git rebase --stat 2>&1 |
                    ForEach-Object -Process { Show-GitProgress -Id 10 -command 'git rebase' -theItem $PSItem -Verbose:$false }
            }
        }

        if ($PassThru) {
            $PSItem
        }
    }

    END {
        if ($AF4JMgitErrors) {
            ${global:ErrorView} = ${local:ErrorView}
        }
    }
}


function Update-Repository {
    <#
        .SYNOPSIS
        Get latest on a specified git repository.
        .DESCRIPTION
        Get latest on a specified git repository, rebase all known remote tracking branches.
        .INPUTS
        The repository name.
        .OUTPUTS
        Pipeline input, if -PassThru is $true; otherwise this function does not generate any output.
        .EXAMPLE
        Update-Repository -Name 'myRepo'
        .EXAMPLE
        'myRepo1','myRepo2','myRepo3' | Update-Repo
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Path', PositionalBinding = $false, SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('Update-Repo')]
    PARAM(
        #repositories to get latest on
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $true, Position = 0, HelpMessage = 'Repository must be specified')]
        [ValidateNotNullOrEmpty()]
        [Alias('RepositoryName', 'RepoName')]
        [String[]]$Name,

        #path to repositories folder, ${global:AF4JMsrcPath} if not specified
        [Parameter(ParameterSetName = 'Path')]
        [Alias('PSPath')]
        [String]$Path = $null,

        #literal path to repositories folder, ${global:AF4JMsrcPath} if not specified
        [Parameter(ParameterSetName = 'LiteralPath')]
        [String]$LiteralPath = $null,

        #switch which when specified indicates that current changes should be reset instead of stashed before getting latest and popped when done
        [Parameter()]
        [Alias('r')]
        [Switch]$Reset,

        #Indicates whether the output of this function should be the function input or nothing.
        [Parameter()]
        [Switch]$PassThru
    )

    BEGIN {
        $ThePath = $AF4JMsrcPath
        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                if ($Path) {
                    $ThePath = $Path
                }
            }
            'LiteralPath' {
                if ($LiteralPath) {
                    $ThePath = $LiteralPath
                }
            }
        }

        Push-Location
        if ($AF4JMgitErrors) {
            ${local:ErrorView} = ${global:ErrorView}
            ${global:ErrorView} = 'CategoryView' # better display in alternate shells for git dumping status to stderr instead of stdout
        }
    }

    PROCESS {
        foreach ($r in $Name) {
            switch ($PSCmdlet.ParameterSetName) {
                'Path' {
                    Set-Location -Path ([Path]::Combine($ThePath, $r))
                }
                'LiteralPath' {
                    Set-Location -LiteralPath ([Path]::Combine($ThePath, $r))
                }
            }

            $branch = (Get-GitStatus -Verbose:$false).Branch

            $stashCount = 0
            $shouldUnstash = $false
            if ((-not $Reset) -and $PSCmdlet.ShouldProcess("${r}/${branch}", 'git stash save --include-untracked')) {
                $stashCount = [int](git stash list | Measure-Object -Verbose:$false).Count
                git stash save --include-untracked
                if (([int](git stash list | Measure-Object -Verbose:$false).Count) -gt $stashCount) {
                    $shouldUnstash = $true
                }
            }

            # shouldn't have to pass Verbose, but if I don't it doesn't work
            Read-Repository -Verbose:($VerbosePreference -ne [ActionPreference]::SilentlyContinue)

            # get all local branches, filter down to remote tracking branches, short name only, call Update-Branch
            git for-each-ref 'refs/heads' --format="%(refname:short)~%(upstream)" --sort="committerdate" |
                Where-Object -FilterScript { $PSItem.split("~")[1].Length -gt 0 } |
                ForEach-Object -Process { $PSItem.split('~')[0] } |
                Update-Branch -Verbose:($VerbosePreference -ne [ActionPreference]::SilentlyContinue)

            if (((Get-GitStatus -Verbose:$false).Branch -ne $branch) -and $PSCmdlet.ShouldProcess($branch, 'git checkout --force')) {
                Switch-GitBranch -Name $branch -Force -Verbose:$false
            }

            if ((-not $Reset) -and (-not $shouldUnstash)) {
                Write-Verbose -Message "No changes found to stash for `"${r}/${branch}`", skipping `"git stash pop`"."
            } elseif ($shouldUnstash -and $PSCmdlet.ShouldProcess($branch, 'git stash pop')) {
                git stash pop
            }
        }

        if ($PassThru) {
            $PSItem
        }
    }

    END {
        Pop-Location
        if ($global:AF4JMgitErrors) {
            $global:ErrorView = $local:ErrorView
        }
    }
}


function Update-DevelopBranch {
    <#
        .SYNOPSIS
        Sync 'develop' branch to 'master' branch on a specified git repository.
        .DESCRIPTION
        Intended to be run immediately after Read-Repository.  Read-Repository updates any and all tracking branches, this function rebases "develop" on "master".
        .INPUTS
        The repository name.
        .OUTPUTS
        Pipeline input, if -PassThru is $true; otherwise this function does not generate any output.
        .EXAMPLE
        Update-DevelopBranch -Name 'myRepo'
        .EXAMPLE
        'myRepo1','myRepo2','myRepo3' | Update-Dev
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Path', PositionalBinding = $false, SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('Update-Dev')]
    PARAM(
        #repositories to get latest on
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $true, Position = 0, HelpMessage = 'Repository must be specified')]
        [ValidateNotNullOrEmpty()]
        [Alias('RepositoryName', 'RepoName')]
        [String[]]$Name,

        #path to repositories folder, ${global:AF4JMsrcPath} if not specified
        [Parameter(ParameterSetName = 'Path')]
        [Alias('PSPath')]
        [String]$Path = $null,

        #literal path to repositories folder, ${global:AF4JMsrcPath} if not specified
        [Parameter(ParameterSetName = 'LiteralPath')]
        [String]$LiteralPath = $null,

        #switch which when specified indicates that current changes should be reset instead of stashed before getting latest and popped when done
        [Parameter()]
        [Alias('r')]
        [Switch]$Reset,

        #Indicates whether the output of this function should be the function input or nothing.
        [Parameter()]
        [Switch]$PassThru
    )

    BEGIN {
        $ThePath = $AF4JMsrcPath
        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                if ($Path) {
                    $ThePath = $Path
                }
            }
            'LiteralPath' {
                if ($LiteralPath) {
                    $ThePath = $LiteralPath
                }
            }
        }

        Push-Location
        if ($AF4JMgitErrors) {
            ${local:ErrorView} = ${global:ErrorView}
            ${global:ErrorView} = 'CategoryView' # better display in alternate shells for git dumping status to stderr instead of stdout
        }

        $Id = 12
    }

    PROCESS {
        foreach ($r in $Name) {
            $Id += 1
            switch ($PSCmdlet.ParameterSetName) {
                'Path' {
                    Set-Location -Path ([Path]::Combine($ThePath, $r))
                }
                'LiteralPath' {
                    Set-Location -LiteralPath ([Path]::Combine($ThePath, $r))
                }
            }

            $branch = (Get-GitStatus -Verbose:$false).Branch

            $stashCount = 0
            $shouldUnstash = $false
            if ((-not $Reset) -and $PSCmdlet.ShouldProcess("${r}/${branch}", 'git stash save --include-untracked')) {
                $stashCount = [int](git stash list | Measure-Object -Verbose:$false).Count
                git stash save --include-untracked
                if (([int](git stash list | Measure-Object -Verbose:$false).Count) -gt $stashCount) {
                    $shouldUnstash = $true
                }
            }

            if (-not ($branch -eq 'develop')) {
                Switch-GitBranch -Name 'develop' -Verbose:$false
            }
            git rebase 'master' --stat 2>&1 |
                ForEach-Object -Process { Show-GitProgress -Id $Id -command 'git rebase "master"' -theItem $PSItem -Verbose:$false }
            if (-not ($branch -eq 'develop')) {
                Switch-GitBranch -Name $branch -Verbose:$false
            }

            if ((-not $Reset) -and (-not $shouldUnstash)) {
                Write-Verbose -Message "No changes found to stash for `"${r}/${branch}`", skipping `"git stash pop`"."
            } elseif ($shouldUnstash -and $PSCmdlet.ShouldProcess($branch, 'git stash pop')) {
                git stash pop
            }
        }

        if ($PassThru) {
            $PSItem
        }
    }

    END {
        Pop-Location
        if ($global:AF4JMgitErrors) {
            $global:ErrorView = $local:ErrorView
        }
    }
}


function Optimize-Repository {
    <#
        .SYNOPSIS
        Optimize a specified git repository.
        .DESCRIPTION
        Runs "git gc --aggressive" on the specified repository.
        .INPUTS
        The repository name.
        .OUTPUTS
        Pipeline input, if -PassThru is $true; otherwise this function does not generate any output.
        .EXAMPLE
        Optimize-Repository -Name 'myRepo'
        .EXAMPLE
        'myRepo1','myRepo2','myRepo3' | Optimize-Repo
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Path', PositionalBinding = $false, SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('Optimize-Repo')]
    PARAM(
        #repositories to get latest on
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $true, Position = 0, HelpMessage = 'Repository must be specified')]
        [ValidateNotNullOrEmpty()]
        [Alias('RepositoryName', 'RepoName')]
        [String[]]$Name,

        #path to repositories folder, ${global:AF4JMsrcPath} if not specified
        [Parameter(ParameterSetName = 'Path')]
        [Alias('PSPath')]
        [String]$Path = $null,

        #literal path to repositories folder, ${global:AF4JMsrcPath} if not specified
        [Parameter(ParameterSetName = 'LiteralPath')]
        [String]$LiteralPath = $null,

        #Indicates whether the output of this function should be the function input or nothing.
        [Parameter()]
        [Switch]$PassThru
    )

    BEGIN {
        $ThePath = $AF4JMsrcPath
        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                if ($Path) {
                    $ThePath = $Path
                }
            }
            'LiteralPath' {
                if ($LiteralPath) {
                    $ThePath = $LiteralPath
                }
            }
        }

        Push-Location
        if ($AF4JMgitErrors) {
            ${local:ErrorView} = ${global:ErrorView}
            ${global:ErrorView} = 'CategoryView' # better display in alternate shells for git dumping status to stderr instead of stdout
        }

        $Id = 34
    }

    PROCESS {
        foreach ($r in $Name) {
            $Id += 1
            switch ($PSCmdlet.ParameterSetName) {
                'Path' {
                    Set-Location -Path ([Path]::Combine($ThePath, $r))
                }
                'LiteralPath' {
                    Set-Location -LiteralPath ([Path]::Combine($ThePath, $r))
                }
            }

            git gc --aggressive 2>&1 |
                ForEach-Object -Process { Show-GitProgress -Id $Id -command 'git gc --aggressive' -theItem $PSItem -Verbose:$false }
        }

        if ($PassThru) {
            $PSItem
        }
    }

    END {
        Pop-Location
        if ($global:AF4JMgitErrors) {
            $global:ErrorView = $local:ErrorView
        }
    }
}


function Publish-Repository {
    <#
        .SYNOPSIS
        Push to a specified git repository.
        .INPUTS
        The repository name.
        .OUTPUTS
        Pipeline input, if -PassThru is $true; otherwise this function does not generate any output.
        .EXAMPLE
        Publish-Repository -Name 'myRepo'
        .EXAMPLE
        'myRepo1','myRepo2','myRepo3' | Pub-Repo
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Path', PositionalBinding = $false, SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('Pub-Repo')]
    PARAM(
        #repositories to get latest on
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $true, Position = 0, HelpMessage = 'Repository must be specified')]
        [Alias('RepositoryName', 'RepoName')]
        [String[]]$Name,

        #path to repositories folder, ${global:AF4JMsrcPath} if not specified
        [Parameter(ParameterSetName = 'Path')]
        [Alias('PSPath')]
        [String]$Path = $null,

        #literal path to repositories folder, ${global:AF4JMsrcPath} if not specified
        [Parameter(ParameterSetName = 'LiteralPath')]
        [String]$LiteralPath = $null,

        #Indicates whether the output of this function should be the function input or nothing.
        [Parameter()]
        [Switch]$PassThru
    )

    BEGIN {
        $ThePath = $AF4JMsrcPath
        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                if ($Path) {
                    $ThePath = $Path
                }
            }
            'LiteralPath' {
                if ($LiteralPath) {
                    $ThePath = $LiteralPath
                }
            }
        }

        Push-Location
        $Id = 56
    }

    PROCESS {
        foreach ($r in $Name) {
            $Id += 1
            switch ($PSCmdlet.ParameterSetName) {
                'Path' {
                    Set-Location -Path ([Path]::Combine($ThePath, $r))
                }
                'LiteralPath' {
                    Set-Location -LiteralPath ([Path]::Combine($ThePath, $r))
                }
            }

            if ($WhatIfPreference) {
                git push 'origin' --porcelain --dry-run
            } elseif ($PSCmdlet.ShouldProcess($r, 'git push "origin"')) {
                $gitDir = (Get-GitDir)

                $command = "${gitDir}: git push `"origin`""
                git push 'origin' --porcelain 2>&1 |
                    ForEach-Object -Process { Show-GitProgress -Id $Id -command $command -theItem $PSItem -Verbose:$false }
            }
        }

        if ($PassThru) {
            $PSItem
        }
    }

    END {
        Pop-Location
    }
}


function Reset-RepositoryCache
{
    <#
        .SYNOPSIS
        Reset the cache for the specified repository.  WARNING: This will undo all uncommitted changes.
        .INPUTS
        The repository name.
        .OUTPUTS
        Pipeline input, if -PassThru is $true; otherwise this function does not generate any output.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Path', PositionalBinding = $false, SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('Reset-RepoCache')]
    [Alias('gitfix')]
    PARAM(
        #repositories to reset the cache on
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $true, Position = 0, HelpMessage = 'Repository must be specified')]
        [Alias('RepositoryName', 'RepoName')]
        [String[]]$Name,

        #path to repositories folder, ${global:AF4JMsrcPath} if not specified
        [Parameter(ParameterSetName = 'Path')]
        [Alias('PSPath')]
        [String]$Path = $null,

        #literal path to repositories folder, ${global:AF4JMsrcPath} if not specified
        [Parameter(ParameterSetName = 'LiteralPath')]
        [String]$LiteralPath = $null,

        #Indicates whether the output of this function should be the function input or nothing.
        [Parameter()]
        [Switch]$PassThru
    )

    BEGIN {
        $ThePath = $AF4JMsrcPath
        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                if ($Path) {
                    $ThePath = $Path
                }
            }
            'LiteralPath' {
                if ($LiteralPath) {
                    $ThePath = $LiteralPath
                }
            }
        }

        Push-Location
        $Id = 78
    }

    PROCESS {
        foreach ($r in $Name) {
            $Id += 1
            switch ($PSCmdlet.ParameterSetName) {
                'Path' {
                    Set-Location -Path ([Path]::Combine($ThePath, $r))
                }
                'LiteralPath' {
                    Set-Location -LiteralPath ([Path]::Combine($ThePath, $r))
                }
            }

            if ($PSCmdlet.ShouldProcess($r, 'git rm --cached -r .')) {
                git rm --cached -r .
            }

            if ($PSCmdlet.ShouldProcess($r, 'git reset --hard')) {
                git reset --hard 2>&1 |
                    ForEach-Object -Process { Show-GitProgress -Id $Id -command 'git reset --hard' -theItem $PSItem -Verbose:$false }
            }
        }

        if ($PassThru) {
            $PSItem
        }
    }

    END {
        Pop-Location
    }
}


function Show-GitProgress {
    <#
        .SYNOPSIS
        Update a progress bar for a git operation.
        .DESCRIPTION
        Update a progress bar for a git operation.  Anything not parsable as progress is written to standard output.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright (c) John Meyer. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/master/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', SupportsPaging = $false, SupportsShouldProcess = $false)]
    PARAM(
        #output from git to parse for progress
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ValueFromRemainingArguments = $true, Position = 0, HelpMessage = '$PSItem must be specified')]
        [Object[]]$theItem,

        #command to display for the progress bar
        [Parameter()]
        [String]$command,

        #command to display for the progress bar
        [Parameter()]
        [Int]$Id = 0
    )

    PROCESS {
        foreach ($i in $theItem) {
            $item = $i.ToString()
            $parsed = $item -split { $PSItem -eq '(' -or $PSItem -eq '/' -or $PSItem -eq ')' }
            if ($item.Contains('done') -or $item.Contains('complete')) {
                Write-Progress -Id $Id -ParentId -1 -Activity $command -SecondsRemaining 0 -PercentComplete 100
                Write-Progress -Id $Id -ParentId -1 -Activity $command -SecondsRemaining -1 -PercentComplete -1 -Complete:$true
                Write-Output -InputObject $item
            } elseif ($parsed.Length -eq 4) {
                try { # calculate the %
                    $pct = [int]((([int]$parsed[1]) / ([int]$parsed[2])) * 100)
                    $progress = $item -split ':',2
                    Write-Progress -Id $Id -ParentId -1 -Activity $command -CurrentOperation $progress[0] -Status $progress[1] -SecondsRemaining -1 -PercentComplete $pct
                } catch { # calculation failed, just display the message
                    Write-Output -InputObject $item
                }
            } else {
                Write-Output -InputObject $item
            }
        }
    }
}
