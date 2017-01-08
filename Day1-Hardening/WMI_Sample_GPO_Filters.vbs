'*******************************************************************************
' Script Name: WMI_Sample_GPO_Filters.vbs
'     Version: 1.2
'      Author: Jason Fossen 
'Last Updated: 25.Sep.2012
'     Purpose: This is not an executable script.  The following are examples
'              of WMI Filters for Group Policy Objects.  Don't forget
'              that Windows 2000 ignores WMI Filters.  
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script is provided "AS IS" without warranties or guarantees of any kind.
'*******************************************************************************
 
'Applies if Windows Server 2012 Standard Enterprise is the operating system.
SELECT * FROM Win32_OperatingSystem WHERE Caption = "Microsoft Windows Server 2012 Standard"

'Applies if the system is a Dell Latitude CPxJ 650MHz
SELECT * FROM Win32_ComputerSystem WHERE Manufacturer = "Dell Computer Corporation" AND Model = "Latitude CPx J650GT" 
   
'Applies if ADMINPAK.MSI has been installed.
SELECT * FROM Win32_Product WHERE name = "ADMINPAK"
  
'Applies if there is at least 500MB (524,288,000 bytes) available on any drive. 
SELECT * FROM Win32_LogicalDisk WHERE FreeSpace > 524288000 AND Description = "Local Fixed Disk"
  
'Applies if located in the eastern time zone, i.e., five hours behind UTC "Zulu" time.
SELECT * FROM win32_timezone WHERE bias =-300

'Applies if patch KB819696 or KB828026 has been applied.
SELECT * FROM Win32_QuickFixEngineering WHERE HotFixID = "KB819696" OR HotFixID = "KB828026"




