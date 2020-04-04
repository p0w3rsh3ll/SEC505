
This folder contains a copy of the OpenPGP public
key of Jason Fossen, the SEC505 course author.

This key may be used with applications such as:

    Pgp4Win     (https://www.gpg4win.org)
    Mailvelope  (https://www.mailvelope.com)
    GnuPG       (https://www.gnupg.org)


But what about PowerShell?  :-) 

For the Mailvelope Key Server, it has an easy-to-use REST interface for PowerShell:

    https://github.com/mailvelope/keyserver/blob/master/README.md#rest-api

For example:

    $key = Invoke-RestMethod -Uri 'https://keys.mailvelope.com/api/v1/key?fingerprint=0a67a610f070037bd6ded0a0b8f01a60977de361' 
    $key.userIds
    $key.keySize
    $key.publicKeyArmored




