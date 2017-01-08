
param ($adObjectDistinguishedName) 

restore-adobject -identity $adObjectDistinguishedName

# Remember that after querying the deleted objects, you can pipe
# them through where-object, then pipe the results into the
# restore-object cmdlet for doing mass restores.




