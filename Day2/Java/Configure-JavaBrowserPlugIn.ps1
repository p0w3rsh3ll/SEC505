##################################################################################
#.SYNOPSIS
#	 Configures Java SE browser plug-in settings for security. 
#
#.DESCRIPTION
#    Java 7 update 10 and later supports security options to 1) allow/disallow the
#    plug-in for Java to run applets in the web browser and 2) security levels
#    for the plug-in if browser applets are permitted to run at all.  This script
#    will create or overwrite the system-wide Java configuration files named
#    'deployment.config' and 'deployment.properties' in C\:Windows\Sun\Java\Deployment
#    in order to enable or disable Java browser plug-in support for all users.
#    The script defaults to disabling the Java browser plug-in and to set the
#    Java browser security level to "HIGH", but note that this does not disable
#    disable standalone Java applications, it only affects the browser.  Supported
#    browsers include at least Microsoft Internet Explorer, Google Chrome, and 
#    Mozilla Firefox.  Changes take effect after closing and reopening the browser.
#    Script must be run with local Administrators or System privileges, such as
#    with a Group Policy assigned startup script or through PowerShell remoting. 
#    The changes made will affect all users who log on locally at the computer.
#    Note that the script does run Java's ssvagent.exe tool, just like when
#    using the Java Control Panel, but Oracle could change this binary or its
#    command-line switches at any time, hence, the script is version-brittle.
#
#.PARAMETER OverWrite
#    If system-wide Java configuration files already exist, this switch is necessary
#    to overwrite them.  These files do not exist by default, but may have been
#    added by other administrators or developers.  The user's personal configuration
#    file(s) for Java are not overwritten or modified by this script in any way.
#
#.PARAMETER EnableBrowserPlugIn
#	 The default behavior is to disable the Java browser plug-in.  This switch
#    will enable the browser plug-in instead.
#
#.PARAMETER UnlockBrowserSettings
#	 The default behavior is to lock (grey out) the browser security options in
#    the Java Control Panel (javacpl.exe) after running the script.  This switch
#    will allow the user to modify the browser Java security settings.
#
#.PARAMETER SecurityLevel
#	 The default behavior is to set the Java browser security level to HIGH.  
#    Valid security level options are VERY_HIGH, HIGH and MEDIUM.
#
#.PARAMETER DeleteConfigurationFiles
#    This switch will delete the system-wide Java configuration files.  These
#    files do not exist by default.  
#
#.EXAMPLE
#
#    Configure-JavaBrowserPlugIn.ps1 -OverWrite
#
#    Disable the Java browser plug-in, set the security level to HIGH, and
#    lock the security options in the Java Control Panel graphical tool.
#    This overwrites any current system-wide Java configuration files.
#
#.EXAMPLE
#
#    Configure-JavaBrowserPlugIn.ps1 -OverWrite -EnableBrowserPlugIn -SecurityLevel VERY_HIGH
#
#    Enable the Java browser plug-in, set the security level to VERY_HIGH,
#    and lock the security options in the Java Control Panel graphical tool.
#    This overwrites any current system-wide Java configuration files.
#
#.EXAMPLE
#
#    Configure-JavaBrowserPlugIn.ps1 -DeleteConfigurationFiles
#
#    Deletes the system-wide Java configuration files.  These are the only files 
#    modified by this script.  These files do not exist by default.
#
#
#.NOTES
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505) 
# Version: 1.0
# Updated: 5.June.2013
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
#          JAVA IS A PRODUCT AND TRADEMARK OF ORACLE CORPORATION.
#
##################################################################################

Param ( [Switch] $OverWrite, [Switch] $EnableBrowserPlugIn, [Switch] $UnlockBrowserSettings, $SecurityLevel = "HIGH", [Switch] $DeleteConfigurationFiles) 


