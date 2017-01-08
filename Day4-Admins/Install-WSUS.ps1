######################################################################
# This script installs WSUS on Server 2012 and later.  It uses the
# Windows Internal Database (WID) instead of SQL Server, and places
# the WSUS database files into a new folder named C:\WSUS.  Note that
# IIS is also installed at the same time as a required service.
######################################################################


# Exit if WSUS is already installed:
if ( $(Get-WindowsFeature -Name UpdateServices).Installed ) { "WSUS aleady installed!" ; exit }  


# Install the WSUS role:
Install-WindowsFeature -Name UpdateServices -IncludeManagementTools


# Create the folder where the WSUS database will be stored:
mkdir C:\WSUS 


# Tell WSUS to use that new folder for its content:
& 'c:\Program Files\Update Services\Tools\wsusutil.exe' postinstall CONTENT_DIR=C:\WSUS





######################################################################
# These are the cmdlets for managing WSUS:
#     Get-Command -Module UpdateServices 
#
# And this is the original management utility:
#     C:\'Program Files'\'Update Services'\Tools\wsusutil.exe /?
######################################################################

