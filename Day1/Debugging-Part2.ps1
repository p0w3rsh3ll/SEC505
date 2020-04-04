# See the Debugging-Part1.ps1 script for an introduction to debugging.
# The following is a list of more debugging and error-handling tips.



##############################################################################
# 
# Debug Context
# 
##############################################################################

# Launch an interactive PowerShell session nested inside the current session:
$host.EnterNestedPrompt()
$NestedPromptLevel  #Should be 1

$host.ExitNestedPrompt()
$NestedPromptLevel  #Should be 0


# If in debugging mode, the $PsDebugContext variable will not be $null, 
# which can be used in the Prompt() function in one's profile:
$PSDebugContext
$PSDebugContext.InvocationInfo     # Current location in the script
$PSDebugContext.BreakPoints        # Current breakpoint


# Display the current call stack, whether in or out of debugging mode:
Get-PSCallStack


# To display internal information about each command executing:
Set-PSDebug -Trace 2


# To be prompted for confirmation for every command to be run:
Set-PSDebug -Step


# To turn off the line-by-line prompting and tracing:
Set-PSDebug -Off



##############################################################################
# 
# Exceptions and Error Code Numbers
# 
##############################################################################

# The return error code number of native commands and 
# scripts is captured in the $LastExitCode variable:
$LASTEXITCODE


# When any command, native or otherwise, suffers an 
# error, $? will be set to $false:
$?


# The $error array is automatically updated with exceptions/errors as they occur:
$Error.Count         #Count of total errors from the session
$Error[0]            #The most recent, or last, error that occurred
$Error.Clear()       #Scrub the array clean, reset it
$Error[0] | Format-List * -Force   #Show all the details of an error object


# To create a custom terminating error and "throw" it:
throw "your message"


# To execute a command, catch any errors, and run post-error code:
try { "do something" } catch { "ooops" } finally { "clean up" } 



##############################################################################
# 
# Display Preferences
# 
##############################################################################

# To display non-terminating errors during execution:
$ErrorActionPreference = Continue           # This is the default, to display errors
Write-Error -Message "your message"         # Error messages are displayed by default
$ErrorActionPreference = SilentlyContinue   # Suppresses non-terminating error messages


# To display non-terminating warning messages during execution:
$WarningPreference = Continue           # This is the default, to display warnings
Write-Warning -Message "your message"   # Warnings are displayed by default
$WarningPreference = SilentlyContinue   # Suppress warnings


# To display optional debug output during execution:
$DebugPreference = Continue             # Display debug messges, even without -Debug switch
Write-Debug -Message "your message"     # Debug messages are not displayed by default, 
$DebugPreference = SilentlyContinue     # Back to default: do not display debug text


# To display optional verbose output during execution:
$VerbosePreference = Continue           # Display verbose output even without -Verbose switch
Write-Verbose -Message "your message"   # Verbose messages not displayed by default, 
$VerbosePreference = SilentlyContinue   # Back to default: do not display verbose text


# To display optional progress output during execution:
$ProgressPreference = Continue          # This is the default, to display progress messages 
Write-Progress -Activity "your message" # Progress is displayed by default, 
$ProgressPreference = SilentlyContinue  # Do not display progress information



##############################################################################
# 
# Tracing
# 
##############################################################################

# Tracing is capturing and displaying low-level or internal operations of PowerShell.
# There are several sources or categories of tracing information.  They can be listed:
Get-TraceSource


# Trace a command using all categories of information:
Trace-Command -Name * -Expression { ping.exe localhost } -PSHost



##############################################################################
# 
# Script Tokenization and AST 
# 
##############################################################################

# This will is very rarely done while debugging, but you can see how PowerShell chops up 
# a script into its components ("tokens") before execution of that script.
# Here is taste of what is possible:

# Get all tokens, then show only command tokens and their line numbers (PowerShell 2.0+):
$code = get-content $profile.CurrentUserAllHosts
$parseErrors = @()
$tokens = [System.Management.Automation.PSParser]::Tokenize( $code, [Ref]$parseErrors ) 
$tokens | where { $_.type -eq 'Command' } | format-table Content,StartLine -AutoSize
"Count of parsing errors = " + $parseErrors.Count
 

# Get the AST tokens and AST tree (PowerShell 3.0+, and not as easy to work with):
$astTokens = @()
$parseErrors = @()
$ast = [System.Management.Automation.Language.Parser]::ParseInput( $code, [ref]$astTokens, [ref]$parseErrors)



##############################################################################
# 
# Remote Debugging
# 
##############################################################################

# ISE supports remote debugging of scripts through a remoting session.
# After connecting, use the PSEdit command to open a remote script, then
# use debugging commands and save changes to the script like normal.

Enter-PSSession -ComputerName Server47
psedit c:\folder\script.ps1



##############################################################################
# 
# Runspace, Hosting Process, and Module Debugging
# 
##############################################################################

# Hidden runspaces may be debugged also.  See the following commands:
Get-Runspace
Debug-Runspace
Enable-RunspaceDebug
Disable-RunspaceDebug
Get-RunspaceDebug


# Any process hosting the PowerShell engine may be debugged with an interactive
# session similar to Enter-PSSession, but to a process instead.  See:
Enter-PSHostProcess
Exit-PSHostProcess


