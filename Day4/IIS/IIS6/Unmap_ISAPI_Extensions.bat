
REM This batch demonstrates how to use ADSUTIL.VBS to unmap ISAPI Extensions.
REM ADSUTIL.VBS comes with IIS.  Look in the \AdminScripts folder.

REM This line will remove all mappings from the default website:

cscript.exe adsutil.vbs set w3svc/1/root/scriptmaps ""



REM This wrapped line remove all mappings except for .asp, .asa and .shtm:

cscript.exe adsutil.vbs set w3svc/1/root/scriptmaps ".asp,C:\Winnt\System32\inetsrv\asp.dll,1,GET,HEAD,POST,TRACE“ ".asa,C:\Winnt\System32\inetsrv\asp.dll,1,GET,HEAD,POST,TRACE" ".shtm,C:\Winnt\System32\inetsrv\ssinc.dll,1,GET,POST“




REM Notice you can change the HTTP verbs allowed at the same time.


