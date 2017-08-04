$bsod = @'
A problem has been detected and Windows has been shut down to prevent 
damage to your computer.

The problem seems to be caused by the following file: SEC505.SYS

   IRQL_NOT_LESS_OR_EQUAL

If this is the first time you've seen this stop error screen, 
restart your computer. If this screen appears again, follow 
these steps:

Check to make sure any new hardware or software is properly installed.
If this is a new installation, ask your hardware or software manufacturer
for any Windows updates you might need.

If problems continue, disable or remove any newly installed hardware
or software. Disable BIOS memory options such as caching or shadowing.
If you need to use Safe Mode to remove or disable components, restart
your computer, press F8 to select Advanced Startup Options, and then
select Safe Mode.

Technical information:

*** STOP: 0xB105F00D (0xFFBADD11,0x00000001,0xDEADBEEF,0x00000001)

*** SEC505.SYS - Address C9SEC505 base at SEC5051F, DateStamp 5e1da27e
'@

$CurrentForegroundColor = [System.Console]::ForegroundColor
$CurrentBackgroundColor = [System.Console]::BackgroundColor

[system.console]::set_foregroundcolor("gray") 
[system.console]::set_backgroundcolor("darkblue")

cls
"`n"
$bsod 

@("`nCollecting data for crash dump ",".",".",".") | foreach { Write-Host -NoNewline $_ ; Start-Sleep -Milliseconds 300 }
Start-Sleep -Seconds 2 
@("`nInitializing disk for crash dump ",".",".",".") | foreach { Write-Host -NoNewline $_ ; Start-Sleep -Milliseconds 50 }
Start-Sleep -Seconds 1 
@("`nBeginning dump of physical memory ",".",".",".") | foreach { Write-Host -NoNewline $_ ; Start-Sleep -Milliseconds 100 }
Start-Sleep -Seconds 1
@("`nDumping physical memory to disk ",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".`n`n") | foreach { Write-Host -NoNewline $_ ; Start-Sleep -Milliseconds 400 }
Start-Sleep -Seconds 3
"Have a nice day.`n`n"

[system.console]::set_foregroundcolor($CurrentForegroundColor) 
[system.console]::set_backgroundcolor($CurrentBackgroundColor)
