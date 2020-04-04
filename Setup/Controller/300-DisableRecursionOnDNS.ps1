###############################################################################
#
#"[+] Disabling recursion on the DNS server..."
# 
###############################################################################

Set-DnsServerRecursion -Enable $False -ErrorAction SilentlyContinue 

