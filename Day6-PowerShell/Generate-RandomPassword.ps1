#*****************************************************
# Function Name: Generate-RandomPassword
#        Author: Jason Fossen
#       Version: 1.0
# Last Modified: 25.Jun.2012
#   Argument(s): A single argument, an integer for the desired length of password.
#       Returns: Pseudo-random complex password that has at
#                least one of each of the following character types:
#                uppercase letter, lowercase letter, number, and
#                legal non-alphanumeric.
#          Note: # and " and <space> are excluded to make the 
#                function play nice with other scripts.  Extended
#                ASCII characters are not included either.  Zero and
#                capital O are excluded to make it play nice with humans.
#          Note: If the argument/password is less than 4 characters 
#                long, the function will return a 4-character password
#                anyway.  Otherwise, the complexity requirements won't
#                be satisfiable.
#         Legal: Public domain.  Modify and redistribute freely.  No rights reserved. 
#                Use at your own risk and only on networks with prior written permission.
#*****************************************************
Param ($length = 15)

Function Generate-RandomPassword ($length = 15)
{
    If ($length -lt 4) { $length = 4 }   #Password must be at least 4 characters long in order to satisfy complexity requirements.
    
    Do {
        $password = $null 
        $hasupper =     $false   #Has uppercase letter character flag.
        $haslower =     $false   #Has lowercase letter character flag.
        $hasnumber =    $false   #Has number character flag.
        $hasnonalpha =  $false   #Has non-alphanumeric character flag.
        $isstrong =     $false   #Assume password is not strong until tested otherwise.
        
        For ($i = $length; $i -gt 0; $i--)
        {
            $x = get-random -min 33 -max 126              #Random ASCII number for valid range of password characters.
                                                          #The range eliminates the space character, which causes problems in other scripts.        
            If ($x -eq 34) { $x-- }                       #Eliminates double-quote.  This is also how it is possible to get "!" as a password character.
            If ($x -eq 39) { $x-- }                       #Eliminates single-quote, also causes problems in scripts.
            If ($x -eq 48 -or $x -eq 79) { $x++ }         #Eliminates zero and capital O, which causes problems for humans. 
            
            $password = $password + [System.Char] $x      #Convert number to an ASCII character, append to password string.

            If ($x -ge 65 -And $x -le 90)  { $hasupper = $true }
            If ($x -ge 97 -And $x -le 122) { $haslower = $true } 
            If ($x -ge 48 -And $x -le 57)  { $hasnumber = $true } 
            If (($x -ge 33 -And $x -le 47) -Or ($x -ge 58 -And $x -le 64) -Or ($x -ge 91 -And $x -le 96) -Or ($x -ge 123 -And $x -le 126)) { $hasnonalpha = $true } 
            If ($hasupper -And $haslower -And $hasnumber -And $hasnonalpha) { $isstrong = $true } 
        } 
    } While ($isstrong -eq $false)
    
    $password
}





#********************************************************
# This demonstrates the function.
#********************************************************
"`nHere's 20 pseudo-random passwords:`n`n"
1..20 | foreach { Generate-RandomPassword -length $length } ; "`n"





#********************************************************
# Here are the characters and ASCII codes for the password
# characters as a reference.  The excluded ones are noted.
# It also shows why the range of random numbers generated
# only starts at 34:  if 34 is generated, then the function
# converts it to 33 because 34 is an excluded character.
#********************************************************
#   = 32  Excluded (the space character)
# ! = 33  
# " = 34  Excluded
# # = 35
# $ = 36
# % = 37
# & = 38
# ' = 39  Excluded
# ( = 40
# ) = 41
# * = 42
# + = 43
# , = 44
# - = 45
# . = 46
# / = 47
# 0 = 48
# 1 = 49
# 2 = 50
# 3 = 51
# 4 = 52
# 5 = 53
# 6 = 54
# 7 = 55
# 8 = 56
# 9 = 57
# : = 58
# ; = 59
# < = 60
# = = 61
# > = 62
# ? = 63
# @ = 64
# A = 65
# B = 66
# C = 67
# D = 68
# E = 69
# F = 70
# G = 71
# H = 72
# I = 73
# J = 74
# K = 75
# L = 76
# M = 77
# N = 78
# O = 79
# P = 80
# Q = 81
# R = 82
# S = 83
# T = 84
# U = 85
# V = 86
# W = 87
# X = 88
# Y = 89
# Z = 90
# [ = 91
# \ = 92
# ] = 93
# ^ = 94
# _ = 95
# ` = 96
# a = 97
# b = 98
# c = 99
# d = 100
# e = 101
# f = 102
# g = 103
# h = 104
# i = 105
# j = 106
# k = 107
# l = 108
# m = 109
# n = 110
# o = 111
# p = 112
# q = 113
# r = 114
# s = 115
# t = 116
# u = 117
# v = 118
# w = 119
# x = 120
# y = 121
# z = 122
# { = 123
# | = 124
# } = 125
# ~ = 126

