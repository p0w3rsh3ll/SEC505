

# To create an associative array where the two-letter U.S. state code is 
# associated with the full name of the state (the two-letter code is the key, 
# the full name is the value):

$States = @{ "CA" = "California" ; 
             "FL" = "Florida"    ; 
             "VA" = "Virginia"   ;  
             "MD" = "Maryland"    
           }

# To dump the entire associative array in tabular format, or just show the keys, 
# or just show the values, or to test whether a particular key or value exists:

$States                                 # Dump entire hash array.
$States.Keys                            # Dump keys only.
$States.Values                          # Dump values only.
$States.ContainsKey("VA")               # Test if key exists.
$States.ContainsValue("Virginia")       # Test if value exists.

# To access the data associated with a key you can use either dot-notation:

$States.CA

# To add a new key-value pair, to remove a pair, or to remove everything in the array:

$States.Add("CO", "Colorado")
$States.Cemove("CO")
$States.Clear()


