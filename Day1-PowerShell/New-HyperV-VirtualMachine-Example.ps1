############################################################################
# Purpose: This script demonstrates how to create a Hyper-V virtual machine.
# Version: 1.0
#    Date: 2.Aug.2013
#  Author: Jason Fossen (http://www.sans.org/windows-security)
#   Legal: Public domain, provided "AS IS" without any warranties.
############################################################################

Param 
( 
    $VmName = "Windows8.1-Enterprise-BETA", 
    $VhdxPath = "C:\Data\Hyper-V-Images",
    $PathToISO = "C:\Sources\Microsoft\Windows-8.1-Enterprise-Beta1\9431.0.WINMAIN_BLUEMP.130615-1214_X64FRE_ENTERPRISE_EN-US_VL-IMP_CENA_X64FREV_EN-US_DV5.iso", 
    $VirtualNetworkSwitchName = "External",
    $Notes = "This is a testing VM."
)


# Try to import the Hyper-V module explicitly in order to see the error better if it fails.
Import-Module Hyper-V


# Multiple VMs can have the same name, their GUIDs will still be different, but it's not very tidy.
if (Get-VM -Name $VmName -ErrorAction SilentlyContinue) { "`n $VmName already exists, quitting..." ; exit } 


# The new VHDX file is very small, it grows dynamically only as needed.
$VM = New-VM -Name $VmName -Path $VhdxPath -SwitchName $VirtualNetworkSwitchName `
       -NewVHDPath "$VhdxPath\$VmName\DiskImage.vhdx" `
       -NewVHDSizeBytes 60GB 


# Memory utilization begins small, it grows dynamically only as needed, then shrinks again.
Set-VMMemory -VM $VM -StartupBytes 1024MB `
       -DynamicMemoryEnabled $True `
       -MinimumBytes 512MB -MaximumBytes 8192MB 


# Must first boot from ISO file to install an OS (this can also just be a drive path, e.g., "D:\").
Get-VMDvdDrive -VM $VM | Set-VMDvdDrive -Path $PathToISO -AllowUnverifiedPaths


# Best to have an even number of virtual CPUs, but not more than actual cores on the host.
Set-VMProcessor -VM $VM -Count 2


# Not required, but handy to specify the purpose of the VM in its notes.
Set-VM -VM $VM -Notes $Notes


# Other virtual hardware can be added or removed too.
Get-VMScsiController -VM $VM | Remove-VMScsiController


# Removing a VM does not also delete its VHDX files, this must be done separately.
if ( $(Read-Host -Prompt "Enter 'd' to delete the VM") -eq 'd' ) 
{
    Remove-VM -VM $VM -Force
    Remove-Item -Path $VhdxPath\$VmName -Recurse -Force
}
elseif ( $(Read-Host -Prompt "Enter 's' to start the VM") -eq 's' )
{
    Start-VM -VM $VM 
    Start-Sleep -Seconds 3
    vmconnect.exe $env:COMPUTERNAME $VmName
}


# After the VM is fully installed and running, the boot order can be changed.
# Set-VMBios -VM $VM -StartupOrder @("IDE","CD","Floppy","LegacyNetworkAdapter")