# When remoting with Invoke-Command, you'll probably want to hardcode your parameters here for simplicity; for example:
# $OverWrite = $true ; $EnableBrowserPlugIn = $true ; $UnlockBrowserSettings = $true ; $SecurityLevel = "VERY_HIGH"


# Sanity check and massage some of the parameters.
if ($DeleteConfigurationFiles -and ($EnableBrowserPlugIn -or $UnlockBrowserSettings)) { "`nInvalid combination of switches, exiting.`n" ; exit -1 } 
if ($SecurityLevel -notmatch '^V|^H|^M'){ "`nSecurity level must be one of: VERY_HIGH, HIGH, or MEDIUM`n" ; exit -1 } 
switch -Regex ($SecurityLevel)
{
    '^V' { $SecurityLevel = "VERY_HIGH" }  # All this extra work is done so that
    '^H' { $SecurityLevel = "HIGH"      }  # the arguments better match some of
    '^M' { $SecurityLevel = "MEDIUM"    }  # Java's documentation.
}


# Construct the strings for the deployment.properties file.
# Defaults to the Java browser plug-in being disabled.
if ($EnableBrowserPlugIn) { $propertiesfile = "deployment.webjava.enabled=true" } else { $propertiesfile = "deployment.webjava.enabled=false" }

# Default to locking the security level and browser plug-in state, i.e., they are visible but greyed out in Java Control Panel.
if (-not $UnlockBrowserSettings) { $propertiesfile += "`ndeployment.webjava.enabled.locked `ndeployment.security.level.locked" } 

# Default to security level being set to High (see Security tab of Java Control Panel).
$propertiesfile += "`ndeployment.security.level=" + $SecurityLevel


# Possibly delete the configuration files and exit, but leave the folder alone though.
if ($DeleteConfigurationFiles)
{
    "`nDeleting system-wide Java configuration files, if they exist...`n"
    if (Test-Path -Path $env:WinDir\Sun\Java\Deployment\deployment.config)
    {
        remove-item $env:WinDir\Sun\Java\Deployment\deployment.config -Force
        if (-not $?) { "`nFailed to delete deployment.config file.`n" }
    }

    if (Test-Path -Path $env:WinDir\Sun\Java\Deployment\deployment.properties)
    {
        remove-item $env:WinDir\Sun\Java\Deployment\deployment.properties -Force
        if (-not $?) { "`nFailed to delete deployment.properties file.`n" }
    } 

    exit 
}


# Create the $env:WinDir\Sun\Java\Deployment folder for the system-wide Java configuration files.
New-Item -Path $env:WinDir\Sun\Java\Deployment -ItemType Directory -Force | Out-Null
if (-not $?) { "`nFailed to create $env:WinDir\Sun\Java\Deployment folder, exiting.`n" ; exit -1 } 


# Test if the deployment.config file already exists.
if ( $(Test-Path -Path $env:WinDir\Sun\Java\Deployment\deployment.config) -and -not $OverWrite )
   { "`nThe deployment.config file already exists and you did not specify -OverWrite, exiting.`n" ; exit 0 } 


# Test if the deployment.properties file already exists.
if ( $(Test-Path -Path $env:WinDir\Sun\Java\Deployment\deployment.properties) -and -not $OverWrite )
   { "`nThe deployment.properties file already exists and you did not specify -OverWrite, exiting.`n" ; exit 0 } 


# Create the deployment.config file.
"deployment.system.config=$env:WinDir\Sun\Java\Deployment\deployment.properties" | 
    Out-File -FilePath $env:WinDir\Sun\Java\Deployment\deployment.config -Force -Encoding ASCII
if (-not $? -or -not $(Test-Path $env:WinDir\Sun\Java\Deployment\deployment.config))
   { "`nCould not create the deployment.config file, exiting.`n" ; exit -1 } 


