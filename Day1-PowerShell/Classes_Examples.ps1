# Creating custom classes requires PowerShell 5.0 or later.
# PowerShell 5.0 is built into Windows 10 and Server 2016.
#Requires -Version 5


# Define a simple class to represent a user:

Class User1
{
    $FirstName
    $LastName
    $EmailAddress
}



# Create an instance of the User class:

$bob = New-Object -TypeName User1
$bob.FirstName = "Bob"
$bob.LastName = "Newhart"
$bob.EmailAddress = "bob@sans.org"



# Another way to create an instance:

$mary = [User1]::New()
$mary.FirstName = "Mary"



# A class may contain methods.  If the method outputs anything,
# declare the output type, like [String], and use the Return
# keyword within the code block of the method.  Methods can be
# overloaded when each method with the same name has different
# input parameters.  By default, a method returns [Void].

Class User2
{
    $FirstName
    $LastName
    $EmailAddress
    [String] FullName() { Return $This.FirstName + ' ' + $This.LastName }  
    [String] FullName($Title) { Return $Title + ' ' + $This.FirstName + ' ' + $This.LastName } 
}

$tim = New-Object -TypeName User2
$tim.FirstName = "Tim"
$tim.LastName = "Doolittle"
$tim.FullName()
$tim.FullName("Dr.")  #Overload




# A constructor is a method with the same name as the class
# and is used when creating a new instance of the class.
# Constructor methods can be overloaded too.  The $This variable
# refers to the object being created when the constructor is run.

Class User3
{
    $FirstName
    $LastName
    $EmailAddress

    User3() { $This.FirstName = "First" ; $This.LastName = "Last" } 

    User3($FirstName, $LastName)
    { 
        $This.FirstName = $FirstName
        $This.LastName = $LastName 
    }
    
    #Not required, but best to constrain the input parameter types:
    User3([String] $FirstName, [String] $LastName, [String] $EmailAddress)
    { 
        $This.FirstName = $FirstName
        $This.LastName = $LastName
        $This.EmailAddress = $EmailAddress 
    } 

    [String] FullName() { Return $This.FirstName + ' ' + $This.LastName }  
}

$generic = New-Object -TypeName User3
$justin  = New-Object -TypeName User3 -ArgumentList "Justin","Brookes"
$billie  = New-Object -TypeName User3 -ArgumentList "Billie","Corgan","billie@sans.org" 



# To see all the overloaded constructors for a class, where it is
# also helpful to see the expected type for each parameter:

[User3]::New  



# A subclass can inherit properties and methods from its parent class.
# The colon (:) indicates the parent class. Note that the only constructor
# in the parent class which can and will be used is the constructor
# which takes zero arguments, i.e., it is not currently possible to
# specify which constructor in the parent class will be invoked when
# an instance of the child class is created.  However, constructors for
# the child class can be defined which duplicate the functionality of
# the same contructors in the parent (so much for code reuse).

Class AdminUser : User3
{
    $Title = "Administrator"
    $FailedLogonCount = 0

    AdminUser ([String] $Title){ $This.Title = $Title } 

    AdminUser ([String] $Title, [String] $FirstName, [String] $LastName, [String] $EmailAddress)
    { 
        $This.Title = $Title 
        $This.FirstName = $FirstName        #Defined in parent class
        $This.LastName = $LastName          #Defined in parent class
        $This.EmailAddress = $EmailAddress  #Defined in parent class
    } 

    SetCount ([Int] $Count = 0) { $This.FailedLogonCount = $Count } 
}

$amy =  New-Object -TypeName AdminUser -ArgumentList "SecManager"
$lara = New-Object -TypeName AdminUser -ArgumentList "Compliance","Lara","Pilotte","larap@sans.org"
$lara.Title
$lara.SetCount(5) 
$lara.LastName       #Property from parent class
$lara.FullName()     #Method from parent class



# If a class includes a property or method declared as Static, that
# property or method is available on the class name itself using
# the double-colon (::) operator.  Static properties and methods do
# not appear on instances of the class however.  The $this variable
# cannot be used within a static method.  

Class User4
{
    $FirstName
    $LastName
    $EmailAddress
    
    #Static properties
    Static [String] $Species = "Human" #This is not a read-only constant

    #Static methods
    Static [Int] Reproduce ([Int] $NumberOfKids) { Return [Math]::Pow(2,$NumberOfKids) } 
    Static [Int] Reproduce () { Return [Math]::Pow(2,4) } #Use a default instead of $NumberOfKids
}


[User4]::Species
[User4]::Species = "Cyborg" #Static properties of the class itself may be changed

[User4]::Reproduce(2) 
[User4]::Reproduce()  #Use default

$jill = New-Object -TypeName User4
$jill.Species       #By design, this does not work
$jill.Reproduce(3)  #By design, this does not work



##############################################################################

# Enums
enum Departments { Sales ; Engineering ; Legal ; HR ; Unassigned }  


