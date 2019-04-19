@{
    IncludeRules = @(
        'PSAlignAssignmentStatement',
        'PSAvoidDefaultValueSwitchParameter',
        'PSAvoidGlobalVars',
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingComputerNameHardcoded',
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        'PSAvoidUsingEmptyCatchBlock',
        'PSAvoidUsingInvokeExpression',
        'PSAvoidUsingPlainTextForPassword',
        'PSAvoidUsingPositionalParameters',
        'PSAvoidUsingUserNameAndPasswordParams',
        'PSAvoidUsingWMICmdlet',
        'PSMissingModuleManifestField',
        'PSPlaceCloseBrace',
        'PSPlaceOpenBrace',
        'PSProvideCommentHelp',
        'PSReservedCmdletChar',
        'PSReservedParams',
        'PSShouldProcess',
        'PSUseApprovedVerbs',
        'PSUseCmdletCorrectly',
        'PSUseCompatibleCommands',
        'PSUseCompatibleSyntax',
        'PSUseCompatibleTypes',
        'PSUseConsistentIndentation',
        'PSUseConsistentWhitespace',
        'PSUseCorrectCasing',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSUsePSCredentialType',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseSingularNouns',
        'PSDSC*'
    )
    Rules = @{
        PSAlignAssignmentStatement = @{
            CheckHashtable = $true
            Enable = $true
        }
        PSPlaceCloseBrace = @{
            Enable = $true
            IgnoreOneLineBlock = $true
            NewLineAfter = $true
            NoEmptyLineBefore = $false
        }
        PSPlaceOpenBrace = @{
            Enable = $true
            IgnoreOneLineBlock = $true
            NewLineAfter = $true
            OnSameLine = $true
        }
        PSUseCompatibleCommmands = @{
            Enable = $true
            TargetProfiles = @(
                'win-48_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework'
                'win-48_x64_10.0.17763.0_6.1.3_x64_4.0.30319.42000_core'
            )
        }
        PSUseCompatibleSyntax = @{
            Enable = $true
            TargetVersions = @(
                '5.1',
                '6.2'
            )
        }
        PSUseCompatibleTypes = @{
            Enable = $true
            TargetProfiles = @(
                'win-48_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework'
                'win-48_x64_10.0.17763.0_6.1.3_x64_4.0.30319.42000_core'
            )
        }
        PSUseConsistentIndentation = @{
            Enable = $true
            IndentationSize = 4
            Kind = 'space'
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
        }
        PSUseConsistentWhitespace = @{
            CheckInnerBrace = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckPipe = $true
            CheckSeparator = $true
            Enable = $true
        }
        PSUseCorrectCasing = @{
            Enable = $true
        }
    }
}
