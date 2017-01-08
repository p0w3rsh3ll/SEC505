'*************************************************************************************
' Script Name: ISA_Add-Remove_Cached_File.vbs
'     Version: 1.0
'      Author: Jason Fossen (www.isascripts.org)
'Last Updated: 9.Aug.2005
'     Purpose: Add or remove individual files from the Web Proxy cache.
'       Notes: URLs below can be either HTTP:// or FTP://
'              If you want to view and delete all the files cached for a particular
'              web site, get CACHEDIR.EXE from www.microsoft.com/isaserver/.
'              Also, you apparently cannot delete data cached in RAM with FetchURL().
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without warranties or guarantees of any kind.
'              USE AT YOUR OWN RISK.  Test on non-production servers first!  
'*************************************************************************************


Function FetchUrlToCache(sURL, iMinutesToCache)
    On Error Resume Next
    
    'FPCFethUrlsFlags enumerated type for the FetchUrl method:
    Const fpcFetchTtlIfNone      = 1   'Use custom TTL (iMinutesToCache) only if server doesn't specify one.
    Const fpcFetchTtlOverride    = 2   'Override any headers from server pertaining to caching.  
    Const fpcFetchSynchronous    = 4   'NA. Obsolete.  
    Const fpcFetchNoArrayRouting = 8   'Cache locally, even if CARP indicates to cache elsewhere.
    Const fpcFetchForceCache     = 16  'Cache, even if not usually cacheable.
    Const fpcFetchDynamicCache   = 32  'Cache, even if content is dynamically generated.
    
    Dim oFPC, oCacheContents
    Set oFPC = CreateObject("FPC.Root")
    Set oCacheContents = oFPC.GetContainingArray.Cache.CacheContents

    oCacheContents.FetchURL sURL, sURL, iMinutesToCache, fpcFetchTtlIfNone
    
    If Err.Number = 0 Then FetchUrlToCache = True Else FetchUrlToCache = False
    On Error Goto 0
End Function




'
' Note: you must pass in a full URL to a specific file, not just a FQDN or a wildcard.
'       This function does not recursively delete all files for a site from cache.
'
Function DeleteUrlToOneFileFromCache(sURL)
    On Error Resume Next
    
    Dim oFPC, oCacheContents
    Set oFPC = CreateObject("FPC.Root")
    Set oCacheContents = oFPC.GetContainingArray.Cache.CacheContents

    oCacheContents.FetchURL "", sURL, 0, 0 

    If Err.Number = -2147012738 Then Err.Clear 'Not a path to a file, but return True anyway (!!!).
    If Err.Number = -2147024894 Then Err.Clear 'File not in cache, so return True.
   
    If Err.Number = 0 Then DeleteUrlToOneFileFromCache = True Else DeleteUrlToOneFileFromCache = False
    On Error Goto 0
End Function




'
' You can use HTTP or FTP to get a file from one location, perhaps a local server, and cache it as though
' it came from a different location or even from a different protocol.  sGetFileFrom is an HTTP or FTP URL
' to a file you want to cache locally; sCacheFileAs is the HTTP or FTP URL under which you want to save it
' in the ISA cache, i.e., this is the URL that clients will use when they get it from the cache.  Example:
' getting a 200MB Service Pack file on CD-ROM, putting it on a local FTP server, uploading that file from the
' FTP server (sGetFileFrom) and caching it under the HTTP URL that users will likely use to request it from
' the web (sCacheFileAs) so that it isn't pulled from the Internet (or from the FTP server).  Play with the
' example down below and then open "ftp://ftp.microsoft.com/save-as.gif" in a Web Proxy client browser To
' get a feel for what's going on.  Combine this function with the ParseInputFile.vbs script to pre-load an
' entire set of files or site as defined in a text file.
'
Function CacheFileUnderDifferentUrl(sGetFileFrom, sCacheFileAs, iMinutesToCache)
    On Error Resume Next
    
    'FPCFethUrlsFlags enumerated type for the FetchUrl method:
    Const fpcFetchTtlIfNone      = 1   'Use custom TTL (iMinutesToCache) only if server doesn't specify one.
    Const fpcFetchTtlOverride    = 2   'Override any headers from server pertaining to caching.  
    Const fpcFetchSynchronous    = 4   'NA. Obsolete.  
    Const fpcFetchNoArrayRouting = 8   'Cache locally, even if CARP indicates to cache elsewhere.
    Const fpcFetchForceCache     = 16  'Cache, even if not usually cacheable.
    Const fpcFetchDynamicCache   = 32  'Cache, even if content is dynamically generated.
    
    Dim oFPC, oCacheContents
    Set oFPC = CreateObject("FPC.Root")
    Set oCacheContents = oFPC.GetContainingArray.Cache.CacheContents

    oCacheContents.FetchURL sGetFileFrom, sCacheFileAs, iMinutesToCache, fpcFetchTtlOverride
    
    If Err.Number = 0 Then CacheFileUnderDifferentUrl = True Else CacheFileUnderDifferentUrl = False
    On Error Goto 0
End Function






'END OF SCRIPT************************************************************************






'If FetchUrlToCache("http://isascripts.org/images/isa-clients.gif", 20) Then WScript.Echo "good cache" 
'If DeleteUrlToOneFileFromCache("http://isascripts.org/images/isa-clients.gif") Then WScript.Echo "good delete" Else WScript.Echo Err.Number & "--" & Err.Description
'If CacheFileUnderDifferentUrl("http://isascripts.org/images/isa-clients.gif", "ftp://ftp.microsoft.com/save-as.gif", 20) Then WScript.Echo "good cache-as" Else WScript.Echo Err.Number & "--" & Err.Description


