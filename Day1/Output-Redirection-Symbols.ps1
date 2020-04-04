# PowerShell supports the following redirection symbols:

    >       #overwrite file
    >>      #append to file
    >&      #combine pipeline streams, e.g., 2>&1 

# Different source streams can be redirected (v = Version of PowerShell):

    1>      #success/normal output v1
    2>      #errors v1
    3>      #warnings v3
    4>      #verbose v3
    5>      #debug v3
    6>      #information/progress v5
    *>      #all of the above v5

# These two commands do the same thing:

    dir  > file.txt
    dir 1> file.txt

# The input redirection symbol (<) is not used in PowerShell:

    <       #Not supported, use "Get-Content | <Command>" instead

# Under the hood, > is like an alias for "| Out-File", but faster:

    dir > file.txt
    dir | Out-File -FilePath file.txt 

# Suppress one or all streams, losing the data:

    dir  > $null
    dir 2> $null
    dir *> $null

# Combine the error stream into the success stream, capture both to $x:

    $x = dir 2>&1 

# Combine all streams and append to a file.txt:

    dir *>> file.txt

# The various output streams of a command can be captured to different 
# variables. If nothing is sent to a stream, the variable will be empty.

    Get-Item -Path .\FileExists.txt,.\NoSuchFile.txt -OutVariable ss `
             -ErrorVariable rr -WarningVariable ww -InformationVariable ii `
             -PipelineVariable pp *>$null 

    $ss  # 1>   success/normal = FileExists.txt object
    $rr  # 2>   errors = NoSuchFile.txt exception
    $ww  # 3>   warnings = $null 
    $ii  # 6>   information/progress = $null 
    $pp  # holds the last item to be piped out to the next command

# $pp can only be access later in a non-blocking pipeline, e.g., no Sort-Object, no Group-Object.
# $rr is a structured error object, not flat text or a plain error code number.  
# The "*>$null" above was not required, and the other variables like $rr still get copies.

