

& {
	"Our preference is to " + $ErrorActionPreference
    nosuch-cmdlet   #Causes an exception.
    dir c:\

	trap { "Exception!!!" }
  }





& {
	$ErrorActionPreference = "stop"
    nosuch-cmdlet   #Causes an exception.
    dir c:\         #Still executes anyway because of Continue.

	trap { 
           "Exception!!!" 
           $_ 
           Continue
         }
  }




& {
	"Our preference is to " + $ErrorActionPreference
    nosuch-cmdlet   #Causes an exception.
    dir c:\         #Does not execute because of Break.


	trap { 
           "Exception!!!" 
           $_ 
           Break
         }
  }



