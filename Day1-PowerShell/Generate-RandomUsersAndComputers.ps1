################################################################################
#   Script: Generate-RandomUsersAndComputers.ps1
#  Purpose: Creates random user and/or computer accounts in Active Directory 
#           with somewhat realistic properties in the top-level OU of your
#           choice.  If the OU does not exist, it will be created; the OU
#           defaults to "NewEmployees" if another target OU is not given.
# Requires: PowerShell 2.0 or later, Server 2008-R2 or later domain controller,
#           and you must run the script on the controller as a Domain Admin
#           for the domain in the forest where you want the accounts created.
#  Version: 1.0
#   Author: Jason Fossen (http://www.sans.org/sec505)
#  Warning: If you target an existing production OU, the script will
#           create accounts in that OU alongside your real accounts. Also,
#           the users will be created with long but predictable passphrases in
#           the format of "phonenumber Pw phonenumber" using each user's 
#           unique and world-readable phone number -- You've Been Warned!
#    Legal: Public domain; script provided AS IS without any warranties or
#           guarantees of any kind, including but not limited to fitness for
#           a particular purpose and/or merchantability; all risks of damage
#           remains with the user, even if the author, supplier or distributor
#           has been advised of the possibility of any such damage.
#Requires -Version 2.0
################################################################################

param ($NumberOfNewUsers = 0, $NumberOfNewComputers = 0, $TargetOU = "NewEmployees")

# Check arguments to parameters.
if ($NumberOfNewUsers -eq 0 -and $NumberOfNewComputers -eq 0)
{ "`nYou must create at least one user and/or computer account.`nSee the parameter names for guidance.`n" ; exit } 


# Collections of user account properties to be randomly combined (feel free to change if you don't want American names).
$LastNames = @("Adams","Adkins","Aguilar","Alexander","Allen","Alvarez","Anderson","Andrews","Armstrong","Arnold","Austin","Bailey","Baker","Baldwin","Ball","Banks","Barber","Barker","Barnes","Barnett","Barrett","Bates","Beck","Becker","Bell","Bennett","Benson","Berry","Bishop","Black","Blair","Blake","Bowen","Bowman","Boyd","Bradley","Brewer","Brooks","Brown","Bryant","Burgess","Burke","Burns","Burton","Bush","Butler","Byrd","Caldwell","Campbell","Cannon","Carlson","Carpenter","Carr","Carroll","Carter","Castillo","Castro","Chambers","Chandler","Chapman","Chavez","Clark","Cobb","Cohen","Cole","Coleman","Collins","Conner","Cook","Cooper","Cox","Craig","Crawford","Cross","Cruz","Cummings","Cunningham","Curry","Curtis","Daniel","Daniels","Davidson","Davis","Dawson","Day","Dean","Delgado","Dennis","Diaz","Dixon","Douglas","Doyle","Duncan","Dunn","Edwards","Elliott","Ellis","Erickson","Estrada","Evans","Farmer","Ferguson","Fernandez","Fields","Fisher","Fitzgerald","Fleming","Fletcher","Flores","Flowers","Floyd","Ford","Foster","Fowler","Fox","Francis","Franklin","Frazier","Freeman","Fuller","Garcia","Gardner","Garner","Garrett","Garza","George","Gibbs","Gibson","Gilbert","Glover","Gomez","Gonzales","Gonzalez","Goodman","Goodwin","Gordon","Graham","Grant","Graves","Gray","Green","Greene","Gregory","Griffin","Griffith","Gross","Guerrero","Gutierrez","Guzman","Hale","Hall","Hamilton","Hammond","Hampton","Hansen","Hanson","Hardy","Harmon","Harper","Harris","Harrison","Hart","Harvey","Hawkins","Hayes","Haynes","Henderson","Henry","Hernandez","Herrera","Hicks","Higgins","Hill","Hines","Hodges","Hoffman","Holland","Holmes","Holt","Hopkins","Horton","Howard","Howell","Hubbard","Hudson","Hughes","Hunt","Hunter","Ingram","Jackson","Jacobs","James","Jenkins","Jennings","Jensen","Jimenez","Johnson","Johnston","Jones","Jordan","Joseph","Keller","Kelley","Kelly","Kennedy","Kim","King","Knight","Lambert","Lane","Larson","Lawrence","Lawson","Lee","Leonard","Lewis","Lindsey","Little","Long","Lopez","Love","Lowe","Lucas","Lynch","Lyons","Mack","Maldonado","Malone","Mann","Manning","Marshall","Martin","Martinez","Mason","Matthews","Maxwell","May","Mccarthy","Mccoy","Mcdaniel","Mcdonald","Mcgee","Mckinney","Medina","Mendez","Mendoza","Meyer","Miles","Miller","Mills","Mitchell","Montgomery","Moody","Moore","Morales","Moreno","Morgan","Morris","Morrison","Moss","Mullins","Munoz","Murphy","Murray","Myers","Neal","Nelson","Newman","Newton","Nguyen","Nichols","Norman","Norris","Obrien","Oliver","Olson","Ortega","Ortiz","Osborne","Owens","Page","Palmer","Parker","Parks","Patterson","Patton","Paul","Payne","Pearson","Pena","Perez","Perkins","Perry","Peters","Peterson","Phillips","Pierce","Pope","Porter","Potter","Powell","Powers","Price","Quinn","Ramirez","Ramos","Ramsey","Ray","Reed","Reese","Reeves","Reid","Reyes","Reynolds","Rhodes","Rice","Richards","Richardson","Riley","Rios","Rivera","Robbins","Roberts","Robertson","Robinson","Rodgers","Rodriguez","Rodriquez","Rogers","Romero","Rose","Ross","Rowe","Ruiz","Russell","Ryan","Salazar","Sanchez","Sanders","Sandoval","Santiago","Santos","Schmidt","Schneider","Schultz","Scott","Sharp","Shaw","Shelton","Sherman","Silva","Simmons","Simpson","Sims","Smith","Snyder","Soto","Spencer","Stanley","Steele","Stephens","Stevens","Stevenson","Stewart","Stokes","Stone","Strickland","Sullivan","Sutton","Swanson","Tate","Taylor","Terry","Thomas","Thompson","Thornton","Todd","Torres","Townsend","Tucker","Turner","Tyler","Valdez","Vargas","Vasquez","Vaughn","Vega","Wade","Wagner","Walker","Wallace","Walsh","Walters","Walton","Ward","Warner","Warren","Washington","Watkins","Watson","Watts","Weaver","Webb","Weber","Webster","Welch","Wells","West","Wheeler","White","Williams","Williamson","Willis","Wilson","Wolfe","Wood","Woods","Wright","Yates","Young")

