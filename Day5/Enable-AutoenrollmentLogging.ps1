####################################################################
#.SYNOPSIS
# Enable enhanced certificate auto-enrollment event logging.
#
#.DESCRIPTION
# Enable enhanced certificate auto-enrollment event logging.  Writes
# to the Application event log, Event Source = AutoEnrollment, with
# various event ID numbers: 2, 3, 20, 27, 28, 29 for successful
# events; and 7, 13, 15 and 16 for errors.
#
#.NOTES
# Errors and problems are logged by default even without
# this enhanced logging being enabled.
####################################################################

# User Cert Auto-Enrollment
reg.exe add 'HKCU\Software\Microsoft\Cryptography\Autoenrollment' /v AEEventLogLevel /t REG_DWORD /d 0

# Machine Cert Auto-Enrollment
reg.exe add 'HKLM\Software\Microsoft\Cryptography\Autoenrollment' /v AEEventLogLevel /t REG_DWORD /d 0


# Delete the above values (not keys) to disable this logging.


