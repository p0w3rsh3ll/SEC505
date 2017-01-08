# Actually disabling Java in *just* Internet Explorer, and not in any other locally installed 
# browser, is ridiculously hard.  Most of the following changes will simply be overwritten the
# next time the Java Control Panel tool (javacpl.exe) is used to change any browser plug-in
# options, hence, it is better to use the Configure-JavaBrowserPlugIn.ps1 script instead to
# manage the Java plug-in for all browsers, not just IE.

# First, disable all Oracle/Sun ActiveX controls and Browser Helper Objects in IE:
# Tools menu > Manage add-ons > Toolbars and Extensions > Show:All add-ons.


# Next, try to disable Java in Internet Explorer for any version of the Java plug-in.
# These changes will be overwritten by the Java Control Panel in Java version 7u10 and later.  

dir HKLM:\SOFTWARE\JavaSoft\'Java Plug-in' | foreach { set-itemproperty -path $_.pspath -name 'UseJava2IExplorer' -value 0 }
dir HKLM:\SOFTWARE\Wow6432Node\JavaSoft\'Java Plug-in' | foreach { set-itemproperty -path $_.pspath -name 'UseJava2IExplorer' -value 0 } 


# Prevent IE from opening .jnlp files automatically without prompting the user.
# These changes will be overwritten by the Java Control Panel tool version 7u10 and later.  
  
$key = get-item HKLM:\SOFTWARE\Classes\JNLPFile                     #Same as HKEY_CLASSES_ROOT
Remove-ItemProperty -Path $key.PSPath -Name 'EditFlags'
Set-ItemProperty -Path $key.PSPath -Name 'EditFlags' -Value 0       #Does not have to be REG_BINARY



# Disable support for the <APPLET> element in web pages for the CURRENT user only, not
# all users globally, hence, this change should be made through Group Policy too.  You
# could also set the Group Policy option named "Security Zones: Use only machine settings",
# which sets a registry value named "Security_HKLM_only", so that there are no per-user IE
# settings, there are only machine settings, and then disable support for the <APPLET> element
# globally, but this script should not touch settings like this which go beyond just Java.
# The per-user GPO setting is named "Java permissions" and it is located under GPO > User
# Configuration > Policies > Administrative Templates > Windows Components > Internet Explorer
# > Internet Control Panel > Security Page > Internet Zone.

# However, this change will not (currently) be overwritten by the Java Control Panel tool.  

$key = get-item HKCU:\Software\Microsoft\Windows\CurrentVersion\'Internet Settings'\Zones\3
Set-ItemProperty -Path $key.PSPath -Name '1C00' -Value 0  

