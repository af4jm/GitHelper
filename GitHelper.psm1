Set-StrictMode -Version Latest

if (Get-Module -Name 'GitHelper') {
    return
}

if (-not (Test-Path -Path 'variable:\Global:AF4JMgitErrors')) {
    ${Global:AF4JMgitErrors} = $false
}

if (-not (Test-Path -Path 'Env:src')) {
    ${Env:src} = (Join-Path -Path ((Get-Item -Path ${Env:HOME}).PSDrive.Root) -ChildPath 'src')
}


function Get-DefaultBranch {
    <#
        .SYNOPSIS
        Get the name of the default branch, typically "main" (or in older repositories "master").
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(SupportsPaging = $false, SupportsShouldProcess = $false)]
    [Alias('head')]
    PARAM()

    BEGIN {
        (git symbolic-ref --short refs/remotes/origin/HEAD) -ireplace 'origin/',''
    }
}


function Initialize-Repository {
    <#
        .SYNOPSIS
        Initialize the current repository with a default branch tracking origin's default branch and an untracked "develop" branch.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(SupportsPaging = $false, SupportsShouldProcess = $false)]
    [Alias('Init-Repo')]
    PARAM()

    BEGIN {
        $default = Get-DefaultBranch
        git branch --track $default "origin/${default}"
        git branch --no-track 'develop' $default
        #git remote set-head 'origin' 'main' # fixes the remote having the wrong default branch
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
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(SupportsPaging = $false, SupportsShouldProcess = $false)]
    [Alias('gitdir')]
    [OutputType([string])]
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


function Set-Repository {
    <#
        .SYNOPSIS
        Set the current location to the root of the specified repository.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Path', PositionalBinding = $true, SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('Set-Repo', 'repo')]
    PARAM(
        #repository to set current location to
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $true, Position = 0, HelpMessage = 'Repository must be specified')]
        [Alias('RepositoryName', 'RepoName')]
        [string]$Name,

        #path to repositories folder, ${Env:src} if not specified
        [Parameter(ParameterSetName = 'Path')]
        [Alias('PSPath')]
        [string]$Path = $null,

        #literal path to repositories folder, ${Env:src} if not specified
        [Parameter(ParameterSetName = 'LiteralPath')]
        [string]$LiteralPath = $null
    )

    BEGIN {
        $ThePath = ${Env:src}
        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                if ($Path) {
                    $ThePath = $Path
                }

                Set-Location -Path (Join-Path -Path $ThePath -ChildPath $Name)
            }
            'LiteralPath' {
                if ($LiteralPath) {
                    $ThePath = $LiteralPath
                }

                Set-Location -LiteralPath (Join-Path -Path $ThePath -ChildPath $Name)
            }
        }
    }
}


function Update-All {
    <#
        .SYNOPSIS
        Stage & commit all files, including new files.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Path', PositionalBinding = $true, SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('commit')]
    PARAM(
        #commit message
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $true, Position = 0, HelpMessage = 'Commit message must be specified')]
        [string]$Message
    )

    BEGIN {
        Remove-Item -Path (Join-Path -Path ${env:AppData} -ChildPath 'gnupg') -Include "*.lock" -Force
        git add --all
        git commit "--message=${Message}"
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
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
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
        [string]$Name,

        #passed to git checkout
        [Parameter()]
        [switch]$Force
    )

    BEGIN {
        git checkout $(IIf { $Force } '--force' $null) $Name
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
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
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
        [string]$Branch
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
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
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
        [string]$Branch
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
        Rebase default branch on 'develop' and push default branch. (git push --tags 'origin' ':')
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
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

        $default = Get-DefaultBranch
        $branch = $gitStatus.Branch

        if (-not ($branch -eq $default)) {
            Switch-GitBranch -Name $default -Verbose:$false
        }

        git rebase 'develop' --stat
        git push --tags 'origin' --progress ':'

        if (-not ($branch -eq $default)) {
            Switch-GitBranch -Name $branch -Verbose:$false
        }
    }
}


