# This is just an example of what could be done with a 
# startup script or script pushed out as a scheduled task.
# The real script would be written more carefully...


$ProcessesToStop = @("mspaint","charmap","baddierootkit","hacktool") 

While ($true)
{
    $ProcessesToStop | ForEach { Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue } 
    Start-Sleep -Seconds 60
}




