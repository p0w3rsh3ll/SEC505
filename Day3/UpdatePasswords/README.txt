**************************************
 Background:
**************************************
The passwords of local administrative accounts should be changed regularly and these passwords should be different from one computer to the next.  But how can this been done securely and conveniently?  How can this be done for free with PowerShell?  

The scripts in this project demonstrate how it can be done.  The scripts are intended to be relatively easy to understand and modify (you don't have to be a PowerShell guru, only intermediate skills required).  Error checking was kept to a minimum to reduce clutter, but should be adequate for troubleshooting.  All scripts are in the public domain.  A sample certificate (CER) and private key file (PFX) are included for testing, but in real life you must use your own keys.  



**************************************
 Solution:
**************************************
A trusted administrator should obtain a certificate and private key, then export that certificate to a .CER file into a shared folder (\\server\share\cert.cer).

Copy the Update-PasswordArchive.ps1 script into that shared folder (\\server\share).

Using Group Policy, SCCM, a third-party EMS, SCHTASKS.EXE or some other technique, create a scheduled job on every computer that runs once per week (or every night) under Local System context that executes the following command: "powershell.exe \\server\share\update-passwordarchive.ps1 -certificatefilepath \\server\share\cert.cer -passwordarchivepath \\server\share -localusername administrator".  This resets the password on the local Administrator account, or whatever account is specified, with a 15-25 character, random complex password.  The password is encrypted in memory with the public key of the certificate (cert.cer) and saved to an archive file to the specified share (\\server\share).  

When a password for a computer (laptop47) needs to be recovered, the trusted administrator should run from their own local computer the following PowerShell script: "recover-passwordarchive.ps1 -passwordarchivepath \\server\share -computername laptop47 -username helpdesk".  This downloads the necessary encrypted files and decrypts them locally in memory using the private key of the administrator, displaying the plaintext password within PowerShell.



**************************************
 Requirements:
**************************************
PowerShell 2.0 or later must be installed on both the computer with the local user account whose password is to be reset and also on the administrators' computers who will recover these passwords in plaintext.

The Update-PasswordArchive.ps1 script, which resets the password, must run with administrative or Local System privileges.

Operating system must be at least Windows XP SP3, Server 2003 SP2, or later.

The private key for the certificate cannot be managed by a Cryptography Next Generation (CNG) key storage provider; instead, please use the "Microsoft Enhanced Cryptographic Provider", as specified in the template used to create the certificate, not the "Microsoft Software Key Storage Provider" in that template.

Also, the certificate you use must have the "Key Encipherment" purpose in the "Key Usage" list in the properties of that certificate (see the Details tab).  You get this when the template for the certificate on the Certification Authority (CA) has "Encryption" listed as an allowed purpose in the properties of that template (see the Request Handling tab).  



**************************************
 Testing Examples:
**************************************
Copy the \Day4-Admins\UpdatePasswords folder to your hard drive.

Open PowerShell with administrative privileges and run this command to reset the password on the Guest account:

    .\New-SelfSignedCert.ps1

    .\PrivateKey.pfx

	.\Update-PasswordArchive.ps1 -LocalUserName Guest -CertificateFilePath .\PublicKeyCert.cer

Do a "dir" listing and you will see a new file with a very long name, similar to the following:

	MYCOMPUTER+Guest+635108515647128197+F5FF0247B0CF6A81148CE83D2EBA4A141CB095F3

If you open the file in Notepad or a hex editor, you'll see that it has been encrypted with the public key in the PublicKeyCert.cer file.  The private key for this public key has already been imported into your local user certificate store, hence, you can use your private key to extract the password from the encrypted file.  Unless hackers have stolen your private key, they will not be able to decrypt the file and obtain the password inside it.

To obtain the plaintext password, run this command:

	.\Recover-PasswordArchive.ps1 -ComputerName $env:computername -UserName Guest

The output is an object with the plaintext password and other properties, similar to this:

	ComputerName : MYCOMPUTER
	FilePath : MYCOMPUTER+Guest+635108515647128197+F5FF0247B0CF6A81148CE83D2EBA4A141CB095F3
	UserName : Guest
	TimeStamp : 2/31/2019 7:12:44 AM
	Thumbprint : F5FF0247B0CF6A81148CE83D2EBA4A141CB095F3
	Valid : True
    StatusMessage : Success
	Password : b4EAti!HiLX]QI2

