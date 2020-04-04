# Create some classification rules for File Server Resource Manger (FSRM).
# Suggest some demos to perform.



# Everything in C:\Classified-Files will get tagged Clearance = Restricted by default.

New-FSRMClassificationRule -Name "Folder Classifier" -Property "RequiredClearance_MS" -PropertyValue "3000" -Namespace @("C:\Classified-Files") -ClassificationMechanism "Folder Classifier" -ReevaluateProperty Overwrite



# During the demo, add "FOUO" to a file, wait a few seconds, and see that now Clearance = Secret.

New-FSRMClassificationRule -Name "Content Classifier" -Property "RequiredClearance_MS" -PropertyValue "4000" -Namespace @("C:\Classified-Files") -ClassificationMechanism "Content Classifier" -Parameters @("RegularExpressionEx=Min=1;Expr=FOUO") -ReevaluateProperty Overwrite 



# After the FOUO bit, change the extension of the file to ".docx" and see that now Discoverability = Hold.

$PowerShellScript = @'
function GetPropertyValueToApply ( $Target )
{
   if ($Target.Name -like "*.docx") { "Hold" }
}
'@

New-FSRMClassificationRule -Name "PowerShell Classifier" -Property "Discoverability_MS" -Namespace @("C:\Classified-Files") -ClassificationMechanism "Windows PowerShell Classifier" -Parameters @("ScriptText=$PowerShellScript","FSRMClearPropertyInternal=0") -ReevaluateProperty Overwrite 








