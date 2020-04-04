########################################################################
#
# Demonstrate how to use built-in Windows speech synthesis, i.e., to
# make your computer say stuff...
#
########################################################################


Param ( $TextToSpeak = "You can make your computer say anything you wish, such as for audio alerts." ) 

# Load the .NET assembly (DLL) with the SpeechSynthesizer class:
Add-Type -AssemblyName "System.Speech"

# Create a SpeechSynthesizer object:
$Speech = New-Object System.Speech.Synthesis.SpeechSynthesizer

# List available voice types:
$Voices = $Speech.GetInstalledVoices()
$Voices | ForEach { $_.VoiceInfo | Select Gender,Age,Name,Description } | Format-Table -AutoSize 

# Select a voice to use, in this case, the last one from the list:
$Speech.SelectVoice( $Voices[-1].VoiceInfo.Name ) 

# Make sure your speakers aren't muted...
$Speech.Speak( $TextToSpeak )



return



# By adding Speech Synthesis Markup Language (SSML) tags in XML, you can control 
# pitch, speed, gender, pauses, and other voice qualities:

$SSMLmarkup = @'
<?xml version="1.0" encoding="ISO-8859-1"?>
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="en-US">
<s>

  <voice gender="female" age="24">
    <prosody pitch="-400Hz" rate=".3" volume="70"> Oh my </prosody> 
    <break time="50ms"/> 
    this is the <prosody pitch="+50Hz" rate=".5" volume="100"> best </prosody> 
    SANS course I've ever taken!
  </voice>

  <voice gender="male" age="54">
    <prosody pitch="-1100Hz" rate="1.1" volume="100"> You betcha sister! </prosody> 
  </voice>

</s>
</speak>
'@


$Speech.SpeakSsml( $SSMLmarkup ) 





# And as long as we are on the subject of Stupid PowerShell Tricks,
# here's how you can make your computer sound like it's working hard:

Start-Job -Name ThinkingHard -ScriptBlock { while ($true){ [Console]::Beep( (Get-Random -Min 300 -Max 7000), 200) } } 
# Then stop the beeping later with this:
Stop-Job -Name ThinkingHard -PassThru | Remove-Job



