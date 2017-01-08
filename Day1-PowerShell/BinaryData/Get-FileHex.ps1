##############################################################################
#.Synopsis
#    Display the hex dump of a file.
#
#.Parameter Path
#    Path to file as a string or as a System.IO.FileInfo object;
#    object can be piped into the function, string cannot.
#
#.Parameter Width
#    Number of hex bytes shown per line (default = 16).
#
#.Parameter Count
#    Number of bytes in the file to process (default = all).
#
#.Parameter PlaceHolder
#    What to print when byte is not a character (default = '.' ).
#
#.Parameter NoOffset
#    Switch to suppress offset line numbers in output (left side).
#
#.Parameter NoText
#    Switch to suppress text mapping of bytes in output (right side).
#
#.Notes
#    Date: 1.Jul.2014
# Version: 1.3
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain.  No rights reserved.
##############################################################################


[CmdletBinding()] Param 
(
    [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
    [Alias("FullName","FilePath")] $Path,
    [Int] $Width = 16,
    [Int] $Count = -1,
    [String] $PlaceHolder = '.',
    [Switch] $NoOffset,
    [Switch] $NoText
)




function Get-FileHex 
{
    ################################################################
    #.Synopsis
    #    Display the hex dump of a file.
    #.Parameter Path
    #    Path to file as a string or as a System.IO.FileInfo object;
    #    object can be piped into the function, string cannot.
    #.Parameter Width
    #    Number of hex bytes shown per line (default = 16).
    #.Parameter Count
    #    Number of bytes in the file to process (default = all).
    #.Parameter PlaceHolder
    #    What to print when byte is not a character (default= '.' ).
    #.Parameter NoOffset
    #    Switch to suppress offset line numbers in output (left).
    #.Parameter NoText
    #    Switch to suppress text mapping of bytes in output (right).
    ################################################################
    [CmdletBinding()] Param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [Alias("FullName","FilePath")] $Path,
        [Int] $Width = 16,
        [Int] $Count = -1,
        [String] $PlaceHolder = ".",
        [Switch] $NoOffset,
        [Switch] $NoText
    )

    $linecounter = 0      # Offset from beginning of file in hex.
    #$placeholder = "."    # What to print when byte is not a letter or digit.


    get-content $path -encoding byte -readcount $width -totalcount $count |
    foreach-object `
    {
         $paddedhex = $text = $null
         $bytes = $_  # Array of [Byte] objects that is $width items in length.


         foreach ($byte in $bytes)`
         {
            $byteinhex = [String]::Format("{0:X}", $byte)   # Convert byte to hex.
            $paddedhex += $byteinhex.PadLeft(2,"0") + " "   # Pad with two zeros.
         } 


         # Total bytes unlikely to be evenly divisible by $width, so fix last line.
         # Hex output width is '$width * 3' because of the extra spaces.
         if ($paddedhex.length -lt $width * 3)
         { $paddedhex = $paddedhex.PadRight($width * 3," ") }


         foreach ($byte in $bytes)`
         {
             if ( [Char]::IsLetterOrDigit($byte) -or
                  [Char]::IsPunctuation($byte) -or
                  [Char]::IsSymbol($byte) )
             { $text += [Char] $byte }
             else
             { $text += $placeholder }
         }


         $offsettext = [String]::Format("{0:X}", $linecounter)  # Linecounter in hex too.
         $offsettext = $offsettext.PadLeft(8,"0") + "h:"        # Pad linecounter with left zeros.
         $linecounter += $width                                 # Increment linecounter.


         if (-not $NoOffset) { $paddedhex = "$offsettext $paddedhex" }
         if (-not $NoText) { $paddedhex = $paddedhex + $text }
         $paddedhex
    }
}





Get-FileHex -path $path -width $width -count $count -placeholder $placeholder -NoOffset:$NoOffset -NoText:$NoText

