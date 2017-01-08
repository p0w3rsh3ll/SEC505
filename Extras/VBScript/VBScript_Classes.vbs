'**********************************************************************************
' Script Name: VBScript_Classes.vbs
'     Version: 2.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 29.Mar.2004
'     Purpose: Demonstrate the use of custom classes in VBScript.
'       Notes: To use classes in VBScript, you should install version 5.6 or later  
'              of the Windows Script Host (http://msdn.microsoft.com/scripting/).
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'**********************************************************************************


'
' When to make your own classes?  Well, one case is when you want to store a bunch
' of related data together as a single object.  This is often easier and more
' coder-friendly than to create a ton a variables or a multi-dimensional array.  You're
' not compelled to create Property methods, private variables, Class_* methods, etc.
'


Class AIRPLANE
    Public TailNumber
    Public Model
    Public Latitude
    Public Longitude
    Public Heading
    Public Speed    
End Class

Set oPlane = New AIRPLANE         'Create a new instance of the class AIRPLANE.

oPlane.TailNumber = "N691SP" 
oPlane.Model = "Cessna 172-SP"
oPlane.Latitude = "N30.55"
oPlane.Longitude = "W120.31"
oPlane.Heading = 270
oPlane.Speed = 113

WScript.Echo oPlane.TailNumber & " can travel 50 miles in " & (50 / (oPlane.Speed/60)) & " minutes."


'
' But if you were frequently calculating the time to cover a certain distance,
' it would be simpler to make that a method of the class itself, and perhaps you 
' could encapsulate some error-correcting code into it as well while your're at it...  
'

Class HELICOPTER
    Public TailNumber
    Public Model
    Public Latitude
    Public Longitude
    Public Heading
    Public Speed    

    Public Function MinutesToTravel(iDistance)
        If Me.Speed = "" Then Me.Speed = 80                      'Set a default speed if object not initialized with one.
        MinutesToTravel = Int((iDistance / (Me.Speed / 60)))
    End Function
    
End Class

Set oHuey = New HELICOPTER
WScript.Echo "Minutes for Huey to fly 50 miles = " & oHuey.MinutesToTravel(50)


'
' In general, create custom classes in your script when this makes your
' script easier to read, more efficient, easier to extend, more reusable, etc.
' The shorter the script and simpler its tasks, the less likely that making your
' own objects will help.  The longer and more complex your tasks, the more likely 
' creating your own objects will simplify and shorten your script.  But it's 
' largely a matter of taste and programming style...
'


' **************************************************************************************


' 
' Here's a longer example showing more features of VBScript classes.
'


Set oPerson = New HUMAN                         'Creates a new instance of the class HUMAN.  
oPerson.Initialize "Billy", "Corgan", "Male"    'Initialize() is a custom procedure, not built-in.  
oPerson.BirthDate = "12/25/1979"                 'Objects have properties that can be Get or Set.


'
' You can create an array of objects from your class.
'
ReDim MyArray(5)
For i = 0 To 5
    Set MyArray(i) = New HUMAN
    MyArray(i).Initialize "Nicole" & i, "Kidman" & i, "Female"
    MyArray(i).Weight = 214
Next



' 
' The optional "With...End With" block is used to optimize the script
' when a single object will be mentioned many times in a row.  Notice 
' that there are "missing" objects being mentioned, e.g., " .Weight = 170"
' 
For Each oDude In MyArray
    With oDude   
        .Weight = 130
        .Height = 70    
        .BirthDate = "Nov 1, 1963"
        
        WScript.Echo .FullName & " was born on " & .BirthDate
        WScript.Echo .FullName & " is " & .Age
        WScript.Echo .FullName & " is a " & .Sex
    End With
Next


'
' Objects also have methods that can be called.
'
oPerson.ShowBio()


'
' When an object is destroyed, either manually or when the script exits, then
' the Class_Terminate() method in the class, if present, is called automatically.
'
Set oPerson = Nothing    'Such is life...  



