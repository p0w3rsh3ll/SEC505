@REM  ==========================================================================
@REM  Changes the connection response banner for the SMTP service, but it 
@REM  only works on Windows Server 2003 and later (KB555080).  See KB281224 for 
@REM  how to set it manually on Windows 2000.  Change the BANNER variable below
@REM  if desired, and add more entries if you have more than five virtual SMTP
@REM  servers.  It's OK to leave the lines as-is if you have fewer than five.
@REM  Find adsutil.vbs under the \Inetpub\AdminScripts folder on the IIS server.
@REM  ==========================================================================


@set BANNER=ESMTP

adsutil.vbs set smtpsvc/1/ConnectResponse "%BANNER%"
adsutil.vbs set smtpsvc/2/ConnectResponse "%BANNER%"
adsutil.vbs set smtpsvc/3/ConnectResponse "%BANNER%"
adsutil.vbs set smtpsvc/4/ConnectResponse "%BANNER%"
adsutil.vbs set smtpsvc/5/ConnectResponse "%BANNER%"

