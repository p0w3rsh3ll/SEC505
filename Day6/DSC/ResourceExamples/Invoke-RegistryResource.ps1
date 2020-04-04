<#############################################################################
.DESCRIPTION
    Demonstrate Invoke-DscResource as the quickest way to apply a DSC
    configuration.  The MOF is created in memory only.  Remember, only
    one module may be loaded, and only one DSC resource from that
    module may be invoked, and only one set of resource properties may
    be specified, when using Invoke-DscResource in this way.  However,
    the Invoke-DscResource cmdlet may be run multiple times in a script.
    When multiple modules or resource types are needed, it's usually better
    to use the Start-DscConfiguration cmdlet and create an on-disk MOF.

#############################################################################>



# Resource properties are like command-line arguments to the DSC resource.
# Where will the MOF file be created?  It will exist only in memory.

$ResourceProperties = 
@{
    Ensure = "Present"  
    Key = "HKEY_LOCAL_MACHINE\SOFTWARE\AAANewKey"
    ValueName = "EnableGoodness"
    ValueData = @("0x1")
    Hex = $True
    ValueType = "Dword"
    Force = $True 
} 


# Now, invoke the DSC resource from the PoSh module directly, giving the
# $ResourceProperties data like arguments.  The -Method in the following
# command may be SET, GET, or TEST.  SET enacts a configuration, TEST will
# return $True/$False if already in compliance with a configuration (nothing
# will be changed), and GET returns info about that configuration.

$Results = Invoke-DscResource -ModuleName PSDesiredStateConfiguration `
                              -Name Registry `
                              -Method SET `
                              -Property $ResourceProperties 



# Did it work?  What is the output of the SET/GET/TEST command?

$Results | Select-Object * 



