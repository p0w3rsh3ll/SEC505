
$ErrorActionPreference = "Continue"
dir c:\ ; nosuch-cmdlet ; dir c:\

$ErrorActionPreference = "Stop"
dir c:\ ; nosuch-cmdlet ; dir c:\

$ErrorActionPreference = "Continue"




# To experiment with the  erroraction parameter and the non-existent service "444":

get-service 444 -erroraction Continue ; dir c:\
get-service 444 -erroraction Stop ; dir c:\
get-service 444 -erroraction SilentlyContinue ; dir c:\

 
