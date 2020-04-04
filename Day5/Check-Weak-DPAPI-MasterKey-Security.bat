REM *****************************************************************************
REM If Windows XP or later systems are configured to protect private keys and 
REM other DPAPI-protected secrets like Windows 2000, then it is vastly easier
REM for hackers or malware to steal these secrets in plaintext.  If you discover
REM that this Windows-2000-mode has been enabled in the registry, it is possible
REM that the machine has already been hacked or infected.  
REM
REM For more information:
REM    http://csrc.nist.gov/groups/STM/cmvp/documents/140-1/140sp/140sp240.pdf
REM    http://www.passcape.com/index.php?section=blog&cmd=details&id=20
REM    Search on the following keyword: MasterKeyLegacyCompliance 
REM *****************************************************************************


REM If the following query shows that MasterKeyLegacyCompliance is set to a non-zero number,
REM then it is bad sign that hackers or malware have set this value deliberately to weaken
REM the security of DPAPI-protected secrets like cached passwords or private keys.

reg.exe query HKLM\SOFTWARE\Microsoft\Cryptography\Protect\Providers\df9d8cd0-1501-11d1-8c7a-00c04fc297eb /v MasterKeyLegacyCompliance 


REM Run the following command to delete the MasterKeyLegacyCompliance value, which
REM is the default on Windows XP and later, and is best for security.

REM reg.exe delete HKLM\SOFTWARE\Microsoft\Cryptography\Protect\Providers\df9d8cd0-1501-11d1-8c7a-00c04fc297eb /v MasterKeyLegacyCompliance /f 


