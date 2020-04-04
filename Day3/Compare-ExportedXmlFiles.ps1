# Assist in the comparison of two XML files with objects
# of the same type, usually produced by the same command.
# First run: compare the XML files, look for differences
# that are potentially relevant, note the names of the
# properties with differences.  Subsequent runs: give
# the property name which contained a difference, examine
# the output and pay attention to that property, the
# names of the objects involved, and the SideIndicator.

   
Param ( $ReferenceXmlFile, $DifferenceXmlFile, [String] $PropertyName)


# Confirm valid paths to XML files.
if (-not (Test-Path -Path $ReferenceXmlFile)) { "$ReferenceXmlFile not found."  ; return } 
if (-not (Test-Path -Path $DifferenceXmlFile)){ "$DifferenceXmlFile not found." ; return } 


# Get the file objects.
$ReferenceXmlFile  = dir $ReferenceXmlFile
$DifferenceXmlFile = dir $DifferenceXmlFile 


# Confirm that file hashes are different before proceeding.
if ( ($ReferenceXmlFile.Length -eq $DifferenceXmlFile.Length) -and 
    ((Get-FileHash -Path $ReferenceXmlFile) -eq (Get-FileHash -Path $DifferenceXmlFile)) )
{ return } #Files are identical


# Parse the XML files and stop on any errors.
$RefXml = Import-Clixml -Path $ReferenceXmlFile -ErrorAction Stop
$DifXml = Import-Clixml -Path $DifferenceXmlFile -ErrorAction Stop


# Compare the objects with all properties, unless a specifc property name is given.
if ($PropertyName.Length -eq 0)
{
    $Properties = $RefXml | Get-Member -MemberType Properties | Select -ExpandProperty Name | Where { $_.Length -gt 0 } | Sort
    ForEach ($Prop in $Properties) 
    {
        Write-Host -ForegroundColor Green -NoNewline -Object "`nComparing by Property: " 
        Write-Host -ForegroundColor Yellow -Object $Prop
        Compare-Object -ReferenceObject $RefXml -DifferenceObject $DifXml -Property "$Prop" -PassThru | Format-Table -AutoSize
    } 
}
else
{
    Write-Host -ForegroundColor Green -NoNewline -Object "`nComparing by Property: " 
    Write-Host -ForegroundColor Yellow -Object $PropertyName
    Compare-Object -ReferenceObject $RefXml -DifferenceObject $DifXml -Property "$PropertyName" -PassThru | Format-List *
}


 