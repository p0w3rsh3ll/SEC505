# Function to enable NTFS compression on a file.
# Returns $true if file gets (or already is) compressed; $false otherwise.

Param ( $FilePath )


function Compress-NtfsFile ( $FilePath )
{
    # Get full path to file as a string:
    [String] $FilePath = @(dir $FilePath)[0].FullName

    # Return $true if the file is already compressed:
    if (((Get-Item -LiteralPath $FilePath).Attributes -band [System.IO.FileAttributes]::Compressed) -eq 2048){ return $True } 
    
    # WMI needs double backslashes for the path string:
    $FilePath = $FilePath.Replace('\','\\')
    $CimFile = Get-WmiObject -Query ("SELECT * FROM CIM_DataFile WHERE Name='" + $FilePath + "'")
    $Return = $CimFile.Compress() 

    # Output $true if WMI operation returned 0, or $false otherwise:
    if ($Return.ReturnValue -eq 0) { $True } else { $False } 
}


Compress-NtfsFile -FilePath $FilePath

