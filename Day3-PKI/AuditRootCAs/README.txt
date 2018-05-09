*******************************************
 Background 
*******************************************
Hackers and malware can inject fake trusted root Certification Authority (CA) certificates into victim computers.  This can trick victim computers and users into trusting bad code signatures, bad SSL web sites, bad e-mail signatures, and anything else which depends on certificates or PKI.



*******************************************
 Partial Solution 
*******************************************
The following URL is where Microsoft periodically publishes the hashes of their own root CA certificates and the certificates of third-party companies that participate in Microsoft's Root Certification Program:

    http://social.technet.microsoft.com/wiki/contents/articles/3281.introduction-to-the-microsoft-root-certificate-program.aspx

Run the Get-MicrosoftRootCaList.ps1 script to extract the hashes from Microsoft's list.

Apple describes their root CA certification program and publishes a list of trusted CAs here, but note that not every certificate on the list includes the hash of that cert:

	http://www.apple.com/certificateauthority/ca_program.html
	http://support.apple.com/kb/HT5012

Here is a similar list from Mozilla for their products, such as the Firefox browser:

	http://www.mozilla.org/en-US/about/governance/policies/security-group/certs/included/

I was unable to locate Google's list of trusted CAs, but it's possible to extract the list of root CAs from the Chrome browser (Advanced Settings > Manage Certificates > Trusted Root Certification Authorities tab > highlight every cert > Export to a file in any format, then import into an empty certificates container in Windows, then do a listing of that container in PowerShell).

Once you have a list of trustworthy root CA hashes from some source or another, add to this list the SHA1 hashes of any other root CAs you choose to trust, such as your own CA, third-party companies, the US Department of Defense, etc.  The list is just a simple text file of SHA1 hashes.  Feel free to remove the hashes of any CAs you do not want to trust too.

Keep this text file in a protected shared folder on the network which grants Authenticated Users read-only access. Periodically update the file with any new hashes, remove hashes for root CA certificates which have been compromised, and confirm that the file has not been maliciously altered.  Use NTFS auditing to track attempted changes too.



*******************************************
 Audit-TrustedRootCA.ps1 Script
*******************************************
This script will compare the list of CA hashes in the reference file from the shared folder against the list of currently-trusted root CA certificates for the user and computer running the script.  The output is a CSV text file, which can be saved to a shared folder, whose file name indicates the name of the computer, the name of the user, and a timestamp, e.g., LAPTOP47.Administrator.634890196060064770.csv.  The CSV file contains the hashes and names of any root CA certificates trusted by the user and/or computer which are NOT in the list of reference certificates.  The script also writes to the Application event log (Event ID = 9017, Source = RootCertificateAudit).  

The script can be distributed through Group Policy as a logon/startup script, scheduled job or executed through PowerShell remoting.  Don't forget to change the default execution policy for PowerShell too.  The user account under which the script runs will also need read access to the file of reference hashes and also write access to the folder where the output CSV file will be created.  The -OutputPath parameter should take a UNC network path to a shared folder to consolidate the readings from many machines.  A Distributed File System (DFS) share can be used for scalability.  

The script is more-or-less a skeleton script to help you get started.  It's pretty simple when you examine the code.  Feel free to add error handling, logging, security, etc.

Once you've gathered the CSV output files from your desired computers, review any files whose size is larger than zero, i.e., files which indicate the presence of suspicious root CA certificates.



*******************************************
 Threats and Recommendations
*******************************************
Attackers may try to delete or corrupt the existing CSV files to prevent access.  It's best to store the files in a shared folder whose NTFS permissions only allow the following permissions:

    Principal: Authenticated Users
    Apply to: This folder, subfolders and files
        Allow: Full Control
        Deny: Delete subfolders and files
        Deny: Delete
        Deny: Change permissions
        Deny: Take ownership
        Deny: Create folders/append data

    Principal: Authenticated Users
    Apply to: Files only
        Deny: Create files/write data

The trusted administrator(s) can be granted Full Control to the archive files, certificates, and scripts as needed of course. 



*******************************************
Caveats & Legal Disclaimers
*******************************************
The script is free and in the public domain, you may use it for any purpose whatsoever without restriction. However, that being said...

THIS SCRIPT IS PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF ANY SUCH DAMAGE. IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF LIABILITY, THEN DO NOT DOWNLOAD OR USE THE SCRIPT. NO TECHNICAL SUPPORT WILL BE PROVIDED.


