###############################################################################
#
#"[+] Checking for at least one connected network adapter..."
#
###############################################################################

if ( @(Get-NetAdapter | Where { $_.Status -eq "Up" }).Count -eq 0 -And -not $Top.SkipNetworkInterfaceCheck)
{

    "`n`nYour VM appears to not have any connected network adapters."
    "Enable the network adapter inside your VM and set it to use "
    "'Host-Only' or 'Internal' (or similar).  Your VM does not need"
    "network access outside of your host computer.  Run this script"
    "again afterwards please.`n"

    "You may need to install the Microsoft Loopback Adapter driver."
    "Please open Control Panel > Device Manager > right-click your"
    "computer at the top > Add Legacy Hardware > Next > choose 'Install"
    "the hardware that I manually select' > Network Adapters > Next >"
    "choose Microsoft as the manufacturer > choose 'Microsoft KM-TEST"
    "Loopback Adapter' on the right > Next > Next > Finish.  Afterwards,"
    "assign 10.1.1.1 to the loopback interface, 255.0.0.0 as the mask,"
    "set its primary DNS to 127.0.0.1, disable all other network"
    "adapters you see in Control Panel, then run this script again.`n"
    
    $Top.Request = "Stop"
}

