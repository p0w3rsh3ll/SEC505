################################################################################
# The following command will add the DNSSEC root zone trust anchor information
# on Server 2012 and later.  Confirm that this information is still current at:
#      https://data.iana.org/root-anchors/root-anchors.xml
# WARNING: THIS WILL REQUIRE DNSSEC FOR EVERYTHING!  MOST QUERIES WILL FAIL!
################################################################################

# Manually import a couple modules related to DNS, not only for this
# script, but for the other labs to follow:
Import-Module -Name DnsClient -ErrorAction SilentlyContinue
Import-Module -Name DnsServer -ErrorAction SilentlyContinue


# Add DNSSEC root zone trust anchor data on Server 2012 (not R2, 2016, or later):
Add-DnsServerTrustAnchor -Name "." -CryptoAlgorithm RsaSha256 -Digest 49AAC11D7B6F6446702E54A1607371607A1A41855200FD2CE1CDDE32F24E8FB5 -DigestType Sha256 -KeyTag 19036 
Add-DnsServerTrustAnchor -Name "." -CryptoAlgorithm RsaSha256 -Digest E06D44B80B8F1D39A95C0B0D7C65D08458E880409BBC683457104237C7F8EC8D -DigestType Sha256 -KeyTag 20326 


# On Server 2012 R2, 2016, and later, however, it is much simpler:
Add-DnsServerTrustAnchor -Root