$FemaleNames = @("Ada","Adrienne","Agnes","Alberta","Alexandra","Alice","Alicia","Alison","Allison","Alma","Amanda","Amber","Amelia","Amy","Ana","Andrea","Angela","Angelica","Angelina","Angie","Anita","Ann","Anna","Anne","Annette","Annie","Antoinette","April","Arlene","Ashley","Audrey","Barbara","Beatrice","Becky","Belinda","Bernadette","Bernice","Bertha","Bessie","Beth","Bethany","Betty","Beulah","Beverly","Billie","Blanca","Blanche","Bobbie","Bonnie","Brandi","Brandy","Brenda","Bridget","Brittany","Brooke","Candace","Candice","Carla","Carmen","Carol","Carole","Caroline","Carolyn","Carrie","Cassandra","Catherine","Cathy","Cecilia","Celia","Charlene","Charlotte","Chelsea","Cheryl","Christina","Christine","Christy","Cindy","Claire","Clara","Claudia","Colleen","Connie","Constance","Cora","Courtney","Crystal","Cynthia","Daisy","Dana","Danielle","Darlene","Dawn","Deanna","Debbie","Deborah","Debra","Della","Delores","Denise","Diana","Diane","Dianna","Dianne","Dolores","Donna","Dora","Doris","Dorothy","Edith","Edna","Eileen","Elaine","Eleanor","Elena","Elizabeth","Ella","Ellen","Elsie","Emily","Emma","Erica","Erika","Erin","Erma","Ernestine","Estelle","Esther","Ethel","Eunice","Eva","Evelyn","Fannie","Faye","Felicia","Flora","Florence","Frances","Francis","Gail","Gayle","Geneva","Genevieve","Georgia","Geraldine","Gertrude","Gina","Gladys","Glenda","Gloria","Grace","Guadalupe","Gwendolyn","Hannah","Harriet","Hattie","Hazel","Heather","Heidi","Helen","Hilda","Holly","Ida","Inez","Irene","Iris","Irma","Isabel","Jackie","Jacqueline","Jacquelyn","Jamie","Jan","Jane","Janet","Janice","Janie","Jasmine","Jean","Jeanette","Jeanne","Jeannette","Jennie","Jennifer","Jenny","Jessica","Jessie","Jill","Jo","Joan","Joann","Joanna","Joanne","Jodi","Jody","Johnnie","Josephine","Joy","Joyce","Juana","Juanita","Judith","Judy","Julia","Julie","June","Kara","Karen","Kari","Karla","Katherine","Kathleen","Kathryn","Kathy","Katie","Katrina","Kay","Kayla","Kelli","Kelly","Kendra","Kim","Kimberly","Krista","Kristen","Kristi","Kristin","Kristina","Kristine","Kristy","Krystal","Latoya","Laura","Lauren","Laurie","Leah","Lee","Lena","Leona","Leslie","Lillian","Lillie","Linda","Lindsay","Lindsey","Lisa","Lois","Lola","Loretta","Lori","Lorraine","Louise","Lucille","Lucy","Lula","Luz","Lydia","Lynda","Lynn","Lynne","Mabel","Mable","Madeline","Mae","Maggie","Mamie","Marcella","Marcia","Margaret","Margarita","Margie","Marguerite","Maria","Marian","Marianne","Marie","Marilyn","Marion","Marjorie","Marlene","Marsha","Martha","Mary","Maryann","Mattie","Maureen","Maxine","Megan","Melanie","Melinda","Melissa","Melody","Meredith","Michele","Michelle","Mildred","Minnie","Miriam","Misty","Molly","Monica","Monique","Muriel","Myra","Myrtle","Nadine","Nancy","Naomi","Natalie","Natasha","Nellie","Nichole","Nicole","Nina","Nora","Norma","Olga","Olivia","Opal","Pam","Pamela","Pat","Patricia","Patsy","Patty","Paula","Paulette","Pauline","Pearl","Peggy","Penny","Phyllis","Priscilla","Rachael","Rachel","Ramona","Rebecca","Regina","Renee","Rhonda","Rita","Roberta","Robin","Robyn","Rosa","Rosalie","Rose","Rosemary","Rosie","Roxanne","Ruby","Ruth","Sabrina","Sadie","Sally","Samantha","Sandra","Sandy","Sara","Sarah","Shannon","Sharon","Sheila","Shelia","Shelley","Shelly","Sheri","Sherri","Sherry","Sheryl","Shirley","Sonia","Sonya","Sophia","Stacey","Stacy","Stella","Stephanie","Sue","Susan","Susie","Suzanne","Sylvia","Tamara","Tammy","Tanya","Tara","Teresa","Terri","Terry","Thelma","Theresa","Tiffany","Tina","Toni","Tonya","Tracey","Traci","Tracy","Valerie","Vanessa","Velma","Vera","Verna","Veronica","Vicki","Vickie","Vicky","Victoria","Viola","Violet","Virginia","Vivian","Wanda","Wendy","Whitney","Willie","Wilma","Yolanda","Yvette","Yvonne")

