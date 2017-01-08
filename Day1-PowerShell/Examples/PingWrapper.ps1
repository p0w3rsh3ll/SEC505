# To pass arguments into the named parameters
# of a script, use the Param keyword, just
# like with a function.
#
# Comments can come first, like these lines,
# and so can blank lines, but the Param keyword
# must be the first executable line of the script.

param ($computer = "localhost")

function pingwrapper ($ip) { ping.exe $ip }

pingwrapper -ip $computer 


