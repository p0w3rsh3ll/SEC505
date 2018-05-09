<#
When troubleshooting firewall or IPsec problems, you can create an XML trace like this:

Open powershell.exe (not ISE), then run:

    netsh.exe wfp capture start

Now perform the action which is failing, then run:

    netsh.exe wfp capture stop

A file named "wfpdiag.cab" will be created in the current folder.

Extract the XML file from the CAB using 7-Zip or some other archive tool.
The XML file is named "wfpdiag.xml" by default.

Now you can start extracting troubleshooting details from the XML.
This script shows some examples to get started, but they are
just some absolute basics.  Unfortunately, it's not going to be fun...

Also try opening the file in Notepad++ or another text editor which
is XML-aware so that you can expand/collapse nodes, etc.
#>


[xml] $x = Get-Content -Path '.\wfpdiag.xml'


Write-Host -ForegroundColor Cyan -Object "System Info"  
$x.wfpdiag.sysInfo

Write-Host -ForegroundColor Cyan -Object "IPsec Inbound Traffic Statistics"  
$x.wfpdiag.initialState.ipsecStatistics.inboundTrafficStatistics

Write-Host -ForegroundColor Cyan -Object "IPsec Outbound Traffic Statistics"
$x.wfpdiag.initialState.ipsecStatistics.outboundTrafficStatistics

Write-Host -ForegroundColor Cyan -Object "Network Events"
$x.wfpdiag.events.netEvent | ForEach { $_.Type ; $_.header } 

Write-Host -ForegroundColor Cyan -Object "Provider Contexts"
$x.wfpdiag.initialState.providerContexts.ChildNodes
 



# You can also try parsing the raw XML itself (not fun):

Get-Content -Path '.\wfpdiag.xml' | Select-String -Pattern 'ipsec|cipher|hash|transform|pfs' -Context 5 



# If you're OK with using XPath, you can use Select-Xml too.