$MaleNames = @("Aaron","Abraham","Adam","Adrian","Alan","Albert","Alberto","Alejandro","Alex","Alexander","Alfonso","Alfred","Alfredo","Allan","Allen","Alton","Alvin","Andre","Andres","Andrew","Andy","Angel","Angelo","Anthony","Antonio","Archie","Armando","Arnold","Arthur","Arturo","Austin","Barry","Ben","Benjamin","Bennie","Benny","Bernard","Bill","Billy","Blake","Bob","Bobby","Brad","Bradley","Brandon","Brent","Brett","Brian","Bruce","Bryan","Bryant","Byron","Calvin","Cameron","Carl","Carlos","Carlton","Carroll","Casey","Cecil","Cedric","Cesar","Chad","Charles","Charlie","Chester","Chris","Christian","Christopher","Clarence","Clark","Claude","Clayton","Clifford","Clifton","Clinton","Clyde","Cody","Colin","Corey","Cory","Craig","Curtis","Dale","Damon","Dan","Dana","Daniel","Danny","Darrell","Darren","Darryl","Daryl","Dave","David","Dean","Delbert","Dennis","Derek","Derrick","Devin","Dominic","Don","Donald","Donnie","Doug","Douglas","Duane","Dustin","Dwayne","Dwight","Earl","Earnest","Ed","Eddie","Edgar","Edmund","Eduardo","Edward","Edwin","Elmer","Enrique","Eric","Erik","Ernest","Ernesto","Eugene","Evan","Everett","Felipe","Felix","Fernando","Floyd","Forrest","Francis","Francisco","Frank","Franklin","Fred","Freddie","Frederick","Fredrick","Gabriel","Garrett","Garry","Gary","Gene","Geoffrey","George","Gerald","Gerard","Gerardo","Gilbert","Glen","Glenn","Gordon","Grant","Greg","Gregg","Gregory","Guadalupe","Guillermo","Gustavo","Guy","Harold","Harry","Harvey","Hector","Henry","Herbert","Herman","Homer","Horace","Howard","Hubert","Hugh","Ian","Ira","Irving","Isaac","Israel","Ivan","Jack","Jackie","Jacob","Jaime","Jake","James","Jamie","Jared","Jason","Javier","Jay","Jean","Jeff","Jeffery","Jeffrey","Jeremiah","Jeremy","Jermaine","Jerome","Jerry","Jesse","Jessie","Jesus","Jim","Jimmie","Jimmy","Joe","Joel","Joey","John","Johnathan","Johnnie","Johnny","Jon","Jonathan","Jonathon","Jordan","Jorge","Jose","Joseph","Joshua","Juan","Julian","Julio","Julius","Justin","Karl","Keith","Kelly","Kelvin","Ken","Kenneth","Kenny","Kent","Kerry","Kevin","Kim","Kirk","Kristopher","Kurt","Kyle","Lance","Larry","Lawrence","Lee","Leland","Leo","Leon","Leonard","Leroy","Leslie","Lester","Levi","Lewis","Lionel","Lloyd","Lonnie","Loren","Lorenzo","Louis","Lowell","Lucas","Luis","Luke","Luther","Lyle","Lynn","Mack","Malcolm","Manuel","Marc","Marco","Marcos","Marcus","Mario","Marion","Mark","Marshall","Martin","Marvin","Mathew","Matt","Matthew","Maurice","Max","Melvin","Michael","Micheal","Miguel","Mike","Milton","Mitchell","Morris","Myron","Nathan","Nathaniel","Neal","Neil","Nelson","Nicholas","Nick","Noel","Norman","Oliver","Omar","Orlando","Oscar","Otis","Owen","Pablo","Patrick","Paul","Pedro","Perry","Pete","Peter","Philip","Phillip","Preston","Rafael","Ralph","Ramon","Randall","Randolph","Randy","Raul","Ray","Raymond","Reginald","Rene","Rex","Ricardo","Richard","Rick","Rickey","Ricky","Robert","Roberto","Robin","Roderick","Rodney","Rodolfo","Roger","Roland","Ron","Ronald","Ronnie","Roosevelt","Ross","Roy","Ruben","Rudolph","Rudy","Rufus","Russell","Ryan","Salvador","Salvatore","Sam","Sammy","Samuel","Scott","Sean","Sergio","Seth","Shane","Shannon","Shaun","Shawn","Sherman","Sidney","Simon","Spencer","Stanley","Stephen","Steve","Steven","Stuart","Sylvester","Ted","Terrance","Terrence","Terry","Theodore","Thomas","Tim","Timothy","Todd","Tom","Tommy","Tony","Tracy","Travis","Trevor","Troy","Tyler","Tyrone","Vernon","Victor","Vincent","Virgil","Wade","Wallace","Walter","Warren","Wayne","Wendell","Wesley","Wilbert","Wilbur","Willard","William","Willie","Willis","Wilson","Liam","Woodrow","Zachary")

