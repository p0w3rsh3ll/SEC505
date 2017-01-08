##############################################################################
#  Script: Translate.ps1
#    Date: 18.Jul.2014
# Version: 2.0
#  Author: Jason Fossen, Enclave Consulting LLC (www.sans.org)
# Purpose: Demos piping into functions and scripts.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

Param ($Language = "German")



Function Translate ([String] $Language = "German") 
{
    Process
    {
	    $word = $_
	    
        Switch ($Language) 
        {
		    'German'  {"Das " + $word + "en!"    }
		    'French'  {"La "  + $word + "ette..."}
		    'Greek'   {"Oi "  + $word + "tai;"   }
	        'English' {"The " + $word + ", dude!"}
	    }
    }
}


$input | Translate -Language $Language







function auf-deutsch 
{
    Process { "Das " + $_ + "en!" } 
}

 



function Pipe-BeginningEnding
{
    Begin   { "Run only once when the function is called" }
    Process { "For each piped object: " + $_ }
    End     { "Run only once when the function finishes" }  
}





function thewayofdata ($p) {
    $p
    $args[0]
    $args[1]
    foreach ($x in $input) { $x }
}

#   1,2,3 | thewayofdata 4 5 -p 6









# By the way, there is an older way to process piped objects
# that still works, but it has been deprecated in favor of
# advanced functions.  The technique is to use the "filter"
# keyword in place of "function".  Think of it as an
# implicit way to include a "Process {...}" block.

filter auf-deutsch {
    "Das " + $_ + "en!"
}


filter translate ([String] $into = "German") {
	$word = $_
	switch ($into) {
		French  {"La "  + $word + "ette..."}
		Greek   {"Oi "  + $word + "tai;"   }
		German  {"Das " + $word + "en!"    }
	    English {"The " + $word + ", dude!"}
	}
}




