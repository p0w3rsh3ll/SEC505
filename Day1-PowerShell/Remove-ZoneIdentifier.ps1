##################################################################################
#.SYNOPSIS
#	 Removes the hidden tag which identifies Internet-downloaded files. 
#
#.DESCRIPTION
#	 Removes the hidden NTFS Alternate Data Stream tag named Zone.Identifier which
#    is used by a variety of products to restrict access to files downloaded from 
#    the Internet zone in the Internet Explorer browser or which were received as
#    attachments to e-mails received in Microsoft Outlook.  The PowerShell 
#    RemoteExecute execution policy uses this tag, as well as Microsoft Office 
#    protected view, and Adobe Reader protected view.
#
#.PARAMETER  Path
#	 Path to file(s) whose hidden zone identifier tag will be removed.  The file
#    itself is not removed.  Wildcards are supported.  Defaults to "*.ps1".
#
#.PARAMETER  Recurse
#	 Switch to recurse through subdirectories of the given path.
#
##################################################################################


Param ($Path = ".\*.ps1", [Switch] $Recurse)

if ($Recurse)
{ Remove-Item -Path $Path -Stream Zone.Identifier -Recurse }
else
{ Remove-Item -Path $Path -Stream Zone.Identifier          }




# PowerShell 3.0 and later include the Unblock-File cmdlet, but this
# script is meant for backwards compatibility.  Feel free to use
# Unblock-File instead on PowerShell 3.0 and later of course.




# Incidentally, this is how you can change the Zone.Identifier tag, but
# don't be surprised if the content of the Zone.Identifier doesn't matter
# to your applications; it seems instead that the mere existence of the
# "Zone.Identifier" tag is the only thing some applications check (oh well).

function Set-ZoneIdentifier ($Path, $Zone = "Internet")
{
    Switch -RegEx ($Zone)
    {
        'local'      { $Zone = "0" }    # My Computer
        'intranet'   { $Zone = "1" }    # Local Intranet
        'trusted'    { $Zone = "2" }    # Trusted Sites
        'internet'   { $Zone = "3" }    # Internet
        'restricted' { $Zone = "4" }    # Restricted Sites
	} 

    Set-Content -Path $Path -Stream "Zone.Identifier" -Value "[ZoneTransfer]" 
    Add-Content -Path $Path -Stream "Zone.Identifier" -Value "ZoneId=$Zone"
}

