# If your DNS server has Internet access (and it doesn't while still attending the SANS course) then 
# run the following commands if you wish to add the DNSSEC trust anchor keys for POSTEO.NET 
# and POSTEO.DE.  This action will require these records to be signed with DNSSEC.  


Add-DnsServerTrustAnchor -Name posteo.net -CryptoAlgorithm RsaSha256 -DigestType Sha256 -Digest 2bc5229fcf1eb92a7f3565e4d469c9eaf09e49a6b5250cb111bcb5645af0d58c -KeyTag 24136  

Add-DnsServerTrustAnchor -Name posteo.de  -CryptoAlgorithm RsaSha256 -DigestType Sha256 -Digest d3d66d1fb310d448224f2c2e8c4f61f55a73674659ca6bf43edac921ee40428f -KeyTag 53881   




