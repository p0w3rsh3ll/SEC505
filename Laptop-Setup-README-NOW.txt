-----------------------------------------------------

         Welcome to the SANS Institute!

-----------------------------------------------------


Please make the following changes on the morning of the first day before we begin:


* On this drive there is a file named "SEC505.ISO".  Please copy this SEC505.ISO 
  file anywhere to your computer's hard drive, such as to your Desktop. Do not 
  copy the ISO file into your VM.


* In the Windows Server virtual machine (VM) you have created for this course, 
  mount the SEC505.ISO file on your computer's hard drive as a CD/DVD drive.  
  It will probably appear as drive letter D:\ inside the VM (see instructions below).

  
* In your testing VM, not on your host laptop, create this folder:  

    C:\SANS


* Copy everything from the mounted ISO into C:\SANS inside your VM, hence,
  you will probably copy everything from D:\ into C:\SANS inside the VM.
  

* In your VM, go to the Start screen and do a search for "PowerShell ISE". 
  Right-click the blue PowerShell ISE shortcut and Run As Administrator.


* In PowerShell, type the following commands:

    Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
    
    cd C:\SANS
    
    .\SEC505-Setup-Script.ps1


    
Note: You will need to run the script *twice*, as instructed by the script.

Note: The script will reset your password to "P@ssword" inside the VM.

Note: When you run the setup script, if you get error messages about network
      interfaces, please tell the instructor ASAP!  You may need to install
      the Microsoft Loopback Adapter inside your VM to fix the problem.  

Note: If you cannot find the script, or if you do not have a folder named
      C:\SANS\Tools, then you've not copied the contents of the SEC505.ISO to
      the C:\SANS folder.  You may have copied the Windows Server DVD or
      may have copied just the ISO file instead.



      
-----------------------------------------------------

  How To Mount An ISO File In A Virtual Machine

-----------------------------------------------------
In your virtual machine software, go to the Properties or Settings of
your test VM for this course.  There will be a section labeled "CD/DVD"
or similar.  In that section, choose the option to mount an .ISO file,
then browse to your hard drive and select SEC505.ISO.  You may have
copied the SEC505.ISO file to your Desktop.

Be careful not to copy the Windows Server installation DVD/ISO into
the C:\SANS folder of your VM.  If you see folders named "boot", "efi", 
"sources" or "support", then this is not correct, these folders are from
the Windows Server installation media.  Delete all these and try again.

The correct folders will be named "Day1-PowerShell", "Day2-*", etc. and 
there will be a script named "SEC505-Setup-Script.ps1" in the root
folder too.


