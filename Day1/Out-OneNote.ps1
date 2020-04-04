####################################################################################
#.Synopsis 
#    Objects piped into script are sent to the locally-installed Microsoft OneNote. 
#
#.Description 
#    When Microsoft OneNote is installed, normally a virtual printer is created so
#    that anything "printed" to OneNote will actually be sent to OneNote for 
#    inclusion in a notebook or Unfiled Notes.  This script is just a trivial
#    wrapper for Out-Printer.  Only pipe strings into the script or data which can 
#    be converted to strings.  Script only accepts piped input.  Does not work
#    with OneNote in Office 365 over the Internet. Includes the printed strings in
#    OneNote as an image of those strings, so right-click the image in OneNote to
#    copy the text out of the image with Optical Character Recognition (OCR).  
#
#.Example 
#    get-process | .\Out-OneNote.ps1
#
#Requires -Version 2
#
#.Notes 
#  Author: Jason Fossen (http://www.sans.org/sec505)  
# Version: 1.0
# Updated: 14.Dec.2010
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################

function Out-OneNote
{
    # Get the name of the "Send to OneNote" printer:
    [String] $Name = Get-Printer | Where { $_.Name -like '*OneNote*' } | Sort -Property Name | Select -Last 1 | Select -ExpandProperty Name

    # Confirm that a OneNote printer was found:
    if ($Name.Length -eq 0) { Write-Error -Message "Cannot find 'Send To OneNote' printer." ; Return } 

    # Pipe into Out-Printer:
    $Input | Out-Printer -Name $Name -Verbose
}

$Input | Out-OneNote 


