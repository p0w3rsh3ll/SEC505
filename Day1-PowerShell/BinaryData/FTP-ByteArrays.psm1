#################################################################
#.SYNOPSIS
# Functions for interacting with an FTP server using byte arrays.
#
#.DESCRIPTION
# Functions for interacting with an FTP server: get a directory
# listing of folders and files returned as objects, upload a
# byte array to a file, and download a file returned as an
# array of bytes (not as a file). 
#
#.NOTES
# TODO: Need to add error handling, handle very large arrays
# more efficiently, fill out all the help comments, suck less. 
#################################################################

Function Get-FtpDirectoryListing
{
    #.SYNOPSIS
    # Directory listing from FTP server as file/folder objects.
    #.PARAMETER FtpURI
    # FTP URI string like 'ftp://server/folder/'.

    Param 
    (
        [Parameter(Mandatory=$True)][String] $FtpURI, 
        [String] $UserName = 'anonymous', 
        [String] $Password = 'anonymous@local',
        [Switch] $UsePlainText,
        [Switch] $RawListingText 
    )

    # Prepend "ftp://" if missing:
    if ($FtpURI.Substring(0,6) -ne 'ftp://'){ $FtpURI = 'ftp://' + $FtpURI } 

    # Get details of files and folders:
    $FtpWebRequest = [System.Net.FtpWebRequest]::Create($FtpURI)  
    $FtpWebRequest.UsePassive = $True
    $FtpWebRequest.UseBinary = $True 
    $FtpWebRequest.EnableSsl = $True 
    if ($UsePlainText){ $FtpWebRequest.EnableSsl = $False }
    $FtpWebRequest.Credentials = New-Object -TypeName System.Net.NetworkCredential -ArgumentList @($UserName, $Password)
    $FtpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectoryDetails
    $Response = $FtpWebRequest.GetResponse()
    $Reader = New-Object -TypeName System.IO.StreamReader -ArgumentList @($Response.GetResponseStream()) 
    $DirDetailed = $Reader.ReadToEnd() 
    $Reader.Close()
    $Response.Close()

    # Output raw listing text returned by FTP server?
    if ($RawListingText)
    { 
        $FtpWebRequest = $null
        $DirDetailed
        Return 
    } 

    #Get simple file or folder names only:
    $FtpWebRequest = [System.Net.FtpWebRequest]::Create($FtpURI)  
    $FtpWebRequest.UsePassive = $True
    $FtpWebRequest.UseBinary = $True 
    $FtpWebRequest.EnableSsl = $True 
    if ($UsePlainText){ $FtpWebRequest.EnableSsl = $False }
    $FtpWebRequest.Credentials = New-Object -TypeName System.Net.NetworkCredential -ArgumentList @($UserName, $Password)
    $FtpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    $Response = $FtpWebRequest.GetResponse()
    $Reader = New-Object -TypeName System.IO.StreamReader -ArgumentList @($Response.GetResponseStream()) 
    $DirSimple = $Reader.ReadToEnd()
    $Reader.Close()
    $Response.Close()
    $FtpWebRequest = $null

    # Split simple and detailed listings into arrays:
    [System.String[]] $DirSimple = @( $DirSimple -split "`n" ) 
    [System.String[]] $DirDetailed = @( $DirDetailed -split "`n" ) 

    # Sanity checks:
    if ($DirSimple.Count -ne $DirDetailed.Count){ Throw "Directory listing count mismatch!" }
    if ($DirDetailed[0] -notlike ("*" + $DirSimple[0])){ Throw "Directory listing first item mismatch!" } 
    if ($DirDetailed[-1] -notlike ("*" + $DirSimple[-1])){ Throw "Directory listing last item mismatch!" } 

    # Test for directories:
    # TODO: Extract file size too and add it to output objects. 
    For ( $i = 0; $i -lt $DirSimple.Count - 1; $i++ )
    {
        #Unix-style directory entries begin with "d", like "drwxrwxrwx".
        #DOS-style directory entries contain a "<DIR>" in the middle.
        if ( $DirDetailed[$i] -match '^d[r-]|\ {3,}\<DIR\>\ {3,}\S+' -and $DirDetailed[$i].Length -gt 0 )
         { 
            [PSCustomObject] @{ IsFile = $False; Name = $DirSimple[$i].Trim() } 
         }
        else
         { 
            [PSCustomObject] @{ IsFile = $True ; Name = $DirSimple[$i].Trim() } 
         } 
    }
}




