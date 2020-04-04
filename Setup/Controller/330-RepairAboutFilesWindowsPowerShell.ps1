###############################################################################
#
#"[+] Fixing the about files for Windows PowerShell..."
#
# Note that en-US is the hard-coded culture.
# Is this needed for PoSh Core about* files?
#
###############################################################################

$helpfiles = @( dir $env:WINDIR\System32\WindowsPowerShell -Recurse -Filter "about_*" -Exclude "*.help.txt" )

if ($helpfiles.Count -gt 0)
{
    ForEach ($file in $helpfiles)
    {
        if ($file.name -notlike "*.help.txt")
        { Rename-Item -ErrorAction SilentlyContinue -Path $file.fullname -NewName ($file.name -replace "\.txt$",".help.txt") } 
    }
}

