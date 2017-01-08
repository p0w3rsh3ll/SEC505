 # Script will make the Windows Firewall permanently ignore the VMware network adapters
 # for the sake of determining network profile (Domain, Public, Private).  VMware
 # will still work normally otherwise and the change can be easily undone by hand.
 # Script must be run from an elevated shell.
 
 
 
 
 # Code copied from the excellent PowerShell blog at:
 #    http://www.nivot.org/2008/09/05/VMWareVMNETAdaptersTriggeringPublicProfileForWindowsFirewall.aspx
 # 
 # See also http://msdn2.microsoft.com/en-us/library/bb201634.aspx



 # adapters key  
 pushd 'hklm:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}' 
  
 # ignore and continue on error  
 dir -ea 0  | % {  
     $node = $_.pspath  
     $desc =  Get-ItemProperty $node -name driverdesc  
     if ($desc -like "*vmware*") {  
             new-itemproperty $node -name '*NdisDeviceType' -propertytype dword -value 1 
         }  
 }  
 popd  
  
  
# disable/enable network adapters  
 gwmi win32_networkadapter | ? {$_.name -like "*vmware*" } | % {         
     $x = $_.Disable()  
     $x = $_.Enable()  
 }   
 
 
 