function Publish-DevelopAlt {
    <#
        .SYNOPSIS
        Rebase 'development' on 'develop' and push 'development'. (git push --tags 'origin' ':')
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
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

        git rebase 'develop' --stat
        git push --tags 'origin' --progress ':'

        if (-not ($branch -eq 'development')) {
            Switch-GitBranch -Name $branch -Verbose:$false
        }
    }
}


function Update-Develop {
    <#
        .SYNOPSIS
        Pull default branch and rebase 'develop'.
        .INPUTS
        You cannot pipe input to this function.
        .OUTPUTS
        Nothing is output from this function.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('pulldev')]
    PARAM()

    BEGIN {
        $gitStatus = Get-GitStatus -Verbose:$false
        if (-not $gitStatus) {
            throw 'Not a git repository!'
        }

        if ($PSCmdlet.ShouldProcess('current repository')) {
            $stashRef = (git stash create --include-untracked "work in progress (GitHelper)")

            $default = Get-DefaultBranch
            $branch = $gitStatus.Branch
            if (-not ($branch -eq $default)) {
                Switch-GitBranch -Name $default -Verbose:$false
            }

            Read-Repository
            git rebase --stat
            Switch-GitBranch -Name 'develop' -Verbose:$false
            git rebase $default --stat

            if (-not ($branch -eq 'develop')) {
                Switch-GitBranch -Name $branch -Verbose:$false
            }

            if (-not $stashRef) {
                Write-Verbose -Message "No changes found to stash for branch `"${branch}`", skipping `"git stash apply`"."
            } else {
                git stash apply $stashRef
            }
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
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('pulldeva')]
    PARAM()

    BEGIN {
        $gitStatus = Get-GitStatus -Verbose:$false
        if (-not $gitStatus) {
            throw 'Not a git repository!'
        }

        if ($PSCmdlet.ShouldProcess('current repository')) {
            $stashRef = (git stash create --include-untracked "work in progress (GitHelper)")

            $default = Get-DefaultBranch
            $branch = $gitStatus.Branch
            if (-not ($branch -eq $default)) {
                Switch-GitBranch -Name $default -Verbose:$false
            }

            Read-Repository
            git rebase --stat
            Switch-GitBranch -Name 'development' -Verbose:$false
            git rebase --stat
            Switch-GitBranch -Name 'develop' -Verbose:$false
            git rebase 'development' --stat

            if (-not ($branch -eq 'develop')) {
                Switch-GitBranch -Name $branch -Verbose:$false
            }

            if (-not $stashRef) {
                Write-Verbose -Message "No changes found to stash for branch `"${branch}`", skipping `"git stash apply`"."
            } else {
                git stash apply $stashRef
            }
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
        .NOTES
        Author: John Meyer, AF4JM
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('Read-Repo')]
    [Alias('fetch')]
    PARAM()

    BEGIN {
        $gitDir = (Get-GitDir)
        if (($gitDir) -and $PSCmdlet.ShouldProcess($gitDir, 'git fetch --all --tags --prune')) {
            git fetch --all --tags --prune --progress
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
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', PositionalBinding = $true, SupportsPaging = $false, SupportsShouldProcess = $true)]
    PARAM(
        #string array of local tracking branches. If omitted rebases the current branch only
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $true, Position = 0, HelpMessage = 'Branch must be specified')]
        [AllowEmptyCollection()]
        [Alias('BranchName')]
        [string[]]$Name = $null,

        #Indicates whether the output of this function should be the function input or nothing.
        [Parameter()]
        [switch]$PassThru
    )

    BEGIN {
        if (($null -eq $Name) -or ($Name.Length -le 0)) {
            $Name = , ((Get-GitStatus).Branch)
        }

        if (${Global:AF4JMgitErrors}) {
            ${Local:ErrorView} = ${Global:ErrorView}
            ${Global:ErrorView} = 'CategoryView' # better display in alternate shells for git dumping status to stderr instead of stdout
        }
    }

    PROCESS {
        if (($Name) -and ($Name.Length -gt 0)) {
            foreach ($refname in $Name) {
                if ($PSCmdlet.ShouldProcess($refname, 'git checkout --force')) {
                    Switch-GitBranch -Name $refname -Force -Verbose:$false
                }

                $gitStatus = (Get-GitStatus)
                if ((($gitStatus.AheadBy -gt 0) -or ($gitStatus.BehindBy -gt 0)) -and $PSCmdlet.ShouldProcess("origin/${refname}", 'git rebase')) {
                    git rebase --stat
                }
            }
        }

        if ($PassThru) {
            $PSItem
        }
    }

    END {
        if (${Global:AF4JMgitErrors}) {
            ${Global:ErrorView} = ${Local:ErrorView}
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
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Path', PositionalBinding = $true, SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('Update-Repo')]
    PARAM(
        #repositories to get latest on
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $true, Position = 0, HelpMessage = 'Repository must be specified')]
        [AllowEmptyCollection()]
        [Alias('RepositoryName', 'RepoName')]
        [string[]]$Name,

        #path to repositories folder, ${Env:src} if not specified
        [Parameter(ParameterSetName = 'Path')]
        [Alias('PSPath')]
        [string]$Path = $null,

        #literal path to repositories folder, ${Env:src} if not specified
        [Parameter(ParameterSetName = 'LiteralPath')]
        [string]$LiteralPath = $null,

        #switch which when specified indicates that current changes should be reset instead of stashed before getting latest and popped when done
        [Parameter()]
        [Alias('r')]
        [switch]$Reset,

        #Indicates whether the output of this function should be the function input or nothing.
        [Parameter()]
        [switch]$PassThru
    )

    BEGIN {
        $ThePath = ${Env:src}
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
        if (${Global:AF4JMgitErrors}) {
            ${Local:ErrorView} = ${Global:ErrorView}
            ${Global:ErrorView} = 'CategoryView' # better display in alternate shells for git dumping status to stderr instead of stdout
        }
    }

    PROCESS {
        if (($Name) -and ($Name.Length -gt 0)) {
            foreach ($r in $Name) {
                Write-Verbose -Message "Getting latest for `"${name}`"."

                switch ($PSCmdlet.ParameterSetName) {
                    'Path' {
                        Set-Location -Path (Join-Path -Path $ThePath -ChildPath $r)
                    }
                    'LiteralPath' {
                        Set-Location -LiteralPath (Join-Path -Path $ThePath -ChildPath $r)
                    }
                }

                $branch = (Get-GitStatus -Verbose:$false).Branch

                if ((-not $Reset) -and $PSCmdlet.ShouldProcess("${r}/${branch}", 'git stash create --include-untracked')) {
                    $stashRef = (git stash create --include-untracked 'work in progress (GitHelper)')
                }

                # shouldn't have to pass Verbose, but if I don't it doesn't work
                Read-Repository -Verbose:($VerbosePreference -ne [Management.Automation.ActionPreference]::SilentlyContinue)

                # get all local branches, filter down to remote tracking branches, short name only, call Update-Branch
                (git for-each-ref 'refs/heads' --format="%(refname:short)~%(upstream)" --sort="committerdate") |
                    Where-Object -FilterScript { $PSItem.split("~")[1].Length -gt 0 } |
                    ForEach-Object -Process { $PSItem.split('~')[0] } |
                    Update-Branch -Verbose:($VerbosePreference -ne [Management.Automation.ActionPreference]::SilentlyContinue)

                if (((Get-GitStatus -Verbose:$false).Branch -ne $branch) -and $PSCmdlet.ShouldProcess($branch, 'git checkout --force')) {
                    Switch-GitBranch -Name $branch -Force -Verbose:$false
                }

                if ((-not $Reset) -and (-not $stashRef)) {
                    Write-Verbose -Message "No changes found to stash for `"${r}/${branch}`", skipping `"git stash apply`"."
                } elseif ($stashRef -and $PSCmdlet.ShouldProcess($branch, "git stash apply ${stashRef}")) {
                    git stash apply $stashRef
                }
            }
        }

        if ($PassThru) {
            $PSItem
        }
    }

    END {
        Pop-Location
        if (${Global:AF4JMgitErrors}) {
            ${Global:ErrorView} = ${Local:ErrorView}
        }
    }
}


