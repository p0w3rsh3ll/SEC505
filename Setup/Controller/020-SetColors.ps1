###############################################################################
#
#"[+] Changing colors and clearing shell..."
#
###############################################################################

if ($host.Name -like "*ISE*")
{
    $psISE.Options.ConsolePaneBackgroundColor = "black"
    $psISE.Options.ConsolePaneTextBackgroundColor = "black"
    $psISE.Options.ConsolePaneForegroundColor = "white"
    $psISE.Options.FontName = "Lucida Console"
    $psISE.Options.FontSize = 12
}


# Change the color of the command prompt to yellow:
function prompt 
{
    write-host "$(get-location)>" -nonewline -foregroundcolor yellow
    return ' '  #Needed to remove the extra "PS"
}

#cls

