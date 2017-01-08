########################################################################
# The following are example commands with CERTUTIL.EXE to manage
# client-side Certificate Revocation List (CRL) settings and behavior.
# These commands only work on Windows Vista, Server 2008 and later, and
# on these systems the CERTUTIL.EXE program is built in by default.
########################################################################


# To see the URLs of the CRLs currently being cached by the client:
certutil.exe -URLCache CRL


# To flush cached CRLs in order to force fresh downloads (PowerShell):
certutil.exe -setreg chain\ChainCacheResyncFiletime '@now'


# To flush cached CRLs in order to force fresh downloads in CMD.EXE;
# notice that the last argument is not enclosed in quotes for CMD:
# certutil.exe -setreg chain\ChainCacheResyncFiletime @now


# Delete CRLs from the cache after invalidating them, just for good measure:
certutil.exe -URLcache CRL delete


# To open a GUI app to check the revocation status of an exported
# certificate using the CRL and/or OCSP information in the cert, i.e.,
# you do not have to download the CRL or provide the URL to the OCSP
# responder yourself, these are extracted from the certificate file:
certutil.exe -url <path-to-cert-file>



