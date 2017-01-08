###########################################################################
#
# The following are examples for scripting KeePass with PowerShell.
#
# For KeePass object classes, see:
#        http://keepassps.codeplex.com/SourceControl/latest#keepass.ps1
#
# Version: 1.1
# Updated: 19.Aug.2015
#  Author: Enclave Consulting LLC, Jason Fossen (http://sans.org/sec505)
#   Legal: Public domain.  Script provided "AS IS" without warranties or
#          or guarantees of any kind.  Use at your own risk.
###########################################################################





###########################################################################
#
# Helper Function: Convert secure string back into plaintext
#
###########################################################################

Function Convert-FromSecureStringToPlaintext ( $SecureString )
{
    [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString))
}



###########################################################################
#
# Load the classes from KeePass.exe:
#
###########################################################################
$KeePassProgramFolder = Dir C:\'Program Files (x86)'\KeePass* | Select-Object -Last 1 
$KeePassEXE = Join-Path -Path $KeePassProgramFolder -ChildPath "KeePass.exe"
[Reflection.Assembly]::LoadFile($KeePassEXE) 




###########################################################################
#
# To open a KeePass database, the decryption key is required, and this key
# may be a constructed from a password, key file, Windows user account, 
# and/or other information sources.  
#
###########################################################################

# $CompositeKey represents a key, possibly constructed from multiple sources of data.
# The other key-related objects are added to this composite key.
$CompositeKey = New-Object -TypeName KeePassLib.Keys.CompositeKey  #From KeePass.exe
 
# The currently logged-on Windows user account can be added to a composite key. 
$KcpUserAccount = New-Object -TypeName KeePassLib.Keys.KcpUserAccount  #From KeePass.exe

# A key file can be added to a composite key.
$KeyFilePath = 'C:\SomeFolder\KeePassKeyFile.keyfile' 
$KcpKeyFile = New-Object -TypeName KeePassLib.Keys.KcpKeyFile($KeyFilePath)

# A password can be added to a composite key.
$Password = Read-Host -Prompt "Enter passphrase" -AsSecureString 
$Password = Convert-FromSecureStringToPlaintext -SecureString $Password
$KcpPassword = New-Object -TypeName KeePassLib.Keys.KcpPassword($Password) 

# Add the Windows user account key to the $CompositeKey, if necessary:
#$CompositeKey.AddUserKey( $KcpUserAccount ) 
$CompositeKey.AddUserKey( $KcpPassword ) 
$CompositeKey.AddUserKey( $KcpKeyFile ) 



###########################################################################
#
# To open a KeePass database, the path to the .KDBX file is required.
#
###########################################################################

$IOConnectionInfo = New-Object KeePassLib.Serialization.IOConnectionInfo
$IOConnectionInfo.Path = 'C:\SomeFolder\KeePass-Database.kdbx' 



###########################################################################
#
# To open a KeePass database, an object is needed to record status info.
# In this case, the progress status information is ignored.
#
###########################################################################

$StatusLogger = New-Object KeePassLib.Interfaces.NullStatusLogger



###########################################################################
#
# Open the KeePass database with key, path and logger objects.
# $PwDatabase represents a KeePass database.
#
###########################################################################

$PwDatabase = New-Object -TypeName KeePassLib.PwDatabase  #From KeePass.exe
$PwDatabase.Open($IOConnectionInfo, $CompositeKey, $StatusLogger)



###########################################################################
#
# List groups.  A group is shown as a folder name in the KeePass GUI.
#
###########################################################################

$PwDatabase.RootGroup.Groups
$PwDatabase.RootGroup.Groups | Format-Table Name,LastModificationTime,Groups -AutoSize



###########################################################################
#
# List all entries from all groups, including nested groups.
#
###########################################################################

$PwDatabase.RootGroup.GetEntries($True) |
ForEach { $_.Strings.ReadSafe("Title") + " : " + $_.Strings.ReadSafe("UserName") } 



