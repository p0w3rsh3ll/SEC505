# A PowerShell script may have zero or more "#Requires" lines to
# indicate requirements for the script to run successfully.


#Requires -Version N[.n]
#Requires -PSEdition [ Core | Desktop ]
#Requires -RunAsAdministrator
#Requires -PSSnapin PSSnapinName [-Version N[.n]]
#Requires -Modules { ModuleName | Hashtable } 
#Requires -ShellId ShellId





<#
.EXAMPLES
#Requires -Version 4
#Requires -Version 5.1


.NOTES
RunAsAdministrator requires PowerShell 4.0.
RunAsAdministrator does not work on Linux.
Version is the minimum version, not the version that will be used.
Must use "#", not "<# .. # >".
Must be left-aligned, no leading spaces or tabs.
Is global to entire script.
Cannot be used inside a scriptblock to apply to that block.
#>
