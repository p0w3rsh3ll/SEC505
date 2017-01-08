<# ###########################################################################

*Glyphs and Unicode*

A glyph is a visual symbol seen by a human on a page of paper or screen.  We
often call these "characters", but the term "character" is ambiguous: Is it
what you see?  The name of what you see?  The binary representation in 
memory or storage for what you see?  For example, if "A" is shown in both
italics and in bold with the Arial font, are these two characters or just one?  
As a glyph, we would say they are the same glyph but shown in two ways with
the same font.  So, what makes them the same despite their different shapes?

Unicode is a system which aims to map all glyphs to unique numbers called 
"code points".  There are not separate code point numbers for each font or 
shape of a glyph, like Arial italics or New Times Roman bold, but to all 
possible shapes and fonts of that one glyph.  A glyph is an abstraction of a 
symbol apart from any font, size, color, or other minor change of shape.  


*Unicode Encoding*

A Unicode code point number for a glyph is either 16 or 32 bits long.  Many 
glyphs require only 16 bits to be numbered, and most glyphs used in Western 
Europe and USA only actually need 8 bits of a 16-bit code point; after all, 
ASCII includes USA letters, numbers and puntuation marks in 8 bits or less.

A 16- or 32-bit code point number often includes many zeros which do not 
convey information, hence, there are various ways to encode these binary 
numbers to avoid consuming unnecessary storage space or bandwidth, even though
this comes at the price of encoding/decoding complexity.

A Unicode code point number can be encoded using one to four single-byte units
(UTF-8), as one or two 16-bit units (UTF-16) or as a single 32-bit unit 
(UTF-32).  UTF-32 is rarely used because it does not conserve storage space.  
UTF-16 is common on Windows, in the .NET Framework, and in Java.  UTF-8 is 
common on Linux and with Internet protocols.  When Microsoft says that Windows
uses "Unicode", it is more accurate to say that Windows uses little-endian 
UTF-16 encoding of Unicode. (Incidentally, "UCS-2" is an obsolete term which 
just means "UTF-16" today.)  UTF-7 is a seven-bit encoding of Unicode which
is used for SMTP e-mail and virtually nothing else.  Avoid UTF-7.  

UTF-16 and UTF-32 encodings can be big-endian or little-endian, which refers 
to the ordering of bytes in an encoding which uses two or more bytes per unit 
to represent a Unicode code point.  Because UTF-8 uses one to four single-byte
units, UTF-8 is neither big- nor little-endian.  The endian-ness of an 
UTF-16/32 encoding can be abbreviated as "LE" or "BE"; for example, Windows API
function calls normally expect strings to be UTF-16LE encoded.  

