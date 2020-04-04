
Configuration TestConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node LocalHost 
    {
        Registry RegExample
        {
            Ensure = "Present"  
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\AAANewKey"
            ValueName = "EnableGoodness"
            ValueData = "0x1"
            Hex = $True
            ValueType = "Dword"
            Force = $True 
        }
    }
} 




