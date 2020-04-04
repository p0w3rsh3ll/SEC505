#######################################################################
# This is an example PowerShell classifier rule as used by the
# File Server Resource Manager (FSRM) for the sake of tagging files 
# for Dynamic Access Control.  The GetPropertyValueToApply() function
# can be enhanced to examine any aspect of the target file's
# contents or properties; whatever is returned by this function
# is given to the classifier rule in FSRM to tag the file.
#######################################################################


function GetPropertyValueToApply ( $Target )
{
   if ($Target.Name -like "*.docx") { "Hold" }
}


