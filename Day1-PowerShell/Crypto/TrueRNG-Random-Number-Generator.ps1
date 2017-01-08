<#
---------------------------------------
Version: 1.0
Updated: 24.Jul.2015
Legal: Public domain, code provided "AS IS" without any warranties or guarantees whatsoever, use at your own risk.
Author: Enclave Consulting LLC (www.sans.org/sec505)
---------------------------------------

TrueRNG is a hardware-based random number generator the size of a USB thumb drive (www.ubld.it).  This article has sample PowerShell code for using TrueRNG to produce arrays of random bytes, such as for use with Math.NET Numerics or for generating encryption keys.  The code could easily be converted to C#.  

To download the PowerShell functions listed here, get the SEC505 zip file from the Downloads page.  This zip file contains hundreds of other scripts used in my SANS six-day course: Securing Windows with PowerShell (SEC505).  All the scripts are in the public domain.

Background

Random numbers are useful for cryptography, exploit fuzzers, neural network learning, solving engineering optimization problems, statistical modeling, gaming/gambling applications, training up high-frequency trading systems, software unit testing, producing different "colors" of audio noise, and more.  

Without special hardware, Windows and Linux can only produce streams of "pseudo" random bytes, not truly random bytes that are 100% unpredictable in principle.  This is because computers are deliberately designed to be the opposite of random in their operation: as computers shuffle bits around from one nanosecond to the next, they must strictly follow simple, deterministic rules or else data becomes corrupted.  In computer design, random changes occuring in code or data is the sign of a flaw.  

At the scale of electrons and photons, however, the universe often behaves randomly.  With special hardware, a computer can tap into this indeterminate quantum flux to churn out ones and zeros.  Random numbers can also come from observing events in the macro world which are chaotically sensitive to very minute changes in complex initial conditions, e.g., the timing of solar wind particles striking a satellite, neural activity in a teenager running from the police, global atmospheric noise, or the nanosecond changes in floor tremors at a Katy Perry concert.  Katy Perry Generators (KPGs) are somewhat expensive however.  On the other hand, devices which monitor particle decay or the noise produced by certain electronic circuits are much cheaper and more portable.  TrueRNG, for example, relies on the well-known avalanche breakdown effect in its circuitry to produce random bytes.  

TrueRNG FAQ

TrueRNG (www.ubld.it) is a USB device the size of a thumb drive.  It is compatible with Windows and Linux.  It's device driver is digitally signed, so it is compatible with Windows Vista/7/8/10 and later.  

Windows mounts the TrueRNG device as a simple COM port, hence, it is easy to obtain random bytes using PowerShell, C#, VB.NET, Python, C/C++, or anything else which can read from a serial COM port.

When plugged in, TrueRNG continuously produces random bits internally, i.e., the bits are always "fresh", no matter how often the COM port is read or how many/few bytes are obtained.  Unlike a software-based pseudo random number generator (PRNG), a true RNG (TRNG) does not have to be "seeded" first and will not "loop" back around to the beginning of a repeated series of bits.  

The maximum throughput of TrueRNG is about 50KB/second, which is slow by USB standards, but pretty good for such an inexpensive and portable TRNG.  When producing encryption keys or refilling /dev/random on Linux, TrueRNG is usually more than fast enough.  When producing a gigabyte of randomness to save to a file, however, the process will require about six hours, so this job would probably be scheduled to run overnight.  On the other hand, TrueRNG can be used to seed another PRNG which is much faster, such as from Math.NET Numerics, then hope the output has enough bits of entropy per byte for the application's needs.  

Note: Changing the baud rate, read buffer, bits/sec of the COM port in Windows Device Manager, using a USB 3.0 port, etc. will not increase the output rate of the TrueRNG device.  

There are faster products than TrueRNG, but check Windows compatibility (and the price) first:

    http://onerng.info
    https://www.tindie.com/products/WaywardGeek/infinite-noise/
    https://en.wikipedia.org/wiki/Comparison_of_hardware_random_number_generators

    
Random Numbers in Windows

