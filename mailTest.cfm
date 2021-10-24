<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>EMail Test</title>
</head>

<cfobject component="code/clients" name="cust">
<cfparam name="sendto" default="news@shortlanesendstore.co.uk">
<body>
	<cfoutput> 
		to="#sendTo#" <br />
		bcc="#application.siteclient.cltMailOffice#" <br />
		from="#application.siteclient.cltMailOffice#" <br />
		server="#application.siteclient.cltMailServer#" <br />
		username="#application.siteclient.cltMailAccount#" <br />
		password="#cust.DecryptStr(application.siteclient.cltMailPassword,application.siteRecord.scCode1)#" <br />
		subject="subject - #application.siteclient.cltCompanyName#"> <br />
		cfmailpart charset="utf-8" type="text/plain">cust.textMessage(msgText) <br />
		cfmailpart charset="utf-8" type="text/html">msgText <br />
		cfmailparam type="application/pdf" disposition="attachment" file="msg.attach" <br />
	</cfoutput>
</body>
</html>
