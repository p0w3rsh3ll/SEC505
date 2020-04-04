<####################################################################
.SYNOPSIS
    Test for a dangerous SAN setting on a Certification Authority.

.DESCRIPTION
    On a Windows Server Certification Authority (CA) running the Active
    Directory Certificate Services role, it is dangerous to allow
    users to provide arbitrary Subject Alternative Names (SANs) in
    their enrollment requests.  This script outputs $True if the
    EDITF_ATTRIBUTESUBJECTALTNAME2 flag has been set on the CA, i.e.,
    if the CA allows this dangerous user behavior.  The script returns
    $False if this dangerous behavior is not allowed, which is the
    default.  This dangerous SAN behavior will be allowed if these
    commands are run (notice the "+EDITF*"): 

       certutil.exe –setreg policy\EditFlags +EDITF_ATTRIBUTESUBJECTALTNAME2 

       Restart-Service -Name CertSvc

    To disable this dangerous setting, run these commands (notice the "-"):

       certutil.exe –setreg policy\EditFlags -EDITF_ATTRIBUTESUBJECTALTNAME2 

       Restart-Service -Name CertSvc

#####################################################################>

if (-not (Test-Path "$env:WinDir\System32\certutil.exe") ) 
{ Throw 'ERROR: Could not find CERTUTIL.EXE!' ; return } 


$output = certutil.exe –getreg policy\EditFlags

if (-not $?){ Throw 'ERROR: Could not determine setting!'; return } 


if ( Select-String -Quiet -InputObject $output -Pattern 'EDITF_ATTRIBUTESUBJECTALTNAME2')
{ $True }
Else
{ $False }



