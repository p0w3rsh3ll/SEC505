#####################################################################################################
#  A couple of functions for coverting to/from Base64 and US-ASCII, as defined in RFC4648.
#  Both functions can accept piped input.
#  Legal: Public Domain, No Warranties or Guarantees of Any Kind, USE AT YOUR OWN RISK.
#####################################################################################################

function Convert-FromBase64ToAscii 
{ 
    [CmdletBinding()] 
    Param( [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)] $String )

    [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($String)) 

} 



function Convert-FromAsciiToBase64
{ 
    [CmdletBinding()] 
    Param( [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)] $String )

    [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($String)) 
} 




#####################################################################################################
#  The same functions as above, but for Unicode (UTF16-LE) instead of US-ASCII.
#####################################################################################################

function Convert-FromBase64ToUnicode 
{ 
    [CmdletBinding()] 
    Param( [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)] $String )

    [System.Text.Encoding]::UNICODE.GetString([System.Convert]::FromBase64String($String)) 
} 


function Convert-FromUnicodeToBase64
{ 
    [CmdletBinding()] 
    Param( [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)] $String )

    [System.Convert]::ToBase64String([System.Text.Encoding]::UNICODE.GetBytes($String)) 
} 




#####################################################################################################
#  Convert an array of bytes to/from Base64 when read from a binary file.
#  File does not have to be binary, but it will be read/written as raw bytes.
#  Example: dir file.exe | Convert-FromFileBytesToBase64 | Convert-FromBase64ToFile -Path file2.exe
#####################################################################################################

function Convert-FromBinaryFileToBase64 
{ 
    [CmdletBinding()] 
    Param
    ( 
      [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)] $Path,
      [Switch] $InsertLineBreaks
    )

    if ($InsertLineBreaks){ $option = [System.Base64FormattingOptions]::InsertLineBreaks }
    else { $option = [System.Base64FormattingOptions]::None }

    [System.Convert]::ToBase64String( $(Get-Content -ReadCount 0 -Encoding Byte -Path $Path) , $option )
} 



function Convert-FromBase64ToBinaryFile 
{ 
    [CmdletBinding()] 
    Param( [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]  $String , 
           [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $False)] $OutputFilePath )

    [System.Convert]::FromBase64String( $String ) | Set-Content -OutputFilePath $Path -Encoding Byte 

} 





#####################################################################################################
#  Execute a command encoded in Base64
#####################################################################################################

$encodedcmd = Convert-FromUnicodeToBase64 -String "ps"   # Which is "cABzAA==" by the way.

invoke-expression -Command $(Convert-FromBase64ToUnicode -String $encodedcmd)


#Here is another way, by dot-sourcing a script block:
. $( [SCRIPTBLOCK]::Create("ps") )


#Same thing, but now Base64-encoded instead:
. $( [SCRIPTBLOCK]::Create( $(Convert-FromBase64ToUnicode -String $encodedcmd) ))


# See also the -EncodedCommand command-line switch for powershell.exe too.


