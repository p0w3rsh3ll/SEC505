# Just a function to demo doing some simple forensics with PowerShell.
# It returns only files whose LastWriteTime property is within the
# number of hours specified, e.g., 72 = within last three days.

param ($Path = ".", $WithinLastNumberOfHours = 9999999)




function Get-FileLastWriteTime ($Path = ".", $WithinLastNumberOfHours = 9999999)
{
    dir -recurse -force -path $path | 
    where { $_.gettype().name -ne "DirectoryInfo" } | 
    where { $_.lastwritetime -gt $(get-date).addhours($withinlastnumberofhours * -1)} | 
    sort lastwritetime -desc |
    format-table lastwritetime,fullname -auto
}



Get-FileLastWriteTime -path $Path -within $WithinLastNumberOfHours 