# Create the deployment.properties file.
$propertiesfile | Out-File -FilePath $env:WinDir\Sun\Java\Deployment\deployment.properties -Force -Encoding ASCII
if (-not $? -or -not $(Test-Path $env:WinDir\Sun\Java\Deployment\deployment.properties))
   { "`nCould not create the deployment.properties file, exiting.`n" ; exit -1 } 


# Show system-wide deployment.properties file contents FYI.
"`nCurrent contents of the deployment.properties file:`n"
get-content $env:WinDir\Sun\Java\Deployment\deployment.properties ; "`n"


# Run latest ssvagent.exe for both x86 and x64, but not on Java Platform 6 or earlier, and 
# hope future Javas support these switches (man, what a mess, doomed to rewrites...):
if ($propertiesfile -like '*deployment.webjava.enabled=false*')
{
    # Try the x64 version, if any:
    $ssvagent = $null
    if (Test-Path -Path "$env:ProgramFiles\Java\")
    {
        $ssvagent = dir "$env:ProgramFiles\Java\*.exe" -Recurse | 
                where { $_.name -eq 'ssvagent.exe' -and $_.fullname -notmatch '\\jre[1-6]\\'} | 
                sort LastWriteTimeUtc -desc | select -first 1 
    }

    if ($ssvagent -ne $null) 
    { 
        $expression = $ssvagent.FullName.Replace("Program Files","'Program Files'") + " -disablewebjava"
        "Executing: $expression `n"
        invoke-expression -command $expression
    }


    # Now for the x86 version second, because this is the Oracle-preferred:
    $ssvagent = $null
    if (Test-Path -Path "${env:ProgramFiles(x86)}\Java\")
    {
        $ssvagent = dir "${env:ProgramFiles(x86)}\Java\*.exe" -Recurse | 
                where { $_.name -eq 'ssvagent.exe' -and $_.fullname -notmatch '\\jre[1-6]\\'} | 
                sort LastWriteTimeUtc -desc | select -first 1 
    }

    if ($ssvagent -ne $null) 
    { 
        $expression = $ssvagent.FullName.Replace("Program Files (x86)","'Program Files (x86)'") + " -disablewebjava"
        "Executing: $expression `n"
        invoke-expression -command $expression
    }
}
elseif ($propertiesfile -like '*deployment.webjava.enabled=true*')
{
    # Try the x64 version, if any:
    $ssvagent = $null
    $ssvagent = dir "$env:ProgramFiles\Java\*.exe" -Recurse | 
                where { $_.name -eq 'ssvagent.exe' -and $_.fullname -notmatch '\\jre[1-6]\\'} | 
                sort LastWriteTimeUtc -desc | select -first 1 
    if ($ssvagent -ne $null) 
    { 
        $expression = $ssvagent.FullName.Replace("Program Files","'Program Files'") + " -forceinstall -register -new -high"  #Only -high exists?
        "Executing: $expression `n"
        invoke-expression -command $expression
    }

    # Now for the x86 version second, to let it possibly overwrite x64 settings, since x86 is Oracle-preferred:
    $ssvagent = $null
    $ssvagent = dir "${env:ProgramFiles(x86)}\Java\*.exe" -Recurse | 
                where { $_.name -eq 'ssvagent.exe' -and $_.fullname -notmatch '\\jre[1-6]\\'} | 
                sort LastWriteTimeUtc -desc | select -first 1 
    if ($ssvagent -ne $null) 
    { 
        $expression = $ssvagent.FullName.Replace("Program Files (x86)","'Program Files (x86)'") + " -forceinstall -register -new -high"  #Only -high exists?
        "Executing: $expression `n"
        invoke-expression -command $expression
    }
}


# Done, but feel free to add code to write to an Event Log, set further options, etc. (it's public domain).
#
# For more information, see the following:
#     http://docs.oracle.com/javase/7/docs/technotes/guides/deployment/deployment-guide/properties.html
#     http://docs.oracle.com/javase/7/docs/technotes/guides/jweb/client-security.html
