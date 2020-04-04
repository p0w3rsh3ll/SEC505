# This demos some commands for querying and setting a particular IIS configuration option, namely,
# the Error Pages feature setting concerning custom or detailed error pages.  Copy and paste
# each command into your shell to test it out.



# Import IIS module and cmdlets first, then test out the IIS provider.
import-module webadministration
dir iis:\sites


# At the server level, get/set the Error Pages feature to "Detailed error for local requests and custom error pages for remote requests".
# This ensures the proper default for any new sites or for sites inheriting this setting.

Get-WebConfigurationProperty -Name errorMode -Filter /system.webServer/httpErrors -PSPath IIS:\
Set-WebConfigurationProperty -Name errorMode -Value "DetailedLocalOnly" -Filter /system.webServer/httpErrors -PSPath IIS:\



# Explicitly get/set the Error Pages feature for all existing sites.
Get-WebConfigurationProperty -Name errorMode -Filter /system.webServer/httpErrors -PSPath IIS:\Sites\*
Set-WebConfigurationProperty -Name errorMode -Value "DetailedLocalOnly" -Filter /system.webServer/httpErrors -PSPath IIS:\Sites\*


# Explicitly get/set the Error Pages feature for a particular site named WebSite1.
Get-WebConfigurationProperty -Name errorMode -Filter /system.webServer/httpErrors -PSPath IIS:\Sites\WebSite1
Set-WebConfigurationProperty -Name errorMode -Value "DetailedLocalOnly" -Filter /system.webServer/httpErrors -PSPath IIS:\Sites\WebSite1



# The Error Pages feature setting might be configured on individual folders or files within a 
# site?  Yes, but this script does not show how to enumerate through all of these.

# Note: If you get an error about "Cannot commit configuration changes because the 
# file has changed on disk", then wait a minute and try again.  



