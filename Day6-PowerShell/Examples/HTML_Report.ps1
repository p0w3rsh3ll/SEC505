get-process | 
convertto-html -property Name,Path,ID `
-title "Process Report" `
-head "<h1>Process Report</h1>" `
-body "<h2>Report Was Run: $(get-date) </h2><hr>" | 
out-file -filepath $env:temp\report.html

invoke-item $env:temp\report.html

