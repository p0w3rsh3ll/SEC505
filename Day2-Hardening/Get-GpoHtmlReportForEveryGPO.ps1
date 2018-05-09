<#################################################################
.SYNOPSIS
    Create an HTML report for all Group Policy Objects (GPOs) in
    the local domain in a new folder named after the current date.

##################################################################>

# Create folder in the present directory like "2018-11-30":
$NewFolder = Get-Date -Format "yyyy-MM-dd"
mkdir -Path $NewFolder  
cd -Path $NewFolder


# Create HTML report in new folder for every GPO:
Get-GPO -All | ForEach `
{
   $GpoReportFullPath = $pwd.Path + "\" + $_.DisplayName + ".html" 
   Get-GPOReport -Name ($_.DisplayName) -ReportType Html -Path $GpoReportFullPath
} 

# Go back up:
cd ..

