
<!--- send payslip --->
<cftry>
	<cfobject component="code/clients" name="cust">
	<cfparam name="sendTo" default="#application.company.email_accounts#">
	<cfparam name="msgText" default="Please see attached document">
	<cfparam name="attachment" default="sample.txt">
	<cfset filePath = "#application.site.dir_data#payslips\">
	<cfif len(sendTo)>
		<cfmail		
			debug="yes"
			to="#sendTo#"
			bcc="#application.siteclient.cltMailSupport#"
			from="#application.siteclient.cltMailSupport#"
			server="#application.siteclient.cltMailServer#"
			username="#application.siteclient.cltMailAccount#"
			password="#cust.DecryptStr(application.siteclient.cltMailPassword,application.siteRecord.scCode1)#"
			subject="#application.siteclient.cltCompanyName# - Payslip">
			<cfmailpart charset="utf-8" type="text/plain">#cust.textMessage(msgText)#</cfmailpart>	 <!---always put plain first --->
			<cfmailpart charset="utf-8" type="text/html">#msgText#</cfmailpart>
			<cfif len(attachment)><cfmailparam type="application/pdf" disposition="attachment" file="#filePath##attachment#"></cfmailparam></cfif>
		</cfmail>
		<cfoutput>File was sent to = "#sendTo#"</cfoutput>
	<cfelse>
		<cfoutput>No email address for #person#</cfoutput>
	</cfif>

<cfcatch type="any">
	<cfoutput>
		<h1>An error occurred.</h1>
		<p>#cfcatch.Message#</p>
		to = "#sendTo#" <br>
		msg = #msgText# <br>
		attachment = #attachment# <br>
	</cfoutput>
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

