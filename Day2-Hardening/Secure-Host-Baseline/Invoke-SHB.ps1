# This script will create the NSA Secure Host Baseline (SHB) Group
# Policy Objects (GPOs).  The script assumes that this zip file exists:
# C:\SANS\Day2-Hardening\Secure-Host-Baseline\Secure-Host-Baseline-master.zip
# Download latest zip from https://github.com/iadgov/Secure-Host-Baseline.
# Script assumes that C:\Temp exists and is writeable. 
# It is OK to run the script multiple times, any errors are suppressed.
# Script requires at least PowerShell 5.0 for the Expand-Archive cmdlet.
#
# Last Updated: 2.Aug.2017


# Delete temp folders if this script has been run previously:
if (Test-Path -Path C:\Temp\Secure-Host-Baseline -PathType Container)
{ Remove-Item -Path C:\Temp\Secure-Host-Baseline -Recurse -Force } 

if (Test-Path -Path C:\Temp\Secure-Host-Baseline-master -PathType Container)
{ Remove-Item -Path C:\Temp\Secure-Host-Baseline-master -Recurse -Force } 

# Extract the SHB source files from their Zip:
Expand-Archive -Path C:\SANS\Day2-Hardening\Secure-Host-Baseline\Secure-Host-Baseline-master.zip -DestinationPath C:\Temp -Force

# Rename the folder with the SHB source files (as GitHub README recommends):
Rename-Item -Path C:\Temp\Secure-Host-Baseline-master -NewName C:\Temp\Secure-Host-Baseline 

# Dot-source the functions from the main SHB source file:
Import-Module C:\Temp\Secure-Host-Baseline\Scripts\GroupPolicy.psm1

# Run a function just dot-sourced to create the SHB Group Policy Objects.
# Conceal any errors produced in case the script is run multiple times.
$currentPref = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue" 
Invoke-ApplySecureHostBaseline -Path 'C:\Temp\Secure-Host-Baseline' -PolicyNames 'Adobe Reader','AppLocker','Certificates','Chrome','EMET','Internet Explorer','Office 2013','Windows','Windows Firewall' -UpdateTemplates -ErrorAction SilentlyContinue 
$ErrorActionPreference = $currentPref


# Now, look in the GPMC and there will be new GPOs, but they are not
# linked to anything by default.


# Fix GPMC pop-up errors (July 2017):
del C:\Windows\PolicyDefinitions\en-US\ReaderDC.adml -ErrorAction SilentlyContinue
del C:\Windows\PolicyDefinitions\ReaderDC.admx -ErrorAction SilentlyContinue


