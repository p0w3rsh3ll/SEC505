##############################################################################
#  Script: Speak-Text.ps1
#    Date: 28.Mar.2015
# Version: 1.3
#  Author: Enclave Consulting LLC, Jason Fossen
# Purpose: Demos how to use a COM object to speak audible text.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

Param ( $TextToSpeak = "You can make your computer say anything you wish, such as for audio alerts." ) 



function Speak-Text( $TextToSpeak = "Please tell me what to say!" )
{
    $Voice = new-object -com "SAPI.SpVoice" -strict
    $Voice.Rate = -2                         # Valid Range: -10 to 10, slowest to fastest, 0 default.
    $Voice.Speak( $TextToSpeak ) | out-null  # Piped to null to suppress text output.
}




Speak-Text -TextToSpeak $TextToSpeak


