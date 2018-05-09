# Windows 8 and later can use a TPM chip to implement a virtual smart card.
# The following are example commands for managing a TPM virtual smart card when
# an enterprise smart card management system is not used, e.g., MS Identity Manager.

# NOTES:
# The user PIN can be any standard printable ASCII character, not just numbers.
# The Admin Key, if any, must begin with "0" and be exactly 48 HEX characters in length.
# The PIN Unlock Key (PUK), if any, must be at least 8 characters long.
# If you set a PUK, the Admin Key can no longer be used to reset the user's PIN.
# When any key is set to "random", the key is not outputted, displayed or saved in any way.
# When prompted for a PIN or key, each PIN or key must be entered twice for confirmation.



# Create a virtual smart card and be prompted for the user PIN and PIN Unlock Key (PUK) PIN,
# with a minimum PIN length of 4 characters and a maximum PIN length of 55 characters:

tpmvscmgr.exe create /name "VirtualSmartCard" /pin prompt /puk prompt /adminkey random /pinpolicy minlen 4 maxlen 55 /generate 



# Function to list current virtual smart card instance ID strings:

function Get-VirtualSmartCard
{
    dir 'HKLM:\system\CurrentControlSet\Control\DeviceClasses\{50dd5230-ba8a-11d1-bf5d-0000f805f530}\' |
    ForEach `
    {
        $name = ($_.pschildname -split '{')[0]
        $name = $name -replace '##\?#',''
        $name = $name.Substring(0, $($name.length - 1))
        $name = $name.Replace('#','\')
        $name
    }
}

Get-VirtualSmartCard




# Permanently delete a virtual smart card and its key data (need instance ID of the card):

tpmvscmgr.exe destroy /instance ROOT\SMARTCARDREADER\0000






