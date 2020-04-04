######################################################################
#
# A variety of sample commands for managing log file sizes, retention
# settings, and log file paths.
#
######################################################################


# See the EVTX event log files themselves:
dir $env:SystemRoot\System32\Winevt\Logs\


# List the archived EVTX log files, if any:
dir $env:SystemRoot\System32\Winevt\Logs\Archive*.evtx


# Delete any archived EVTX log files:
dir $env:SystemRoot\System32\Winevt\Logs\Archive*.evtx | Remove-Item


# Show essential properties of the System, Security and Application logs:
Get-WinEvent -ListLog System,Security,Application | Select-Object LogName,LogMode,MaximumSizeInBytes,LogFilePath


# Get logs which exist, but which are not enabled:
Get-WinEvent -ListLog * | Where { $_.IsEnabled -eq $False } 


# Set the System log to overwrite events as need, but only
# if the event to be deleted is more than 10 days old:
Limit-EventLog -LogName System -OverflowAction OverwriteOlder -RetentionDays 10


# Set the maximum size of the System log to 40MB and allow
# any older events to be overwritten as needed:
Limit-EventLog -LogName System -OverflowAction OverwriteAsNeeded -MaximumSize 40MB


# Try to find logs with configuration problems, such as invalid log file paths,
# by coaxing error messages to be displayed by Get-WinEvent:
Get-WinEvent -ListLog * -ErrorAction Continue | Out-Null


# Save the names and full paths to all EVTX log files to a CSV file:
Get-WinEvent -ListLog * |
  Select-Object -Property LogName,LogFilePath |
    Export-Csv -Path LogPaths.csv




#####################################################################
# A function to change the folder where an event log is stored,
# while keeping the original name of the log file itself.
#####################################################################

function Set-EventLogFileFolderPath 
{
<#
.Synopsis
    Changes the folder where a Windows event log file is stored.
.Description
    Changes the folder where an event log is stored. The new destination
    folder must already exist.  The path to the folder may be defined
    with an environment variable inside percentage symbols, such as
    was used with CMD batch scripts, but not with $env:VARIABLE syntax
    used normally in PowerShell.
.Parameter LogName
    The name of the event log as shown in its LogName property. The
    event log object itself may be piped in instead. Multiple log
    names or log objects from Get-WinEvent may be piped in.  
.Parameter NewFolder
    The path to the new folder as a LITERAL string. The path may
    use environment variables such as %SystemRoot%, but you CANNOT
    use the $env:SystemRoot syntax for this! Use a single-quoted LITERAL
    string with the percentage symbols because the string will be
    written to a REG_EXPAND_SZ registry value as is.  You may use an
    explicit full path with no variables too.  
.Example
    Get-WinEvent -ListLog 'Microsoft-Windows-RetailDemo/Admin' | Set-EventLogFileFolderPath -NewFolder 'C:\NewDir' -Verbose 
.Notes
    Legal: Script provided "AS IS" without warranties or guarantees of any kind.
    Author: Enclave Consulting LLC.
    Redistribution: Public Domain, no rights reserved.
#>

    Param
    ( 
      [Parameter(Mandatory=$true,ValueFromPipeline=$true)] $LogName,
      [Parameter(Mandatory=$true,ValueFromPipeline=$false)][ValidateNotNullOrEmpty()] $NewFolder
    )

    BEGIN 
    {
        #Check existence of $NewFolder path even if it contains percentage symbols:
        $ExpandedNewFolder = [System.Environment]::ExpandEnvironmentVariables($NewFolder)
        if (-not (Test-Path -PathType Container -Path $ExpandedNewFolder))
        { 
            throw 'You must enter a $NewFolder path to a folder that currently exists.'
            return 
        }
        
        #Test-Path will succeed when using the $env:VARIABLE syntax to specify the path, but
        #Windows cannot accept $env:VARIABLE syntax when setting the REG_EXPAND_SZ value
        #in the registry for the event log file path. Function *must* fail if $env: is used!
        if ($NewFolder -like '*$env:*')
        { 
            throw 'You cannot use $env:VARIABLE syntax for the $NewFolder! Use percentage symbols for the environment variable and make the argument a literal string.'
            return
        } 

        #WARNING: If the registry is updated with a folder path that does not exist, either
        #with this script or updated by any other means, Get-WinEvent -ListLog LOG will fail!
        #That means this script will fail to update the path too and the registry will have
        #to be fixed by directly editing the File value in the key for each log affected with
        #either regedit.exe or Event Viewer. To list which logs are failing this way, run: 
        #  Get-WinEvent -ListLog * -ErrorAction Continue | Out-Null  

        #Count of log paths updated for Write-Verbose:
        $counter = 0 
    } 

    PROCESS
    {
        #Get the event log object, if only the string of the log name is given:
        if ($LogName.GetType().FullName -eq 'System.String')
        { $LogName = Get-WinEvent -ListLog $LogName -ErrorAction Stop } 
    
        #Confirm that we have a healthy event log object:
        if ($LogName.GetType().FullName -ne 'System.Diagnostics.Eventing.Reader.EventLogConfiguration')
        { throw 'You must pipe in an event log object of type EventLogConfiguration.' ; return } 

        #Extract just the EVTX filename from the current logfile path:
        Write-Verbose -Message ("Name of target event log is " + $LogName.LogName)
        Write-Verbose -Message ("Current log file path is " + $LogName.LogFilePath) 
        $LogFilePath = ($LogName.LogFilePath -split '\\')[-1] 

        #Sanity check the $LogFilePath:
        if ($LogFilePath -notmatch '\.evtx$')
        { 
            throw ("This log file name does not end with *.evtx: " + $LogFilePath)
            return
        }

        #Construct new full path to the event log EVTX file and allow Join-Path
        #to expand any $env:VARIABLE strings it finds in case one has snuck
        #through somehow: better to have a valid explicit path than a path
        #which uses $env:VARIABLE syntax, which will break things:
        Write-Verbose -Message ("Extracted EVTX log file name is " + $LogFilePath)
        $JoinedFolder = Join-Path -Path $NewFolder -ChildPath $LogFilePath 
        Write-Verbose -Message "New log file path is $JoinedFolder"

        #Sanity check the $JoinedFolder, it must start with '%' or '<letter>:\'
        if ($JoinedFolder -notmatch '^[a-z]\:\\|^\%')
        { 
            throw ("This log file path does not start with a valid folder path " + $JoinedFolder)
            return
        }

        #Set the new full path on the log:
        $LogName.LogFilePath = $JoinedFolder
        $LogName.SaveChanges() 
        if ($?){ Write-Verbose -Message "No errors on call to SaveChanges()."}

        #Try to activate change immediately, but only if log is already enabled:
        if ($LogName.IsEnabled)
        { 
            Write-Verbose -Message "Log already enabled, activating change now."
            $LogName.IsEnabled = $false
            $LogName.SaveChanges()
            # Will get an error here if the log file path is invalid.
            $LogName.IsEnabled = $true
            $LogName.SaveChanges()
        }
        else
        { Write-Verbose -Message "Log currently not enabled." } 

        Write-Verbose -Message '-------------------------------------------'
        $counter++ 
    }#PROCESS

    END { Write-Verbose -Message ("Logs Processed: " + $counter) } 
}





