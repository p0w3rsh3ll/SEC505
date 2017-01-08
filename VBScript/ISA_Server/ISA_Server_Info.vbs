'*************************************************************************************
' Script Name: ISA_Server_Info.vbs
'     Version: 1.1
'      Author: Jason Fossen (www.isascripts.org)
'Last Updated: 16.Aug.2005
'     Purpose: Demonstrate querying information from an ISA Server (misc stuff).
'       Notes: You should download the free ISA Server SDK from Microsoft's web site
'              to understand the objects and collections referenced below:
'              http://www.microsoft.com/isaserver/downloads/
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'              USE AT YOUR OWN RISK.  Test on non-production servers first.
'*************************************************************************************
Option Explicit



Function GetIsaServerArray()
    Dim oFPC    'Root COM object for ISA admin.
    Set oFPC = CreateObject("FPC.Root")
    GetIsaServerArray = oFPC.GetContainingArray.Name  'Even Standard Edition is an array member.
End Function



Function GetIsaServerName()
    Dim oFPC    'Root COM object for ISA admin.
    Set oFPC = CreateObject("FPC.Root")
    GetIsaServerName = oFPC.GetContainingServer.Name
End Function



Function GetAdaptersInfo()
    Dim oFPC    'Root COM object for ISA admin.
    Dim cAdapters, oAdapter, sResult
    Set oFPC = CreateObject("FPC.Root")
    Set cAdapters = oFPC.GetContainingServer.Adapters
    
    For Each oAdapter In cAdapters
        sResult = sResult & "Adapter Name: " & oAdapter.FriendlyName & vbCrLf
        sResult = sResult & " Description: " & oAdapter.Description & vbCrLf
        sResult = sResult & "DHCP Enabled: " & oAdapter.DhcpEnabled & vbCrLf
        sResult = sResult & "IP Addresses: " & oAdapter.IpAddresses & vbCrLf & vbCrLf
        'IpAddressSet and IpRanges not included in dump.
    Next
    GetAdaptersInfo = sResult
End Function



Function GetCacheDrivesInfo()
    Dim oFPC    'Root COM object for ISA admin.
    Dim cCacheDrives, oDrive, sResult, cDiskDrives
    Set oFPC = CreateObject("FPC.Root")
    Set cCacheDrives = oFPC.GetContainingServer.CacheDrives
    Set cDiskDrives = oFPC.GetContainingServer.DiskDrives

    sResult = sResult & "      Number of disk drives: " & cDiskDrives.Count & vbCrLf
    sResult = sResult & "     Total NTFS drive space: " & cDiskDrives.TotalDiskSizeInMegs & " MB" & vbCrLf    
    sResult = sResult & "Total free NTFS drive space: " & cDiskDrives.TotalFreeSizeInMegs & " MB" & vbCrLf    
    sResult = sResult & "     Number of cache drives: " & cCacheDrives.Count & vbCrLf
    sResult = sResult & "    Total cache drive space: " & cCacheDrives.TotalCacheInMegs & " MB" & vbCrLf & vbCrLf
        
    For Each oDrive In cCacheDrives
        sResult = sResult & "Drive " & oDrive.Name & " has " & oDrive.CacheLimitInMegs & " MB of cache space." & vbCrLf
    Next

    For Each oDrive In cDiskDrives
        sResult = sResult & "Drive " & oDrive.Name & " has " & oDrive.FreeSpaceInMegs & " MB of free space." & vbCrLf
    Next

    GetCacheDrivesInfo = sResult
End Function





'END OF SCRIPT************************************************************************




WScript.Echo " ISA Array: " & GetIsaServerArray()
WScript.Echo "ISA Server: " & GetIsaServerName()

WScript.Echo vbCrLf
WScript.Echo "*******************************************************"
WScript.Echo " Network Adapters "
WScript.Echo "*******************************************************"
WScript.Echo GetAdaptersInfo()

WScript.Echo vbCrLf
WScript.Echo "*******************************************************"
WScript.Echo " Disk and Cache Drives "
WScript.Echo "*******************************************************"
WScript.Echo GetCacheDrivesInfo()



