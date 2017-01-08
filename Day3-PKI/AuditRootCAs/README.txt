*******************************************
 Background 
*******************************************
Hackers and malware can inject fake trusted root Certification Authority (CA) certificates into victim computers.  This can trick victim computers and users into trusting bad code signatures, bad SSL web sites, bad e-mail signatures, and anything else which depends on certificates or PKI.



*******************************************
 Partial Solution 
*******************************************
The following URL is where Microsoft periodically releases a PDF file with the hashes of their own root CA certificates and the certificates of third-party companies that participate in Microsoft's Root Certification Program:

    http://social.technet.microsoft.com/wiki/contents/articles/3281.introduction-to-the-microsoft-root-certificate-program.aspx

Unfortunately, you'll have to extract the hashes from the PDF yourself, e.g., save as a spreadsheet or text file, pull out the hashes, and remove the space characters.  This folder contains a text file of these hashes, but please note the date in the file name, the list might be out of date.

Once you have Microsoft's latest list of trustworthy root CA hashes, add to this list the SHA1 hashes of any other root CAs you choose to trust, such as your own CA, third-party companies, the US Department of Defense, etc.  The list will be a simple text file of SHA1 hashes.

Keep this text file in a protected shared folder on the network which grants Authenticated Users read-only access. Periodically update the file with any new hashes, remove hashes for root CA certificates which have been compromised, and confirm that the file has not been maliciously altered.  Use NTFS auditing to track attempted changes too.



*******************************************
 Audit-TrustedRootCA.ps1 Script
*******************************************
This script will compare the list of CA hashes in the reference file from the shared folder against the list of currently-trusted root CA certificates for the user and computer running the script.  The output is a CSV text file, which can be saved to a shared folder, whose file name indicates the name of the computer, the name of the user, and a timestamp, e.g., LAPTOP47.Administrator.634890196060064770.csv.  The CSV file contains the hashes and names of any root CA certificates trusted by the user and/or computer which are NOT on the list of reference certificates.  The script also writes to the Application event log (Event ID = 9017, Source = RootCertificateAudit).  

The script can be distributed as a logon script through Group Policy as long as PowerShell 2.0 or later is installed on the client.  The client user will also need read access to the file of reference hashes and write access to the folder where the output CSV file will be created.

The script is more-or-less a skeleton script to help get started.  It's pretty simple.  Feel free to add code for error handling, logging, security, etc.

Once you've gathered the CSV output files from your desired computers, review any files with a non-zero size indicating the presense of suspicious root CA certificates.



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




