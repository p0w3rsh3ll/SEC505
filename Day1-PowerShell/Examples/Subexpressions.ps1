
"The sum of all workingset sizes is $($x = 0 ; get-process | foreach {$x += $_.workingset} ; $x / 1024 / 1024) MB."

@(foreach ($x in get-process) {if ($x.name -like "powershell") {$x}}).count


