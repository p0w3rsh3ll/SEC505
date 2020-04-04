##############################################################################
# 
# This script demonstrates how to interact with Microsoft Azure Active 
# Directory via PowerShell.  You will need an Azure AD account first, which
# is free: http://azure.microsoft.com/en-us/services/active-directory/
#
# 
# Script Prerequisites:
# 
# Install latest version of the Azure PowerShell cmdlets:
#      https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/
#      https://github.com/Azure/azure-powershell/
#
#
# Install latest version of the "Microsoft Online Services Sign-in Assistant" for MsOnline module:
#      Last Seen At: http://go.microsoft.com/fwlink/?LinkID=286152
#
#
# Install latest version of "Windows Azure AD Module" for MsOnline module:
#      Last Seen At: http://go.microsoft.com/fwlink/p/?linkid=236297   
#
##############################################################################


# Import the Azure AD PowerShell module:
Import-Module -Name Azure


# List the cmdlets provided by the module (750+):
Get-Command -Module Azure 


# Authenticate with your Microsoft Account or Organizational
# Account with a pop-up dialog box; you may run the command
# multiple times to load multiple accounts simultaneously:
Add-AzureAccount


# Show current Azure management account(s), subscriptions and tenants:
Get-AzureAccount


# Show Azure subscription(s) and which is the current one:
Get-AzureSubscription




#################################################################################
# As of Jan 2016, Azure Active Directory account management has not yet been
# incorporated into the main Azure AD module used above, hence, the two MsOnline
# prerequisites mentioned above are necessary for the following commands.
#################################################################################


# Import the Azure AD PowerShell module for MSOnline:
Import-Module -Name MSOnline


# List the cmdlets provided by the MSOnline module:
Get-Command -Module MSOnline


# Connect and authenticate to Azure AD, where your username will
# be similar to '<yourusername>@<yourdomain>.onmicrosoft.com':
$creds = Get-Credential
Connect-MsolService -Credential $creds


# Get subscriber company contact information:
Get-MsolCompanyInformation


# Get subscription and license information:
Get-MsolSubscription | Format-List *
Get-MsolAccountSku   | Format-List *


# Get Azure AD users:
Get-MsolUser


# Get list of Azure AD management roles:
Get-MsolRole


# Show the members of each management role:
Get-MsolRole | ForEach { "`n`n" ; "-" * 30 ; $_.Name ; "-" * 30 ; Get-MsolRoleMember -RoleObjectId $_.ObjectId | ForEach { $_.DisplayName } }  