The password property can now be piped into other commands or copied into the wetware clipboard through your retinas.

To see the full help for this script, run:

	get-help -full .\Update-PasswordArchive.ps1 



**************************************
 Notes:
**************************************
The password is never sent over the network in plaintext, never saved to disk in plaintext, and never exposed as a command-line argument, either when resetting the password or when recovering it later.  The new password is generated randomly in the memory of the PowerShell process running on the computer where the password is reset.  The process runs for less than a second as Local System in the background.    

Different certificates can be used at different times, as long as their private keys are available to the administrator.  When recovering a password, the correct certificate and private key will be used automatically.  A smart card can be used too.  The script has been successfully tested with the Common Access Card (CAC) used by the U.S. military and DoD.  

If the shared folder is not accessible to the computer when the scheduled job runs, the password is not reset.

If multiple administrators must be able to recover the plaintext passwords, export the relevant certificate and private key to a PFX file and import it into each administrator's local profile.  Because this is not a certificate used to uniquely identify a person or device, everyone on the help desk could have a copy of its private key (though this increases the risk of private key exposure as more copies are distributed).  

To delegate authority to different administrators over different computers, simply use different public/private key pairs.  When using Group Policy to create the scheduled job on the machines in an organizational unit, for example, any certificate can be specified, and this does not have to be the same certificate used for all machines in a domain.  The corresponding private keys can be shared with whatever subset of administrators is desired.  If the private key is on a smart card, that card can be physically protected from unauthorized admins.

The update script writes to the Application event log whenever and wherever the script is run (Source: PasswordArchive, Event ID: 9013).

The script can only be used to reset the passwords of local accounts, not domain accounts in AD.



**************************************
 Threats:
**************************************
Keep the private key for the certificate used to encrypt the password archive files secure, such as on a smart card.  This is the most important factor.  

If the private key for the certificate is compromised, create a new key pair, replace the certificate file (.CER) in the shared folder, and immediately remotely trigger the scheduled job on all machines using Group Policy, SCHTASKS.EXE or some other technique.  Once all passwords have been changed, the fact that the old private key has been compromised does not mean any current passwords are known. 

Use an RSA public key which is 2048 bits or larger.  The public key encrypts a random 256-bit Rijndael key, which encrypts the password.  Every file has a different Rijndael key.  RSA and Rijndael are used for maximum backwards compatibility (using AES explicitly in the script requires .NET Framework 3.5 or later).  

Prevent modification of the Update-PasswordArchive.ps1 script itself by digitally signing the script, enforcing script signature requirements, and using restrictive NTFS permissions.  Only allow NTFS read access to the script to those identities (computer accounts) which need to run it.  Use NTFS auditing to track changes to the script.

Attackers may try to corrupt or delete the existing password archive files to prevent access to current passwords.  Each archive file contains an encrypted SHA256 hash of the username, computername and password in that file in order to detect modified or damaged bits; the hash is checked whenever a password is recovered.  

To deter file deletions, it's best to store the certificate and archive files in a shared folder whose NTFS permissions only allow the client computer accounts the following permissions:

   Principal: Domain Computers
    Apply to: This folder, subfolders and files
       Allow: Full Control
        Deny: Delete subfolders and files
        Deny: Delete
        Deny: Change permissions
        Deny: Take ownership
        Deny: Create folders/append data

   Principal: Domain Computers
    Apply to: Files only
        Deny: Create files/write data

The trusted administrators can be granted Full Control to the archive files, certificates, and scripts as needed of course.  The above permissions are for just for Domain Computers.  

