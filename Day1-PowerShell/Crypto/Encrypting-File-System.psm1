# Functions related to Encrypting File System (EFS).



function Find-EncryptedFile 
{
    #.SYNOPSIS
    # Outputs files or folders marked as EFS-encrypted.
    #.DESCRIPTION
    # Outputs files or folders marked as encrypted using the
    # built-in NTFS Encrypting File System (EFS) feature.
    #.PARAMETER Path
    # Path to search for EFS-encrypted files.
    #.PARAMETER Recurse
    # Search subdirectories too.
    #.PARAMETER IncludeFolders
    # By default, only EFS-encrypted files are returned, so this
    # switch returns folder objects marked for encryption too.

    Param ( $Path = '.', [Switch] $Recurse, [Switch] $IncludeFolders ) 

    $ParamArgs = @{ Path = $Path; Recurse = $Recurse; Force = $True; File = !$IncludeFolders } 

    dir @ParamArgs | Where { $_.Attributes.HasFlag( [System.IO.FileAttributes]::Encrypted ) }  
}




function Encrypt-File
{
    #.SYNOPSIS
    # Encrypts one or more files with EFS (accepts piping).

    [CmdletBinding()] Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    $Path ) 

    PROCESS { (Get-Item -Path $Path).Encrypt() } 
}




function Decrypt-File
{
    #.SYNOPSIS
    # Decrypts one or more files encrypted with EFS (accepts piping).

    [CmdletBinding()] Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    $Path ) 

    PROCESS { (Get-Item -Path $Path).Decrypt() } 
}




# What about folders?  See cipher.exe /?
# Would rather not depend on that EXE, but
# we might be stuck...   :-\

