This folder contains offline help files for PowerShell. 


Update the help files on an Internet-connected machine:

	Update-Help


Then export its help files to a previously-created empty folder:

	Save-Help -DestinationPath X:\folderpath -UICulture en-US


Then import on another computer with a command like this:

	Update-Help -SourcePath X:\folderpath -Force -UICulture en-US -Recurse


The above steps are useful in air-gapped networks and automated installs.


(Note: The XDROP.txt file can be ignored, it's not from Microsoft.) 