An attacker might try to generate millions of spoofed archive files and add them to the shared folder.  This is possible because the script and public key would be accessible to the attacker too.  Realistically, though, a DoS attack in which millions of new archive files are created would likely be of low value for the attacker since it would be easy to detect, easy to log the name or IP of the machine creating the new files, easy to use timestamps in the share to identify post-attack files, easy to recover from nightly or weekly backups, and the DoS attack would not allow the hacker to expand their existing powers to new machines.  Besides, the benefit to us of managing local administrative account passwords correctly far exceeds the potential negative of this sort of DoS attack.  

IPSec permissions which limit access to the SMB ports of the file server is recommended for restricting access to the SMB ports (TCP 139/445) based on group memberhips, e.g., domain computer, administrators, help desk personnel, etc.  IPSec encryption is nice too, but not the main purpose.  



**************************************
 Tips:
**************************************
The output of the Recover-PasswordArchive.ps1 script can be piped into other scripts to automate other tasks which require the plaintext password, such as executing commands, doing WMI queries, opening an RDP session, or immediately resetting the password again when finished.

When recovering a password, you can pipe the password into the built-in clip.exe utility to put the password into the clipboard, like this:

	\\controller\password-archives\Recover-PasswordArchive.ps1 `
	-PasswordArchivePath \\controller\password-archives -ComputerName laptop47 ` 
	-UserName Administrator | select-object -expandproperty password | clip.exe

Keep the number of files in the archive folder manageable by using the CleanUp-PasswordArchives.ps1 script.  Perhaps running this script as a scheduled job every two or four weeks.

To optimize the performance of the Recover-PasswordArchive.ps1 script when there are more than 100,000 files in the folder containing the password archives, disable 8.3 file name generation and strip all current 8.3 names on the volume containing that folder.  Search the Internet on "fsutil.exe 8dot3name" to see how.  

To maximize fault tolerance and scalability, use Distributed File System (DFS) shared folders across two or more servers.  With DFS and Group Policy management of the scheduled jobs, the solution can scale to very large networks.

You can also perform an immediate password update with commands wrapped in a function like the following:

    Copy-Item -Path .\PublicKeyCert.cer -Destination \\laptop47\c$ 
    Invoke-Command -ComputerName laptop47 -filepath .\Update-PasswordArchive.ps1 -argumentlist "C:\publickeycert.cer","Administrator","c:\"
    Copy-Item -Path \\laptop47\c$\laptop47+Administrator+* -Destination C:\LocalFolder
    Remove-Item -Path \\laptop47\c$\PublicKeyCert.cer
    Remove-Item -Path  \\laptop47\c$\laptop47+Administrator+*

The above Invoke-Command can be done by specifying UNC paths instead, but this requires delegation of credentials to the remote computer, which is not ideal for limiting token abuse attacks, so the certificate and archive files should be copied back-and-forth manually.  Besides, wrapped in a function, all these steps would be hidden from us anyway.

Do not use the sample certificate and private key provided with these scripts.  You must obtain your own key pair and never share your private keys with outsiders.  

To manually convert the ticks timestamp in the file name (e.g., 635093865618276588) to a human-readable date and time:

	[DateTime][Int64] 635093865618276588

To reset the NTFS LastWriteTime property of the archive files to match the ticks timestamp in the archive file names themselves:

	dir *+*+* | foreach { $_.LastWriteTime = [DateTime][Int64] $(($_.Name -split '\+')[2]) }

Shouldn't this solution use a database instead of a shared folder?  No, requiring a database would simply make the solution more complex without increasing security or scalability.  The formatting of the filenames effectively allows us to search and manipulate the files like records in a database, DFS gives us high availability and scalability, the encryption of the files can be combined with IPSec/SMB encryption, and backup/recovery of the files couldn't be simpler because they're just normal files.  Most administrators are more comfortable managing files in a shared folder than managing SQL Server or some other database management system.  

Shouldn't this solution have a web interface?  This would defeat the point of using PowerShell, namely, automation.  But it would be easy to layer a web application (or Metro/Modern app) on top of the files to have a nice GUI.



**************************************
 Legal:
**************************************
PUBLIC DOMAIN.  SCRIPTS PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
LIABILITY, THEN DELETE THESE FILES SINCE YOU ARE NOW PROHIBITED TO HAVE THEM.

