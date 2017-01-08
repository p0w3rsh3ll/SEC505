$xmldoc = @"
  <Users>
        <Person>
            <FirstName>Leslie</FirstName>
            <LastName>Cummings</LastName>
            <Birthdate>20-June-1974</Birthdate>
        </Person>
        
        <Person>
            <FirstName>Matt</FirstName>
            <LastName>Shepard</LastName>
            <Birthdate>9-Oct-1961</Birthdate>
        </Person>
  </Users>
"@


# What kind of object is $doc at this point in the script?  It's just a string.  
$xmldoc.gettype().fullname


# But this string is also a well-formed XML document, hence, it can be cast as 
# a System.Xml.XmlDocument object to change its .NET class type. 

$xmldoc = [XML] $xmldoc
$xmldoc.gettype().fullname


# Now that it's an XML document, we can start enumerating through it.

$xmldoc
$xmldoc.Users
$xmldoc.Users.Person
$xmldoc.Users.Person[0]
$xmldoc.Users.Person[0].LastName


# Because PowerShell treats the elements as string properties, they can be treated as such.  

$xmldoc.Users.Person[0].LastName = "Garcia"


# To see the new XML document, you can either write a function to enumerate 
# through it, or just save it to a file and view that file's contents (must 
# provide the full path to file).  

$xmldoc.Save("c:\temp\users.xml")
get-content c:\temp\users.xml


# To read an existing XML file on the hard drive into a variable (must use full path):

$xmldoc = new-object System.XML.XMLdocument
$xmldoc.Load("c:\temp\users.xml")


# To create an XML document from scratch and add an element to it, you have to 
# build the various pieces first and then append them to the document.  Functions can 
# be used to make the process not so tedious (see Append-XmlElement.ps1).

# Create a new blank XML document.

$xmldoc = new-object System.Xml.XmlDocument


# Create a top-level element and append to doc.

$Users = $xmldoc.CreateElement("Users")
$xmldoc.AppendChild($Users)


# Manually create and append a Person element.

$Person = $xmldoc.CreateElement("Person")

$fn = $xmldoc.CreateElement("FirstName")
$fn.Set_InnerText("Leslie")
$Person.AppendChild($fn)

$ln = $xmldoc.CreateElement("LastName")
$ln.Set_InnerText("Cummings")
$Person.AppendChild($ln)

$bd = $xmldoc.CreateElement("BirthDate")
$bd.Set_InnerText('18-May-1978')
$Person.AppendChild($bd)


# Append the new Person to the Users element.

$Users.AppendChild($Person)


# To delete just one element from an XML document:

$element = $xmldoc.Users.Person
$xmldoc.Users.RemoveChild($element)







