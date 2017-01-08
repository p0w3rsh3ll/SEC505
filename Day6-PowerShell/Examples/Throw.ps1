

& {
	$ErrorActionPreference = "stop"
    throw "Something bad has happened!"
    dir c:\

	trap { "Exception!!!" 
            $_ 
            continue
          }
  }




# A common use for Throw is to inform coders that certain script or 
# function parameters are mandatory.  In the following snippet, if the 
# $name parameter is not passed into the function, an exception is 
# thrown and the coder is given a gentle reminder:

function repeat-name ($name = $(throw "Enter a name, fool!") ) 
{
	"$name " * 20 
}