Function Upload-ByteArrayToFtpServer
{
    #.SYNOPSIS
    # Create new file at FTP server from a Byte[] array.
    #.PARAMETER ByteArray
    # A System.Byte[] array to fill new file on FTP server.
    #.PARAMETER FtpURI
    # FTP URI string like 'ftp://server/folder/file.ext'.

    Param 
    (
        [Parameter(Mandatory=$True)][Byte[]] $ByteArray, 
        [Parameter(Mandatory=$True)][String] $FtpURI, 
        [String] $UserName = 'anonymous', 
        [String] $Password = 'anonymous@local',
        [Switch] $UsePlainText
    )

    # Prepend "ftp://" if missing:
    if ($FtpURI.Substring(0,6) -ne 'ftp://'){ $FtpURI = 'ftp://' + $FtpURI } 

    # Sanity checks:
    # TODO: URI does not end with "/", and what else?

    # Upload bytes to a new file:
    $FtpWebRequest = [System.Net.FtpWebRequest]::Create($FtpURI)  
    $FtpWebRequest.UsePassive = $True
    $FtpWebRequest.UseBinary = $True 
    $FtpWebRequest.EnableSsl = $True 
    if ($UsePlainText){ $FtpWebRequest.EnableSsl = $False }
    $FtpWebRequest.Credentials = New-Object -TypeName System.Net.NetworkCredential -ArgumentList @($UserName, $Password)
    $FtpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $FtpWebRequest.ContentLength = $ByteArray.Count
    $Response = $FtpWebRequest.GetRequestStream()
    #TODO: Catch error 550 here if dest is not writable.
    $Response.Write($ByteArray,0,$ByteArray.Count)
    $Response.Close()
    Write-Verbose -Verbose -Message $FtpWebRequest.GetResponse().StatusDescription
    $FtpWebRequest = $null
}



Function Download-ByteArrayFromFtpServer
{
    #.SYNOPSIS
    # Download file from FTP server, output Byte objects.
    #.PARAMETER FtpURI
    # FTP URI string like 'ftp://server/folder/file.ext'.

    Param 
    (
        [Parameter(Mandatory=$True)][String] $FtpURI, 
        [String] $UserName = 'anonymous', 
        [String] $Password = 'anonymous@local',
        [Switch] $UsePlainText
    )

    # Prepend "ftp://" if missing:
    if ($FtpURI.Substring(0,6) -ne 'ftp://'){ $FtpURI = 'ftp://' + $FtpURI } 

    # Sanity checks:
    # TODO: URI does not end with "/", and what else?

    # Output file URI as System.Byte objects: 
    $FtpWebRequest = [System.Net.FtpWebRequest]::Create($FtpURI)  
    $FtpWebRequest.UsePassive = $True
    $FtpWebRequest.UseBinary = $True 
    $FtpWebRequest.EnableSsl = $True 
    if ($UsePlainText){ $FtpWebRequest.EnableSsl = $False }
    $FtpWebRequest.Credentials = New-Object -TypeName System.Net.NetworkCredential -ArgumentList @($UserName, $Password)
    $FtpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
    $Response = $FtpWebRequest.GetResponse()

    $Reader = New-Object -TypeName System.IO.BinaryReader -ArgumentList @($Response.GetResponseStream()) 
    
    [System.Byte[]] $Bytes = @()
    Do { $Bytes = $Reader.ReadBytes(1000) ; $Bytes } 
    While ( $Bytes.Count -eq 1000) 

    $Response.Close()
    Write-Verbose -Verbose -Message $FtpWebRequest.GetResponse().StatusDescription
    $FtpWebRequest = $null

}


