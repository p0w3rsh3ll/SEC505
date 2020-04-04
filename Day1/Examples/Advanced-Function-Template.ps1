#######################################################################
#
# This is a template for creating an advanced function (aka, "script
# cmdlet") in PowerShell 2.0 and later.  See the following help:
#
#    get-help about_Functions_Advanced
#    get-help about_Functions_Advanced_Methods
#    get-help about_Functions_Advanced_Parameters
#    get-help about_Functions_CmdletBindingAttribute
#    get-help about_Functions_OutputTypeAttribute
#
#######################################################################



<#
.SYNOPSIS
   Short description of function

.DESCRIPTION
   Long description

.EXAMPLE
   Example of how to use this function

.EXAMPLE
   Another example of how to use this function

.INPUTS
   Inputs to this function, if any

.OUTPUTS
   Output from this function, if any

.COMPONENT
   The component this function belongs to

.ROLE
   The role this function belongs to

.FUNCTIONALITY
   The functionality that best describes this function

.NOTES
   General notes, author, version, licensing
#>
function Verb-Noun
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.sans.org/sec505',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(0,5)]
        [ValidateSet("List", "of", "valid", "arguments")]
        [Alias("p1")] 
        $Param1,

        # Param2 help description
        [Parameter(ParameterSetName='Parameter Set 1')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [ValidateScript({ script block to validate arg, must return $true or $false })]
        [ValidateRange(0,5)]
        [int]
        $Param2,

        # Param3 help description
        [Parameter(ParameterSetName='Another Parameter Set')]
        [ValidatePattern("regex pattern to match")]
        [ValidateLength(0,15)]
        [String]
        $Param3
    )

    BEGIN
    {
        # Optional BEGIN block executed first and only once.
    }

    PROCESS
    {
        # PROCESS block executed for each piped-in object, if any,
        # or run only once if the function is the first command in
        # a statement or pipeline of commands.  The block is mandatory
        # if any parameter is set to accept ValueFromPipeline=$True.
    }
    
    END
    {
        # Optional END block executed last and only once.
    }
}
