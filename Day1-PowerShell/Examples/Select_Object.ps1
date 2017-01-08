
get-process "powershell*" | select-object -property Path

get-process "powershell*" | select-object modules

get-process "powershell*" | select-object -expandproperty modules


# To only show unique event ID numbers from the Application event log:

get-eventlog Application | select-object EventID -unique


# To select the last 10 events from the System event log:

get-eventlog -logname system | select-object -last 10


# To select the first 5 services:

get-service | select-object -first 5

