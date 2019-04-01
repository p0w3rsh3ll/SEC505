<#################################################################
.SYNOPSIS
    Create an HTML report for all Group Policy Objects (GPOs) in
    the local domain in a new folder named after the current date.

##################################################################>

# Create a folder in the present directory with a name like "2019-11-30":
$NewFolderName = Get-Date -Format "yyyy-MM-dd"

New-Item -ItemType Directory -Name $NewFolderName

cd -Path $NewFolderName


# Create HTML report in the new folder for every GPO:
Get-GPO -All | ForEach `
{
   $GpoReportFullPath = $pwd.Path + "\" + $_.DisplayName + ".html" 

   Get-GPOReport -Name ($_.DisplayName) -ReportType Html -Path $GpoReportFullPath
} 

# Go back up:
cd ..

