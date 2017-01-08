
$voice = new-object -comobject "sapi.spvoice"
$voice | get-member
$voice.speak("I have a type library!")




notepad.exe
start-sleep -seconds 1 
$WshShell = new-object -comobject "WScript.Shell" 
$result = $WshShell.AppActivate("Untitled")  
$WshShell.SendKeys("I'm sending keystrokes to notepad.exe!")



$excel = new-object -com "Excel.Application" -strict

