##############################################################################################
#
# In addition to writing to the standard textual W3C logs, Windows Firewall connections, port
# bindings, and dropped packets can be logged to the Windows event logs too, such as for
# troubleshooting or incident response.  Log events for successful connections and port bindings
# will include information about the associated process (name, path, PID, etc).  If even more
# information is required, install Microsoft Message Analyzer for a GUI to capture, filter and
# analyze events from the protocol stack.
# 
# Requires at least Windows Vista or Server 2008.
#
#  Author: Jason Fossen, Enclave Consulting LLC, https://www.sans.org/sec505
# Updated: 6-Sep-2016
# 
##############################################################################################



###########################################
#
#  View Current Audit Policies
#
###########################################

auditpol.exe /get /subcategory:'Filtering Platform Connection'  | Select-String -Pattern 'Filtering Platform'
auditpol.exe /get /subcategory:'Filtering Platform Packet Drop' | Select-String -Pattern 'Filtering Platform'



###########################################
#
#  Log Successful Connections: 5156
#  Log New Listening Port: 5158
#
###########################################

# Security 5156: The Windows Filtering Platform has permitted a connection.
# Security 5158: The Windows Filtering Platform has permitted a bind to a local port.
auditpol.exe /set /subcategory:'Filtering Platform Connection' /success:enable /failure:disable



###########################################
#
#  Log Blocked Connections: 5157
#  Log Blocked New Listening Port: 5159
#
###########################################

# Security 5157: The Windows Filtering Platform has blocked a connection.
# Security 5159: The Windows Filtering Platform has blocked a bind to a local port.
auditpol.exe /set /subcategory:'Filtering Platform Connection' /success:disable /failure:enable



###########################################
#
#  Log All Connection Events
#  Log All Listening Port Events
#
###########################################

# All of the above: Security 5156, 5158, 5157, and 5159:
auditpol.exe /set /subcategory:'Filtering Platform Connection' /success:enable /failure:enable



###########################################
#
#  Log Dropped Packets: 5152,5153
#
###########################################

# Security 5152: The Windows Filtering Platform has blocked a packet.
auditpol.exe /set /subcategory:'Filtering Platform Packet Drop' /success:disable /failure:enable 

# Security 5153: A more restrictive Windows Filtering Platform filter has blocked a packet.
# (Note: 5153 is for MAC address filtering at layer 2, which is not exposed in the Windows Firewall tool.)
auditpol.exe /set /subcategory:'Filtering Platform Packet Drop' /success:enable /failure:disable

# All of the above: Security 5152 and 5153:
auditpol.exe /set /subcategory:'Filtering Platform Packet Drop' /success:enable /failure:enable



###########################################
#
#  Query Packets Dropped by Firewall
#
###########################################

$xpath = @'
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=5152)]]</Select>
  </Query>
</QueryList>
'@

Get-WinEvent -LogName Security -FilterXPath $xpath -MaxEvents 100



###########################################
#
#  Query Connections Blocked By Firewall
#
###########################################

$xpath = @'
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=5157)]]</Select>
  </Query>
</QueryList>
'@

Get-WinEvent -LogName Security -FilterXPath $xpath -MaxEvents 100



###########################################
#
#  Query Successful Connections
#
###########################################

$xpath = @'
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=5156)]]</Select>
  </Query>
</QueryList>
'@

Get-WinEvent -LogName Security -FilterXPath $xpath -MaxEvents 100



###########################################
#
#  Disable All Firewall Audit Logging
#
###########################################

auditpol.exe /set /subcategory:'Filtering Platform Connection' /success:disable /failure:disable 
auditpol.exe /set /subcategory:'Filtering Platform Packet Drop' /success:disable /failure:disable 



