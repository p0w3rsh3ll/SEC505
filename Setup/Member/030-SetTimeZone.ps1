# Set the time zone to match the zone on local domain controllers.


# Btw, you can do this manually on Server Core with:
#  control.exe timedate.cpl 
#  control.exe intl.cpl  


Set-TimeZone -Id 'Central Standard Time'


# To see a list of available time zone ID's:
#   Get-TimeZone -ListAvailable | Select Id

# Some time zone ID examples:
#   Eastern Standard Time
#   Central Standard Time
#   Mountain Standard Time
#   Pacific Standard Time
#   Central European Standard Time
#   GMT Standard Time
#   AUS Central Standard Time
#   Tokyo Standard Time
