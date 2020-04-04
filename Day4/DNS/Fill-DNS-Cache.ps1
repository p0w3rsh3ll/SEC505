#########################################################
#
# This is a basic script to be scheduled to run perhaps
# every 30 minutes to ensure that certain FQDNs are
# always fresh in the cache of a DNS server. Edit the
# list of FQDNs and perhaps add more internal DNS servers.
#
#########################################################


# Don't run late at night:
$now = Get-Date
if ($now.Hour -gt 22 -or $now.Hour -lt 5){ exit } 


# Array of FQDNs to regularly resolve:
$names = @(
"antwrp.gsfc.nasa.gov.",
"www.google.com.",
"www.bing.com.",
"www.outlook.com.",
"outlook.live.com",
"www.netflix.com.",
"www.amazon.com.",
"news.google.com.",
"www.theverge.com.",
"arstechnica.com.",
"www.theregister.co.uk.",
"www.sans.org.",
"feedproxy.google.com.",
"feeds.feedburner.com.",
"feeds2.feedburner.com.",
"www.zdnet.com.",
"bigcharts.marketwatch.com.",
"stockcharts.com.",
"www.facebook.com.",
"www.microsoft.com.",
"sxp.microsoft.com.",
"blogs.msdn.com.",
"pop.1and1.com.",
"video2.timewarnercable.com.",
"watch.spectrum.net.",
"phys.org.",
"www.bloomberg.com.",
"www.fidelity.com.",
"eresearch.fidelity.com.",
"www.google-analytics.com.",
"ssl.google-analytics.com.",
"safebrowsing.google.com.",
"www.gstatic.com.",
"t0.gstatic.com.",
"t1.gstatic.com.",
"t2.gstatic.com.",
"t3.gstatic.com.",
"csi.gstatic.com.",
"clients1.google.com.",
"www.youtube.com.",
"news.google.com.",
"tweetdeck.twitter.com",
"login.live.com.",
"blu406-m.hotmail.com.",
"blogs.technet.com.",
"blogs.msdn.com.",
"en.wikipedia.org.",
"rei.com.",
"www.vegetariantimes.com.",
"www.backcountry.com.",
"www.dickssportinggoods.com.",
"litebackpacker.com."
)


# Randomize the sorting of $names:
$names = Get-Random -Count $names.Count -InputObject $names


# Resolve each name with a delay between the requests:
foreach ($name in $names) 
{ 
   Resolve-DnsName -Type A -DnssecOK -DnsOnly -Name $name > $null 
   Start-Sleep -Seconds (Get-Random -Minimum 3 -Maximum 11)
} 



