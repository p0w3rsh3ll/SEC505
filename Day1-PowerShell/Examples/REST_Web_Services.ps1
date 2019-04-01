##############################################################################
#.DESCRIPTION
#  Show a few Invoke-RestMethod examples with some live RESTful web services on the Internet.
#.NOTES
#  Credits:
#      https://wilsonmar.github.io/powershell-rest-api/
#      https://www.gngrninja.com/script-ninja/2016/7/24/powershell-getting-started-utilizing-the-web-part-2-invoke-restmethod
#
##############################################################################



# NewEgg Daily Deals
$Response1 = Invoke-RestMethod -Uri "http://www.newegg.com/Product/RSS.aspx?Submit=RSSDailyDeals&Depa=0"
$Response1.Count 
$Response1 | Select-Object -Property pubDate,title,link 


# Reddit
$Response2 = Invoke-RestMethod "http://www.reddit.com/r/sysadmin.rss"
$Response2.Count
$Response2 | Select-Object -Property updated,title 


# Wunderground
$Response3 = Invoke-RestMethod -Uri "http://autocomplete.wunderground.com/aq?query=ATHENS"
$Response3.RESULTS.Count
$Response3.RESULTS
$Response3.RESULTS | Select-Object -Property name,lat,lon   #latitude & longitude



