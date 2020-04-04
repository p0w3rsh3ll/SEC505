#.SYNOPSIS
#  Apply all the .INF security templates in a folder.
#
#.NOTES
#  Most native programs return 0 to indicate success.
#  SecEdit.exe also sometimes returns an exit code of 3,
#  for which Microsoft says, "It's okay to ignore the warning."



# Assume failure:
$Top.Request = "Stop"


# Should the INF folder path be defined in $Top?
$FolderPath = "$PWD\Resources\SecurityTemplates\" 


# Return without error if the $FolderPath doesn't exist:
if (-not (Test-Path -Path $FolderPath))
{ 
    $Top.Request = "Continue"
    Exit 
} 


# Get the INF templates' full paths, but allow zero:
$Templates = @( dir -Path $FolderPath -File -Filter "*.inf" |
                Sort-Object -Property Name |
                Select-Object -ExpandProperty FullName )


# If there are no INFs to apply, return without error:
if ($Templates.Count -eq 0)
{ 
    $Top.Request = "Continue"
    Exit 
} 


# Define temp file for secedit database:
$TempFile = Join-Path -Path $env:TEMP -ChildPath ([String](Get-Date).Ticks + ".sdb")


# Apply each template:
ForEach ($Inf in $Templates)
{
    #Show full path of INF:
    $Inf

    #Make sure to start with a fresh database each time (/overwrite).
    #If you comment out the /quiet switch for testing, you cannot use ISE.
    SecEdit.exe /configure /db $TempFile /cfg $Inf /overwrite /quiet 

    #Did it work? Microsoft says we can ignore error code 3:
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 3)
    {
        Remove-Item -Path $TempFile -Force 
        Throw ("ERROR: Failed to apply " + $Inf)
        Exit
    }
}


# Remove temp file:
Remove-Item -Path $TempFile -Force 


# Assume success:
$Top.Request = "Continue"
