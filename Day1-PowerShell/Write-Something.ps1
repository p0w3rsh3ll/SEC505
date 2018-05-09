################################################################
#  There are a variety of Write-* cmdlets, but which one
#  should be used and how are they different?
################################################################


# For automatic common parameters, your script must begin with:
[CmdletBinding()] Param() 



# To list the commands with the Write-* verb:
Get-Command -Verb Write



# Some Write-* cmdlets change their behavior in response to certain switches and variables:
Get-Help about_CommonParameters | more
Get-Help about_Preference_Variables | more





# Write-Output is redundant and should be ignored:
"Does the same thing." | Write-Output
"Does the same thing." 



# Write-Host displays text with control over colors and newlines:
Write-Host -BackgroundColor Yellow -ForegroundColor Black -Object "Message"
"Message" | Write-Host -BackgroundColor White -ForegroundColor Red 
"Message" | Write-Host -NoNewline 



# Write-Progress displays a graphical percentage progress bar while in a loop:
1..100 | foreach { 
	Start-Sleep -Milliseconds 1  #Do something useful here, not just sleep.
	Write-Progress -Activity "Title For Progress Bar" -PercentComplete $_ 
}



# Write-Verbose only displays text with the -Verbose switch to the script and continues:
Write-Verbose -Message "Message"            # Does not display message.
Write-Verbose -Message "Message" -Verbose   # Always displays message.
"It's a nice way to make code comments too!" | Write-Verbose
"This is not written to the file" | Write-Verbose -Verbose | Out-File -File .\file.txt 



# Write-Debug displays text with the -Debug switch and prompts user to continue:
Write-Debug -Message "Message"              # Does not display.
Write-Debug -Message "Message" -Debug       # Displays message.



# Write-Warning displays message with explicit -WarningAction control:
Write-Warning -Message "Danger!"                                   # $WarningPreference default = Continue
Write-Warning -Message "Danger!" -WarningAction Continue           # Displays message and continues.
Write-Warning -Message "Danger!" -WarningAction Ignore             # Suppresses message and continues.
Write-Warning -Message "Danger!" -WarningAction SilentlyContinue   # Suppresses message and continues.
Write-Warning -Message "Danger!" -WarningAction Inquire            # Displays message and prompts user whether to continue.
Write-Warning -Message "Danger!" -WarningAction Stop               # Displays message and stops script.



# Write-Error creates a non-terminating error object, displays it, and script continues:
Write-Error -Message "Invalid data caused an error!"
$Error[0]  #Error object added to the $Error[] array.



# Write-EventLog writes to the traditional event logs on local or remote systems:
# If source does not exist, it must be created first:
New-EventLog -LogName Application -Source InventedSourceName
Write-EventLog -LogName Application -Source InventedSourceName -EventId 9000 -Message "My message here."


