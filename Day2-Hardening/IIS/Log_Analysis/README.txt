# To show a summary of matches in the log from the signatures file:

.\Search-TextLog.ps1 -LogFile IIS.log -PatternsFile Signatures.txt | format-table -auto


# To extract all the lines from the log which match one or more signatures:

.\Search-TextLog.ps1 -LogFile IIS.log -PatternsFile Signatures.txt -ShowMatchedLines


