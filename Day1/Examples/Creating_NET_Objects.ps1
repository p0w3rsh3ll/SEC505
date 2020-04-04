# To create an object whose parent assembly is already loaded:

$object = new-object System.Int32
$object = new-object System.DateTime
$object = new-object System.Net.WebClient
$object = new-object System.Net.Mail.SmtpClient



# But if the assembly containing the class hasn't been loaded, you'll have to load it first:

[System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework") > $null
$object = New-Object -TypeName Microsoft.Win32.OpenFileDialog
$object.ShowDialog()
$object.FileName


# Some .NET object constructor methods require one or more arguments:

$s = new-object -type System.String -argumentlist "Hello"



# To get hints about the possible constructor arguments for a type of object:

[System.String].GetConstructors() | 
foreach-object { $_.getparameters() } | 
select-object  name,member | 
format-table -autosize




# To see a list of the assemblies currently loaded into PowerShell:

[System.AppDomain]::CurrentDomain.GetAssemblies() | format-list FullName,Location


# To see a list of all the classes from all the assemblies currently loaded into PowerShell:

[System.AppDomain]::CurrentDomain.GetAssemblies() | 
foreach-object { $_.GetExportedTypes() } | 
format-list fullname,assembly


# To see the assembly which implements a currently-loaded class:

[System.String].Assembly | format-list
[System.Management.Automation.ErrorRecord].Assembly | format-list


# To see all the properties and methods of a class:

[System.Net.WebClient] | get-member | format-list


# To see all the static properties and methods of a class:

[System.String] | get-member -static | format-list


# Besides the get-member cmdlet, you can also query a class with its own methods:

[System.String].GetMembers()
[System.DateTime].GetMembers()
[System.Net.WebClient].GetMembers()



# To load a .NET class into PowerShell from its assembly stored in the Global Assembly Cache (GAC) using the short/simple/partial name of that class:

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")


# To load a .NET assembly into PowerShell using the full/strong name of the assembly:

[System.Reflection.Assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=Neutral, PublicKeyToken= b77a5c561934e089")


# To load a .NET assembly into PowerShell using the full path to the assembly file:

[System.Reflection.Assembly]::LoadFrom('C:\folder\module.dll')

