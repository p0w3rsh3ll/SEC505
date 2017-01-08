REM   Search http://msdn.microsoft.com/library/ for the names of the values for more info.
REM   These values limit the number bytes that may be present in an HTTP request to IIS 6.0 
REM   and later.  They do not work in earlier versions of IIS.  See Microsoft's URLSCAN.DLL
REM   documenation for a fuller discussion of how these settings can enhance security.


cscript.exe adsutil.vbs SET W3SVC/MaxRequestEntityAllowed "32000"
cscript.exe adsutil.vbs SET W3SVC/AspMaxRequestEntityAllowed "32000"


