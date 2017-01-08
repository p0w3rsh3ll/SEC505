
# Need to check if it already exists, don't want to overwrite it:

if (-not $(test-path $profile)) { new-item -path $profile -itemtype file -force }

notepad.exe $profile


