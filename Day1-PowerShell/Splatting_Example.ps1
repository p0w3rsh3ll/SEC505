# Splatting can be used to pass in a hashtable of parameters and
# arguments into a cmdlet or function instead of passing those
# same arguments explicitly at the command line.  It is useful
# especially when a script, function or cmdlet has two or more
# switch parameters.  
#Requires -Version 2


# Construct a hashtable of parameter=arg pairs:
$ParamArgs = @{ Name = "powershell_ise" ; Module = $True ; FileVersionInfo = $True }  


# You can update the hashtable afterwards:
$ParamArgs.Name = "lsass"
$ParamArgs.FileVersionInfo = $False


# Call the function or cmdlet, pass in the hashtable with an @-symbol:
Get-Process @ParamArgs


# Note: In an advanced function, you can also use the $PSBoundParameters
# automatic variable, which is a hashtable of all parameters passed into
# the function.  



