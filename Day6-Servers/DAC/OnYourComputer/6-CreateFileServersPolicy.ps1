# Create new Central Access Policy named "File Servers Policy".



New-ADCentralAccessPolicy "File Servers Policy" 

# And add the HR rule to it.
Add-ADCentralAccessPolicyMember -Identity "File Servers Policy" -Member "Only HR Access to Files with PII"



# Don't forget, F5 refresh to see it in the GUI if it does not appear...

