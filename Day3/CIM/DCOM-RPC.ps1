# Example of connecting with DCOM RPC instead of WSMAN:

$box = 'some.target.box'

$rpc = New-CimSessionOption -Protocol DCOM

$s = New-CimSession -ComputerName $box -SessionOption $rpc

Get-CimInstance -Query 'select * from win32_bios' -CimSession $s



