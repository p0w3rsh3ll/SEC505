<# ###############################################################################
.DESCRIPTION
This script demos how to pop up a graphical dialog box to a user which asks a
question, displays one or more buttons with labels with mouse-over help text,
then returns back to the script which button the user clicked. For more examples:

  https://technet.microsoft.com/en-us/library/ff730939.aspx

See the PopUp.ps1 script for another example which includes a timeout.

#> ###############################################################################


$Title = "Appears In Titlebar At Top"

$Question = "This text is in the body of the dialog box and `n may include many lines with backtick-n newlines."

#Button0
$buttonTxt0 = "&Button Zero"
$buttonHelp0 = "Appears when mouse hovers over 0 button."
$button0 = New-Object System.Management.Automation.Host.ChoiceDescription $buttonTxt0,$buttonHelp0

#Button1
$buttonTxt1 = "&Button One"
$buttonHelp1 = "Appears when mouse hovers over 1 button."
$button1 = New-Object System.Management.Automation.Host.ChoiceDescription $buttonTxt1,$buttonHelp1

#Button2
$buttonTxt2 = "&Button Two"
$buttonHelp2 = "Appears when mouse hovers over 2 button."
$button2 = New-Object System.Management.Automation.Host.ChoiceDescription $buttonTxt2,$buttonHelp2

#Create a list of one or more buttons:
$ButtonList = [System.Management.Automation.Host.ChoiceDescription[]]($button0,$button1,$button2)

#Decide which button number should be the default:
$DefaultButton = 0

#Display the pop-up GUI to the user and wait forever for a click:
$answer = $host.ui.PromptForChoice($Title, $Question, $ButtonList, $DefaultButton) 

#Do something useful with the user input:
"The user clicked on button number " + $answer



