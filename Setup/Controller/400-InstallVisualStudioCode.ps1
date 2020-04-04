###############################################################################
#.SYNOPSIS
#   Install Visual Studio Code and the PowerShell extension.
#
#.NOTES
#   Need to install the PoSh extension, but wait at least 10 seconds before trying.
#   Do not overwrite settings file until after the posh extension is installed.
#   Code.cmd is not in PATH until after shell is reopened.
#   
#   Settings: %APPDATA%\Code\User\settings.json
#   Extensions: %USERPROFILE%\.vscode\extensions
#   code.cmd:  C:\Program Files\Microsoft VS Code\bin\code.cmd
#   code.cmd: C:\PROGRA~1\MICROS~1\bin\code.cmd
###############################################################################

#VSCode
if (-not (Test-Path -Path "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd"))
{
    # Install VSCode:
    $setup = dir .\Resources\VisualStudioCode\*setup*.exe | select -Last 1
    Invoke-Expression -Command ($setup.FullName + ' /VERYSILENT /SUPPRESSMSGBOXES /MERGETASKS=!runcode')

    # Wait a bit...
    do { Start-Sleep -Seconds 10 } 
    until ( Test-Path -Path "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd") 
}



#PoSh Extension for VSCode:
$exts = @( dir -Directory -Path "$env:UserProfile\.vscode\extensions\*powershell*" -ErrorAction SilentlyContinue )

if ($exts.Count -eq 0)
{
    # Still need to wait longer before continuing, not sure what to test for instead:
    Start-Sleep -Seconds 10 

    # Get full path to vsix file:
    $vsix = dir .\Resources\VisualStudioCode\*PowerShell*.vsix | select -Last 1
    $vsix = $vsix.FullName

    # Escape stinkin space characters so that Invoke-Expression doesn't puke...
    # But the loader.js script called by code.cmd doesn't handle this well.
    #$cmd4 = "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd" -replace ' ','` '
    
    # Switch into folder with code.cmd:
    cd "$env:ProgramFiles\Microsoft VS Code\bin\"

    # Must place $null in single quotes to avoid premature substitution:
    Invoke-Expression -Command (".\code.cmd --install-extension $vsix 2>" + '$null | Out-Null')

    # Wait a bit before creating the settings.json file or else the settings wont stick:
    Start-Sleep -Seconds 15
}


# Overwrite settings.json to reduce VSCode annoyances to a minimum.
# This must be done after the PoSh extension is installed, not before. 
$theJson = @'
{
    "workbench.startupEditor": "newUntitledFile",
    "telemetry.enableTelemetry": false,
    "telemetry.enableCrashReporter": false,
    "update.mode": "none",
    "extensions.ignoreRecommendations": true,
    "powershell.codeFormatting.newLineAfterCloseBrace": false,
    "powershell.codeFormatting.openBraceOnSameLine": false,
    "powershell.codeFormatting.newLineAfterOpenBrace": false,
    "powershell.codeFormatting.whitespaceAfterSeparator": false,
    "powershell.codeFormatting.whitespaceAroundOperator": false,
    "powershell.codeFormatting.WhitespaceAroundPipe": false,
    "powershell.codeFormatting.whitespaceBeforeOpenBrace": false,
    "powershell.codeFormatting.whitespaceBeforeOpenParen": false,
    "powershell.codeFormatting.WhitespaceInsideBrace": false,
    "powershell.helpCompletion": "Disabled",
    "powershell.integratedConsole.focusConsoleOnExecute": false,
    "powershell.promptToUpdatePowerShell": false,
    "powershell.scriptAnalysis.enable": false,
    "workbench.colorTheme": "PowerShell ISE",
    "powershell.codeFolding.showLastLine": false,
    "files.defaultLanguage": "powershell",
    "editor.minimap.enabled": false
}
'@

# Create or overwrite the VSCode settings file:
new-item -path $env:APPDATA\Code\User\settings.json -itemtype file -force | out-null
$theJson | Out-File -Encoding utf8 -Force -FilePath $env:APPDATA\Code\User\settings.json 


#Note: Start-Top.ps1 will return to the original $PWD again.

