
function show-folder ([Switch] $list) {
	if ($list) {dir | format-list *}
	else {dir | format-table fullname,length -autosize}
}

# Call function with or without the switch parameter:
show-folder -list
show-folder -l
show-folder








function show-hkcu ([Switch] $list) {
	If ($list) {get-childitem hkcu:\ | format-list *}
	Else {dir hkcu:\ | ft name,subkeycount,valuecount}
}

# Call function with the switch parameter:
show-hkcu -list
show-hkcu -l


