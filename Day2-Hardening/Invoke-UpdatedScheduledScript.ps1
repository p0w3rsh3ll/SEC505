<##########################################################################
.SYNOPSIS
    Download a script, check its digital signature, and run it.  

.DESCRIPTION
    This script would likely be executed by a scheduled task.  Call this
    script the "scheduled" script.  This scheduled script downloads 
    another script in a zip file.  Call this second script in the zip 
    file the "target" script.  The HTTPS URL to the zip with the target 
    script is defined below by you.  The scheduled script downloads
    the zip file, extracts the target script from the zip, checks the
    digital signature of the target script, and, if the signature is
    valid, runs the target script.  The target script is saved locally.
    When the scheduled task next runs, if the target script cannot be
    downloaded or has a bad signature, the locally-saved target script
    from the prior run is executed instead.

    This scheduled script is really just a boilerplate or skeleton script
    to get you started.  You'll need to enhance this script for your
    environment, e.g., to perform logging, alerting, etc.  The most
    important thing is the IDEA, not the precise lines below; for example,
    if you don't want to use (or trust) Get-AuthenticodeSignature, then
    GnuPG signatures could be used instead (https://www.gpg4win.org).
    Security depends on the integrity of the HTTPS server, the private 
    keys trusted for signing target scripts, the list of CAs trusted by 
    the client running the target scripts, and in general the integrity
    of the client OS.  The architecture is similar to Windows Update.

.NOTES
    Update: 20.Sep.2018
    Author: Enclave Consulting LLC, Jason Fossen, https://sans.org/sec505
     Legal: Public domain, no guarantees or warranties, provided AS IS.
#########################################################################>



#########################################################################
#
# Edit the following three variables or edit the script to use Param():
#
#########################################################################

# URL to the script zip file to be downloaded and executed locally:
$ScriptZipURL = "https://www.sans.org/tgtscript.zip"

# Path to the folder where the downloaded script is to be copied and executed:
$TargetScriptFolder = "$Env:WinDir\Progra~1\ScheduledTaskScripts\Task-KD6-3.7"

# Name of the script from the zip to be executed:
$TargetScriptName = "thescript.ps1"

#########################################################################
#
# Only the above variables need modification.
#
#########################################################################



# The full path to script to be executed:
$FullTargetScriptPath = Join-Path -Path $TargetScriptFolder -ChildPath $TargetScriptName


# Create temp folder to hold the downloaded zip:
$TempFolder = Join-Path -Path $env:TEMP -ChildPath (Get-Date).Ticks 
New-Item -ItemType Directory -Path $TempFolder -ErrorAction Stop


# Download the zip over HTTPS to the temp folder:
$OutFile = Join-Path -Path $TempFolder -ChildPath "deleteme.zip" 
Invoke-WebRequest -Uri $ScriptZipURL -MaximumRedirection 0 -OutFile $OutFile -ErrorAction Stop 


# Extract script from zip:
Expand-Archive -Path $OutFile -DestinationPath $TempFolder -Force -ErrorAction Stop 


# Check for the correct name of the extracted script:
$ScriptInTempFolder = Join-Path -Path $TempFoler -ChildPath $TargetScriptName

if ( -not (Test-Path -Path $ScriptInTempFolder) )
{ 
    Write-Error -Message "Could not find correct script in the zip, exiting..."
    Exit 
}


# Check digital signature of the downloaded script:
$SigCheck = $False 
#$SigCheck = Get-GnuGpSignatureStatus -FilePath $ScriptInTempFolder #TODO: write this function...
$SigCheck = Get-AuthenticodeSignature -FilePath $ScriptInTempFolder -ErrorAction Stop

If ( $SigCheck.Status -eq "Valid" )
{ $SigCheck = $True } 
Else 
{ $SigCheck = $False } 



# Create or replace local script file, if the signature is good:
If ( $SigCheck )
{
    Copy-Item -Path $ScriptInTempFolder -Destination $FullTargetScriptPath -Force
}
Else 
{
    # Log the signature validation failure or some other useful things here...   
}


# Delete temp folder:
Remove-Item -Path $TempFolder -Recurse -Force


# Run the (old or new) script:
Start-Process -FilePath "$PSHOME\powershell.exe" -ArgumentList "-NoProfile -File $FullTargetScriptPath" 




