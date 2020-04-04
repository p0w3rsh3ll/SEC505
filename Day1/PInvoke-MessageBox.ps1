# PowerShell can use the Platform Invoke (P/Invoke) features of .NET to 
# call unmanaged functions in DLLs.  The code below alows you to pop
# up a dialog box to a user and capture the button the user clicked, but
# it's mainly to demonstrate Add-Type for the sake of P/Invoke.



function MessageBox ($Message = "Body of the message.", $Caption = "In The Titlebar", $Type = "yesnocancel", $Icon = "information")
{
    Switch ($Type.ToLower())
    {
        'ok'                     { [Int] $Type = 0x0 } 
        'okcancel'               { [Int] $Type = 0x1 }
        'abortretryignore'       { [Int] $Type = 0x2 }
        'yesnocancel'            { [Int] $Type = 0x3 }
        'yesno'                  { [Int] $Type = 0x4 }
        'retrycancel'            { [Int] $Type = 0x5 }
        'canceltryagaincontinue' { [Int] $Type = 0x6 }
        default                  { [Int] $Type = 0x0 } 
    }


    Switch ($Icon.ToLower())
    {
        'stop'         { [Int] $Icon = 0x10 }
        'exclamation'  { [Int] $Icon = 0x30 }
        'information'  { [Int] $Icon = 0x40 }
        default        { [Int] $Icon = 0x40 } 
    }

    $Type = $Type + $Icon
    
    Try  
    { 
        $signature = '[DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern uint MessageBox(IntPtr hWnd, String text, String caption, uint type);'
        $MsgBox = add-type -passthru -name "MessageBox137553" -memberdefinition $signature
    } Catch { } 

    $return = $MsgBox::MessageBox(0,$Message,$Caption,$Type)   
    
    Switch ( $return )
    {
        0  {"function-call-failed"}
        1  {"ok"}
        2  {"cancel"}
        3  {"abort"}
        4  {"retry"}
        5  {"ignore"}
        6  {"yes"}
        7  {"no"}
        10 {"tryagain"}
        11 {"continue"}
        default {"unknown"}
    }
}


$clicked = MessageBox -Message "This demonstrates P/Invoke to create a dialog box." -Caption "Click A Button" -Type 'yesnocancel' -Icon 'exclamation'

"`nUser clicked on $($clicked.toupper()) `n"




#
# For more information about MessageBox:
#    http://msdn.microsoft.com/en-us/library/windows/desktop/ms645505%28v=vs.85%29.aspx
#
# For more information about Platform Invoke Services:
#    http://www.leeholmes.com/blog/2009/01/19/powershell-pinvoke-walkthrough/
#    http://msdn.microsoft.com/en-us/library/aa288468%28v=vs.71%29.aspx
#    http://www.pinvoke.net
#


