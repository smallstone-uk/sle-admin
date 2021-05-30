<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>EMail Client Invoices</title>
<link rel="stylesheet" type="text/css" href="css/main.css">

<script src="scripts/jquery-1.9.1.js"></script>
<script>
	$(document).ready(function(e) {
		$('.selectAllOnList').click(function(event) {
			if (this.checked) {
				$('.selectitem').prop({checked: true});
				$('.selectAllOnList').prop({checked: true});
			} else {
				$('.selectitem').prop({checked: false});
				$('.selectAllOnList').prop({checked: false});
			}
		})
	});
</script>

</head>

<!---<cffunction name="textMessage" access="public" returntype="string" hint="Converts an html email message into a nicely formatted plain text message with line breaks">
    <cfargument name="string" required="true" type="string">
    <cfscript>
        var pattern = "<br />";
        var CRLF = chr(13) & chr(10);
        var message = ReplaceNoCase(arguments.string, pattern, CRLF , "ALL");
        pattern = "<[^>]*>";
    </cfscript>
    <cfreturn REReplaceNoCase(message, pattern, "" , "ALL")>
</cffunction>
--->
<cfparam name="sendMsgs" default="false">
<cfparam name="attachLetter" default="Charges-2021.pdf">	<!--- no spaces in name please --->
<cfset attachFile1="#application.site.dir_invoices#letters/#attachLetter#">
<cftry>
	<cfobject component="code/clients" name="cust">
	<cfset parms={}>
	<cfset parms.datasource=application.site.datasource1>
	<cfset parms.emailTemplate='invoice'>
	<cfset emailList=cust.EmailLatestInvoice(parms)>
	<cfoutput>
		<h1>Current invoice date: #emailList.invDate#</h1>
		Attach Letter: #attachFile1#
		<cfif FileExists(attachFile1)>
			<cfset attachment = true>
			...Found
		<cfelse>
			<cfset attachment = false>
			...NOT Found
		</cfif><br />
			
		<form enctype="multipart/form-data" method="post">
			
			<table class="tableList">
				<tr>
					<th><input type="checkbox" name="selectAllOnList" class="selectAllOnList" style="width:20px; height:20px;"></th>
					<th>Ref</th>
					<th>name</th>
					<th>email</th>
					<th>trnRef</th>
					<th></th>
					<th></th>
				</tr>
				<cfloop array="#emailList.msgs#" index="msg">
					<tr>
						<td><input type="checkbox" name="sendme" class="selectitem" value="#msg.cltRef#" /></td>
						<td>#msg.cltRef#</td>
						<td>#msg.name#</td>
						<td>#msg.email#</td>
						
						<td>#msg.trnRef#</td>
						<td><a href="#msg.url#" target="_blank"><img src="images/pdfIcon.gif" /></a></td>
						<cfif sendMsgs AND ListFind(form.sendMe,msg.cltRef,",")>
							<cfif StructKeyExists(form,"testMsgs")>
								<cfset sendTo="steven@shortlanesendstore.co.uk">
							<cfelse><cfset sendTo=msg.email></cfif>
							<cfset msgText = "Dear #msg.name#,<br />#ParagraphFormat(msg.text)#">
							<cfmail 
								to="#sendTo#" 
								bcc="#application.siteclient.cltMailOffice#"
								from="#application.siteclient.cltMailOffice#"
								server="#application.siteclient.cltMailServer#"
								username="#application.siteclient.cltMailAccount#"
								password="rNUy5XBXuZfxkdw"
								<!---password="#cust.DecryptStr(application.siteclient.cltMailPassword,application.siteRecord.scCode1)#"--->
								subject="#msg.subject# - #application.siteclient.cltCompanyName#">
								<cfmailpart charset="utf-8" type="text/plain">#cust.textMessage(msgText)#</cfmailpart>
								<cfmailpart charset="utf-8" type="text/html">#msgText#</cfmailpart>
								<cfmailparam type="application/pdf" disposition="attachment" file="#msg.attach#"></cfmailparam>
								<cfif len(attachLetter) AND attachment>
									<cfmailparam type="application/pdf" disposition="attachment" file="#attachFile1#"></cfmailparam>								
								</cfif>
							</cfmail>
							<cffile action="append" addnewline="yes" 
								file="D:\HostingSpaces\SLE-Production\sle-admin.co.uk\data\logs\email\mail-#DateFormat(Now(),'yyyymmdd')#.txt"
								output="Message sent to: #sendTo# - #msg.subject# #msg.cltRef#">
							<td>sent to #sendTo#</td>
						<cfelse>
							<td>not sent</td>
						</cfif>
					</tr>
				</cfloop>
				<tr>
					<td colspan="7">#ArrayLen(emailList.msgs)#</td>
				</tr>
				<tr>
					<td colspan="7">
						<input type="checkbox" name="testMsgs" value="1" checked="checked" />Send to test address?<br />
						<input type="checkbox" name="sendMsgs" value="1" />Send these messages?<br />
						<input type="submit" name="btnSend" value="send messages" />
					</td>
				</tr>
			</table>
		</form>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
<body>
</body>
</html>
