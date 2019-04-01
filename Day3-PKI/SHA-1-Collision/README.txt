The SHA-1 hashing algorithm was deprecated by NIST in 2011.

This folder contains two PDF files with different contents
but identical SHA-1 hashes.  Their MD5 and SHA-256 hashes
are different.  Viewing the PDF files shows different colors.
Both PDF files are the same size.  

    Get-FileHash -Path .\shattered-*.pdf -Algorithm SHA1 

    Get-FileHash -Path .\shattered-*.pdf -Algorithm SHA256

For more information, visit http://shattered.io.

Producing these PDF files required over 9 quadrillion SHA1 
computations in 2017.  This took the equivalent processing 
power as 6,500 years of single-CPU computations and 110 years 
of single-GPU computations at the time.  However, as cloud 
provider services become cheaper and faster, attacks against 
SHA-1 signatures will become affordable for more adversaries. 


