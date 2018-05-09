
# To see a list of all local event logs:

get-winevent -listlog *



# To see a list logs that begin with "s" on the computer named "localhost":

get-winevent -listlog s* -computername "localhost"



# To save the event log data to an array named $logdata:

$logdata = get-winevent -logname system



# To show only the last 3 events from the security log:

get-winevent -logname security -maxevents 3 | select *



# To get the last 20 events from each of the three classic logs:

$events  = get-winevent -logname system      -maxevents 20
$events += get-winevent -logname application -maxevents 20
$events += get-winevent -logname security    -maxevents 20

$events | sort-object -property TimeCreated | 
format-table TimeCreated,ID,LevelDisplayName,Message -auto



# To use an XML query constructed from Event Viewer to show just Critical, Error and
# Warning events from the System log in the last 24 hours:

$FromEventViewer = @'
<QueryList>
    <Query Id="0" Path="System">
       <Select Path="System">*[System[(Level=1 or Level=2 or Level=3) and TimeCreated[timediff(@SystemTime) &lt;= 86400000]]]</Select>
    </Query>
</QueryList>
'@

get-winevent -FilterXML $FromEventViewer |
select-object MachineName,LogName,Id,TimeCreated |
export-csv -path .\searchresults.csv








####################################################################
# Extra Examples
####################################################################

# To only show the 10 most recent event ID 4624 from the Security log:
# (Note: Cannot use wildcards in FilterHashTable values.)

get-winevent -filterhashtable @{LogName="Security"; ID=4624} -MaxEvents 10



# To only show Security log events between five and three days ago:

$Day5Ago = (get-date).AddDays(-5)
$Day3Ago = (get-date).AddDays(-3)
get-winevent -filterhashtable @{LogName="Security"; StartTime=$Day5Ago; EndTime=$Day3Ago} 



# To only show 1000 recent Critical, Error and Warning events from the Application log:
#    Level 1 = Critical
#    Level 2 = Error 
#    Level 3 = Warning
#    Level 4 = Information
#    Level 5 = Verbose

get-winevent -FilterHashtable @{LogName="Application"; Level=1,2,3} -MaxEvents 1000



# To only show 10 recent Warning events from the System log on a remote computer:

get-winevent -FilterHashtable @{LogName="System"; Level=3} -MaxEvents 10 -ComputerName "localhost"



# To list the last 10 user accounts created:

$events  = get-winevent -FilterHashtable @{LogName="Security"; ID=4720} -ErrorAction SilentlyContinue
$events += get-winevent -FilterHashtable @{LogName="Security"; ID=624} -ErrorAction SilentlyContinue
$events | select-object -last 10



# To see the details of just the Security log:

get-winevent -listlog security | select *




