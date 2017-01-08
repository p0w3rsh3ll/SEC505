# nosuchfile.txt does not exist, raises an error.

xcopy.exe nosuchfile.txt tofile.txt
"Succeeded? " + $?
"Error Code: " + $LASTEXITCODE



# nosuchfile.txt does not exist, raises an error.

copy-item nosuchfile.txt tofile.txt
$?    # Is now False.


# To show the properties of the last error object thrown:

$error[0] | get-member


# To show the details of the last error object thrown:

$error[0] | format-list * -force



# To show just the essential information from the last five errors:

$error[0..4]


# To show the last five errors, each separated by a line of 70 dashes for easier reading:

$error[0..4] | foreach-object {"-" * 70 ; $_}



# To copy the $error array to another (unchanging) array for analysis:

$errs = $error.clone()
$errs.count
$errs[0]


# To empty or clear the $error array:

$error.clear()


# nosuchfile.txt does not exist, raises an error.

copy-item nosuchfile.txt tofile.txt 2>$null

$alloutput = dir c:\,c:\windows,c:\nofolderhere 2>&1


# Remember, the $alloutput contains objects, not text:

$alloutput.count
$alloutput | get-member

