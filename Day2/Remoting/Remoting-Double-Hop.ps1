<#############################################################################

The Double-Hop Problem for WinRM Remoting

Imagine this scenario, where you are sitting at Laptop1:

    Laptop1 --> Jump2 --> Target3

Each "-->" arrow represents a WinRM PowerShell remoting connection.  How 
can we remote into Jump2 and execute a command to Target3?  Is this 
double-hop of authentication even possible?

Credit & More Information:
https://blogs.technet.microsoft.com/ashleymcglone/2016/08/30/powershell-remoting-kerberos-double-hop-solved-securely/

#############################################################################>

$Creds = Get-Credential             #Enter your global account creds

$Jump2 = 'surface.testing.local'    #Edit with your own test FQDN

$Target3 = 'dc.testing.local'       #Edit with your own test FQDN


Invoke-Command -ComputerName $Jump2 -Credential $Creds -ScriptBlock `
{
    Invoke-Command -ComputerName $Using:Target3 -Credential $Using:Creds -ScriptBlock `
    { "Running this command on $env:ComputerName" }
}



# Notice the "$Using:XXX" syntax above.  This allows the contents of
# a variable defined in the memory of Laptop1 (namely, your local
# machine) to be passed through to a remote session.




