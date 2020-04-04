# Comments are OK both outside and inside the hashtable.

@{
    # Use comments to help your co-workers to
    # understand your settings and code.
    IPaddress 	= "10.1.1.1"
    SubnetMask 	= "255.255.0.0"
    Gateway 	= "10.1.9.9"

    # Semicolons are optional, unless you have two 
    # or more items on one line:
    DnsServer1 	= "10.1.1.10"; DnsServer2 = "10.1.1.20"

    Domain 	= "testing.local"; 

    # The $Top hashtable will have the above keys,
    # but you can add a key (below) which is itself
    # another hashtable:
    NestedHashTable = @{ UserName = "Amy" ; Password = "P@ssword" } 
}


# The syntax for accessing the above nested hashtable:
#   $Top.NestedHashTable.UserName
#   $Top.NestedHashTable.Password
#
# Yikes, a plaintext password in a config file!! 
# Maybe encrypt this file with Protect-CmsMessage...
