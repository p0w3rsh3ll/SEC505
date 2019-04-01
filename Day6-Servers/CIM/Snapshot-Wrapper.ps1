<# ###########################################################

This is a simple wrapper for Snapshot.ps1.  Use this to
delete prior snapshots older than 21 days (or whatever
number you choose) and then create a new snapshot.
Edit the $SnapshotDir variable to change the path; the
snapshot.ps1 script must be in this folder.  Edit the
shared folder path at the bottom, if you want to move the
zip to a centralized locations for all snapshot zips.
To keep it simple, this script includes no error handling
or logging, so these should be added in real life.

########################################################### #>

# Local folder where the Snapshot.ps1 script is placed and
# where the actual snapshot data folders will be kept:
$SnapshotDir = 'C:\Data\Snapshots'


# Make that directory the current:
cd $SnapshotDir


# Get a datetime object representing 21 days ago, or
# edit the number to change the number of days:
$DaysAgo = (get-date).AddDays(-21)


# Delete any old zip files:
dir -Path (Join-Path -Path $SnapshotDir -ChildPath '*.zip') |
where { $_.LastWriteTime -lt $DaysAgo } |
Where { $_.Name -match '^.+\-20\d\d\-\d+\-\d+\-\d+\-\d+\.zip$' } |
del -force 


# Create a new snapshot folder in current dir:
.\Snapshot.ps1 -Verbose


# Get all snapshot folders in current directory:
$snapfolders = dir -Directory | Where { $_.Name -match '^.+\-20\d\d\-\d+\-\d+\-\d+\-\d+$' }


# Compress each folder into a zip with the same name:
$snapfolders | foreach { Compress-Archive -Path $_.FullName -DestinationPath $_.Name -CompressionLevel Optimal } 


# Delete any snapshot folders:
$snapfolders | del -Recurse -Force 


# Move all zips into a centralized share:
# dir *.zip | Move-Item -Force -Destination \\server\share 



 