Because of the confusion LE or BE encoding may cause, a string might optionally
begin with a "Byte Order Mark" (BOM), which is a set of special non-printing 
Unicode code point numbers at the beginning of an encoded string that act as a
decoding hint (see http://www.unicode.org/faq/utf_bom.html). These complexities
are another reason to always prefer UTF-8 when possible (www.utf8everywhere.org).


*Code Pages and US-ASCII*

A "code page" is also a mapping between glyphs and patterns of 7, 8, 16 or
more bits.  There are many code page mapping sets from different countries,
different manufacturers, and even for different versions of the same OS or 
program.  Code pages historically predate Unicode; in fact, the limitations 
and difficulties of code pages was one driver for inventing Unicode.  Most
code pages are single-byte, but others, especially for Asian glyphs, have
units which are two or more bytes.  In the USA, the most common code pages
are named "US-ASCII", "Windows-1252" and "IBM437".  UTF-7 and UTF-8 are also
implemented as code pages.  While most applications and protocols today use
either UTF-16 or UTF-8 encodings of Unicode, not code pages, older applications
still require the use of code pages.  Windows supports many code pages and
includes several functions for converting between Unicode and a code page 
(the characters in a code page will be a subset of Unicode, but Unicode will 
have many thousands of characters which cannot be represented in any 
particular code page, hence, a conversion from Unicode to a code page may
involve loss of information).


*Unicode in PowerShell*

POWERSHELL.EXE is a console application with limited support for displaying
Unicode code points.  If a TrueType font is selected, then more glyphs can 
be displayed, but this depends on what is included in the font definition.

POWERSHELL_ISE.EXE is actually a Windows application and can display a much
larger number of glyphs for Unicode code points.  Font limitations still
apply, but Windows applications have access to many more fonts by default,
and more fonts can easily be installed, such as with an Asian language pack.

To see the difference, run this command in both POWERSHELL and POWERSHELL_ISE:

    256..5000 | foreach { write-host -NoNewline -Object ([char] $_) }

A substitute glyph like "৾" indicates an unavailable font for the code point.

Keep in mind that displaying a glyph on-screen is not the same thing as
manipulating bytes of data.  Just because the console PowerShell cannot 
display all the glyphs in a UTF-16 encoded text file does not mean that
PowerShell cannot edit, copy, upload or otherwise manipulate that file.

########################################################################### #>





# List possible code page names and identifier numbers:

[System.Text.Encoding]::GetEncodings() | Format-Table -AutoSize



# Get a particular code page by name or identifier number:

[System.Text.Encoding]::GetEncoding("x-cp50227")  #Chinese Simplified (ISO-2022)
[System.Text.Encoding]::GetEncoding(50227)        #Chinese Simplified (ISO-2022)



# Get the current encoding for console PowerShell output and input:

[System.Console]::OutputEncoding
[System.Console]::InputEncoding



# Set the encoding for the PowerShell console's output to Chinese Simplified (ISO-2022):
# Note that this will not start displaying all glyphs/characters in Chinese.

[System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("x-cp50227")
[System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(50227)




# Show which encoding is used when the output of a cmdlet is piped into 
# native command (defaults to US-ASCII for backwards compatibility):

$OutputEncoding



# Set the encoding to UTF-8 when a cmdlet's output is piped into a native command:

$OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")



# Some cmdlets with an -Encoding parameter:

Out-File
Get-Content
Set-Content
Add-Content
Export-Clixml
Export-Csv
Import-Csv
Select-String



# Change the encoding of a text file from ASCII to UTF-8:

Get-Content -Encoding ASCII -Path .\ascii.txt | Set-Content -Encoding UTF8 -Path .\utf8.txt



# An experiment: view these files with a hex editor and note the byte-width of
# each character unit, Byte Order Mark (BOM), and newline bytes, if any:

"AAAAAAAA" | Out-File -Encoding utf32   -FilePath .\utf32.txt
"AAAAAAAA" | Out-File -Encoding unicode -FilePath .\utf16-LE.txt
"AAAAAAAA" | Out-File -Encoding utf8    -FilePath .\utf8.txt
"AAAAAAAA" | Out-File -Encoding ascii   -FilePath .\ascii.txt
"AAAAAAAA" | Out-File -Encoding bigendianunicode -FilePath .\utf16-BE.txt



# Common Byte Order Mark (BOM) patterns:

$BOM = @{
    "UTF8"    = 0xEF,0xBB,0xBF        #UTF-8 usually does not include BOM however.
    "UTF16LE" = 0xFF,0xFE             #Microsoft "Unicode" is UTF16LE.
    "UTF16BE" = 0xFE,0xFF
    "UTF32LE" = 0xFF,0xFE,0x00,0x00
    "UTF32BE" = 0x00,0x00,0xFE,0xFF
}



<#
#######################################################################################
Be careful of unexpected encoding conversion, BOM and newline bytes when saving to a file!

# The following converts to UTF16-LE ("Unicode") with BOM and newline bytes.
"AAAAA" | out-file c:\temp\password1.txt  

# The following adds newline bytes (0D,0A) to the end without asking. 
"AAAAA" | out-file c:\temp\password2.txt -Encoding ascii 

# The following writes only the raw bytes: no BOM, no Unicode, no newline bytes.
$("AAAAA").ToCharArray() | foreach { [byte] $_ } | Set-Content -Path c:\temp\password3.txt -Encoding Byte

When converting from one string encoding to another, first convert the starting
string to raw bytes, convert to the ending encoding, then convert back to a string
again. To test for correctness, view the raw bytes before and after, but avoid
doing so by saving those bytes to a file because of unexpected encoding conversions,
Byte Order Mark (BOM) byte prepending, and newline bytes appending.
#######################################################################################
#>



# Function to convert a string from one encoding to another, or to the raw bytes
# of the target encoding without converting back to a string object again.

function Convert-StringEncoding ($StartingEncoding, $EndingEncoding, $String, [Switch] $RawBytes)
{
    #.Parameter Encoding
    #   Must be UNICODE, ASCII, UTF8, UTF32, or UTF16-BE.
    #.Parameter RawBytes
    #   Return raw ending encoded bytes instead of a string.

    [byte[]] $Bytes = @()

    Switch -Regex ( $StartingEncoding.ToUpper().Trim() )
    {
        'UNICODE|UTF16-LE|^UTF16$'
            { 
                $Bytes = ([System.Text.Encoding]::Unicode).GetBytes($String)
                $From = [System.Text.Encoding]::Unicode
                continue 
            } 
        'ASCII' 
            { 
                $Bytes = ([System.Text.Encoding]::ASCII).GetBytes($String) 
                $From = [System.Text.Encoding]::ASCII
                continue 
            }
        'UTF8'  
            { 
                $Bytes = ([System.Text.Encoding]::UTF8).GetBytes($String)
                $From = [System.Text.Encoding]::UTF8
                continue 
            } 
        'UTF32' 
            { 
                $Bytes = ([System.Text.Encoding]::UTF32).GetBytes($String)
                $From = [System.Text.Encoding]::UTF32
                continue 
            }     
        '^UTF16-BE$' 
            { 
                $Bytes = ([System.Text.Encoding]::BigEndianUnicode).GetBytes($String)
                $From = [System.Text.Encoding]::BigEndianUnicode
                continue 
            } 
        default
            { throw "Must provide a valid starting encoding name." } 
    }

    
    Switch -Regex ( $EndingEncoding.ToUpper().Trim() )
    {
        'ASCII' 
            { 
                $Bytes = [System.Text.Encoding]::Convert($From, [System.Text.Encoding]::ASCII, $Bytes )  
                If ($RawBytes) { $Bytes } Else { ([System.Text.Encoding]::ASCII).GetString($Bytes) } 
                continue 
            }
        'UTF8'     
            { 
                $Bytes = [System.Text.Encoding]::Convert($From, [System.Text.Encoding]::UTF8, $Bytes )  
                If ($RawBytes) { $Bytes } Else { ([System.Text.Encoding]::UTF8).GetString($Bytes) } 
                continue 
            } 
        'UNICODE|UTF16-LE|^UTF16$|^UTF16LE$'  
            {
                $Bytes = [System.Text.Encoding]::Convert($From, [System.Text.Encoding]::Unicode, $Bytes )  
                If ($RawBytes) { $Bytes } Else { ([System.Text.Encoding]::Unicode).GetString($Bytes) } 
                continue
            } 
        'UTF32'    
            { 
                $Bytes = [System.Text.Encoding]::Convert($From, [System.Text.Encoding]::UTF32, $Bytes )  
                If ($RawBytes) { $Bytes } Else { ([System.Text.Encoding]::UTF32).GetString($Bytes) } 
                continue
            }
        '^UTF16-BE$|^UTF16BE$' 
            { 
                $Bytes = [System.Text.Encoding]::Convert($From, [System.Text.Encoding]::BigEndianUnicode, $Bytes )  
                If ($RawBytes) { $Bytes } Else { ([System.Text.Encoding]::BigEndianUnicode).GetString($Bytes) } 
                continue 
            } 
        default
            { throw "Must provide a valid ending encoding name." } 
    }
}


$in = Convert-StringEncoding -StartingEncoding "UNICODE" -EndingEncoding "ASCII" -String "AAAAA"
Convert-StringEncoding -StartingEncoding "ASCII" -EndingEncoding "UTF16BE" -String $in -RawBytes





