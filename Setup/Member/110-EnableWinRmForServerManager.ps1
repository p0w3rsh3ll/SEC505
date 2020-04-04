# Enable WinRM remote access for Server Manager
# https://docs.microsoft.com/en-us/windows-server/administration/server-core/server-core-manage

# This confirms that AllowRemoteAccess for WinRM is set to "true":
#   (Get-Item WSMan:\localhost\Service\AllowRemoteAccess).Value


Configure-SMRemoting.exe -enable 2>$null | Out-Null


