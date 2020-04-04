###########################################################################
#
# This script demonstrates how to create, mount, and format a VHDX
# virtual machine image as a new drive letter, then encrypt it with
# a BitLocker passphrase.  The passphrase is "passphrase".
#
# Requires: 
#    Windows Server 2012, Windows 8, or later.
#    BitLocker feature must be installed.
#    Hyper-V role must be installed.
#    PowerShell 4.0 or later.
#    Run as administrator.
#
#  Version: 1.0
#   Author: JF
#    Legal: Public Domain, No Guarantees or Warranties of Any Kind.
#
###########################################################################


# The Hyper-V role must be installed on Windows Server, or
# the Hyper-V module must be installed on a Windows client:
Try { Import-Module -Name Hyper-V -ErrorAction Stop } 
Catch { "`nYou must have Hyper-V installed!`n" }



# The passphrase used to encrypt the VHDX volume with BitLocker:
$SecureString = ConvertTo-SecureString -String "passphrase" -AsPlainText -Force



# Get next available drive letter for the new VHDX volume:
Function Get-NextAvailableDriveLetter 
{ 
    $LettersTaken = @() #Media might be currently unmounted.
    Get-Volume | ForEach { $LettersTaken += $_.DriveLetter }

    Switch ( 69..90 | ForEach { [Char] $_ } )  #Letters E-Z
    {
        { $LettersTaken -Contains $_ }
            { continue }
        { -Not (Test-Path -Path ($_ + ':\')) } 
            { $_ ; Break } 
        { $True } 
            { Throw "No drive letters available!" } 
    }
} 

$DriveLetter = Get-NextAvailableDriveLetter



# Create, mount and format a VHDX volume:
New-VHD -Path C:\Temp\TestingBitLocker.vhdx -Dynamic -SizeBytes 64MB | 
Mount-VHD -Passthru | 
Initialize-Disk -PartitionStyle MBR -Passthru | 
New-Partition -UseMaximumSize | 
Format-Volume -FileSystem NTFS -NewFileSystemLabel "VHDX" -Confirm:$False -Force | 
Get-Partition | Set-Partition -NewDriveLetter $DriveLetter



# The BitLocker feature must be installed:
Try { Import-Module -Name BitLocker -ErrorAction Stop } 
Catch { "`nYou must have BitLocker feature installed!`n" }



# Encrypt that new VHDX volume with a BitLocker passphrase:
Enable-BitLocker -MountPoint $DriveLetter -EncryptionMethod AES256 -UsedSpaceOnly -PasswordProtector -Password $SecureString 



# For this demo, do not execute any more lines:
Exit



# Display info about the BitLocker volume:
Get-BitLockerVolume -MountPoint $DriveLetter



# Enable auto-unlock on the BitLocker volume for
# just the current user on just this computer, but
# note that the C: drive with the OS must also be
# BitLocker-encrypted in order for this to work:
if ( (Get-BitLockerVolume -MountPoint $ENV:SystemDrive).VolumeStatus -eq "FullyEncrypted" ) 
{  
    Enable-BitLockerAutoUnlock -MountPoint $DriveLetter
} 



# Unmount the volume and delete the VHDX image file:
Dismount-VHD -Path C:\Temp\TestingBitLocker.vhdx
Remove-Item -Path C:\Temp\TestingBitLocker.vhdx





### Notes ##############################################################
# 
# On Windows 8 and later, double-click a VHDX file to mount it.
#
# Minimum size of a GPT disk is 128MB, and 64MB for a MBR disk with BitLocker.
#
# The -AssignDriveLetter switch of New-Partition is not used in order to avoid a GUI prompt about formatting.
#
# In real life, do not hard-code the BitLocker passphrase, use code to prompt the user for it.
#
# The -Passthru switch is needed when a cmdlet does not output an object by default.
#
########################################################################