###########################################################################
#
# Get a particular group named 'Websites-1' and show some of its properties.
#
###########################################################################

$Group = $PwDatabase.RootGroup.Groups | Where { $_.Name -eq 'Websites-1' } 
$Group.Name
$Group.Notes
$Group.CreationTime
$Group.LastAccessTime
$Group.LastModificationTime
$Group.GetEntriesCount($True)  #Count of all entries, including in subgroups.



###########################################################################
#
# Get the unique UUID for the Websites-1 group.  Objects in KeePass have
# unique ID numbers so that multiple objects may have the same name.
#
###########################################################################
$Group.Uuid.ToHexString()
[Byte[]] $byteArray = $Group.Uuid.UuidBytes



###########################################################################
#
# List the entries from the Websites-1 group, including plaintext passwords.
#
###########################################################################

$tempObj = '' | Select Title,UserName,Password,URL,Notes

$Group.GetEntries($True) | ForEach `
{ 
    $tempObj.Title    = $_.Strings.ReadSafe("Title")
    $tempObj.UserName = $_.Strings.ReadSafe("UserName")
    $tempObj.Password = $_.Strings.ReadSafe("Password")
    $tempObj.URL      = $_.Strings.ReadSafe("URL")
    $tempObj.Notes    = $_.Strings.ReadSafe("Notes")
    $tempObj
} 



###########################################################################
#
# Export all the usernames and passwords from the Websites-1 group to an
# XML file where the passwords are encrypted using the Data Protection
# API (DPAPI) such that only the current user on the local computer can
# recreate PSCredential objects from the data.  Very useful when piped into
# other cmdlets that accept a -Credential parameter, like Get-WmiObject.
# Computer names (the "Titles") and usernames will be in plaintext in the
# XML file, but the passwords will be encrypted using the DPAPI.
#
###########################################################################

$ServersHashTable = @{}   #Key = computer name, Value = PSCredential object

$Group.GetEntries($True) | ForEach `
{ 
    $ComputerName = $_.Strings.ReadSafe("Title")
    $UserName = $_.Strings.ReadSafe("UserName")
    $secureString = ConvertTo-SecureString -String ($_.Strings.ReadSafe("Password")) -AsPlainText -Force
    $Cred = New-Object System.Management.Automation.PSCredential($UserName, $secureString) 
    $ServersHashTable.Add( $ComputerName, $Cred )
}

$ServersHashTable | Export-Clixml -Path .\EncryptedForMe.xml

$RestoredTable = Import-Clixml -Path .\EncryptedForMe.xml

$cred = $RestoredTable.Item("server47.sans.org")  #Example use




###########################################################################
#
# Function to return an entry from a KeePass database.
#
###########################################################################

