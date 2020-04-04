# Enable the five resource property rules mentioned in the 
# courseware (Department, PII, Discoverability, etc) and add
# them to Global Resource Property List.



# Disable all current resource properties:

Get-ADResourceProperty -Filter {Enabled -eq $True} | Set-ADResourceProperty -Enabled $False



# Enable just the five needed for the course:

Set-ADResourceProperty -Id "Discoverability" -Enabled $True
Set-ADResourceProperty -Id "Personally Identifiable Information" -Enabled $True
Set-ADResourceProperty -Id "Required Clearance" -Enabled $True
Set-ADResourceProperty -Id "Intellectual Property" -Enabled $True
Set-ADResourceProperty -Id "Department" -Enabled $True



# Convert to a reference resource property:

Set-ADResourceProperty -Id "Department" -SharesValuesWith "Department" 



# Add more suggested values to Required Clearance:

function New-ADSuggestedValueEntry ([String] $Value, [String] $DisplayName = "", [String] $Description = "")
{
    if ($DisplayName -eq ""){ $DisplayName = $Value }  
    New-Object Microsoft.ActiveDirectory.Management.ADSuggestedValueEntry($Value,$DisplayName,$Description) 
}

$Suggestions = (Get-ADResourceProperty -Identity "Required Clearance").SuggestedValues 
$Suggestions += New-ADSuggestedValueEntry -Value 4000 -DisplayName "Secret" -Description "The user must possess a Secret clearance level or higher to access the resource"
$Suggestions += New-ADSuggestedValueEntry -Value 5000 -DisplayName "Top Secret" -Description "The user must possess a Top Secret clearance level or higher to access the resource"

Set-ADResourceProperty -Id "Required Clearance" -SuggestedValues $Suggestions 



# Remove all current resource properties from the Global Resource Property List:

Get-ADResourcePropertyList -Identity "Global Resource Property List" | 
Select-Object -ExpandProperty Members | 
ForEach-Object { Remove-ADResourcePropertyListMember -Identity "Global Resource Property List" -Members $_ -Confirm:$False } 



# Add only the enabled resource properties to the Global Resource Property List:

$ResProps = Get-ADResourceProperty -Filter {Enabled -eq $True} 
Add-ADResourcePropertyListMember -Identity "Global Resource Property List" -Members $ResProps 



# Trigger fresh download of resource properties from AD:

Update-FSRMClassificationPropertyDefinition 



