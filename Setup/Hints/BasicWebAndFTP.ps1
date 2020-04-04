#.SYNOPSIS
#  Installs the Web-WebServer and Web-Ftp-Server roles.
#
#.NOTES
#  It doesn't always have to be fancy!  :-)
#
#  If a role is already installed, it doesn't hurt when
#  you try to install it again.  


Install-WindowsFeature -Name "Web-WebServer","Web-Ftp-Server" -IncludeManagementTools 


