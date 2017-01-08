
# To add a couple simple numeric or textual properties to a process object:

$x = @(get-process "powershell")[0]
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


# To import the MyCustom.types.ps1xml file into the current PowerShell session:

update-typedata MyCustom.types.ps1xml


# To see the view types of an object, list its PSTypeNames property:

$soft = get-item hklm:\software
$soft.PSTypeNames


# To see the snap-ins loaded along with their *.types.ps1xml and *.format.ps1xml files:

get-pssnapin | format-list name,types,formats


# To create a wrapped System.Management.Automation.PSCustomObject object:

$x = new-object System.Management.Automation.PSObject
$x.GetType().FullName 


# To wrap a non-PSObject-wrapped object inside a new PSObject:

$int = 3
$int -is [PSObject]                            # Returns $False.

$PSint = new-object PSObject -arg $int
$PSint -is [PSObject]                          # Returns $True.


