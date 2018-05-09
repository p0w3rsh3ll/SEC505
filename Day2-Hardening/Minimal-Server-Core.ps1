##########################################################################
# Server 2012 and 2012 R2 can run in three modes: Full, Minimal, and Core.
#        Full = Full graphical interface and graphical management tools.
#        Minimal = Like Full, but no IE, File Explorer or desktop.
#        Core = Almost no graphical tools will run.
# You can switch between the modes from within PowerShell without 
# reinstalling the OS from scratch again.  However, this is not supported
# on Server 2016, where it is not possible to switch between Core, Minimal
# and Full Desktop Experience without reinstalling.  This is the way it
# was on Server 2008, now it is that way again on Server 2016 and later.  
##########################################################################

# To reduce from Full GUI to Minimal GUI on Server 2012:
Remove-WindowsFeature Server-Gui-Shell

# To reduce from Minimal to Core on Server 2012:
Remove-WindowsFeature Server-Gui-Mgmt-Infra

# To reduce from Full GUI down to Core with a single command on Server 2012:
Remove-WindowsFeature Server-Gui-Shell,Server-Gui-Mgmt-Infra




##########################################################################
# To go from Core back up to Full is more difficult because you will likely
# need to provide the path to the install.wim file on the source DVD.
##########################################################################

# If the following command shows "Removed" for the Install State, the binaries
# are not present on the local drive will need to be copied from the DVD:

Get-WindowsFeature Server-Gui*

# If the binaries are not present on the drive, they'll have to be copied from the DVD.
# You will need the index number of the correct image from the source DVD (drive d:\).
# If your source is an ISO file, just double-click or execute the name of the file in
# PowerShell in order to mount that ISO file as a drive letter.

# To list the index numbers of the images in the source WIM file (replace d:\ with yours):
Get-WindowsImage -ImagePath d:\sources\install.wim

# To list the index numbers of the images in the source WIM file using dism.exe instead:
dism.exe /get-wiminfo /wimfile:d:\sources\install.wim

# Here are the normal index numbers of the images in install.wim:
#     Index 1 = Server Core Standard
#     Index 3 = Server Core Datacenter
#     Index 2 = Full GUI Standard
#     Index 4 = Full GUI Datacenter

# To go from Core back up to Full GUI Standard (Index 2):
Install-WindowsFeature server-gui-mgmt-infra,server-gui-shell -source:wim:d:\sources\install.wim:2

# To go from Core back up to Full GUI Datacenter (Index 4):
Install-WindowsFeature server-gui-mgmt-infra,server-gui-shell -source:wim:d:\sources\install.wim:4