function Update-DevelopBranch {
    <#
        .SYNOPSIS
        Sync 'develop' branch to default branch on a specified git repository.
        .DESCRIPTION
        Intended to be run immediately after Read-Repository.  Read-Repository updates any and all tracking branches, this function rebases "develop" on default branch.
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
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Path', PositionalBinding = $true, SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('Update-Dev')]
    PARAM(
        #repositories to get latest on
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $true, Position = 0, HelpMessage = 'Repository must be specified')]
        [AllowEmptyCollection()]
        [Alias('RepositoryName', 'RepoName')]
        [string[]]$Name,

        #path to repositories folder, ${Env:src} if not specified
        [Parameter(ParameterSetName = 'Path')]
        [Alias('PSPath')]
        [string]$Path = $null,

        #literal path to repositories folder, ${Env:src} if not specified
        [Parameter(ParameterSetName = 'LiteralPath')]
        [string]$LiteralPath = $null,

        #switch which when specified indicates that current changes should be reset instead of stashed before getting latest and popped when done
        [Parameter()]
        [Alias('r')]
        [switch]$Reset,

        #Indicates whether the output of this function should be the function input or nothing.
        [Parameter()]
        [switch]$PassThru
    )

    BEGIN {
        $ThePath = ${Env:src}
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
        if (${Global:AF4JMgitErrors}) {
            ${Local:ErrorView} = ${Global:ErrorView}
            ${Global:ErrorView} = 'CategoryView' # better display in alternate shells for git dumping status to stderr instead of stdout
        }
    }

    PROCESS {
        if (($Name) -and ($Name.Length -gt 0)) {
            foreach ($r in $Name) {
                switch ($PSCmdlet.ParameterSetName) {
                    'Path' {
                        Set-Location -Path (Join-Path -Path $ThePath -ChildPath $r)
                    }
                    'LiteralPath' {
                        Set-Location -LiteralPath (Join-Path -Path $ThePath -ChildPath $r)
                    }
                }

                $default = Get-DefaultBranch
                $branch = (Get-GitStatus -Verbose:$false).Branch

                if ((-not $Reset) -and $PSCmdlet.ShouldProcess("${r}/${branch}", 'git stash create --include-untracked')) {
                    $stashRef = (git stash create --include-untracked "work in progress (GitHelper)")
                }

                if (-not ($branch -eq 'develop')) {
                    Switch-GitBranch -Name 'develop' -Verbose:$false
                }

                git rebase $default --stat

                if (-not ($branch -eq 'develop')) {
                    Switch-GitBranch -Name $branch -Verbose:$false
                }

                if ((-not $Reset) -and (-not $stashRef)) {
                    Write-Verbose -Message "No changes found to stash for `"${r}/${branch}`", skipping `"git stash apply`"."
                } elseif ($stashRef -and $PSCmdlet.ShouldProcess($branch, "git stash apply ${stashRef}")) {
                    git stash apply $stashRef
                }
            }
        }

        if ($PassThru) {
            $PSItem
        }
    }

    END {
        Pop-Location
        if (${Global:AF4JMgitErrors}) {
            ${Global:ErrorView} = ${Local:ErrorView}
        }
    }
}


