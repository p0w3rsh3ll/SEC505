##############################################################################
#  Script: Get-FileHex.ps1
#    Date: 16.May.2007
# Version: 1.0
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
# Purpose: Shows the hex translation of a file, binary or otherwise.  The
#          $width argument determines how many bytes are output per line.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

param ( $path = $(throw "Enter path to file!"), [Int] $width = 16 )


function Get-FileHex ( $path = $(throw "Enter path to file!"), [Int] $width = 16 ) {
    $linecounter = 0  
    $padwidth = $width * 3
    $placeholder = "."     # What to print when byte is not a letter or digit.

    get-content $path -encoding byte -readcount $width | 
    foreach-object { 
        $paddedhex = $asciitext = $null
        $bytes = $_        # Array of [Byte] objects that is $width items in length.
 
        foreach ($byte in $bytes) { 
            $simplehex = [String]::Format("{0:X}", $byte)     # Convert to hex.
            $paddedhex += $simplehex.PadLeft(2,"0") + " "     # Pad with zeros to force 2-digit length
        } 
 
        # Total bytes in file unlikely to be evenly divisible by $width, so fix last line.
        if ($paddedhex.length -lt $padwidth) 
           { $paddedhex = $paddedhex.PadRight($padwidth," ") }

        foreach ($byte in $bytes) { 
            if ( [Char]::IsLetterOrDigit($byte) -or 
                 [Char]::IsPunctuation($byte) -or 
                 [Char]::IsSymbol($byte) ) 
               { $asciitext += [Char] $byte }                 # Cast raw byte to a character.
            else 
               { $asciitext += $placeholder }
        }
        
        $offsettext = [String]::Format("{0:X}", $linecounter) # Linecounter to hex too.
        $offsettext = $offsettext.PadLeft(9,"0") + "h:"       # Pad hex linecounter with zeros.
        $linecounter += $width                                # Increment linecounter.

        "$offsettext $paddedhex $asciitext"           
    }
}


Get-FileHex -path $path -width $width

