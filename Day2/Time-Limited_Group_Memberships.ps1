<###########################################################
If your domain controllers are Server 2016 or later, and 
your forest functionality level is Server 2016 or later too, 
then you can enable support for time-limited group 
memberships.  Microsoft calls this "Privileged Access 
Management (PAM)."

###########################################################>


# To check whether PAM is currently enabled, run: 

Get-ADOptionalFeature -Filter { Name -like "Priv*" }

# If the "EnabledScopes" property of the object outputted by 
# the above command is empty, then the feature is not enabled. 


# To confirm that your AD forest is at the Server 2016 or 
# better forest functionality level:

Get-ADForest -Current LocalComputer | Select ForestMode

# Your "ForestMode" should be "Windows2016Forest" or later.  


# To enable time-limited group memberships for your forest, 
# where the root domain of your forest is named "testing.local", 
# run this command (it wraps to multiple lines):

Enable-ADOptionalFeature "Privileged Access Management Feature" `
 -Scope ForestOrConfigurationSet -Target "testing.local" `
 -Confirm:$False

# This change will replicate to your other domain controllers.  
# No domain controller reboot necessary.

