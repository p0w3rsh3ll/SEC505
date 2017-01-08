REM Query the SEHOP registry value: 0 = SEHOP is enabled (not disabled):

reg.exe query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel" /v DisableExceptionChainValidation



REM Set the SEHOP registry value to enable SEHOP:

reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel" /v DisableExceptionChainValidation /t REG_DWORD /d 0 /f 








REM (Don't forget that reg.exe can modify the registry on remote systems too.)