########################################################################
#
# Windows 10 runs universal apps in AppContainer sandboxes, which are
# not standard Windows executable programs.  For each of the following,
# you can run the string from the Run line, place into a shortcut, or
# launch with PowerShell's Start-Process cmdlet; for example:
#
#      Start-Process -FilePath "ms-settings:"
#
# Which might be placed in a little function and used as an alias:
#
#      function Edge ($URL="sans.org/sec505"){ Start-Process -FilePath "microsoft-edge:$URL" }
#
# Nicely, even when PowerShell is running elevated, the apps run in their
# correct (standard user) unelevated mode.
#
# Full list of app strings: 
# http://winsupersite.com/windows-10/how-open-windows-10-apps-using-shell-commands
#
########################################################################

ms-settings:                              # Settings
ms-settings-emailandaccounts:             # Accounts
ms-settings-airplanemode:                 # AirplaneMode
ms-settings-Bluetooth:                    # Bluetooth
ms-settings-cellular:                     # CellularNetwork
ms-settings:display                       # DisplaySettings
ms-settings:personalization               # Personalization
ms-settings:personalization-background    # PersonalizationBackground
ms-settings:personalization-colors        # PersonalizationColors
ms-settings:personalization-start         # PersonalizationStartMenu
ms-settings-language:                     # Language
ms-settings-location:                     # Location
ms-settings-lock:                         # Lockscreen
ms-settings-notifications:                # Notifications
ms-settings-power:                        # Power
ms-settings-privacy:                      # Privacy
ms-settings-proximity:                    # ProximitySensor
ms-settings-screenrotation:               # ScreenRotation
ms-settings-wifi:                         # Wi-fi
ms-settings-workplace                     # Workplace
ms-settings:storagesense                  # StorageSense
ms-actioncenter:                          # ActionCenter
ms-clock:                                 # Clock
ms-contact-support:                       # ContactSupport
ms-cortana:                               # Cortana
microsoft-edge:                           # Edge
read:                                     # EdgeReadingView
mailto:                                   # Mail
maps:                                     # Maps
ms-drive-to:                              # MapsDriveTo
ms-walk-to:                               # MapsWalkTo
ms-cxh:                                   # MicrosoftAccountProfile
onenote:                                  # OneNote
ms-wpc:                                   # ParentalControls
ms-people:                                # People
ms-phone-companion:                       # PhoneCompanion
windows-feedback:                         # WindowsFeedback
xbox-tcui:                                # Xbox


