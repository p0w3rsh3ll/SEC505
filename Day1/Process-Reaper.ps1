# This is just an example of what could be done with a 
# startup script or script pushed out as a scheduled task.
# The real script would be written more carefully.


# List of process names to terminate:

$ProcessesToStop = @("mspaint","charmap","baddierootkit","hacktool") 


# This represents 24 hours from now so that the script can
# break out of its loop after one day, then optionally be
# created as a new daily scheduled task again:

$Tomorrow = (Get-Date).AddDays(1) 


# Loop until Break:
While ($True)
{
    # Is it now 24 hours later?
    if ( (Get-Date) -gt $Tomorrow ){ Break } 

    $ProcessesToStop | ForEach { Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue } 

    Start-Sleep -Seconds 60
}



