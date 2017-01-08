This folder contains offline help files for PowerShell. 


Update the help files on an Internet-connected machine:

	Update-Help

Then export its help files, perhaps to a flash drive: 

	Save-Help -DestinationPath X:\folderpath -UICulture en-US

Then import on another computer with a command like this:

	Update-Help -SourcePath X:\folderpath -Force -UICulture en-US -Recurse


The above steps are useful in air-gapped networks and automated installs.

