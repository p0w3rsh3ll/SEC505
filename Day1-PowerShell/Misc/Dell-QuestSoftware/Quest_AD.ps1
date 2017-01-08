###############################################################################
# NOTE: None of these commands will work unless you have already installed
#       the ActiveRoles AD snap-in from Quest:
#       http://www.quest.com/activeroles-server/arms.aspx
###############################################################################


# To load the snap-in with the Quest cmdlets into your current shell:

add-pssnapin Quest.ActiveRoles.ADManagement


# To see a list of all Quest-related cmdlets (they all have "QAD" in their names):

get-command Quest.ActiveRoles.ADManagement\*


# Before any AD cmdlets can be run, you have to establish an authenticated connection to a domain controller.  \

$dc = connect-qadservice -service 'localhost'
$dc | format-list *

# To be prompted for different credentials and connect with those credentials instead:

$me = get-credential
$dc = connect-qadservice -service '10.4.3.5' -credential $me


# To get all user and computer objects from the domain:

get-qaduser
get-qadcomputer

# To view all the properties of the Administrator account from the giac.org domain:

get-qaduser administrator@giac.org | format-list *
get-qaduser giac\administrator | format-list *
get-qaduser 'cn=Administrator,cn=Users,dc=giac,dc=org'|fl *

# To reset the passphrase of the Guest account in the giac.org domain:

set-qaduser giac\guest -userpassword 'fly tomatoes at nite'

# To change the pager number of the Justin account in the giac.org domain:

set-qaduser justin@giac.org -pager '(214)328-2292'


# To change the e-mail address for Justin in the giac.org domain:

set-qaduser justin@giac.org -objectattributes @{mail='justin@giac.org'}


# To change Justin's e-mail address, description and home phone number properties:

set-qaduser justin@giac.org -objectattributes @{mail='justin@giac.org'; description='IT Engineer'; homephone='(222)333-4444'}


# To create a user named "Jessica Parker" in the Users container of the giac.org domain:

new-qaduser -name 'Jessica Parker' -parentcontainer 'cn=Users,dc=giac,dc=org' -userpassword 'mice ate my legs again'  -samaccountname 'JessicaP' -objectattributes @{useraccountcontrol='544'}


# To delete a user named "Jessica Parker" in the Users container of the giac.org domain:

remove-qadobject 'CN=Jessica Parker,CN=Users,DC=giac,DC=org'


# To recursively delete an organizational unit named "Test" from the giac.org domain:

remove-qadobject 'OU=Test,DC=giac,DC=org' -DeleteTree -Force


# To list each group's name, scope (domain local, global, universal) and type (security or distribution group):

get-qadgroup | format-table name,groupscope,grouptype -auto


# To list the members of the Domain Admins group:

get-qadgroupmember 'Domain Admins'


# To add the Administrator account in the giac.org to the Guests group:

add-qadgroupmember 'Guests' -member 'administrator@giac.org'


# To remove the Administrator account from the Guests group in the giac.org domain:

remove-qadgroupmember 'Guests' -member 'administrator@giac.org'


