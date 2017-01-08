##################################################################################
# Name: Get-ServiceIdentity.ps1
# Author: Jason Fossen
# Version: 1.0.1
# Date: 3.May.2013
# Purpose:
#    Outputs standard Get-Service objects, but with two additional properties:
#        Path = Path to binary executed to launch service, plus any arguments.
#        Identity = Identity under which the service runs, e.g., LocalSystem.
#    Depends on SC.EXE, which is a built-in tool by default.
# Legal: Public domain, no warranties or guarantees of any type.
##################################################################################



# Filter extracts submatch text using a regex.
filter extract-text ($RegularExpression) 
{ 
    select-string -inputobject $_ -pattern $regularexpression -allmatches | 
    select-object -expandproperty matches | 
    foreach { 
        if ($_.groups.count -le 1) { if ($_.value){ $_.value } } 
        else 
        {  
            $submatches = select-object -input $_ -expandproperty groups 
            $submatches[1..($submatches.count - 1)] | foreach { if ($_.value){ $_.value } } 
        } 
    }
}



Get-Service | ForEach `
{ 
    $sctxt = sc.exe qc $_.name
    $Path = $sctxt | extract-text -reg 'BINARY_PATH_NAME\W+\:[\W\"]+([^\"]+)'
    $Identity = $sctxt | extract-text -reg 'SERVICE_START_NAME\W+\:[\W\"]+([^\"]+)'
    Add-Member -InputObject $_ -NotePropertyName "Path" -NotePropertyValue $Path 
    Add-Member -InputObject $_ -NotePropertyName "Identity" -NotePropertyValue $Identity
    $_
} | format-list Name,DisplayName,Identity,Path

# The line just above is just for demos, delete it to output full objects.

