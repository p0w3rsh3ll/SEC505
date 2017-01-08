<#
PowerShell commands can be run concurrently using background processes, workflows, runspaces,
and, with a lot of effort, the .NET Task Parallel Library (TPL) or .NET threads directly.  

This script demonstrates how to use multiple, concurrent runspaces to execute commands
which all share a single thread-safe dictionary to collect their output. 

While runspaces have been supported since PowerShell 2.0, this script requires
PowerShell 4.0 (and version 4.0+ of the .NET Framework) because of its use of a
thread-safe dictionary of type System.Collections.Concurrent.ConcurrentDictionary.
Removing the use of this concurrent dictionary object will make the script
backwards compatible, but then each command must collect its output separately,
while is not a problem, just not as fun.

Guidance for this example came from these authors, who did all the real work:
    http://newsqlblog.com/category/powershell/powershell-concurrency/
    http://www.codeproject.com/Tips/895840/Multi-Threaded-PowerShell-Cookbook
    https://msdn.microsoft.com/en-us/library/dd997305(v=vs.100).aspx
    http://learn-powershell.net/2012/05/13/using-background-runspaces-instead-of-psjobs-for-better-performance/

Author: Enclave Consulting LLC, Jason Fossen (http://sans.org/sec505)
Version: 1.0
#>




# Function to create thread-safe hashtable (requires .NET 4.0+):
function New-ThreadSafeTypedDictionary([Type] $KeyType, [Type] $ValueType)
{
    $GenericDict = [System.Collections.Concurrent.ConcurrentDictionary``2]
    $GenericDict = $GenericDict.MakeGenericType( @($KeyType, $ValueType) )
    New-Object -TypeName $GenericDict 
}


# Create a variable to collect the output of the runspace threads.
# Preferably, it should be thread safe, e.g., a concurrent dictionary.
# Without this, each command must output to a different array.
$Output = New-ThreadSafeTypedDictionary -KeyType 'String' -ValueType 'String' 

# Create an array to hold objects representing the state of executed commands:
$AsyncResults = @()

# Define the initial session state for a pool:
$SessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$SessionState.ApartmentState = 'STA'
$SessionState.ThreadOptions = 'ReuseThread'

# Add a variable to the session state pool that can be used to pass in data and/or collect output:
# ArgumentList = name of the variable, initial value of variable, an optional description
$SessionVar = New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList @("Output", $Output, 'MyDescription') 
$SessionState.Variables.Add( $SessionVar ) 

# Create between 1 (min) and 4 (max) runspaces in a pool, with an initial session state, in the current PowerShell host:
$RunspacePool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, 4, $SessionState, $Host)

# Open the runspace pool:
$RunspacePool.Open()


##############################################################
# RUN FIRST COMMAND
##############################################################

# Define the command you want to run, and note how $Output is used:
$Script = '1..100000 | ForEach { $Output.TryAdd( ("AAA" + $_), "AAAAA" ) }'

# Create a PowerShell command to run in the pool
$Command = [System.Management.Automation.PowerShell]::Create()
$Command.RunspacePool = $RunspacePool
$Command.AddScript($Script) > $null 

# Note that positional arguments and named parameters may be added to the *last* command in the command pipeline:
# $Argument = 'somearg'
# $Command.AddScript($ScriptBlock).AddArgument($Argument) > $null 

# Run the command in a runspace asynchronously:
$AsyncResults += $Command.BeginInvoke()


##############################################################
# RUN SECOND COMMAND
##############################################################
$Script = '1..100000 | ForEach { $Output.TryAdd( ("BBB" + $_), "BBBBB" ) }'
$Command = [System.Management.Automation.PowerShell]::Create()
$Command.RunspacePool = $RunspacePool
$Command.AddScript($Script) > $null 
$AsyncResults += $Command.BeginInvoke()


##############################################################
# RUN THIRD COMMAND
##############################################################
$Script = '1..100000 | ForEach { $Output.TryAdd( ("CCC" + $_), "CCCCC" ) }'
$Command = [System.Management.Automation.PowerShell]::Create()
$Command.RunspacePool = $RunspacePool
$Command.AddScript($Script) > $null 
$AsyncResults += $Command.BeginInvoke()



# Wait until all the commands finish, then clean up the resources:
while ($true)
{
    Start-Sleep -Milliseconds 100
    Write-Host -Object '.' -NoNewline -ForegroundColor Green
    $AsyncResults | Where { $_.IsCompleted -eq $False } | ForEach { Continue }

    # Clean up objects and break out of the While loop: 
    $AsyncResults | ForEach { $_.AsyncWaitHandle.Close() }
    $AsyncResults = @() 
    $Command = $null 
    $RunspacePool.Close()
    $RunspacePool.Dispose() 
    Break 
}


# Do something with the output.
# Because $Output is a thread-safe concurrent dictionary,
# it should have 300000 entries now:
$Output.Count







