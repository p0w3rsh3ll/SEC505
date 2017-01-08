###############################################################################
#
# Purpose: Delete unread messages in the Deleted Items folder in Outlook, but
#          the script also demos some of the pains involved in COM interop.
#
###############################################################################


function Remove-UnReadMessagesFromDeletedItemsInOutlook ( [Switch] $ShowCount )
{
    $DeletedMessagesCounter = 0
    Add-Type -AssemblyName Microsoft.Office.Interop.Outlook
    $olDefaultFolders = "Microsoft.Office.Interop.Outlook.OlDefaultFolders" -as [Type]
    $olObjectClass = "Microsoft.Office.Interop.Outlook.OlObjectClass" -as [Type]

    # The following line will fail if Outlook is already running and this script
    # is running UAC elevated as administrator.  Run script as standard user.
    $Outlook = New-Object -ComObject Outlook.Application
    if (-not $?) { "`nRun script as a standard user, not as administrator.`n" ; exit } 

    $MAPI  = $Outlook.GetNameSpace("MAPI")
    $DeletedItemsFolder = $MAPI.getDefaultFolder($olDefaultFolders::olFolderDeletedItems) 
    
    $DeletedItems = $DeletedItemsFolder.Items 
    
    # When deleting an array of things in any Office product, start at the bottom 
    # of the array and work towards the beginning or else items will be missed.
    # Many of these arrays are 1-based, not 0-based, i.e., first item is #1, not #0.
    # Note that when Deleted Items is large, this script is very slooowwwwww...
    For ( $i = $DeletedItems.Count ; $i -ge 1 ; $i-- )
    {
        If ( ($DeletedItems.Item($i).Class -eq $olObjectClass::olMail.value__ -or $DeletedItems.Item($i).Class -eq $olObjectClass::olPost.value__) -and $DeletedItems.Item($i).UnRead ) 
        { $DeletedItems.Item($i).Delete() ; $DeletedMessagesCounter++ } 
    }
    
    If ($ShowCount) { "`n $DeletedMessagesCounter items deleted.`n" } 

    # Outlook as a background COM process does not Quit() gracefully, so this speeds it up (yuck).
    # A background process is not created if Outlook is already running, but, in this case, you
    # must run the script at the same UAC level (standard user) as Outlook itself.
    $DeletedItems = $null
    $DeletedItemsFolder = $null
    $MAPI = $null   
    [System.Runtime.InteropServices.Marshal]::FinalReleaseComObject([System.__ComObject] $Outlook) | Out-Null
    $Outlook = $null
    Start-Sleep -Seconds 4 # Need to give time to before trying to collect, or else process lives too long.
    [GC]::Collect(0)  
}



Remove-UnReadMessagesFromDeletedItemsInOutlook -ShowCount 


