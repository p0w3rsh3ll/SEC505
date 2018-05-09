####################################################################################
# Group Managed Service Accounts can be used on Server 2012, Windows 8, and later.
# GMSAs can be used across multiple machines and for scheduled jobs.
# Requires at least one controller to be running Server 2012 or later.
# Requires the schema to be upgraded to Server 2012 or later.
# Scheduled tasks which use GMSAs must be created and edited in PowerShell.
# When used with SQL Server, it must be SQL Server 2012 or later.
# For more information see:
#    http://blogs.technet.com/b/askpfeplat/archive/2012/12/17/windows-server-2012-group-managed-service-accounts.aspx
####################################################################################


# Step 1: Create the Key Distribution Service (KDS) root key:
Add-KdsRootKey -EffectiveTime ((Get-Date).AddHours(-10))

# Note that in real life you would execute the following command
# to create the KDS root key and then wait 10 hours:
#    Add-KdsRootKey -EffectiveImmediately
# This only needs to be done once per domain.


# Step 2: Choose or create a computer group whose member computers
# will be allowed to use the GMSA, e.g., "Domain Controllers".


# Step 3: Create the GMSA and specify the computer group:
New-ADServiceAccount -name TestingGMSA `
 -DNSHostName testinggmsa.testing.local `
 -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers"


# Step 4: Install and text GMSA on a computer in the group:
Install-AdServiceAccount TestingGMSA
Test-AdServiceAccount TestingGMSA


# Step 5a: Use the GMSA for a service account.  Make sure to
# specify the username as "testing\TestingGMSA$", i.e., the name 
# of the domain, backslash, then the name of the of the GMSA account
# with a dollar sign ($) at the end.  Leave the password blank.


# Step 5b: Or use the GMSA for a scheduled task.  This must be done in
# PowerShell since Microsoft couldn't be bothered with updating the
# Task Scheduler graphical tool to support creating or editing tasks
# which use GMSA accounts (very nice).  Don't forget to grant the
# GMSA account the "Log on as a batch job" right also.

$Principal = New-ScheduledTaskPrincipal -UserID testing\TestingGMSA$ -LogonType Password
$Action = New-ScheduledTaskAction  "C:\Folder\Script.ps1" 
$Trigger = New-ScheduledTaskTrigger -At 2:00 -Daily 
Register-ScheduledTask GmsaTaskName -Action $Action -Trigger $Trigger -Principal $Principal

# Note that '-LogonType Password' should be entered as shown literally, do not replace the
# 'Password' with another string which might be the password in the first command above.


# That's it!  But be aware that if the GMSA account is added to Domain Admins or another
# high-powered group, anyone who is a member of the local Administrators group on an
# authorized computer can create a scheduled task using the GMSA account.  Also, we do not
# yet have the details about how the GMSA account's password or hash is stored in AD or
# transmitted over the network to the computers permitted to use the GMSA.