$Offices = @("Accounting","Sales","Human Resources","Manufacturing","Maintenance","Engineering","Legal","Data Processing","Secretarial Pool","Administration","Operations","Telemarketing","Shipping","Packaging & Delivery","Safety & Quality")

$Descriptions = @("Manager","Director","Associate","Team Member","Contractor","Intern")

# Collections of computer account properties to be randomly combined (OS:VersionNumber:ServicePackNumber).
$OperatingSystems = @("Windows XP Professional:5.1:3","Windows Vista Enterprise:6.0:2","Windows 7 Enterprise:6.1:1")
$FormFactors = @("LAP-","WKS-","TRM-","PDA-") #Max of four chars here.

# Save current working directory.
$CurrentPWD = $pwd

# Import ActiveDirectory module and switch to AD: drive.
if (get-module activedirectory) { cd ad:\ } 
else { import-module activedirectory ; cd ad:\ } 

# Test for AD: drive and get the domain's DN and DNS names.
if ($pwd.path -notlike "AD*") { "`nFailed to enter AD: drive, quitting!" ; exit } 
$DnsDomainName = $(get-addomain).DNSRoot
$DN = $(get-addomain).DistinguishedName

# Get the $TargetOU OU or create it if it doesn't exist.
$OU = Get-ADOrganizationalUnit -SearchBase $DN -SearchScope OneLevel -Filter $('Name -like "' + $TargetOU + '"')
if (-not $OU) 
{
    "`nCreating the $TargetOU OU in the $DnsDomainName domain...`n"
    New-ADOrganizationalUnit -Name $TargetOU -Path $DN -ProtectedFromAccidentalDeletion $False 
    if ($?) { $OU = Get-ADOrganizationalUnit -SearchBase $DN -SearchScope OneLevel -Filter $('Name -like "' + $TargetOU + '"') } 
    else { "`nFailed to create $TargetOU OU, quitting!" ; exit }
}
if ($OU.ObjectClass -ne "organizationalUnit") { "`nFailed to get the $TargetOU OU, quitting!" ; exit }


