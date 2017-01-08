#.SYNOPSIS
# A wrapper for whoami.exe to emit a parsed object, not lines of text.

function Get-WhoAmI
{
#.SYNOPSIS
# A wrapper for whoami.exe to emit a parsed object, not lines of text.

    $id = [PsCustomObject]@{UserName = ''; UserSID = ''; UserUPN = ''; UserDN = ''; Groups = ''; Privileges = ''}
    $user = whoami.exe /user /fo csv | ConvertFrom-Csv
    $id.UserName = $user.'User Name'
    $id.UserSID = $user.SID
    $id.UserUPN = whoami.exe /upn 
    $id.UserDN = whoami.exe /fqdn 
    $id.Privileges = @(whoami.exe /priv /fo csv | ConvertFrom-Csv | select -ExpandProperty 'Privilege Name') 
    $id.Groups = @(whoami.exe /groups /fo csv | ConvertFrom-Csv | select -ExpandProperty 'Group Name') 
    $id 
}


Get-WhoAmI   

