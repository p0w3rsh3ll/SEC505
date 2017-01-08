# Just a little playful module to "Import-Module -Name .\Play.psm1"


# These need to be global variables (I'll fix this later...)
# You will need to edit the path that is dir-ed:
$GLOBAL:Player = New-Object System.Windows.Media.MediaPlayer 
$GLOBAL:List = dir c:\data\music\sans -File | where { $_.Extension -match 'mp3|wma' } | Select-Object -ExpandProperty fullname


# Play song list using hidden Windows Media Player.  Hit Ctrl-C to return
# to the shell, then run Play again to stop (or terminate PowerShell process):

function Play ( [Switch] $Stop ) 
{
    # If currently playing something, stop playing and return:
    if ($Player.Position.Ticks -ne 0) { $Player.Stop() ; Return } 

    # Randomize order of play list:
    $GLOBAL:List = Get-Random -Count $List.Count -InputObject $GLOBAL:List 

    # Play the list 4 times:
    $GLOBAL:List * 4 | ForEach `
    { 
        $Player.Open($_)
        Start-Sleep -Milliseconds 400
        Write-Host -Object $_ -ForegroundColor Green
        $Player.Play()
        Start-Sleep -Milliseconds ([Int32] $Player.NaturalDuration.TimeSpan.TotalMilliSeconds)
        $Player.Stop()
    } 
} 