'**********************************************************************************
' The implementation of the HUMAN class.
'**********************************************************************************
Class HUMAN

    'Public variables are visible properites of the instances of the class.
    '
    Public FirstName        
    Public LastName
    Public Weight  
    Public Height
    
    
    'Private variables can only be used inside this class implementation itself.    
    '
    Private pvtBirthDate    
    Private pvtAge
    Private pvtSex 


    ' Class_Initialize() is called automatically when an instance of the class is created.  
    ' No arguments to the sub are permitted, but you can create your own constructor (like Initialize()).
    '
    Private Sub Class_Initialize()
        FirstName = "UNKNOWN"
        LastName =  "UNKNOWN"
        Weight = 0
        Height = 0
        pvtSex = "UNKNOWN"
        pvtBirthDate = Now()
        pvtAge = 0
    End Sub


    ' Initialize() is not special or built into WSH in any way.  But you can use a sub like
    ' this to have something like a constructor for the object.  Because polymorphism is
    ' not supported in VBScript, you'll have to create multiple Initialize() versions if
    ' you want multiple ways of configuring new object instances.  Because this sub is
    ' marked as "Default" it can be called without mentioning the sub's name; for example,
    ' the following two lines do exactly the same thing, that is, invoke Initialize():
    '       oPerson.Initialize "Susan", "Sheets", "Female"
    '       oPerson "Susan", "Sheets", "Female"
    ' "Me" is a keyword that refers to this particular instance of the class.
    '
    Public Default Sub Initialize(sFirst, sLast, sSex)
        FirstName = sFirst
        LastName = sLast
        Me.Sex = sSex    
    End Sub
    
    
    'Class_Terminate() is called automatically when an instance of this class dies.
    'Place any necessary clean-up code here.  Instances are destroyed when set
    'to Nothing or when the script exits, whichever comes first.      
    '
    Private Sub Class_Terminate()
        WScript.Echo Me.FullName & " was terminated when the object was destroyed!"
    End Sub  


    ' Get() methods are for retrieving a property, usually a Private property.
    ' Get() methods are not needed for accessing Public variables.
    '
    Public Property Get FullName
        FullName = FirstName & " " & LastName
    End Property


    Public Property Get Age
        Age = Int(DateDiff("m", pvtBirthDate, Now()) / 12)
    End Property


    Public Property Get BirthDate
        BirthDate = CStr(pvtBirthDate)
    End Property
    
    
    ' Let() methods are for settings or assigning some data to a property of the
    ' object, usually a Private variable.  Let() methods are not needed for Publics.    
    '
    Public Property Let Sex(ByVal sSex)
        If UCase(Left(sSex,1)) = "F" Then
            pvtSex = "FEMALE"
        Else 
            pvtSex = "MALE"
        End If
    End Property


    Public Property Let BirthDate(ByVal sDate)
        pvtBirthDate = DateValue(sDate)
    End Property
            
            
    Public Property Get Sex
        Sex = pvtSex
    End Property 


    ' Public procedures and functions can be called from other statements in the
    ' script outside of the Class..End_Class block itself.  Instances of this
    ' class "expose" these methods on their globally-visable surfaces.
    '
    Public Sub ShowBio()
        WScript.Echo "Hello. My name is " & FirstName & " " & LastName &_ 
                         ".  I have been alive for " & GetAgeInDays() & " days."
        Call MsgBoxBio(False)  'A private procedure, see below.
    End Sub


    Public Function GetFullName()
        GetFullName = FirstName & " " & LastName    'Notice that this is like a Get() property!
    End Function


    ' Private procedures and functions can only be called by other statements inside
    ' the Class..End_Class implementation itself.  You cannot call Private methods 
    ' through instances of the class, these methods are not globally visible.
    '
    Private Function GetAgeInDays()   
        GetAgeInDays = DateDiff("d", pvtBirthDate, Now())
    End Function


    Private Sub MsgBoxBio(bFlag)
        If bFlag Then MsgBox Me.FullName,,"Popped Up By MsgBoxBio()"
    End Sub

End Class



'END OF SCRIPT*********************************************************************

