<# ###############################################

       Linux Bash to PowerShell Tips

################################################ #>



# Several aliases and functions built in by default:

Get-Alias -Name ls,man,ps,cp,mv,pwd,rm,cat,echo,kill,find,diff,rmdir,pushd,popd

Get-Command -Name more,mkdir   




# The 'find' alias is for PowerShell's grep, not bash's find:

Get-Alias -Name find

"some kind of string" | find -pattern 'k.nd'




# Cat the first or last 20 lines of text:

cat -path somefile.txt -totalcount 20

cat -path somefile.txt -tail 20




# Tail -F a text file (doesn't work exactly the same)

cat -tail -wait -path somefile.txt




# sed search and replace with regex:

"some kind of string" -replace "k.nd","sort"




# Parse a string with a regex:

"some,kind,of,string" -split ","




# Convert piped objects into text:

ps | out-string -stream | find 'svc'




# touch a new file, or append to existing file:

new-item -itemtype file -path somefile.txt

"some text" | out-file -append -filepath somefile.txt




# chmod and chown:

icacls.exe




# Count lines, words and characters in a text file:

cat somefile.txt | measure -line -word -character




# top (there is no easy shell-only equivalent, only GUI)

taskmgr.exe




# env and $PATH

ls env:\ 

env:\path 




# Special automatic variables like $pid, $?, $$:

man about_Automatic_Variables 





<# ###################################################

### NOTES ####


'more' only works in powershell.exe, not powershell_ise.exe.

Beware, even though the command examples above all work,
PowerShell is object-oriented, not text-oriented.  Many
PowerShell commands appear to produce text as output, but
it only looks like text in the shell; the output is really
a stream of objects, not text.

#################################################### #>





