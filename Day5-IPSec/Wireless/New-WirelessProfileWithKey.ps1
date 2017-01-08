####################################################################################
#.Synopsis 
#    Create a WPA2-Personal wireless profile with a preshared key using AES.  
#
#.Description
#    Create a WPA2-Personal wireless profile with a preshared key using AES.  
#    Requires Windows 7 or later.  Must be run with administrative privileges.
#    The script is just a wrapper for NETSH.EXE.
#
#.Parameter SSID
#    Name of the wireless network (1-32 characters).  Will overwrite any existing
#    network profile of the same name without warning.
#
#.Parameter PreSharedKey
#    The WPA2-Personal preshared key string (at least 8 characters).  This key
#    string will be written to a random temp file which is deleted afterwards.
#
#.Parameter DoNotConnectAutomatically
#    By default, the wireless profile will connect automatically.  This switch
#    will require the user to choose to connect to this wireless network.
#
#.Parameter ShowProfileDetails
#    Show the details of the wireless profile, including the plaintext
#    preshared key, after the wireless profile is created.  
#
#.Example 
#    New-WirelessProfileWithKey.ps1 -SSID "MySsid" -PreSharedKey "MySekritKey"
#
#Requires -Version 2.0 
#
#.Notes 
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)  
# Version: 1.0
# Updated: 24.Jul.2013
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################


[CmdletBinding()] Param 
(
 [Parameter(Mandatory = $True)] [ValidateLength(1,32)] [String] $SSID,
 [Parameter(Mandatory = $True)] [ValidateLength(8,10000)] [String] $PreSharedKey,
 [Parameter()] [Switch] $DoNotConnectAutomatically,
 [Parameter()] [Switch] $ShowProfileDetails
)

# Convert SSID into uppercase hex:
[String] $ssidhex += [System.Text.Encoding]::ASCII.GetBytes($ssid) | foreach { "{0:X}" -F $_ } 
$ssidhex = $ssidhex.replace(" ","")

# Assume that the "Connect Automatically" box should be checked in the GUI.
$connectionmode = "auto"  
if ($DoNotConnectAutomatically) { $connectionmode = "manual" }  

# This is the file which will contain the preshared key in plaintext.
$tempfile = [System.IO.Path]::GetTempFileName()


# The contents of the XML file used by NETSH.EXE to create the wireless profile.
# To see how to create your own, run: netsh.exe wlan export profile ?

$xmlfile = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
	<name>$ssid</name>
	<SSIDConfig>
		<SSID>
			<hex>$ssidhex</hex>
			<name>$ssid</name>
		</SSID>
		<nonBroadcast>true</nonBroadcast>
	</SSIDConfig>
	<connectionType>ESS</connectionType>
	<connectionMode>$connectionmode</connectionMode>
	<autoSwitch>false</autoSwitch>
	<MSM>
		<security>
			<authEncryption>
				<authentication>WPA2PSK</authentication>
				<encryption>AES</encryption>
				<useOneX>false</useOneX>
			</authEncryption>
			<sharedKey>
				<keyType>passPhrase</keyType>
				<protected>false</protected>
				<keyMaterial>$presharedkey</keyMaterial>
			</sharedKey>
		</security>
	</MSM>
</WLANProfile>
"@

# Now create the wireless profile using netsh.exe.
# NETSH.EXE enforces a minimum preshared key length of 8 characters.
# NETSH.EXE enforces a maximum SSID name length of 32 characters.

$xmlfile | out-file -filepath $tempfile -force 
netsh.exe wlan add profile filename="$tempfile"
remove-item -path $tempfile -force 
if ($ShowProfileDetails) { netsh.exe wlan show profiles "$ssid" key=clear } 

