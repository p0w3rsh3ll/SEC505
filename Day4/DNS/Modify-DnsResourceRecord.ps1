#Jason, flesh this one out...

function Modify-DnsResourceRecord ($RecordName, $ZoneName, $IPaddress)
{
    $old = Get-DnsServerResourceRecord -Name $RecordName -RRType "A" -ZoneName $ZoneName

    $new = $old.Clone()

    $new.RecordData.IPv4Address = [System.Net.IPAddress]::Parse( $IPaddress )

    Set-DnsServerResourceRecord -NewInputObject $new -OldInputObject $old -ZoneName $ZoneName
}



