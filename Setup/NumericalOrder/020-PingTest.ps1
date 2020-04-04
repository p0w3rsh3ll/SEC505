$Top.Request = "Stop" 

"Hello World!"

if (Test-Connection -ComputerName 127.0.0.1 -Quiet -Count 1)
{ 
    $Top.Request = "Continue"
}
else
{
    Throw "Cannot ping the domain controller, giving up!"
}
