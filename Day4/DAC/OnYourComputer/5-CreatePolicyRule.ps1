# Create the DAC rule named "Only HR Access to Files with PII".




# Get SID for the Human_Resources global group (unique per domain).
# If there are multiple, just get the first one.

Import-Module -Name ActiveDirectory
$HR = @( Get-ADGroup -Filter "Name -like 'Human*'" )
$SID = $HR[0].SID.Value 



# Get Department resource property, unique per domain because we made Dept a reference resource property.

$DeptName = @( Get-ADResourceProperty -Filter "Name -like 'Department*'" ) 
$DeptName = $DeptName[0].Name 



# Construct SDDL string for the ACL permissions.
# Original came from creating the rule in the GUI and then Get-ADCentralAccessRule to show string.

$AclString = "O:SYG:SYD:AR(A;;FA;;;BA)(A;;FA;;;SY)(A;;FA;;;" + $SID + ")"



# Construct targeting conditions.

$Targeting = '((@RESOURCE.PII_MS Any_of {5000, 4000, 3000}) && (@RESOURCE.' + $DeptName + ' == "Human Resources"))'



# Create the new rule.
# Press F5 for a refresh in the GUI in order to see it.

New-ADCentralAccessRule -Name "Only HR Access to Files with PII" -CurrentAcl $AclString -ResourceCondition $Targeting


