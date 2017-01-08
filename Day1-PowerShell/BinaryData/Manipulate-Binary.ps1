##############################################################################
#  Script: Manipulate-Binary.ps1
# Purpose: A variety of functions for manipulating hex and binary files.
#    Date: 29.Nov.2012
# Version: 3.0
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
#   Notes: Requires PowerShell 2.0 or later.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

# Convert the following base data types into an array of
# bytes: Boolean, Char, Double, Int*, UInt*, and Single.
# Char is the Unicode code point number of a glyph (two bytes).
[Byte[]] $bytes = [System.BitConverter]::GetBytes( [Int64] 99999999999999999 ) 
[Byte[]] $bytes = [System.BitConverter]::GetBytes( [Char] 65 ) 


# You can read a binary (or text) file into an array of bytes
# using the -encoding parameter of get-content:
[System.Byte[]] $filebytes = get-content HelloWorld.ps1 -encoding byte 


# You can of course construct the array and then write it to a file:
$filebytes = @(13,10,34,72,101,108,108,111,32,87,111,114,108,100,33,34,13,10,13,10)


# To create a single Byte object or an array of Bytes:
[Byte] $x = 0x4D
[Byte[]] $y = 0x4D,0x5A,0x90,0x00,0x03


# Once you have an array of bytes, you can write them back to a file:
$filebytes | set-content HelloWorld2.ps1 -encoding byte


# To read the bytes of a file into an array (SLOW with large files):
[byte[]] $x = get-content -encoding byte -path .\file.exe


# To overwrite or create a file with raw bytes, avoiding any hidden string conversion, where $x is a Byte[] array:
set-content -value $x -encoding byte -path .\outfile.exe


# To append to or create a file with raw bytes, avoiding any hidden string conversion, where $x is a Byte[] array:
add-content -value $x -encoding byte -path .\outfile.exe


