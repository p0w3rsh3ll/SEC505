<# ####################################################################################
.SYNOPSIS
   Expands a Microsoft @-prefixed indirect string.

.DESCRIPTION
   Expands a Microsoft indirect string, such as '@vmms.exe,-279', which can be mapped
   to a normal human-readable string.  Also supports indirect strings similar to this:
   '@{Microsoft.Cortana?ms-resource://Microsoft.Cortana/resources/ProductDescription}'.
   Microsoft indirect strings begin with an "@" symbol and are common in the registry.
   See https://msdn.microsoft.com/en-us/library/windows/desktop/bb759919(v=vs.85).aspx

.EXAMPLE
   Expand-IndirectString.ps1 -IndirectString '@vmms.exe,-279' 

.INPUTS
   A string that begins with an '@' symbol.

.OUTPUTS
   If unsuccessful, outputs $null; if successful, the expanded string.

.NOTES
   Does not throw exceptions; returns $null if there is an error.
   If a normal string without an "@" prefix is given, that input string
   is simply returned unmodified.

   Version: 1.0
   Last Updated: 20.Sep.2016
   Author: Jason Fossen, Enclave Consulting LLC (www.sans.org/sec505)
   Legal: Public domain, no rights reserved, no warranties or guarantees.

#################################################################################### #>

Param ([String] $IndirectString = "") 


# Source code in C# to P/Invoke SHLoadIndirectString from shlwapi.dll:
$CSharpSHLoadIndirectString = @'
using System;
using System.Text;
using System.Runtime.InteropServices;
using Microsoft.Win32; 

namespace SHLWAPIDLL 
{
    public class IndirectStrings 
    {
        [DllImport("shlwapi.dll", CharSet=CharSet.Unicode)]
        private static extern int SHLoadIndirectString(string pszSource, StringBuilder pszOutBuf, int cchOutBuf, string ppvReserved);

        public static string GetIndirectString(string indirectString)
        {
            try 
            {
                int returnValue;
                StringBuilder lptStr = new StringBuilder(1024);
                returnValue = SHLoadIndirectString(indirectString, lptStr, 1024, null);

                if (returnValue == 0)
                {
                    return lptStr.ToString();
                }
                else
                {
                    return null;
                    //return "SHLoadIndirectString Failure: " + returnValue;
                }
            }
            catch //(Exception ex)
            {
                return null;
                //return "Exception Message: " + ex.Message;
            }
        }
    }
}
'@



# Create the type [SHLWAPIDLL.IndirectStrings]: 
Add-Type -TypeDefinition $CSharpSHLoadIndirectString -Language CSharp

# Call method to expand the indirect string:
[SHLWAPIDLL.IndirectStrings]::GetIndirectString( $IndirectString ) 




<#
# When calling repeatedly, do not run the script, copy the above code into your
# script and use the static method directly:

$instr1 = '@{Microsoft.Windows.Cortana_1.7.0.14393_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.Windows.Cortana/resources/ProductDescription}' 
$instr2 = '@{This.Will.Fail.Deliberately}'
$instr3 = '@vmms.exe,-279'

[SHLWAPIDLL.IndirectStrings]::GetIndirectString( $instr1 ) 
[SHLWAPIDLL.IndirectStrings]::GetIndirectString( $instr2 ) -eq $null  #Should be $true
[SHLWAPIDLL.IndirectStrings]::GetIndirectString( $instr3 ) 

#> 