# Create user accounts in the $TargetOU.
while ( $NumberOfNewUsers -gt 0 )
{
    $ln = $LastNames[$(get-random -min 0 -max $LastNames.count)]
    
    if (get-random -min 0 -max 2)     
    { $fn = $MaleNames[$(get-random -min 0 -max $MaleNames.count)] } 
    else
    { $fn = $FemaleNames[$(get-random -min 0 -max $FemaleNames.count)] }

    $display = "$fn $ln"
    
    if ($fn.length -ge 3) { $username = $fn.substring(0,3) } else { $username = $fn.substring(0,1) }
    if ($ln.length -le 17) { $username += $ln } else { $username += $ln.substring(0,17) } 
    $username = $username.tolower()
    
    $desc = $Descriptions[$(get-random -min 0 -max $Descriptions.count)] 
    $office = $Offices[$(get-random -min 0 -max $Offices.count)]
    $phone = "$(get-random -min 203 -max 984).$(get-random -min 303 -max 792).$(get-random -min 1002 -max 9984)"
    
    #Intial passphrase is "phonenumber Pw phonenumber", which will be different but predictable for each user!
    $password = convertto-securestring "$phone Pw $phone" -asplaintext -force  
    
    new-aduser -name $display -displayname $display -samaccountname $username `
               -enabled $true -givenname $fn -surname $ln -description "$desc in $office" `
               -office $office -emailaddress $($username + "@" + $DnsDomainName) `
               -userprincipalname $($username + "@" + $DnsDomainName) -officephone $phone `
               -path $OU.DistinguishedName -accountpassword $password -erroraction SilentlyContinue
               
    if ($?) { $NumberOfNewUsers-- ; "$display,$username,$phone" }
}


# Create computer accounts in the $TargetOU.
while ( $NumberOfNewComputers -gt 0 )
{
    $os = $OperatingSystems[$(get-random -min 0 -max $OperatingSystems.count)] -split ":"
    $version = $os[1]
    $sp = $os[2]
    $os = $os[0]
    
    $cname = $FormFactors[$(get-random -min 0 -max $FormFactors.count)]
    1..10 | foreach { $cname += [Char] $(get-random -min 65 -max 90) }
        
    new-adcomputer -name $cname -displayname $cname -samaccountname $cname `
                   -enabled $true -operatingsystem $os -operatingsystemservicepack $sp `
                   -operatingsystemversion $version -path $OU.DistinguishedName `
                   -description $os -erroraction SilentlyContinue
               
    if ($?) { $NumberOfNewComputers-- ; "$cname,$os" }
}


cd $CurrentPWD


