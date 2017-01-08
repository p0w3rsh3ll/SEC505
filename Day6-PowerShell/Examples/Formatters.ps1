
get-item hklm:\software | format-list *
get-item hklm:\software | fl *


get-service | format-table Name,DisplayName,Status -autosize
get-service | format-list *


get-item hklm:\software\microsoft | fl name,subkeycount


get-childitem $env:windir\*.exe | format-table *
get-childitem $env:windir\*.exe | ft *


dir $env:windir\*.exe| ft name,lastaccesstime -autosize


dir $env:windir | format-wide name -column 3
dir $env:windir | fw name -col 3


get-item $env:windir | format-custom * -depth 1
get-item $env:windir | format-custom * -depth 2

