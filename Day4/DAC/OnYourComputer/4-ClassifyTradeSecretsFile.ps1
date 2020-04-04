# Assign classification tags to the TradeSecrets.txt file in C:\Classified-Files.



# Ensure that most recent resource properties have been downloaded.

Update-FSRMClassificationPropertyDefinition



# Create object representing the File Server Resource Manager (FSRM) service.

$FSRM = New-Object -com Fsrm.FsrmClassificationManager



# Obtain the currently-defined resource property names, but
# only include those related to the examples in this course.

$ResourcePropertyDefinitions = $FSRM.EnumPropertyDefinitions() | Select -ExpandProperty Name | Where { $_ -match 'IntellectualProperty|Discoverability|Department|RequiredClearance|PII' } 



# Assign data to each of the tags discussed in the course.
# The names may be different from standard if manual not followed exactly,
# and Department will always be unique per machine because we made it 
# a reference resource property.

Switch ( $ResourcePropertyDefinitions ) 
{
    { $_ -like "Department*" } 
        { $FSRM.SetFileProperty("C:\Classified-Files\TradeSecrets.txt", "$_", "Engineering") } 
   
    { $_ -like "Discoverability*" } 
        { $FSRM.SetFileProperty("C:\Classified-Files\TradeSecrets.txt", "$_", "Not Applicable") } 

    { $_ -like "IntellectualProperty*" } 
        { $FSRM.SetFileProperty("C:\Classified-Files\TradeSecrets.txt", "$_", "Trade Secret") }  

    { $_ -like "PII*" } 
        { $FSRM.SetFileProperty("C:\Classified-Files\TradeSecrets.txt", "$_", "1000") }  

    { $_ -like "RequiredClearance*" } 
        { $FSRM.SetFileProperty("C:\Classified-Files\TradeSecrets.txt", "$_", "4000") } 

}



# List the current classification tag values.

$FSRM.EnumFileProperties("C:\Classified-Files\TradeSecrets.txt",0) | Format-Table Name,Value -AutoSize

