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


# Add DNSSEC root zone trust anchor data on Server 2012:
Add-DnsServerTrustAnchor -Name . -CryptoAlgorithm RsaSha256 -Digest 49AAC11D7B6F6446702E54A1607371607A1A41855200FD2CE1CDDE32F24E8FB5 -DigestType Sha256 -KeyTag 19036 


# On Server 2012 R2 and later, however, it is simpler:
Add-DnsServerTrustAnchor -Root




