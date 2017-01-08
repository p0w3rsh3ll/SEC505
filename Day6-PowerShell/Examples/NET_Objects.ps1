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

