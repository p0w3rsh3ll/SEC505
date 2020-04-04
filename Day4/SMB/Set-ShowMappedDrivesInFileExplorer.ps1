#.SYNOPSIS
# Allow SMB drives mapped in an elevated shell to appear in File Explorer too.
#
#.NOTES
# Requires reboot.
# Drive mappings are not just per-user, but per-SAT per-user; hence, User Account Control issues.
# Users who do not or cannot elevate PoSh will not have this problem; only IT admins do.  
# https://www.bloggingforlogging.com/2018/11/22/windows-mapped-drives-what-the-hell-is-going-on/
# https://security.stackexchange.com/questions/94528/does-enabling-enablelinkedconnections-pose-a-security-risk


Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLinkedConnections -Value 1 -Type DWord 