function Get-KeePassEntryByTitle 
{
<#
.SYNOPSIS
    Find and return a KeePass entry from a group based on entry title.

.DESCRIPTION
    After opening a KeePass database, provide the function with the name
    of a top-level group in KeePass (cannot be a nested subgroup) and the
    title of a unique entry in that group. The function returns the username,
    password, URL and notes for the entry by default, all in plaintext.
    Alternatively, just a PSCredential object may be returned instead; an
    object of the same type returned by the Get-Credential cmdlet. Note that
    the database is not closed by the function.

.PARAMETER PwDatabase
    The previously-opened KeePass database object.

.PARAMETER TopLevelGroupName
    Name of the KeePass folder. Must be top level, cannot be nested, and
    must be unique, i.e., no other groups/folders of the same name.

.PARAMETER Title
    The title of the entry to return.  Must be unique.

.PARAMETER AsSecureStringCredential
    Switch to return a PSCredential object with just the username and
    password as a secure string.  Username cannot be blank.  The object
    is of the same type returned by the Get-Credential cmdlet.
#>

    [CmdletBinding()]
    Param 
    ( 
        [Parameter(Mandatory=$true)] [KeePassLib.PwDatabase] $PwDatabase, 
        [Parameter(Mandatory=$true)] [String] $TopLevelGroupName, 
        [Parameter(Mandatory=$true)] [String] $Title, 
        [Switch] $AsSecureStringCredential
    )

    # This only works for a top-level group, not a nested subgroup (lazy).
    $PwGroup = @( $PwDatabase.RootGroup.Groups | where { $_.name -eq $TopLevelGroupName } )
    
    # Confirm that one and only one matching group was found
    if ($PwGroup.Count -eq 0) { throw "ERROR: $TopLevelGroupName group not found" ; return } 
    elseif ($PwGroup.Count -gt 1) { throw "ERROR: Multiple groups named $TopLevelGroupName" ; return } 

    # Confirm that one and only one matching title was found
    $entry = @( $PwGroup[0].GetEntries($True) | Where { $_.Strings.ReadSafe("Title") -eq $Title } )
    if ($entry.Count -eq 0) { throw "ERROR: $Title not found" ; return } 
    elseif ($entry.Count -gt 1) { throw "ERROR: Multiple entries named $Title" ; return } 

    if ($AsSecureStringCredential)
    {
        $secureString = ConvertTo-SecureString -String ($entry[0].Strings.ReadSafe("Password")) -AsPlainText -Force
        [string] $username = $entry[0].Strings.ReadSafe("UserName")
        if ($username.Length -eq 0){ throw "ERROR: Cannot create credential, username is blank" ; return } 
        New-Object System.Management.Automation.PSCredential($username, $secureString) 
    }
    else
    {
        $output = '' | Select Title,UserName,Password,URL,Notes
        $output.Title    = $entry[0].Strings.ReadSafe("Title")
        $output.UserName = $entry[0].Strings.ReadSafe("UserName")
        $output.Password = $entry[0].Strings.ReadSafe("Password")
        $output.URL      = $entry[0].Strings.ReadSafe("URL")
        $output.Notes    = $entry[0].Strings.ReadSafe("Notes")
        $output
    }
}


Get-KeePassEntryByTitle -PwDatabase $PwDatabase -TopLevelGroupName Websites-1 -Title paypal.com
Get-KeePassEntryByTitle -PwDatabase $PwDatabase -TopLevelGroupName Websites-1 -Title Server47 -AsSecureStringCredential 





###########################################################################
#
# Function to add an entry to a KeePass database.
#
###########################################################################

