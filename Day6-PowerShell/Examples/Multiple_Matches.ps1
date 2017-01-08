
$logdata = @'
2007-11-11 02:36:50 DROP TCP 202.18.44.101 192.168.0.1
2007-11-19 12:12:09 DROP UDP 202.19.44.101 192.168.0.1
2007-11-22 09:01:21 DROP TCP 202.20.44.101 192.168.0.1
2007-11-24 11:29:58 DROP TCP 202.21.44.101 192.168.0.1
2007-11-30 04:48:32 DROP UDP 202.22.44.101 192.168.0.1
'@

$regex = [RegEx] '(TCP|UDP) (\d+\.\d+\.\d+\.\d+)'

$matches = $regex.matches($logdata)


foreach ($match in $matches) 
{
    "Location: " + $match.index
    "  Length: " + $match.length
    "   Value: " + $match.value 

    if ($match.groups.count -gt 0) 
    {
        for ($i=1; $i -lt $match.groups.count; $i++) 
        {
            "      $i : " + $match.groups[$i].value
        }
    }
    "------------------------------------------"
}

