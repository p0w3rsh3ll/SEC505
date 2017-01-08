##############################################################################
#
# Demonstrates the minimal steps to install and use the PowerShell Web Access 
# (PSWA) feature.  Please see Microsoft's web site for further options, such 
# as customizing sessions, authorization rules and SSL for security.
#
# PSWA allows PowerShell remote command execution through any JavaScript-
# enabled browser on any platform, e.g., iPad tablets, Android phones, etc. 
# Commands are executed not just on the PSWA gateway, but on any internal
# computer with PowerShell remoting enabled (and other details of course).
#
# The PSWA gateway requires IIS on Windows Server 2012 or later.
#
##############################################################################



# Install the PSWA feature on the IIS gateway, rebooting if necessary:

Install-WindowsFeature –Name WindowsPowerShellWebAccess -IncludeManagementTools -Restart




##### Two Options ##### 
#
# If you already have an SSL/TLS certificate in IIS, install the PSWA web application:

Install-PswaWebApplication

# If you do NOT already have an SSL/TLS certificate in IIS, install the PSWA web
# application with a temporary self-signed certificate for testing only:

Install-PswaWebApplication -UseTestCertificate





# You have to add at least one PSWA Authorization Rule to control which users
# can connect to which computers through the PSWA web application.  The following
# is just an example, not necessarily what is appropriate for your real LAN:

Add-PswaAuthorizationRule -ComputerGroupName "TESTING\Domain Controllers" `
 -UserGroupName "TESTING\Domain Admins" -ConfigurationName "microsoft.powershell"




# View your current PSWA Authorization Rules to confirm:

Get-PswaAuthorizationRule | Format-List *




# Now open your browser, authenticate and choose the LAN computer to which to 
# connect through the PSWA gateway (or the gatway itself if you wish):

https://<YourFQDN>/pswa/