function New-KeePassEntry
{
<#
.SYNOPSIS
    Adds a new KeePass entry.

.DESCRIPTION
    Adds a new KeePass entry. The database must be opened first.  The name
    of a top-level group/folder in KeePass and an entry title are mandatory,
    but all other arguments are optional.  The group/folder must be at the top
    level in KeePass, i.e., it cannot be a nested subgroup. The password, if
    any, is passed in as plaintext unless you specify a PSCredential object,
    in which case the secure string from the PSCredential is converted to
    plaintext and then saved to the KeePass entry.  The PSCredential object
    is normally created using the Get-Credential cmdlet.

.PARAMETER PwDatabase
    The previously-opened KeePass database object (mandatory).

.PARAMETER TopLevelGroupName
    Name of the KeePass folder (mandatory). Must be top level, cannot be 
    nested, and must be unique, i.e., no other groups of the same name.

.PARAMETER Title
    The title of the entry to add (mandatory).  If possible, avoid
    duplicate titles for the sake of other KeePass scripts.

.PARAMETER PSCredential
    A PowerShell secure string credential object (optional), typically
    created with the Get-Credential cmdlet.  If this is specified, any
    UserName and Password parameters are ignored and the KeePass entry
    will be created using the user name and plaintext password of 
    the PSCredential object.  Other data, such as Notes or URL, may 
    still be added.  The KeePass entry will have the plaintext password 
    from the PSCredential in the KeePass GUI, not the secure string.

.PARAMETER UserName
    The user name of the entry to add, if no PSCredential.

.PARAMETER Password
    The password of the entry to add, in plaintext, if no PSCredential.

.PARAMETER URL
    The URL of the entry to add.

.PARAMETER Notes
    The Notes of the entry to add.
#>

    [CmdletBinding(DefaultParametersetName="Plain")]
    Param 
    ( 
        [Parameter(Mandatory=$true)] [KeePassLib.PwDatabase] $PwDatabase, 
        [Parameter(Mandatory=$true)] [String] $TopLevelGroupName, 
        [Parameter(Mandatory=$true)] [String] $Title, 
        [Parameter(ParameterSetName="Plain")] [String] $UserName,
        [Parameter(ParameterSetName="Plain")] [String] $Password,
        [Parameter(ParameterSetName="Cred")]  [System.Management.Automation.PSCredential] $PSCredential,
        [String] $URL,
        [String] $Notes
    )


    # This only works for a top-level group, not a nested subgroup:
    $PwGroup = @( $PwDatabase.RootGroup.Groups | where { $_.name -eq $TopLevelGroupName } )

    # Confirm that one and only one matching group was found
    if ($PwGroup.Count -eq 0) { throw "ERROR: $TopLevelGroupName group not found" ; return } 
    elseif ($PwGroup.Count -gt 1) { throw "ERROR: Multiple groups named $TopLevelGroupName" ; return } 
    
    # Use PSCredential, if provided, for username and password:
    if ($PSCredential)
    {
        $UserName = $PSCredential.UserName
        $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PSCredential.Password))
    }

    # The $True arguments allow new UUID and timestamps to be created automatically:
    $PwEntry = New-Object -TypeName KeePassLib.PwEntry( $PwGroup[0], $True, $True ) 

    # Protected strings are encrypted in memory:
    $pTitle = New-Object KeePassLib.Security.ProtectedString($True, $Title)
    $pUser = New-Object KeePassLib.Security.ProtectedString($True, $UserName)
    $pPW = New-Object KeePassLib.Security.ProtectedString($True, $Password)
    $pURL = New-Object KeePassLib.Security.ProtectedString($True, $URL)
    $pNotes = New-Object KeePassLib.Security.ProtectedString($True, $Notes)

    $PwEntry.Strings.Set("Title", $pTitle)
    $PwEntry.Strings.Set("UserName", $pUser)
    $PwEntry.Strings.Set("Password", $pPW)
    $PwEntry.Strings.Set("URL", $pURL)
    $PwEntry.Strings.Set("Notes", $pNotes)

    $PwGroup[0].AddEntry($PwEntry, $True)

    # Notice that the database is automatically saved here!
    $StatusLogger = New-Object KeePassLib.Interfaces.NullStatusLogger
    $PwDatabase.Save($StatusLogger) 

}


New-KeePassEntry -PwDatabase $PwDatabase -TopLevelGroupName 'Wireless' -Title 'TestingPlain' -UserName "UserTest99" -Password "Pazzwurd" -URL "http://www.sans.org/sec505" -Notes "Some notes here."   

$cred = Get-Credential
New-KeePassEntry -PwDatabase $PwDatabase -TopLevelGroupName 'Wireless' -Title 'TestingCred' -PSCredential $cred 




###########################################################################
#
# Close the open database.  Don't forget!
#
###########################################################################

$PwDatabase.Close()

 
 
 
 
 
# Note:
# It's possible to launch KeePass from the command line:
#    C:\'Program Files (x86)'\'KeePass Password Safe 2'\KeePass.exe E:\MyDatabase.kdbx -keyfile:F:\mykeyfile.bin
#
# But never launch KeePass from the command line by passing in the passphrase as
# a command-line argument using the "-pw" parameter: the passphrase will be
# visible to anyone who obtains a list of running processes, and, if process
# logging is enabled, will be in the event logs as well.  It's best to be
# prompted for the passphrase by the KeePass pop-up dialog box on the UAC-locked
# secure desktop.  


