
function show-hkcu ([Switch] $list) {
	If ($list) {get-childitem hkcu:\ | format-list *}
	Else {dir hkcu:\ | ft name,subkeycount,valuecount}
}

# Call function with the switch parameter:
show-hkcu -list
show-hkcu -l