function Read-FileByte 
{
################################################################
#.Synopsis
#   Returns an array of System.Byte[] of the file contents.
#.Parameter Path
#   Path to the file as a string or as System.IO.FileInfo object.
#   FileInfo object can be piped into the function. Path as a
#   string can be relative or absolute, but cannot be piped.
################################################################
    [CmdletBinding()] Param (
     [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
     [Alias("FullName","FilePath")]
     $Path )

    [System.IO.File]::ReadAllBytes( $(resolve-path $Path) )
}


function Write-FileByte 
{
################################################################
#.Synopsis
#   Overwrites or creates a file with an array of raw bytes.
#.Parameter ByteArray
#   System.Byte[] array of bytes to put into the file. If you
#   pipe this array in, you must pipe the [Ref] to the array.
#.Parameter Path
#   Path to the file as a string or as System.IO.FileInfo object.
#   Path as a string can be relative, absolute, or a simple file
#   name if the file is in the present working directory.
#.Example
#   write-filebyte -bytearray $bytes -path outfile.bin
#.Example
#   [Ref] $bytes | write-filebyte -path c:\temp\outfile.bin
################################################################
    [CmdletBinding()] Param (
     [Parameter(Mandatory = $True, ValueFromPipeline = $True)] [System.Byte[]] $ByteArray,
     [Parameter(Mandatory = $True)] $Path )

    if ($Path -is [System.IO.FileInfo])
    { $Path = $Path.FullName }
    elseif ($Path -notlike "*\*") #Simple file name.
    { $Path = "$pwd" + "\" + "$Path" }
    elseif ($Path -like ".\*") #pwd of script
    { $Path = $Path -replace "^\.",$pwd.Path }
    elseif ($Path -like "..\*") #parent directory of pwd of script
    { $Path = $Path -replace "^\.\.",$(get-item $pwd).Parent.FullName }
    else
    { throw "Cannot resolve path!" }
    [System.IO.File]::WriteAllBytes($Path, $ByteArray)
}


function Convert-ByteArrayToString 
{
################################################################
#.Synopsis
#   Returns the string representation of a System.Byte[] array.
#   ASCII string is the default, but Unicode, UTF7, UTF8 and
#   UTF32 are available too.
#.Parameter ByteArray
#   System.Byte[] array of bytes to put into the file. If you
#   pipe this array in, you must pipe the [Ref] to the array.
#   Also accepts a single Byte object instead of Byte[].
#.Parameter Encoding
#   Encoding of the string: ASCII, Unicode, UTF7, UTF8 or UTF32.
#   ASCII is the default.  "Unicode" is actually UTF16-LE.
################################################################
    [CmdletBinding()] Param (
     [Parameter(Mandatory = $True, ValueFromPipeline = $True)] [System.Byte[]] $ByteArray,
     [Parameter()] [String] $Encoding = "ASCII" )

    switch ( $Encoding.ToUpper() )
    {
    "ASCII" { $EncodingType = "System.Text.ASCIIEncoding" }
    "UNICODE" { $EncodingType = "System.Text.UnicodeEncoding" }
    "UTF7" { $EncodingType = "System.Text.UTF7Encoding" }
    "UTF8" { $EncodingType = "System.Text.UTF8Encoding" }
    "UTF32" { $EncodingType = "System.Text.UTF32Encoding" }
    Default { $EncodingType = "System.Text.ASCIIEncoding" }
    }
    $Encode = new-object $EncodingType
    $Encode.GetString($ByteArray)
}


function Convert-HexStringToByteArray 
{
################################################################
#.Synopsis
#   Convert a string of hex data into a System.Byte[] array. An
#   array is always returned, even if it contains only one byte.
#.Parameter String
#   A string containing hex data in any of a variety of formats,
#   including strings like the following, with or without extra
#   tabs, spaces, quotes or other non-hex characters:
#   0x41,0x42,0x43,0x44
#   \x41\x42\x43\x44
#   41-42-43-44
#   41424344
#   The string can be piped into the function too.
################################################################
    [CmdletBinding()]
    Param ( [Parameter(Mandatory = $True, ValueFromPipeline = $True)] [String] $String )

    #Clean out whitespaces and any other non-hex crud.
    $String = $String.ToLower() -replace '[^a-f0-9\\\,x\-\:]',''

    #Try to put into canonical colon-delimited format.
    $String = $String -replace '0x|\\x|\-|,',':'

    #Remove beginning and ending colons, and other detritus.
    $String = $String -replace '^:+|:+$|x|\\',''

    #Maybe there's nothing left over to convert...
    if ($String.Length -eq 0) { ,@() ; return }

    #Split string with or without colon delimiters.
    if ($String.Length -eq 1)
    { ,@([System.Convert]::ToByte($String,16)) }
    elseif (($String.Length % 2 -eq 0) -and ($String.IndexOf(":") -eq -1))
    { ,@($String -split '([a-f0-9]{2})' | foreach-object { if ($_) {[System.Convert]::ToByte($_,16)}}) }
    elseif ($String.IndexOf(":") -ne -1)
    { ,@($String -split ':+' | foreach-object {[System.Convert]::ToByte($_,16)}) }
    else
    { ,@() }
    #The strange ",@(...)" syntax is needed to force the output into an
    #array even if there is only one element in the output (or none).
}
 


function Convert-ByteArrayToHexString 
{
################################################################
#.Synopsis
#   Returns a hex representation of a System.Byte[] array as
#   one or more strings. Hex format can be changed.
#.Parameter ByteArray
#   System.Byte[] array of bytes to put into the file. If you
#   pipe this array in, you must pipe the [Ref] to the array.
#   Also accepts a single Byte object instead of Byte[].
#.Parameter Width
#   Number of hex characters per line of output.
#.Parameter Delimiter
#   How each pair of hex characters (each byte of input) will be
#   delimited from the next pair in the output. The default
#   looks like "0x41,0xFF,0xB9" but you could specify "\x" if
#   you want the output like "\x41\xFF\xB9" instead. You do
#   not have to worry about an extra comma, semicolon, colon
#   or tab appearing before each line of output. The default
#   value is ",0x".
#.Parameter Prepend
#   An optional string you can prepend to each line of hex
#   output, perhaps like '$x += ' to paste into another
#   script, hence the single quotes.
#.Parameter AppendComma
#   Appends a comma to each line of output, except the last.
#.Parameter AddQuotes
#   A switch which will enclose each line in double-quotes.
#.Example
#   [Byte[]] $x = 0x41,0x42,0x43,0x44
#   Convert-ByteArrayToHexString $x
#
#   0x41,0x42,0x43,0x44
#.Example
#   [Byte[]] $x = 0x41,0x42,0x43,0x44
#   Convert-ByteArrayToHexString $x -width 2 -delimiter "\x" -addquotes
#
#   "\x41\x42"
#   "\x43\x44"
################################################################
    [CmdletBinding()] 
    Param 
    (
     [Parameter(Mandatory = $True, ValueFromPipeline = $True)] [System.Byte[]] $ByteArray,
     [Parameter()] [Int] $Width = 10,
     [Parameter()] [String] $Delimiter = ",0x",
     [Parameter()] [String] $Prepend = "",
     [Parameter()] [Switch] $AddQuotes,
     [Parameter()] [Switch] $AppendComma 
    )

    if ($Width -lt 1) { $Width = 1 }
    if ($ByteArray.Length -eq 0) { Return }
    $FirstDelimiter = $Delimiter -Replace "^[\,\\:\t]",""
    $From = 0
    $To = $Width - 1
    Do
    {
    $String = [System.BitConverter]::ToString($ByteArray[$From..$To])
    $String = $FirstDelimiter + ($String -replace "\-",$Delimiter)
    $From += $Width
    $To += $Width
    if ($AppendComma -and $From -lt $ByteArray.Length) { $String = $String + ',' } 
    if ($AddQuotes) { $String = '"' + $String + '"' }
    if ($Prepend -ne "") { $String = $Prepend + $String }
    $String
    } While ($From -lt $ByteArray.Length)
} 
 



function Toggle-Endian 
{
################################################################
#.Synopsis
#   Swaps the ordering of bytes in an array where each swappable
#   unit can be one or more bytes, and, if more than one, the
#   ordering of the bytes within that unit is NOT swapped. Can
#   be used to toggle between little- and big-endian formats.
#   Cannot be used to swap nibbles or bits within a single byte.
#.Parameter ByteArray
#   System.Byte[] array of bytes to be rearranged. If you
#   pipe this array in, you must pipe the [Ref] to the array, but
#   a new array will be returned (originally array untouched).
#.Parameter SubWidthInBytes
#   Defaults to 1 byte. Defines the number of bytes in each unit
#   (or atomic element) which is swapped, but no swapping occurs
#   within that unit. The number of bytes in the ByteArray must
#   be evenly divisible by SubWidthInBytes.
#.Example
#   $bytearray = toggle-endian $bytearray
#.Example
#   [Ref] $bytearray | toggle-endian -SubWidthInBytes 2
################################################################
    [CmdletBinding()] Param (
     [Parameter(Mandatory = $True, ValueFromPipeline = $True)] [System.Byte[]] $ByteArray,
     [Parameter()] [Int] $SubWidthInBytes = 1 )

    if ($ByteArray.count -eq 1 -or $ByteArray.count -eq 0) { $ByteArray ; return }

    if ($SubWidthInBytes -eq 1) { [System.Array]::Reverse($ByteArray); $ByteArray ; return }

    if ($ByteArray.count % $SubWidthInBytes -ne 0)
    { throw "ByteArray size must be an even multiple of SubWidthInBytes!" ; return }

    $newarray = new-object System.Byte[] $ByteArray.count

    # $i tracks ByteArray from head, $j tracks NewArray from end.
    for ($($i = 0; $j = $newarray.count - 1) ;
    $i -lt $ByteArray.count ;
    $($i += $SubWidthInBytes; $j -= $SubWidthInBytes))
    {
    for ($k = 0 ; $k -lt $SubWidthInBytes ; $k++)
    { $newarray[$j - ($SubWidthInBytes - 1) + $k] = $ByteArray[$i + $k] }
    }
    $newarray
}




##########################################################################
##
## Save or read large arrays of doubles to binary files very quickly.
## Uses System.Runtime.Serialization.Formatters.Binary.BinaryFormatter,
## which means any other .NET application can easily read it too, but
## the file contents are not text, i.e., not good for non-.NET apps.
## 
##########################################################################

function Save-NumericalArrayToFile ([String] $FilePath, $Array)
{
    if (($FilePath.IndexOf(':') -eq -1) -and (-not $FilePath.StartsWith('\\'))) 
    { throw 'FilePath must be a full explicit path!' ; return } 

    Try
    {
        $FileStream = New-Object -TypeName System.IO.FileStream -ArgumentList @( $FilePath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write) -ErrorAction Stop 
        $BinFormatter = New-Object -TypeName 'System.Runtime.Serialization.Formatters.Binary.BinaryFormatter' -ErrorAction Stop
        $BinFormatter.Serialize( $FileStream, $Array ) 
    }
    Catch { return $_ } 
    Finally { if ($FileStream){ $FileStream.Close() } }
}

[Double[]] $m1 = 1..1000000
Save-NumericalArrayToFile -FilePath 'f:\temp\serial.bin' -Array $m1



function Read-NumericalArrayFromFile ([String] $FilePath)
{
    Try { $FilePath = (dir $FilePath -ErrorAction Stop | Resolve-Path -ErrorAction Stop).ProviderPath } Catch { return $_ } 
    
    Try
    {
        $FileStream = New-Object -TypeName System.IO.FileStream -ArgumentList @( $FilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read) -ErrorAction Stop 
        $BinFormatter = New-Object -TypeName 'System.Runtime.Serialization.Formatters.Binary.BinaryFormatter' -ErrorAction Stop
        ,($BinFormatter.Deserialize( $FileStream )) #Don't delete the comma; returns the entire filled array.
    } 
    Catch { return $_ }
    Finally { if ($FileStream){ $FileStream.Close() } }
}


$data = Read-NumericalArrayFromFile -FilePath "f:\temp\serial.bin" 




##############################################################################
#
# Demo various ways of manipulating binary bits inside a byte.
#
##############################################################################

# Convert a string representation of binary bits to a decimal integer:

function Get-IntFromBits ([String] $Bits) { [System.Convert]::ToUInt32($Bits,2) } 

Get-IntFromBits -Bits "11111111"
Get-IntFromBits -Bits "10101010"
Get-IntFromBits -Bits "00000001"




# Convert a decimal integer to an binary string representation:

function Get-BitsFromInt ([UInt32] $Integer, [Switch] $NoLeadingZeros) 
{ 
    if ($NoLeadingZeros) { [System.Convert]::ToString($Integer,2) } 
    else { ([System.Convert]::ToString($Integer,2)).PadLeft(8,"0") } 
}

Get-BitsFromInt -Integer 255
Get-BitsFromInt -Integer 19
Get-BitsFromInt -Integer 1




# Careful when converting bytes to a 16/32/64-bit number!  x86/x64 machines are
# little-endian, which means the byte array might need to be reversed first.
# See http://blogs.msdn.com/b/bclteam/archive/2008/04/09/working-with-signed-non-decimal-and-bitwise-values-ron-petrusha.aspx

[Byte[]] $In = @(0,0,0,1) 
if ([System.BitConverter]::IsLittleEndian) { [System.Array]::Reverse($In) } 
[System.BitConverter]::ToUInt32($In,0)  #Returns 16777216 without the reversal.
 



# Show bit-shifting (requires PoSh 3.0)

0..7 | foreach { "+$_ : " + ([System.Convert]::ToString( (1 -shl $_),2)).PadLeft(8,"0") }    # -SHL = bit-shift left
0..9 | foreach { "-$_ : " + ([System.Convert]::ToString( (128 -shr $_),2)).PadLeft(8,"0") }  # -SHR = bit-shift right




# Do binary XOR, OR, AND, NOT.
# For more information about bitwise operators: get-help about_Comparison_Operators

"101 = " + (Get-BitsFromInt -Integer 101)
"228 = " + (Get-BitsFromInt -Integer 228)

"`nbxor"
101 -bxor 228
Get-BitsFromInt -Integer (101 -bxor 228)

"`nbor"
101 -bor 228
Get-BitsFromInt -Integer (101 -bor 228)

"`nband"
101 -band 228
Get-BitsFromInt -Integer (101 -band 228)

"`nbnot"  
-bnot 228    #Unary operator.
Get-BitsFromInt -Integer (-bnot 2)





<#
Handling byte arrays can be a challenge for many reasons:

    Bytes can be arranged in big-endian or little-endian format, and the endianness may need to be switched by one's code on the fly, e.g., Intel x86 processors use little-endian format internally, but TCP/IP is big-endian.

    A raw byte can be represented in one's code as a .NET object of type System.Byte, as a hexadecimal string, or in some other format, and this format may need to be changed as the bytes are saved to a file, passed in as an argument to a function, or sent to a TCP port over the network.

    Hex strings can be delimited in different ways in text files ("0xA5,0xB6" vs. "\xA5\xB6" vs. "A5-B6") or not delimited at all ("A5B6").

    Some cmdlets inject unwanted newlines into byte streams when piping.

    The redirection operators (> and >>) mangle byte streams as they attempt on-the-fly Unicode conversion.

    Bytes which represent text strings can encode those strings using ASCII, Unicode, UTF, UCS, etc.

    Newline delimiters in text files can be one or more different bytes depending on the application and operating system which created the file.

    Some .NET classes have unexpected working directories when their methods are invoked, so paths must be resolved explicitly first.

    StdIn and StdOut in PowerShell on Windows are not the same as in other languages on other platforms, which can lead to undesired surprises.

    Manipulating very large arrays can lead to performance problems if the arrays are mishandled, e.g., not using a [Ref] where appropriate, constantly recopying to new arrays under the hood, recasting to different types unnecessarily, using the wrong .NET class or cmdlet, etc.

Notes:

The "0xFF,0xFE" bytes at the beginning of a Unicode text file are byte order marks to indicate the use of little-endian UTF-16.

"0x0D" and "0x0A" are the ASCII carriage-return and linefeed ASCII bytes, respectively, which together represent a Windows-style newline delimiter. This Windows-style newline delimiter in Unicode is "0x00,0x0D,0x00,0x0A". But in Unix-like systems, the ASCII newline is just "0x0A", and older Macs use "0x0D", so you will see these formats too; but be aware that many cmdlets will do on-the-fly conversion to Windows-style newlines (and possibly Unicode conversion too) when saving back to disk. When hashing text files, be aware of how the newlines and encoding (ASCII vs. Unicode) may have changed, since "the same" text will hash to different thumbprints if the newlines or encoding have unexpectedly changed.
#>







##########################################################################
##
## Need to flesh these functions out...
## Save/read large arrays of doubles to raw binary files with more
## PowerShell control over the process (much slower than binary serialization).
##
##########################################################################


[Double[]] $m1 = 1..1000


function Save-DoublesToBinaryFile ( [String] $FilePath, [Double[]] $Array)
{
    if ($FilePath.IndexOf(':') -eq -1) { throw 'Need the full path for now...' ; return $false } 
    Try
    {
        $FileStream = New-Object -TypeName System.IO.FileStream -ArgumentList @( $FilePath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write) -ErrorAction Stop 
        $BinaryWriter = New-Object -TypeName System.IO.BinaryWriter -ArgumentList $FileStream
        ForEach ($number in $Array){ $BinaryWriter.Write( $number ) } 
        $BinaryWriter.Flush() 
    }
    Catch { $error[0] } #Not doing any error handling or path checking yet...
    Finally
    {
        if ($BinaryWriter){ $BinaryWriter.Close() } 
        if ($FileStream  ){ $FileStream.Close()   } 
    }
}

Save-DoublesToBinaryFile -FilePath 'f:\temp\delme.bin' -Array $m1 




function Read-DoublesFromBinaryFile ( [String] $FilePath )
{
    Try
    {
        $FilePath = (dir $FilePath | Resolve-Path -ErrorAction Stop).ProviderPath
        $FileStream = New-Object -TypeName System.IO.FileStream -ArgumentList @( $FilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read) -ErrorAction Stop
        $BinaryReader = New-Object -TypeName System.IO.BinaryReader -ArgumentList $FileStream
        $FileSize = $FileStream.Length
        While ($FileStream.Position -lt $FileSize){ $BinaryReader.ReadDouble() } 
    }
    Catch { $error[0] } #Not doing any error handling or path checking yet...
    Finally
    {
        if ($BinaryReader){ $BinaryReader.Close() } 
        if ($FileStream  ){ $FileStream.Close()   }
    }
}


$m2 = Read-DoublesFromBinaryFile -FilePath "f:\temp\delme.bin" 

$m1 -eq $m2 

