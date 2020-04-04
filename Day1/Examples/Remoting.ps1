# To enable PowerShell remoting on the local machine:

Enable-PSRemoting -Force


# To connect to a local/remote computer by name:

Enter-PSSession -ComputerName LocalHost


# To exit a PowerShell remoting session:

Exit-PSSession       # Or just "exit" by itself.


# To execute a set of commands on remote computer immediately,
# without entering into an interactive session:

Invoke-Command -ComputerName LocalHost -ScriptBlock { "Some commands here on env:computername" } 


# To copy a local script to a remote computer's memory and
# execute the script from memory at the remote computer:

Invoke-Command -ComputerName LocalHost -FilePath .\SomeLocalScript.ps1


# To execute a set of commands or a script on multiple remote machines:

$Servers = @("Server7", "Server8", "Server9")
Invoke-Command -ComputerName $Servers -ScriptBlock { ps }
Invoke-Command -ComputerName $Servers -FilePath .\SomeLocalScript.ps1


# To execute a set of commands or a script on multiple remote machines 
# as a background job, query the status of the job, then capture the
# output of the job (the commands on the machines) to a variable which
# includes the name of the target computer as a property on each object:

$Servers = @("Server7", "Server8", "Server9")
Invoke-Command -ComputerName $Servers -ScriptBlock { ps } -AsJob
Get-Job    #Query status, see the ID number, and look for State = Completed.
$Output = Receive-Job -ID 6
$Output | Select-Object PSComputerName,ProcessName 

