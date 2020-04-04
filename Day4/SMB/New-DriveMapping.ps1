#.SYNOPSIS
#  Map drive with next available drive letter.
#

function New-DriveMapping ($SharedFolderPath, [Switch] $RequireEncryption, [Switch] $NoWriteCaching)
{
    $Existing = (Get-PSDrive -PSProvider FileSystem).Name 

    $NewLetter = $null 

    foreach ($Letter in ([Char[]](90..65)) )
    {
        if ($Letter -notin $Existing){ $NewLetter = $Letter; Break }
    }

    if ($NewLetter -ne $null)
    { New-SmbMapping -LocalPath ($NewLetter + ":") -RemotePath $SharedFolderPath -RequirePrivacy $RequireEncryption -UseWriteThrough $NoWriteCaching }
    else
    { $null } 
}