The RNG under the low-level Windows API is closed source.  The RNG-related classes of the .NET Framework are much more accessible.  Here is a recent academic paper describing and comparing the RNGs in Windows and Linux (http://www.ijcaonline.org/archives/volume113/number8/19847-1710).  

In the .NET Framework, the System.Random class is easy to use, but it provides low-quality PRNG bytes and is not thread safe.  In general, use of this class should be avoided for non-trivial applications.  If this class must be used, use TrueRNG or another TRNG source to generate the Int32 seed value fed into its methods, and reseed frequently.    

In .NET there is also the System.Security.Cryptography.RNGCryptoServiceProvider class, which is a far superior source of PRNG bytes than System.Random.  The RNGCryptoServiceProvider class cannot accept an external seed; it uses it's own seeding mechanism, which is described in the academic paper above.  As far as PRNGs go, this one appears to be pretty good.  



Random Numbers in PowerShell

The Get-Random cmdlet in PowerShell is simply a wrapper for the System.Random class in the .NET Framework.  The cmdlet has a -SetSeed parameter for a Int32 random seed from TrueRNG if necessary.  

There are no PowerShell cmdlets which directly use RNGCryptoServiceProvider, but a function can be easily made for it (see in the code examples below).  



Random Numbers in Math.NET Numerics

Math.NET Numerics is a free, open source set of mathematical libraries for Windows that support the Intel MKL for hardware acceleration.  Math.NET functions often use, and can produce, random numbers for scientific, engineering, and statistical purposes.  (Here are a bunch of PowerShell Math.NET examples.)

In Math.NET Numerics, the SystemRandomSource class derives from the basic System.Random class in .NET, but with thread safety and other enhancements added, such as a better default seed.  

Other Math.NET classes do not use System.Random at all.  The CryptoRandomSource class in Math.NET actually uses RNGCryptoServiceProvider from the .NET Framework, plus extra enhancements, such as thread safety.  

And Math.NET includes additional random number generators which are unrelated to either of the above .NET classes; all of which can accept a seed from TrueRNG, such as:

MersenneTwister: Mersenne Twister 19937 generator
Xorshift: Multiply-with-carry XOR-shift generator
Mcg31m1: Multiplicative congruential generator using a modulus of 2^31-1 and a multiplier of 1132489760
Mcg59: Multiplicative congruential generator using a modulus of 2^59 and a multiplier of 13^13
WH1982: Wichmann-Hill's 1982 combined multiplicative congruential generator
WH2006: Wichmann-Hill's 2006 combined multiplicative congruential generator
Mrg32k3a: 32-bit combined multiple recursive generator with 2 components of order 3
Palf: Parallel Additive Lagged Fibonacci generato

Math.NET also supports non-uniform random number probability distributions too.
#>


<# 
TrueRNG Basic Use 

Here is a basic example of getting some bytes out of TrueRNG, if only for testing.

Use Device Manager or the Get-TrueRngComPort function (below) to see what COM port TrueRNG is using, e.g., COM4.
#>


# Create a byte array to fill with with TrueRNG bytes:
[Byte[]] $buffer = 1..2000 | ForEach { 0 } 

# Create an object to access that COM port:
$port = New-Object -TypeName System.IO.Ports.SerialPort -ArgumentList 'COM4'

#Set Data Terminal Ready (DTR) to start the flow of bytes when the port is opened:
$port.DtrEnable = $True
 
#Open the COM port to allow bytes to be read from it:
$port.Open()                 

#Return how many bytes are immediately available to be read:
$port.BytesToRead            

#Return one byte only:
$port.ReadByte()             

#Copies 2000 random bytes into the buffer array, starting at offset 0:
$port.Read($buffer, 0, 2000) 

#Do something useful with the newly-filled array:
$buffer -join ','            

#All done, so turn off the flow of bytes:
$port.DtrEnable = $false     

#Release the COM port to other processes and clean up resources:
$port.Close()                


# See Microsoft's documentation on the System.IO.Ports.SerialPort class for more details.



<# 
TrueRNG COM Port Discovery 

A Windows computer might have hundreds of COM ports, so which one is TrueRNG using?  This function returns an array of strings (like 'COM4') to identify the TrueRNG port(s).  If you have multiple TrueRNG devices installed, the array will include all of them.  Multiple TrueRNG devices might be used to increase total throughput or perhaps to mix the streams together.
#>

function Get-TrueRngComPort
{   #.SYNOPSIS
    #    Returns an array of the COM port(s) of TrueRNG USB device(s) (for 
    #    example, "COM4") or throws an error if no TrueRNG ports can be found.

    $pnp = @( Get-WmiObject -Query "Select * From Win32_PnPEntity Where Name like 'TrueRNG%'" )  
    
    if ($pnp.Count -eq 0){ write-error -message 'PNP ERROR: Cannot find TrueRNG COM port, check Device Manager!' ; throw 'PNP ERROR' }  
    
    $coms = @()

    ForEach ($dev in $pnp)
    {   
        $devname = ($dev.Name -split '\((COM\d{1,3})\)')[1]  
        if ($devname -notmatch '^COM\d{1,3}$'){ write-error -message 'SPLIT ERROR: Cannot extract TrueRNG COM port, check Device Manager!' ; throw 'SPLIT ERROR' } 
        $coms += $devname
    }

    ,$coms  #Return an array of the COM port strings
}


$ports = Get-TrueRngComPort
if ($ports.Count -eq 1) { $ports[0] } 




<# 
Create An Array of Random Bytes 

The following function returns an array filled with random bytes from TrueRNG or it throws an exception.  Because of the dangers involved, the array to be returned is first filled with pseudo-random bytes, then TrueRNG bytes.  The function aggressively looks for any reason to throw an exception and return nothing.  (There are extra 'return $false' statements mixed into the Catch blocks; these are to deal with an issue on older versions of PowerShell.)  It is not designed to be fast, but that doesn't really matter, the bottleneck will be the TrueRNG device itself.  

#>


function New-TrueRngByteArray 
{   <#
    .SYNOPSIS
        Returns an array of random bytes generated by a TrueRNG USB device.
    .DESCRIPTION
        Returns an array of random bytes generated by the TrueRNG hardware
        random number generator (www.ubld.it).  The output is an array,
        not a stream of bytes, so capture to a variable, do not pipe.
        Default array size is 4 bytes, which can be converted to Int32, a
        common seed size for other random number generators.
    .PARAMETER Size
        Number of random bytes in the returned array.  Defaults to 4.
    .PARAMETER COMPort
        Optional COM port number or string, e.g., "3" or "COM3". Defaults
        to automatic discovery of the correct COM port, which is a bit
        slower than providing the correct COM port as an argument. The
        function assumes that only one TrueRNG device is installed.  If
        there are multiple, the COM port must be specified explicitly.
    .EXAMPLE
        $bytearray = New-TrueRngByteArray -Size 32
        Creates a [Byte[]] array with 32 random bytes.  The TrueRNG COM
        port is discovered automatically; otherwise, an error is thrown.
    .EXAMPLE
        $bytearray = New-TrueRngByteArray -Size 10000 -COMPort 'COM4'
        Creates a [Byte[]] array with 10,000 random bytes, but only if
        the TrueRNG USB device is accessible on COM4.
    .OUTPUTS
        [Byte[]] array, not a stream of individual bytes.
    .NOTES
        Public domain, code provided "AS IS" without warranties or
        guarantees of any kind, including fitness for a purpose. 
        Author: Enclave Consulting LLC, Jason Fossen (www.sans.org/sec505) 
    #>

    [CmdletBinding()]
    Param ([ValidateRange(1,2147483647)][Int] $Size = 4, [String] $COMPort = 'Auto')
    
    # If the COM port is not provided, try to detect it automatically
    if ($COMPort -eq 'Auto')
    {
        $validports = @( [System.IO.Ports.SerialPort]::GetPortNames() )
        Write-Verbose -Message ("Valid available ports: " + ($validports -join ' '))

        if ($validports.Count -eq 0) 
        { write-error -message 'GETPORTNAMES ERROR: Cannot find TrueRNG COM port, check Device Manager!' ; throw 'GETPORTNAMES ERROR' } 
        elseif ($validports.Count -eq 1 -and $validports[0] -match '^COM\d{1,3}$') 
        { 
            $COMPort = $validports[0] 
            Write-Verbose -Message ("Sole port chosen by default: " + $COMPort)
        }
        else
        {
            $pnp = @( Get-WmiObject -Query "Select * From Win32_PnPEntity Where Name like 'TrueRNG%'" -ErrorAction Stop )  
            if ($pnp.Count -ne 1){ write-error -message 'PNP ERROR: Cannot find TrueRNG COM port, check Device Manager!'; throw 'PNP ERROR' }  
            $com = ($pnp[0].Name -split '\((COM\d{1,3})\)')[1]  
            if ($com -notmatch '^COM\d{1,3}$'){ write-error -message 'SPLIT ERROR: Cannot find TrueRNG COM port, check Device Manager!'; throw 'SPLIT ERROR' } 
            $COMPort = $com 
            Write-Verbose -Message ("Port chosen by WMI: " + $COMPort)
        }
    }
    else
    {
        # If the COM port is given as a raw number or in lowercase, fix it
        $COMPort = ([string] $COMPort).ToUpper() 
        if ($COMPort -notlike 'COM*'){ $COMPort = 'COM' + $COMPort } 
        if ($COMPort -notmatch '^COM\d{1,3}$'){ write-error -message 'FIXIT ERROR: Cannot find TrueRNG COM port, check Device Manager!'; throw 'FIXIT ERROR' }
        if (@([System.IO.Ports.SerialPort]::GetPortNames()) -notcontains $COMPort){ write-error -message 'INVALIDPORT ERROR: Windows does not see that COM port!'; throw 'INVALIDPORT ERROR' } 
        Write-Verbose -Message ("Port argument given: " + $COMPort)
    }

    
    # Try to open the TrueRNG COM port
    Try
    {
        $port = New-Object -TypeName System.IO.Ports.SerialPort -ArgumentList $COMPort -ErrorAction Stop
        $port.DtrEnable = $True  #To start the flow of bytes when opened
        $port.Open()
    }
    Catch 
    { 
        write-error -message 'OPEN ERROR: Failed to open the TrueRNG COM port!'
        $port.DtrEnable = $False
        $port.close() 
        throw $_
        return $false 
    } 

    
    # It's faster to wait here just a bit to let the device accumulate some output
    if ($Size -ge 170){ Start-Sleep -Milliseconds ([Math]::Min( 250, ($Size/45) )) } 
    Write-Verbose -Message ("Initial BytesToRead: " + $port.BytesToRead)


    # Confirm that bytes are available to read, maybe wrong COM port was selected
    if ($port.BytesToRead -lt 5)
    { 
        $port.close()
        write-error -message 'TOREAD ERROR: Failed to obtain bytes! Correct COM port chosen?'
        throw 'TOREAD ERROR'
    } 


    # Create byte array to fill with TrueRNG output, and fill it with random bytes, just in case...
    $b = [Byte] 0x00
    [Byte[]] $buffer = ,$b * $Size 
    $RngProv = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
    $RngProv.GetNonZeroBytes( $buffer )     


    # Fill byte array with random bytes from TrueRNG
    $bytesremaining = $Size 
    $offset = 0
    While ($True)
    { 
        $bytesavailable = $port.BytesToRead
        if ($bytesremaining -gt $bytesavailable){ $ToRead = $bytesavailable }
        else { $ToRead = $bytesremaining }

        Try 
        { 
            Write-Verbose -Message ("Bytes Remain: " + $bytesremaining + "`nVERBOSE: Bytes ToRead: " + $port.BytesToRead) 
            $counter = $port.Read( $buffer, $offset, $ToRead ) 
            Write-Verbose -Message ("Read TrueRNG: " + $counter)  
            $offset += $counter 
            $bytesremaining -= $counter
            if ($bytesremaining -le 0){ break } 
            Start-Sleep -Milliseconds ([Math]::Min( 250, ($bytesremaining/45) ))
        }
        Catch { $port.close(); write-error -message 'MULTIREAD ERROR: Failed to obtain bytes!'; throw $_ ; return $false } 
    }
    
    
    # Close the TrueRNG COM port
    $port.DtrEnable = $False
    $port.Close()

    #Return the array as a whole, don't delete the comma
    ,$buffer
}




<# 
Example Uses 

Here are some example uses of the New-TrueRngByteArray function.  Note that, by default, the function returns four bytes if a -Size is not specified.  This is because four bytes can be converted to an Int32, and Int32 seed numbers are common with other random number generator algorithms.

#>

# Convert four TrueRNG bytes to a 32-bit signed integer:
$Int32 = [System.BitConverter]::ToInt32( (New-TrueRngByteArray), 0) 


# The Get-Random cmdlet can accept an Int32 as a seed for conditioning its own output:
Get-Random -SetSeed $Int32


# You don't have to save the seed to a separate variable first:
Get-Random -SetSeed ([System.BitConverter]::ToInt32((New-TrueRngByteArray),0))


# The seed affects subsequent calls to Get-Random too.  Ideally, set a new TrueRNG seed every time, but it's not required.
# Just make sure to not use the same seed value twice!  Doing so produces the same output series, which is useful
# for testing, but not for generating secrets.
Get-Random ; Get-Random ; Get-Random  #OK
Get-Random -SetSeed $Int32            #BAD, unless you want the same output series


# When the -Maximum argument to Get-Random is an Int64 or Double, it outputs a number of that type:
$Int32 = [System.BitConverter]::ToInt32( (New-TrueRngByteArray), 0) 
Get-Random -Maximum ( [Int64]::MaxValue) -Minimum ([Int64]::MinValue ) -SetSeed $Int32
Get-Random -Maximum ([Double]::MaxValue) -Minimum ([Double]::MinValue) -SetSeed $Int32


# Doubles and Int64s are 64-bit values, hence, generate some multiple of 8-byte arrays with TrueRNG
# to produce random values of size Double or Int64:
$array = New-TrueRngByteArray -Size (8 * 10)
for ($i = 0; $i -lt $array.Count; $i += 8)
{ 
    [System.BitConverter]::ToInt64(  $array, $i ) 
    [System.BitConverter]::ToDouble( $array, $i ) 
} 


# Save random bytes to a binary file, perhaps for sampling later:
Set-Content -Value (New-TrueRngByteArray -Size 10000) -Encoding Byte -Path .\random.bin 


# Append or create a 100MB file of random bytes (verrry slooowwww), but then it can be quickly
# sampled for as many TRNG bytes as needed, perhaps only reading forward then wrapping around:
1..100 | ForEach { Add-Content -Value (New-TrueRngByteArray -Size 1000000) -Encoding Byte -Path .\bigrandom.bin } 
$bytes = Get-Content -Encoding Byte -ReadCount 0 -Path .\bigrandom.bin
$bytes.Count
$SomethingUseful = $bytes[0..511]


# The System.Random class can be seeded when an instance is created:
$rnd = New-Object -TypeName System.Random -Arg ([System.BitConverter]::ToInt32((New-TrueRngByteArray),0))
$rnd.Next() 


# The RNGCryptoServiceProvider class in .NET can generate good PRNG bytes, but it 
# cannot accept a TrueRNG seed value despite having a constructor which accepts [Byte[]].
# Any such byte array provided to the constructor is ignored (see the documentation).
# However, we can still easily use this class, e.g., to XOR its bytes with TrueRNG bytes.

function New-XorByteArray ( [Byte[]] $Array1, [Byte[]] $Array2 )
{   #.SYNOPSIS
    #  XOR's two same-sized byte arrays, returns a new array as a whole
    if ($Array1.Count -ne $Array2.Count){ throw 'Arrays not the same size!' } 
    $count = $Array1.Count
    $out = New-Object -TypeName 'System.Collections.Generic.List[Byte]' -ArgumentList $count
    For ($i = 0; $i -lt $count; $i++){ $out.Add( ($Array1[$i] -bxor $Array2[$i]) ) } 
    ,$out.ToArray()  #Don't delete the comma, return entire array whole
}

[Byte[]] $fillme = 1..4
$RngProv = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
$RngProv.GetNonZeroBytes( $fillme ) 
$RngProv.Dispose() 
$mixed = New-XorByteArray -Array1 $fillme -Array2 (New-TrueRngByteArray) 


# For fault tolerance in your script, but not for avoiding PRNG bytes, you can try to use 
# TrueRNG and then fall back to RNGCryptoServiceProvider only if necessary:

function New-TrueRngByteArrayWithFallBack 
{
    [CmdletBinding()] Param ( [Int] $Size = 16 ) 
     
    Try 
    { 
        New-TrueRngByteArray -Size $Size -ErrorAction Stop -Verbose:$False #-COMPort 999 #Uncomment to simulate TrueRNG failure
        Write-Verbose -Message "TrueRNG USB Device" 
    } 
    Catch
    {
        Write-Verbose -Message "Fallback to .NET PRNG"
        $b = [Byte] 0x00 
        [Byte[]] $bytes = ,$b * $Size
        $RNG = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
        Try { $RNG.GetBytes( $bytes ) } Catch { throw $_ ; return $false } Finally { $RNG.Dispose() } 
        ,$bytes  #Don't delete comma, return array as a whole
    }
}

New-TrueRngByteArrayWithFallBack -Size 4 -Verbose



<# 

Math.NET Numerics Examples  

Math.NET Numerics provides thread-safe and high-performance random numbers.  Because the TrueRNG USB device only produces data at about 50KB/second, it would be far quicker to use TrueRNG to provide a seed value to various Math.NET classes and then let Math.NET do the heavy lifting.

For the Math.NET functions, see the Math.NET.Numerics-Examples.ps1 script.
#>

# Load the Math.NET Numerics DLL:
Add-Type -Path .\MathNet.Numerics.dll

# With the Mersenne Twister 19937 generator, make 10 million Doubles with a TrueRNG seed:
$seed = [System.BitConverter]::ToInt32((New-TrueRngByteArray),0)
$quantity = 10000000
[MathNet.Numerics.Random.MersenneTwister]::Doubles( $quantity, $seed )


# With the Multiply-with-Carry XOR-Shift generator, make 10 million Doubles with a seed 
# from TrueRNG and helper values of a=9, c=6, x1=11, x2=12: 
$seed = [System.BitConverter]::ToInt32((New-TrueRngByteArray),0)
$quantity = 10000000
[MathNet.Numerics.Random.Xorshift]::Doubles( $quantity, $seed, 9, 6, 11, 12 )


<# 
Large Random Sampling Files

Another option is to use TrueRNG to create a large number of random bytes, convert them to Doubles, then save the Doubles to one of the file formats preferred by Math.NET.  For example, the following code takes a long time to run (about 6 minutes) because TrueRNG only outputs about 50KB/sec, but once completed, a 33MB MatrixMarket file is saved with a 3000x500 matrix of random Doubles.  This can quickly be read and used again by Math.NET if fresh random bytes are not required for each run.  A new file could be regularly generated with a scheduled task as a background job.  

For the Math.NET functions, see the Math.NET.Numerics-Examples.ps1 script.
#>

# Preallocate the memory for 1.5 million Doubles:
$list = New-Object -TypeName 'System.Collections.Generic.List[Double]' -ArgumentList 1.5e6

# Convert TrueRNG bytes to Doubles, add to array:
while($true) 
{ 
    $array = New-TrueRngByteArray -Size 12000 -COMPort 'COM4' #Get 1500 doubles each round

    for ($i = 0; $i -lt $array.Count; $i += 8)
    { 
        $list.add( [System.BitConverter]::ToDouble( $array, $i ) ) 
    } 

    if ($list.Count -ge 1.5e6){ break } 
} 

# Convert array into a 3000x500 matrix:
$MATRIX = [MathNet.Numerics.LinearAlgebra.Matrix[Double]] 
$m = $MATRIX::Build.DenseOfColumnMajor( 3000, 500, ($list.ToArray()) )
$list = $null

# Save matrix to a file format common in science/engineering/Math.NET.
# See the Math.NET.Numerics-Examples.ps1 script for this function: 
Export-NistMatrixMarketFile -FilePath .\RandomMatrix-3000x500.mtx -Matrix $m 



