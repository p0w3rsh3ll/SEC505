(get-service spooler).status
(get-service spooler).stop()
(get-service spooler).start()

# To get today's date and time in a System.DateTime object, add three days to the current date, then show the result:

(get-date).AddDays(3)


# To get the count of processes using over 50MB of workingset memory:

(get-process | where {$_.workingset -gt 50MB}).count

