##############################################################################
#
# This script is just for fun, it's to implement a block cipher named
# "CheeseBall" with permutation, s-boxes, counter mode, and all the fixins.  
# I'll eventually get around to finishing it.  Right now it just has the
# permutation functions (I do have a day job after all...)
# 
##############################################################################



# helper functions for testing
function Get-IntFromBits ([String] $Bits) { [System.Convert]::ToUInt32($Bits,2) } 

function Get-BitsFromInt ([UInt32] $Integer, [Switch] $NoLeadingZeros) 
{ 
    if ($NoLeadingZeros) { [System.Convert]::ToString($Integer,2) } 
    else { ([System.Convert]::ToString($Integer,2)).PadLeft(32,"0") } 
}






# Our test input array of four bytes to permutate:
[Byte[]] $TestInput = @(0x00,0x0F,0xF0,0x00) 
[System.Array]::Reverse($TestInput)
[UInt32] $Inty = [System.BitConverter]::ToUInt32($TestInput,0) 
"Original number was $Inty"
"Original bits were  " + $(Get-BitsFromInt -Integer $Inty)
[System.Array]::Reverse($TestInput)  #Set it back again.
"Original bytes were: "
$TestInput
"`n" 


# Our 256-bit test key:
0..31 | foreach { [byte[]] $key += Get-Random -Minimum 0 -Maximum 255 } 




# The permutation table maps original bit position (left) to new permutated position (right).
# With all x=y pairings, during encryption each bit at position x will be moved to position y, and
# during decryption, each bit at position y will be moved back to position x.  For the functions
# below, the permutation table must have exactly 32 keys (0..31), each key must be an unsigned
# integer from 0 to 31, each value must be unsigned integer between 0 and 31, and no value can
# be used twice, i.e., there must be a 1-to-1 mapping of numbers 0-31 to values 0-31.

$Permutation1 = @{  0 = 27 ;  1 =  9 ;  2 = 30 ;  3 = 22 ;  4 = 11 ;  5 = 10 ;  6 = 28 ;  7 = 23 ; 
                    8 = 13 ;  9 = 21 ; 10 =  7 ; 11 = 26 ; 12 = 31 ; 13 =  4 ; 14 =  0 ; 15 =  6 ; 
                   16 = 12 ; 17 = 24 ; 18 = 29 ; 19 =  3 ; 20 = 25 ; 21 =  5 ; 22 =  2 ; 23 = 17 ; 
                   24 = 16 ; 25 = 14 ; 26 =  1 ; 27 = 20 ; 28 = 15 ; 29 = 18 ; 30 = 19 ; 31 =  8 }


$Permutation2 = @{  0 = 12 ;  1 = 19 ;  2 = 31 ;  3 = 17 ;  4 = 18 ;  5 = 25 ;  6 = 30 ;  7 = 24 ; 
                    8 = 16 ;  9 =  0 ; 10 = 29 ; 11 =  4 ; 12 = 23 ; 13 =  5 ; 14 = 21 ; 15 =  6 ; 
                   16 = 22 ; 17 = 26 ; 18 = 28 ; 19 =  8 ; 20 =  3 ; 21 = 15 ; 22 = 27 ; 23 = 10 ; 
                   24 = 11 ; 25 =  1 ; 26 = 13 ; 27 = 20 ; 28 =  7 ; 29 =  2 ; 30 =  9 ; 31 = 14 }




