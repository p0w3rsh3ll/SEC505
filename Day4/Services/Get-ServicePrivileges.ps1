# List explicitly-granted privileges for services.

Param ($ServiceName = '*') 

function Get-ServicePrivileges ($ServiceName = '*')
{
    Get-Service -Name $ServiceName | ForEach `
    { 
        $output = '' | Select Name,DisplayName,Privileges
        $output.Name = $_.Name
        $output.DisplayName = $_.DisplayName

        $privs = sc.exe qprivs $_.Name | select-string -NotMatch '_NAME|SUCCESS' | Out-String
        $privs = $privs.Replace('PRIVILEGES','')
        $privs = $privs.Replace(':',' ') 
        $privs = $privs -Replace '\s+',' '
    
        $output.Privileges = $privs.Trim()
        $output 
    }
}


Get-ServicePrivileges -ServiceName $ServiceName


