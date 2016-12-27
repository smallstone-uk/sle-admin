<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Messages</title>
<link rel="stylesheet" type="text/css" href="css/main.css"/>
</head>

<cfobject component="code/email" name="email">
<cfset parm={}>
<cfset mail=email.ReadMail(parm)>
<cfdump var="#mail#" label="mail" expand="false">
<cfoutput>
	<table width="600" border="1">
	<cfloop query="mail.msgs">
    	<tr>
        	<td>#messagenumber#</td>
        	<td>#date#</td>
        	<td>#from#</td>
        	<td>#Subject#</td>
        </tr>
        <tr><td colspan="4">#htmlbody#</td></tr>
    </cfloop>
   </table>
</cfoutput>
<body>
</body>
</html>