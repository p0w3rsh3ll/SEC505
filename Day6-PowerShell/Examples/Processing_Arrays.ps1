
$stopped = $running = $paused = 0

switch (get-service | select-object status) {
	{$_.status -like "Running"} {$running++}
	{$_.status -like "Stopped"} {$stopped++}
	{$_.status -like "Paused"}  {$paused++}
}

"Services Running = $running"
"Services Stopped = $stopped"
"Services Paused = $paused"


