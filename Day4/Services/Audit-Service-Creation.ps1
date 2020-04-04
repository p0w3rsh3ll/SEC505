### Recommendations to better audit the creation of new services: ###
#
#   Enable the "Audit System Service Extension" audit policy under the System category.
#   Audit the creation and deletion of subkeys under HKLM\SYSTEM\CurrentControlSet\Services\.
#   Audit the execution of sc.exe.
#
###


# Create and then delete a service to generate some auditable activity:

sc.exe create 'Your Service Name Here' start= auto binPath= 'C:\Windows\System32\cmd.exe'
sc.exe delete 'Your Service Name Here'



# Extract service creation events on Vista/2008 and later:

Get-WinEvent -FilterHashtable @{ LogName = 'System'; ID = 7045 } 



# Try to extract service creation events on Vista/2008 and later, but apparently never works despite Microsoft's documentation:

Get-WinEvent -FilterHashtable @{ LogName = 'Security'; ID = 4697 } 



# Extract events for service-related keys in the registry: 

Get-WinEvent -FilterHashtable @{ LogName = 'Security'; ID = 4656,4660,4663 } | 
 Where { $_.Message -like '*\SYSTEM\ControlSet*\Services\*' -or $_.Message -like '*\System32\services.exe*' }



# Same extraction as above, but using a more efficient XPath query that limits returns by
# source and the task category ID (12801) for the registry specifically:

$xpath = '<QueryList><Query Id="0" Path="Security"><Select Path="Security">*[System[Provider[@Name="Microsoft-Windows-Security-Auditing"] and Task = 12801]]</Select></Query></QueryList>'

Get-WinEvent -LogName Security -FilterXPath $xpath | 
 Where { $_.Message -like '*\SYSTEM\ControlSet*\Services\*' -or $_.Message -like '*\System32\services.exe*' }




