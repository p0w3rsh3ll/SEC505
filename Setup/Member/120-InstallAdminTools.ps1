# Install version 1.0 of the App Compatibility FOD:

# Some attendees will not have en-US locale set, but the FOD packages are en-US only, so:
$Top.CurrentCulture =   [System.Threading.Thread]::CurrentThread.CurrentCulture
$Top.CurrentUICulture = [System.Threading.Thread]::CurrentThread.CurrentUICulture
[System.Threading.Thread]::CurrentThread.CurrentCulture =   "en-US"
[System.Threading.Thread]::CurrentThread.CurrentUICulture = "en-US"


Add-WindowsCapability -Online -Source ".\Resources\FOD" -LimitAccess -Name "ServerCore.AppCompatibility~~~~0.0.1.0" | Out-Null


[System.Threading.Thread]::CurrentThread.CurrentCulture = $Top.CurrentCulture
[System.Threading.Thread]::CurrentThread.CurrentUICulture = $Top.CurrentUICulture 

