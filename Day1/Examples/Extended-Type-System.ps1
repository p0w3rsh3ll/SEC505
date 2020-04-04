###########################################################################
#
# Different versions of PowerShell support different techniques for 
# creating objects with custom properties and methods.  In general, newer
# methods are simpler and faster, but not backwards compatible.
#
###########################################################################




###########################################################################
#
# PowerShell 1.0 and Later : Add-Member
#
###########################################################################

# To add a couple simple numeric or textual properties to a process object:

$x = get-process -name "powershell*" | select -first 1
add-member -in $x -membertype NoteProperty -name Foo -value $true
add-member -in $x -membertype NoteProperty -name Bar -value 5555 


# To add a method implemented with a scriptblock:

add-member -input $x -membertype ScriptMethod -name Shout -value { ([string] $this.Bar).ToUpper() + "!!!" }


# To test whether an object $x can have new members added (must return $true):

$x -is [System.Management.Automation.PSObject]
$x -is [PSObject] 


# To use the modified object:

$x | get-member
$x.Foo
if ($x.Foo) { $x | select-object Foo }
$x.Bar = "Hi There"
$x.Shout()




###########################################################################
#
# PowerShell 1.0 and Later : Select-Object 
#
###########################################################################

$x = '' | select-object -property Foo,Bar,Some
$x.Foo = 47
$x.Bar = "Unicorn"
$x.Some = "Ninja"
$x | format-table -autosize 





###########################################################################
#
# PowerShell 2.0 and Later : New-Object -Property 
#
###########################################################################

$x = new-object -typename PSObject -property @{ 'Foo' = 47 ; 'Bar' = 'Kirk' }
$x | format-table -autosize 




###########################################################################
#
# PowerShell 2.0 and Later : Add-Type
#
###########################################################################

$mytype = @'
using System;
namespace MyCustomNamespace
{
  public class MyCustomClass
  {
    public int MyMethod(int numero)
    {
       return (47 * numero);
    }
  }
}
'@

add-type -typedefinition $mytype
$x = new-object MyCustomNamespace.MyCustomClass
$x.MyMethod(3) 





###########################################################################
#
# PowerShell 3.0 and Later : [PSCustomObject]
#
###########################################################################

$x = [PSCustomObject] @{ 'Foo' = 47 ; 'Bar' = 'Kirk' }
$x | format-table -autosize 





###########################################################################
#
# PowerShell 3.0 and Later : Import-Module -AsCustomObject
#
###########################################################################

<#
Not covered here, but you can import a custom module (.psm1) with the 
-AsCustomObject parameter such that the properties and methods exported 
by the module become properties and methods on the object outputted.  
#>





###########################################################################
#
# PowerShell 3.0 and Later : Update-TypeData
#
###########################################################################

Update-TypeData
Update-TypeData -TypeName System.IO.FileInfo -MemberType ScriptProperty -MemberName MB -Value { $this.length / 1MB } 
$x = dir *.ps1 | sort length | select -last 1
$x.MB





###########################################################################
#
# PowerShell 5.0 and Later : Class
#
###########################################################################

class MyNewClass
{
  [Int] $Foo = 47
  [String] $Bar = "Data"
  [Int] Multi3() { return $This.Foo * 3 }
}

$x = [MyNewClass]::New()
$x.Foo
$x.Bar
$x.Multi3()






###########################################################################
#
# Misc
#
###########################################################################

# To import the MyCustom.types.ps1xml file into the current PowerShell session:

update-typedata MyCustom.types.ps1xml


# To see the view types of an object, list its PSTypeNames property:

$soft = get-item hklm:\software
$soft.PSTypeNames


# To see the snap-ins loaded along with their *.types.ps1xml and *.format.ps1xml files:

get-pssnapin | format-list name,types,formats


# To create a wrapped System.Management.Automation.PSCustomObject object:

$x = new-object 
$x.GetType().FullName 


# To wrap a non-PSObject-wrapped object inside a new PSObject:

$int = 3
$int -is [PSObject]                            # Returns $False.

$PSint = new-object PSObject -arg $int
$PSint -is [PSObject]                          # Returns $True.


