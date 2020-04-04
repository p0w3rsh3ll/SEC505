# Manage Windows Automatic Update settings

# View current setting:
#    cscript.exe //nologo $env:SystemRoot\System32\scregedit.wsf /AU /v 
# (Should replace this with a PowerShell function.)


# Choose only one:

# Enable full automatic updates:
# cscript.exe //nologo $env:SystemRoot\System32\scregedit.wsf /AU 4 2>$null | Out-Null 

# Only download updates, don't install automatically:
#cscript.exe //nologo $env:SystemRoot\System32\scregedit.wsf /AU 3 2>$null | Out-Null 

# Manual updating, don't even download:
cscript.exe //nologo $env:SystemRoot\System32\scregedit.wsf /AU 1 2>$null | Out-Null 



