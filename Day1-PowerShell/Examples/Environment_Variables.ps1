
# Environment variables are in the ENV:\ drive:
dir env:\


# Use an environment variable (not case sensitive):
$env:Path
$env:windir
$env:USERNAME


# Another way to get environment variables:
[Environment]::GetEnvironmentVariables()
[Environment]::GetEnvironmentVariable("Path")


# Retrieve a computer-wide vs. current-user-only vs. this-process-only variable:
[Environment]::GetEnvironmentVariable("Path", "Machine")
[Environment]::GetEnvironmentVariable("Path", "User")
[Environment]::GetEnvironmentVariable("Path", "Process")


# Set a variable at the machine, user or process scope (must relaunch PowerShell to see):
[Environment]::SetEnvironmentVariable("VarName", "SomeData", "Machine")
[Environment]::SetEnvironmentVariable("VarName", "SomeData", "User")
[Environment]::SetEnvironmentVariable("VarName", "SomeData", "Process") #Immediately visible, but not permanent



# While not exactly environment variables, these are also often useful:

# Full path to currently-running script, if any (PowerShell 3.0+):
$PSCommandPath


# Folder containing this script, if any:
$PSScriptRoot


# Information about the current script, function or scriptblock which is executing:
$MyInvocation | Get-Member -MemberType Properties
$MyInvocation.Line                #The exact command as entered to begin the execution
$MyInvocation.ScriptLineNumber    #Returns an integer, the line number of the calling script
$MyInvocation.ScriptName          #Name of script which called current function or scriptblock


# The present working directory of the command shell:
$PWD


# Because there are complexities involved in commands calling other commands which
# call further commands, etc., here is the sure-fire way to get the current folder
# of a script which is running (must be executed within a script):

function Get-FolderContainingThisScript { Split-Path -Path $MyInvocation.ScriptName } 
Get-FolderContainingThisScript