##############################################
# Permutate
##############################################
function Permutate32bitBlock ([Byte[]] $In, [System.Collections.Hashtable] $PermutationTable)
{
    # During encryption, a bit set to 1 in the original 32-bit block at position x is "moved" 
    # by left-shifting [UInt32]0x1 for y number of times (as determined by the permutation table)
    # and then adding the resulting unsigned 32-bit integer to an accumulator UInt32 originally set
    # to zero.  The keys of the forward hashtable are the original bit positions, and the values are 
    # the UInt32 integers computed by left-shifting a one by y-position places.
    $forward1 = @{} 
    0..31 | foreach { $forward1.add($_, ([UInt32] 1 -shl $($PermutationTable.$_)) ) }

    # Create a zeroed-out UInt32 to hold our permutation output:
    [UInt32] $Out = 0x00000000

    # Because x86/x64 CPUs are little endian, the byte array must be reversed.
    if ([System.BitConverter]::IsLittleEndian) { [System.Array]::Reverse($In) }

    # Now the reversed array can be converted to a UInt32: 
    [UInt32] $UInt32_In = [System.BitConverter]::ToUInt32($In,0) 

    #Uncomment when debugging.
    #write-host "Original number was $UInt32_In"
    #write-host "Original bits were $(Get-BitsFromInt -Integer $UInt32_In)"


    # Now check each bit, starting at position 0 (rightmost), shifting right each turn:
    for ($i = 0; $i -lt 32; $i++)
    {
        if (0x00000001 -band $UInt32_In) 
        {
            #It was a one, add forward permutation value, then move on to next bit.
            $Out = $Out + $forward1.$i 
            $UInt32_In = $UInt32_In -shr 1 
        }
        else
        { 
            #It was a zero, $Out defaults to zero, so move on to next bit.
            $UInt32_In = $UInt32_In -shr 1
        } 
    }

    # GetBytes() returns the bytes little-endian.
    [Byte[]] $OutBytes = [System.BitConverter]::GetBytes( $Out )
    [System.Array]::Reverse( $OutBytes )
    $OutBytes
}




# Demo the Permutate function:
$out1 = Permutate32bitBlock -In $TestInput -PermutationTable $Permutation1
$out2 = Permutate32bitBlock -In $out1      -PermutationTable $Permutation2

"Permutated number is " + [System.BitConverter]::ToUInt32($out2,0)  
"Permutated bits are " + $(Get-BitsFromInt -Integer $([System.BitConverter]::ToUInt32($out2,0))) 





##############################################
# Un-Permutate
##############################################
function UnPermutate32bitBlock ([Byte[]] $In, [System.Collections.Hashtable] $PermutationTable)
{
    # During decryption, a bit set to 1 in the enciphered data at position y is "moved" back to
    # its original position x by left-shifting [UInt32]0x1 by x number of times.  
    $invert1 = @{} 
    $i = 31   #The $permutation.values are emitted from item 31 to item 0 from the hashtable.
    $PermutationTable.values | foreach { $invert1.add($_, ([UInt32] 1 -shl $i)) ; $i-- }

    # Create a zeroed-out UInt32 to hold our inverted output:
    [UInt32] $Out = 0x00000000

    # Because x86/x64 CPUs are little endian, the byte array must be reversed.
    if ([System.BitConverter]::IsLittleEndian) { [System.Array]::Reverse($In) }


    # Now the reversed array can be converted to a UInt32: 
    [UInt32] $UInt32_In = [System.BitConverter]::ToUInt32($In,0) 


    # Now check each bit:
    for ($i = 0; $i -lt 32; $i++)
    {
        if (0x00000001 -band $UInt32_In) 
        { 
            #It was a one, add inverted permutation value, then move on to next bit.
            $Out = $Out + $invert1.$i 
            $UInt32_In = $UInt32_In -shr 1 
        }
        else
        { 
            #It was a zero, move on to next bit.
            $UInt32_In = $UInt32_In -shr 1
        } 

    }

    # GetBytes() returns the bytes little-endian.
    [Byte[]] $OutBytes = [System.BitConverter]::GetBytes( $Out )
    [System.Array]::Reverse( $OutBytes )
    $OutBytes
}




# Demo the UnPermutate function:
$out3 = UnPermutate32bitBlock -In $out2 -PermutationTable $permutation2
$out4 = UnPermutate32bitBlock -In $out3 -PermutationTable $permutation1

[System.Array]::Reverse( $out4 )
"Unpermutated number is " + [System.BitConverter]::ToUInt32($out4,0)  
"Unpermutated bits are " + $(Get-BitsFromInt -Integer $([System.BitConverter]::ToUInt32($out4,0))) 
[System.Array]::Reverse( $out4 )
"Unpermutated bytes are: "
$out4






# To-Do List:
# SBox functions
# Feed-forward key permutation, counter mode?
# Do compression or whitening with an IV?
# What about implementing blowfish in PowerShell?
#