function Update-DevelopBranchAlt {
    <#
        .SYNOPSIS
        Sync 'develop' branch to 'development' branch on a specified git repository.
        .DESCRIPTION
        Intended to be run immediately after Read-Repository.  Read-Repository updates any and all tracking branches, this function rebases "develop" on "development".
        .INPUTS
        The repository name.
        .OUTPUTS
        Pipeline input, if -PassThru is $true; otherwise this function does not generate any output.
        .EXAMPLE
        Update-DevelopBranchAlt -Name 'myRepo'
        .EXAMPLE
        'myRepo1','myRepo2','myRepo3' | Update-DevAlt
        .NOTES
        Author: John Meyer, AF4JM
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Path', PositionalBinding = $true, SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('Update-DevAlt')]
    PARAM(
        #repositories to get latest on
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $true, Position = 0, HelpMessage = 'Repository must be specified')]
        [AllowEmptyCollection()]
        [Alias('RepositoryName', 'RepoName')]
        [string[]]$Name,

        #path to repositories folder, ${Env:src} if not specified
        [Parameter(ParameterSetName = 'Path')]
        [Alias('PSPath')]
        [string]$Path = $null,

        #literal path to repositories folder, ${Env:src} if not specified
        [Parameter(ParameterSetName = 'LiteralPath')]
        [string]$LiteralPath = $null,

        #switch which when specified indicates that current changes should be reset instead of stashed before getting latest and popped when done
        [Parameter()]
        [Alias('r')]
        [switch]$Reset,

        #Indicates whether the output of this function should be the function input or nothing.
        [Parameter()]
        [switch]$PassThru
    )

    BEGIN {
        $ThePath = ${Env:src}
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
        if (${Global:AF4JMgitErrors}) {
            ${Local:ErrorView} = ${Global:ErrorView}
            ${Global:ErrorView} = 'CategoryView' # better display in alternate shells for git dumping status to stderr instead of stdout
        }
    }

    PROCESS {
        if (($Name) -and ($Name.Length -gt 0)) {
            foreach ($r in $Name) {
                switch ($PSCmdlet.ParameterSetName) {
                    'Path' {
                        Set-Location -Path (Join-Path -Path $ThePath -ChildPath $r)
                    }
                    'LiteralPath' {
                        Set-Location -LiteralPath (Join-Path -Path $ThePath -ChildPath $r)
                    }
                }

                $branch = (Get-GitStatus -Verbose:$false).Branch

                if ((-not $Reset) -and $PSCmdlet.ShouldProcess("${r}/${branch}", 'git stash create --include-untracked')) {
                    $stashRef = (git stash create --include-untracked "work in progress (GitHelper)")
                }

                if (-not ($branch -eq 'develop')) {
                    Switch-GitBranch -Name 'develop' -Verbose:$false
                }

                git rebase 'development' --stat

                if (-not ($branch -eq 'develop')) {
                    Switch-GitBranch -Name $branch -Verbose:$false
                }

                if ((-not $Reset) -and (-not $stashRef)) {
                    Write-Verbose -Message "No changes found to stash for `"${r}/${branch}`", skipping `"git stash apply`"."
                } elseif ($stashRef -and $PSCmdlet.ShouldProcess($branch, "git stash apply ${stashRef}")) {
                    git stash apply $stashRef
                }
            }
        }

        if ($PassThru) {
            $PSItem
        }
    }

    END {
        Pop-Location
        if (${Global:AF4JMgitErrors}) {
            ${Global:ErrorView} = ${Local:ErrorView}
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
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Path', PositionalBinding = $true, SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('Optimize-Repo')]
    PARAM(
        #repositories to get latest on
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $true, Position = 0, HelpMessage = 'Repository must be specified')]
        [AllowEmptyCollection()]
        [Alias('RepositoryName', 'RepoName')]
        [string[]]$Name,

        #path to repositories folder, ${Env:src} if not specified
        [Parameter(ParameterSetName = 'Path')]
        [Alias('PSPath')]
        [string]$Path = $null,

        #literal path to repositories folder, ${Env:src} if not specified
        [Parameter(ParameterSetName = 'LiteralPath')]
        [string]$LiteralPath = $null,

        #Indicates whether the output of this function should be the function input or nothing.
        [Parameter()]
        [switch]$PassThru
    )

    BEGIN {
        $ThePath = ${Env:src}
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
        if (${Global:AF4JMgitErrors}) {
            ${Local:ErrorView} = ${Global:ErrorView}
            ${Global:ErrorView} = 'CategoryView' # better display in alternate shells for git dumping status to stderr instead of stdout
        }
    }

    PROCESS {
        if (($Name) -and ($Name.Length -gt 0)) {
            foreach ($r in $Name) {
                switch ($PSCmdlet.ParameterSetName) {
                    'Path' {
                        Set-Location -Path (Join-Path -Path $ThePath -ChildPath $r)
                    }
                    'LiteralPath' {
                        Set-Location -LiteralPath (Join-Path -Path $ThePath -ChildPath $r)
                    }
                }

                Write-Verbose -Message "${r}: `"git gc --aggressive`""
                git gc --aggressive
            }
        }

        if ($PassThru) {
            $PSItem
        }
    }

    END {
        Pop-Location
        if (${Global:AF4JMgitErrors}) {
            ${Global:ErrorView} = ${Local:ErrorView}
        }
    }
}


function Publish-Repository {
    <#
        .SYNOPSIS
        Push to a specified git repository. (git push --tags 'origin' ':')
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
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Path', PositionalBinding = $true, SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('Pub-Repo')]
    PARAM(
        #repositories to get latest on
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $true, Position = 0, HelpMessage = 'Repository must be specified')]
        [AllowEmptyCollection()]
        [Alias('RepositoryName', 'RepoName')]
        [string[]]$Name,

        #path to repositories folder, ${Env:src} if not specified
        [Parameter(ParameterSetName = 'Path')]
        [Alias('PSPath')]
        [string]$Path = $null,

        #literal path to repositories folder, ${Env:src} if not specified
        [Parameter(ParameterSetName = 'LiteralPath')]
        [string]$LiteralPath = $null,

        #Indicates whether the output of this function should be the function input or nothing.
        [Parameter()]
        [switch]$PassThru
    )

    BEGIN {
        $ThePath = ${Env:src}
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
    }

    PROCESS {
        if (($Name) -and ($Name.Length -gt 0)) {
            foreach ($r in $Name) {
                switch ($PSCmdlet.ParameterSetName) {
                    'Path' {
                        Set-Location -Path (Join-Path -Path $ThePath -ChildPath $r)
                    }
                    'LiteralPath' {
                        Set-Location -LiteralPath (Join-Path -Path $ThePath -ChildPath $r)
                    }
                }

                if ($WhatIfPreference) {
                    git push --tags --porcelain --dry-run 'origin' ':'
                } elseif ($PSCmdlet.ShouldProcess($r, 'git push --tags "origin" ":"')) {
                    git push --tags --porcelain --progress 'origin' ':'
                }
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


function Reset-RepositoryCache {
    <#
        .SYNOPSIS
        Reset the cache for the specified repository.  WARNING: This will undo all uncommitted changes.
        .INPUTS
        The repository name.
        .OUTPUTS
        Pipeline input, if -PassThru is $true; otherwise this function does not generate any output.
        .NOTES
        Author: John Meyer, AF4JM
        Copyright © 2017-2025 John Meyer, AF4JM. Licensed under the MIT License. https://github.com/af4jm/GitHelper/blob/main/LICENSE
        .LINK
        https://www.powershellgallery.com/packages/GitHelper/
        .LINK
        https://github.com/af4jm/GitHelper/
    #>
    [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = 'Path', PositionalBinding = $true, SupportsPaging = $false, SupportsShouldProcess = $true)]
    [Alias('Reset-RepoCache')]
    [Alias('gitfix')]
    PARAM(
        #repositories to reset the cache on
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromRemainingArguments = $true, Position = 0, HelpMessage = 'Repository must be specified')]
        [AllowEmptyCollection()]
        [Alias('RepositoryName', 'RepoName')]
        [string[]]$Name,

        #path to repositories folder, ${Env:src} if not specified
        [Parameter(ParameterSetName = 'Path')]
        [Alias('PSPath')]
        [string]$Path = $null,

        #literal path to repositories folder, ${Env:src} if not specified
        [Parameter(ParameterSetName = 'LiteralPath')]
        [string]$LiteralPath = $null,

        #Indicates whether the output of this function should be the function input or nothing.
        [Parameter()]
        [switch]$PassThru
    )

    BEGIN {
        $ThePath = ${Env:src}
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
    }

    PROCESS {
        if (($Name) -and ($Name.Length -gt 0)) {
            foreach ($r in $Name) {
                switch ($PSCmdlet.ParameterSetName) {
                    'Path' {
                        Set-Location -Path (Join-Path -Path $ThePath -ChildPath $r)
                    }
                    'LiteralPath' {
                        Set-Location -LiteralPath (Join-Path -Path $ThePath -ChildPath $r)
                    }
                }

                if ($PSCmdlet.ShouldProcess($r, 'git rm --cached -r .')) {
                    git rm --cached -r .
                }

                if ($PSCmdlet.ShouldProcess($r, 'git reset --hard')) {
                    git reset --hard
                }
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
