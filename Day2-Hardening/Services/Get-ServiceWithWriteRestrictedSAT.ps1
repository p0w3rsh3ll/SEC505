# Only output services with a write-restricted Security Access Token (SAT).
# When a write-restricted-SAT service requires access to a resource, such
# as a file, the permissions on that resource must grant permission to the
# service explicitly by name. 

Get-Service | foreach `
{ 
    if ((sc.exe qsidtype $_.name) -match 'SID_TYPE:\s+RESTRICTED') 
    { $_ } 
} 

