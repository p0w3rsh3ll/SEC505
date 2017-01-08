
$droptcp = $dropudp = $dropicmp = 0
$allowtcp = $allowudp = $allowicmp = 0

# Log file is locked, copy it to local folder:
copy-item C:\Windows\system32\LogFiles\Firewall\pfirewall.log .

switch -regex -file .\pfirewall.log {
	'DROP TCP'   {$droptcp++}
	'DROP UDP'   {$dropupd++}
	'DROP ICMP'  {$dropicmp++}
	'ALLOW TCP'  {$allowtcp++}
	'ALLOW UDP'  {$allowudp++}
	'ALLOW ICMP' {$allowicmp++}
}

"FIREWALL LOG SUMMARY:"
"------------------------------------------------------"
"Dropped: TCP=$droptcp, UDP=$dropudp, ICMP=$dropicmp"
"Allowed: TCP=$allowtcp, UDP=$allowudp, ICMP=$allowicmp"
 
