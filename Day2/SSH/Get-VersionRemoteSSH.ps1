##############################################################################
#.SYNOPSIS
#   Get the identification string from a remote SSH server.
#
#.DESCRIPTION
#   Get the identification string from an SSH server, including SSH version,
#   software version, and any optional server comments.  See RFC 4253 section
#   4.2 for the mandatory ID string format.  SSH server must send this ID.
#
#.PARAMETER HostName
#   Name or IP address of the SSH server.  Default is localhost.
#
#.PARAMETER Port
#   TCP port of SSH server.  Default is 22.
#
#.NOTES
#   Compatible with Windows PowerShell and PowerShell Core.
#   TODO: setup PROCESS section to handle array of HostName.
#   TODO: add all the ssh -Q queries and output.
#   Last Updated: 23.Dec.2019 by JF@Enclave
##############################################################################

Param ($HostName = 'localhost', $Port = 22)

# Return of the script, Success defaults to $False
$Output = @{ ProtocolVersion = $null ; SoftwareVersion = $null ; Comment = $null ; FullIdString = $null ; Success = $False } 

# Test TCP handshake
if (-not (Test-Connection -TimeoutSeconds 1 -TargetName $HostName -TCPPort $Port -Quiet))
{
    $Output
    Exit 
}

# Try to get the ID string without sending anything myself. 
# Hope that the first line received is the ID string even though the
# RFC allows the server to send other lines of data first as long as
# the other lines do not beging with "SSH-" (section 4.2).
Try 
{
    $TcpClient = New-Object System.Net.Sockets.TcpClient($HostName, $Port)
    $Stream = $TcpClient.GetStream()
    $StreamReader = New-Object System.IO.StreamReader($Stream)

    while ($TcpClient.Connected) 
    {
        while ($Stream.DataAvailable) 
        {
            [String] $Line = $StreamReader.ReadLine()
            $StreamReader.Close()
            $TcpClient.Close()                
        }
    }
}
Catch
{
    $StreamReader.Close()
    $TcpClient.Close()
    $Output
    Exit 
}



# From RFC 4253, $Line should match:  SSH-protoversion-softwareversion SP comments CR LF 

# Sanity check
if (($Line -eq $null) -or ($Line.Length -lt 4) -or ($Line.SubString(0,4) -notmatch '^SSH\-'))
{ 
    $Output
    Exit 
} 

#Whole ID string returned, trimmed of any CR LF
$Output.FullIdString = $Line.Trim() 

# Is there a space char?  RFC allows no comment at all:
$SpaceIndex = $Line.IndexOf(' ') 
if ($SpaceIndex -eq -1)
{
    #No space char, no comment
    $LeftSide = $Line.Trim()
}
else 
{
    #Left of the first space char
    $LeftSide = $Line.SubString(0, ($SpaceIndex + 1)) 

    #Everything right of the first space char
    $Output.Comment = ($Line -replace "^$LeftSide",'').Trim()
    if ($Output.Comment.Length -eq 0){ $Output.Comment = $null } 
}

# Mandatory stuff now
$LeftSide = @( $LeftSide -split '-' )

$Output.ProtocolVersion = $LeftSide[1].Trim()
if ($Output.ProtocolVersion.Length -eq 0){ $Output.ProtocolVersion = $null } 

$Output.SoftwareVersion = $LeftSide[2].Trim()
if ($Output.SoftwareVersion.Length -eq 0){ $Output.SoftwareVersion = $null } 

# Sanity check; comment is optional
if (($Output.ProtocolVersion -eq $null) -or ($Output.SoftwareVersion -eq $null))
{ 
    #Success is still $False 
    $Output 
} 
else
{
    $Output.Success = $True
    $Output
}

#FIN