#.SYNOPSIS
#   Show the questionable parentage of an object.
#
#.DESCRIPTION
#   Lists the full names of the types/classes of the piped
#   in object, starting with its top or most specific type
#   then the base types recursively until System.Object last.
#
#.NOTES
#   TODO: actually finish the thing...
#   TODO: add more functions for gm -view *

function Show-BaseTypeTree
{
    PROCESS  
    {
        $cmd = '$_.GetType()'
        Do {
            [String] $output = Invoke-Expression ($cmd + ".FullName")
            if ($output.trim().length -gt 0){ $output }
            $cmd += ".BaseType"
        } Until ($output.length -lt 3) 
    }
} 

