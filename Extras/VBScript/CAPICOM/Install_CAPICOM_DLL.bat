@ECHO OFF

REM This will copy capicom.dll to your %SystemRoot%\System32 folder and register it there.

copy capicom.dll %SystemRoot%\System32
regsvr32.exe %SystemRoot%\System32\capicom.dll /s 


