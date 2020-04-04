$Top.Request = "Stop" 

"Hello from $PSCommandPath"

if (Test-Connection -ComputerName $Top.IPaddress -Quiet -Count 1)
{ 
    $Top.Request = "Continue"
}
else
{
    Throw "Cannot ping the domain controller, giving up!"
}
