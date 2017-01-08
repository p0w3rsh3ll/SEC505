
get-pssnapin | format-list * 

# To see which snap-in makes a given cmdlet available, such as the get-process cmdlet:
  
get-command get-process | format-list Name,DLL



# The following won't work unless you have Quest's snap-in installed:

add-pssnapin Quest.ActiveRoles.ADManagement

# Then to see a list of all Quest-related cmdlets (they all have "QAD" in their names):

get-command Quest.ActiveRoles.ADManagement\*