class CompanyUser
{
    # Properties
    # Pipe an instance into 'Get-Member -Force' to see auto-generated accessor methods.
    # It is not possible to overload or edit property accessor methods.
    # Every variable outside of a method in a class is public and read-write by default.
    # There is no 'Private' keyword, but there is 'Hidden' to conceal property names and
    # method names from tab completion and IntelliSense, but not hide them from 'gm -force'.  

    [string] $FirstName
    [string] $LastName
    [string] $Title 
    [Departments] $Department  #Enum
    [string] $EmailAddress
    [string] $EmploymentStatus 

    Hidden [int] $Salary       #Hidden

    # Overloaded Constructors
    CompanyUser()
    {
        $this.FirstName = "UnknownFirstName"
        $this.LastName = "UnknownLastName"
        $this.Title = "Employee" 
        $this.EmailAddress = "unknown@sans.org"
        $this.EmploymentStatus = "Hired" 
        $this.Department = "Unassigned" 
    } 

    CompanyUser([string] $FirstName, [string] $LastName)
    {
        Write-Host -Object "Constructor: CompanyUser" -ForegroundColor Green
        $this.FirstName = $FirstName
        $this.LastName = $LastName
        $this.Title = "Employee" 
        $this.EmailAddress = ($FirstName + "." + $LastName + "@sans.org").ToLower() 
        $this.EmploymentStatus = "Hired" 
        $this.Department = "Unassigned" 
    } 

    # Overloaded Methods 
    [Void] Fire()
    { 
        Write-Host -Object "CompanyUser:Fire()" -ForegroundColor Green
        $this.EmploymentStatus = "Fired" 
        $this.Title = "PersonaNonGrata"
        $this.Department = "Unassigned"
    } 

    [String] Salutation()                       #Return type must be satisfied.
    { Return "Ahoy " + $this.FirstName + "!" }  #Return keyword is required.

    [String] Salutation($Title = "Doctor ")     #Cannot assign default value like this!
    { Return "Ahoy " + $Title + $this.FirstName + "!" }  



}


# Contractor is a subclass of CompanyUser.
# Only one parent class for the subclass is permitted, but a class may implement multiple interfaces.
class Contractor : CompanyUser
{
    # Properties
    [string] $Manager
    [datetime] $EndOfContractDate 

    # Constructors
    # Constructors are not inherited from parent class. 
    # The parent class constructor is called first, then this one.
    # When creating an instance of a subclass, you cannot call the constructor of the parent class, except like this with the ": Base()" 
    Contractor([string] $FirstName, [string] $LastName, [string] $Manager, [datetime] $EndOfContractDate) : Base([string] $FirstName, [string] $LastName) 
    { 
        Write-Host -Object "Constructor: Contractor" -ForegroundColor Green
        $this.EndOfContractDate = [datetime] $EndOfContractDate 
        $this.Title = "Contractor" 
        $this.Manager = $Manager
    } 

    # Methods
    # Methods in subclass may override or add overloads to the parent class.
    [void] Fire()
    {
        # How to call Fire() in parent class: ([CompanyUser] $ted).fire() 
        Write-Host -Object "Contractor:Fire()" -ForegroundColor Green
        $this.EndOfContractDate = (Get-Date)
        $this.Manager = "None"
    }
}


# This works in PoSh 5.0 and later
$ted = New-Object -TypeName Contractor -ArgumentList @("Ted","Silke","Nancy Parcells","12-Nov-2018") 


# This instantiation method is twice as fast as New-Object:
$tom = [CompanyUser]::new("Tom","Wylie") 
$bob = [Contractor]::new("Bob","Paper","Nancy Parcells","12-Nov-2018") 


#See the new accessor/getter methods!
$tom | Get-Member -Force  





###################################################################

#Avg: 240ms
class newbie { $name ; $mileage ; newbie(){$this.name = "Toyota"; $this.mileage = 3} }
Measure-Command -Expression {
    1..10000 | foreach { [newbie]::new() }
} 

#Avg: 270ms
Measure-Command -Expression {
    1..10000 | foreach {  [pscustomobject] @{ name = "Toyota"; mileage = 3 }   }
}


###################################################################

enum Fruit
{
    Apple
    Orange
    Pear
}

enum Gender
{
    Male
    Female
}

class Person
{
    [void] Eat([Fruit] $food)
    {
        write-host "Ate $food" -fore green
    }

    [Gender] $Gender 

}


$p = [Person]::new()

$p.Eat("Pizza")  #Error, not a [Fruit]
$p.Eat("Orange")

$p.Gender = "Poodle" #Error, not a [Gender]
$p.Gender = "Female"

[Fruit]::Apple 
[Fruit]::Apple | Get-Member  #TypeName is [Fruit], but is actually an [Int].
[Fruit]::Apple.value__       #Returns an Int, and the ordering of items in the Enum changes the Int returned.


# In an enum, may assign a specific Int instead of the default:
enum Bug
{
    Fly = 3
    Ant = 19
    Bee = 38
}

[Bug]::Bee -lt 50 #True
[Bug]::Ant -eq 77 #False

