

# To create an associative array where the two-letter U.S. state code is associated with the full name of the state (the two-letter code is the key, the full name is the value):

$states = @{ "CA" = "California" ; 
             "FL" = "Florida"    ; 
             "VA" = "Virginia"   ;  
             "MD" = "Maryland"    
           }

# To dump the entire associative array in tabular format, or just show the keys, or just show the values, or to test whether a particular key or value exists:

$states                                 # Dump entire hash array.
$states.keys                            # Dump keys only.
$states.values                          # Dump values only.
$states.containskey("VA")               # Test if key exists.
$states.containsvalue("Virginia")       # Test if value exists.

# To access the data associated with a key you can use either dot-notation:

$states.CA

# To add a new key-value pair, to remove a pair, or to remove everything in the array:

$states.add("CO", "Colorado")
$states.remove("CO")
$states.clear()


 
