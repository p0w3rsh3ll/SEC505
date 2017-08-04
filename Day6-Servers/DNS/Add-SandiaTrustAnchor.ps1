# If your DNS server has Internet access (and it doesn't while still attending the SANS course) then 
# run the following commands if you wish to add the DNSSEC trust anchor keys for SANDIA.GOV.  This 
# action will require SANDIA.GOV records to be signed with DNSSEC, hence, query "www.sandia.gov", 
# confirm that it works, then examine the Cached Lookups on your DNS server to see the related
# DNSSEC records now cached in memory.


Add-DnsServerTrustAnchor -Name sandia.gov -CryptoAlgorithm RsaSha1NSec3 -DigestType Sha1 -Digest 3ca461ff5496bc72a772056489d944621eda774e -KeyTag 20739 

Add-DnsServerTrustAnchor -Name sandia.gov -CryptoAlgorithm RsaSha1NSec3 -DigestType Sha256 -Digest 0c5f4cdff8824665acd1d8a132951b193c59fa7fe6cf7b1f82484c25b410cdc6 -KeyTag 20739 

Add-DnsServerTrustAnchor -Name sandia.gov -CryptoAlgorithm RsaSha1NSec3 -DigestType Sha1 -Digest e33b4526cecf2a1b7c733d645b30cd5c912d9538 -KeyTag 36033

Add-DnsServerTrustAnchor -Name sandia.gov -CryptoAlgorithm RsaSha1NSec3 -DigestType Sha256 -Digest 4677626abe69fd1d8dd8e5de10533d2b264a91a7bf1ab3a6bffc4c408a3752ff -KeyTag 36033 

