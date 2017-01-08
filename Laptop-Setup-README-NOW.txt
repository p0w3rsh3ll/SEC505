Welcome to the SANS Institute!  Thank You for attending!

The following steps describe how your virtual machine should be configured each day of the course.  

It's best if these steps are completed *before* the beginning of seminar each day.

You can always get the latest versions of the scripts mentioned from:

	http://www.sans.org/windows-security  (go the Downloads link on the right)




****************************************************************
 Day 1: OS & Applications Hardening
****************************************************************
Copy this entire CD-ROM to your VM's hard drive into a new folder named "C:\SANS".  (Your virus scanner might complain about some of the files, but don't worry, they're supposed to be there, and if your virus scanner deletes any of the files, that's fine too.)   

Have Windows Server 2012 Standard or Datacenter Edition installed in the VM and promote it to be a domain controller.  See the Appendix at the end of the 505.1 manual for step-by-step instructions about how to become a domain controller.  Remember to use a static IP address in the VM (such as 10.1.1.1) and set your primary DNS server to be your own IP address too.  You might choose a domain name of "testing.local" if you wish.  Confirm that whatever user account you are using is a member of both the Domain Admins and the Enterprise Admins groups.

Create a shortcut to "powershell.exe" on your desktop, right-click that shortcut, and launch PowerShell with administrative privileges.

In PowerShell, execute the following commands (answer "Yes" when prompted):

    set-executionpolicy unrestricted
    cd c:\sans
    .\SEC505-Setup-Script.ps1

Open Server Manager, select your Local Server, click the "On" link next to "IE Enhanced Security Configuration" on the right-hand side, and set this feature to Off for both Administrators and Users.

Confirm that you have the Windows Server installation DVD or ISO file with you.  If you do not, plan on downloading it from the Internet or copying it from a friend before Day 3.  




****************************************************************
 Day 2: Restricting Admin Compromise & Dynamic Access Control
****************************************************************
If you ran the SEC505-Setup-Script.ps1 script mentioned above, you are ready for today.



    
****************************************************************
 Day 3: PKI, BitLocker & Secure Boot
****************************************************************
Install IIS with *all* optional subcomponents using Server Manager (Manage menu > Add ...).  Yes, check every single IIS box, but if you are prompted for the Windows Server installation DVD or ISO file, and you have neither, install IIS without the development tools (uncheck those boxes).

Note: Do not install Certificate Services yet, we need to do this together.




****************************************************************
 Day 4: IPSec, Firewall & Wireless
****************************************************************
Open PowerShell as administrator and run the following scripts:

	C:\SANS\Day4-IPSec\NetShell-Add-IPSec-Rule.bat
   	C:\SANS\Day4-IPSec\Add-IPSec-Rule.ps1

OPTIONAL: Install the application found here:

    C:\SANS\Tools\WireShark    (choose x86 or x64 as appropriate)




****************************************************************
 Day 5: Server Hardening & IIS
****************************************************************
You should already have the FileZilla application installed, but, if you do not, install FileZilla from the C:\SANS\Tools\FileZilla.

If you have not done so already, install IIS with *all* optional subcomponents using Server Manager (Manage menu > Add ...).

If you have Internet access, visit http://www.iis.net/downloads, download these items into your VM and install:

	Web Platform Installer (look in the banner at the top)
	URL Rewrite (in the Handle Requests area)

If you do not have Internet access or do not know how to copy files from the host computer into a VM, don't worry at all, everything will be demonstrated on-screen.




****************************************************************
 Day 6: PowerShell
****************************************************************
In PowerShell, run "ise" to launch a graphical PowerShell script editor.




