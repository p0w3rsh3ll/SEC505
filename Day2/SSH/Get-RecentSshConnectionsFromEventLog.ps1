#.DESCRIPTION
#  Take a quick peek at recent SSH connections.

Get-WinEvent -LogName OpenSSH/Operational -MaxEvents 10000 |
Where { $_.Message -match "Accepted|Failed|Starting" } |
Format-List -Property TimeCreated,Message 

