#.SYNOPSIS
#  Applies one .INF security template.


# Assume failure:
$Top.Request = "Stop"


# Should the INF folder path be defined in $Top?
$Inf = "$PWD\Resources\SecurityTemplates\SecuritySettings.inf" 


# Return without error if it doesn't exist:
if (Test-Path -Path $Inf)
{ 
    # Define temp file for secedit database:
    $TempFile = Join-Path -Path $env:TEMP -ChildPath "OkToDeleteMe.sdb" 

    # Apply the template:
    SecEdit.exe /configure /db $TempFile /cfg $Inf /overwrite /quiet 

    # Remove temp file:
    Remove-Item -Path $TempFile -Force 
}


# Assume success:
$Top.Request = "Continue"
