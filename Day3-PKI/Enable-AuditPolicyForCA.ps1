# Enable logging audit policy for Certification Services:

auditpol.exe /set /subcategory:"Certification Services" /success:enable /failure:enable 


# Enable auditing on the properties of the CA (Auditing tab):

certutil.exe -setreg CA\AuditFilter 127




