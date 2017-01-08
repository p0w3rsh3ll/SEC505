
$ErrorActionPreference = "Continue"
dir c:\ ; nosuch-cmdlet ; dir c:\

& {
   $ErrorActionPreference = "Stop"
   dir c:\ ; nosuch-cmdlet ; dir c:\
}

# Notice that the following lines still execute:

$ErrorActionPreference        #Unchanged, it's still "Continue".
dir c:\ ; nosuch-cmdlet ; dir c:\  


