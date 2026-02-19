<cfcomponent displayname="clientFunctions" extends="code/core" hint="clients functions 2015">

	<cffunction name="LoadLatestInvoicesForEmail" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		
		<cftry>
			<cfquery name="loc.QControl" datasource="#args.datasource#">
				SELECT ctlNextInvDate
				FROM tblControl
				WHERE ctlID=1
			</cfquery>
			<cfquery name="loc.QEmail" datasource="#args.datasource#">
				SELECT *
				FROM tblEmail
				WHERE mailRef='#args.emailTemplate#'
				LIMIT 1;
			</cfquery>
			<cfquery name="loc.QClients" datasource="#args.datasource#">
				SELECT cltID,cltRef,cltTitle,cltInitial,cltName,cltCompanyName,cltEMail,cltInvDeliver
				FROM tblClients
				WHERE cltEMail<>''
				AND cltInvDeliver ='email'
				AND cltAccountType<>'N'
				ORDER BY cltName
			</cfquery>
			<cfset loc.result.ctlNextInvDate = loc.QControl.ctlNextInvDate>
			<cfset loc.result.folderName=DateFormat(loc.QControl.ctlNextInvDate,"yy-mm-dd")>
			<cfset loc.QClients=loc.QClients>
			<cfset loc.result.invDate=DateFormat(loc.QControl.ctlNextInvDate,"ddd dd-mmm-yyyy")>
			<cfset loc.records=[]>
			<cfset loc.result.msgs=[]>
			
			<cfloop query="loc.QClients">
				<cfquery name="loc.QLatestTran" datasource="#args.datasource#">
					SELECT trnID,trnDate,trnRef
					FROM tblTrans
					WHERE trnClientRef=#cltRef#
					AND trnType='inv'
					AND trnDate='#DateFormat(loc.QControl.ctlNextInvDate,"yyyy-mm-dd")#'
				</cfquery>
				<cfloop query="loc.QLatestTran">
					<cfset loc.msg={}>
					<cfset loc.msg.name="#loc.QClients.cltTitle# #loc.QClients.cltName#">
					<cfset loc.msg.subject=loc.QEmail.mailSubject>
					<cfset loc.msg.text=loc.QEmail.mailText>
					<cfset loc.msg.email=loc.QClients.cltEMail>
					<cfset loc.msg.cltRef=loc.QClients.cltRef>
					<cfset loc.msg.trnRef=trnRef>
					<cfset loc.msg.url="#application.site.url_invoices##loc.result.folderName#/inv-#trnRef#.pdf">
					<cfset loc.msg.attach="#application.site.dir_invoices##loc.result.folderName#/inv-#trnRef#.pdf">
					<cfset ArrayAppend(loc.result.msgs,loc.msg)>
				</cfloop>
			</cfloop>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="EmailLatestInvoice" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="CheckInvoiceToEmail" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.status = "">
		<cfset loc.result.name = "ehh">

		<cftry>
			<cfquery name="loc.QClient" datasource="#args.datasource#">
				SELECT trnID,trnDate,trnRef, cltID,cltRef,cltTitle,cltInitial,cltName,cltCompanyName,cltEMail,cltInvDeliver
				FROM tblTrans
				INNER JOIN tblClients ON trnClientRef = cltRef
				WHERE trnRef = #args.tranRef#
				AND	trnAccountID = 4
				AND trnType = 'inv'
				AND trnDate = '#DateFormat(args.srchDate,"yyyy-mm-dd")#'
				LIMIT 1;
			</cfquery>
			<cfif loc.QClient.recordCount eq 1>
				<cfloop query="loc.QClient">
					<cfset loc.result.name = "#cltTitle# #cltInitial# #cltName# #cltCompanyName#">
					<cffile action="append" addnewline="yes" 
						file="#application.site.dir_logs#email\mailcheck-#DateFormat(Now(),'yyyymmdd')#.txt"
							output="Message #loc.result.name# #cltEMail# #args.tranRef# #DateFormat(args.srchDate,"yyyy-mm-dd")#">
				</cfloop>
				<cfset loc.result.status = "found">
			<cfelse>
				<cfset loc.result.name = "client missing">
				<cfset loc.result.status = "failed">
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="SendInvoiceByEmail" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cftry>
			<cfquery name="loc.QControl" datasource="#args.datasource#">
				SELECT ctlNextInvDate
				FROM tblControl
				WHERE ctlID = 1
			</cfquery>
			<cfquery name="loc.QEmail" datasource="#args.datasource#">
				SELECT *
				FROM tblEmail
				WHERE mailRef = '#args.emailTemplate#'
				LIMIT 1;
			</cfquery>
			<cfquery name="loc.QTran" datasource="#args.datasource#">
				SELECT trnID,trnDate,trnRef, cltID,cltRef,cltTitle,cltInitial,cltName,cltCompanyName,cltEMail,cltInvDeliver
				FROM tblTrans
				INNER JOIN tblClients ON trnClientRef = cltRef
				WHERE trnRef = #args.tranRef#
				AND trnType = 'inv'
				AND trnDate = '#DateFormat(loc.QControl.ctlNextInvDate,"yyyy-mm-dd")#'
				LIMIT 1;
			</cfquery>
			<cfset loc.result.folderName = DateFormat(loc.QControl.ctlNextInvDate,"yy-mm-dd")>
			<cfset loc.msg = {}>			
			<cfif args.testMsgs>
				<cfset loc.msg.address = "#application.company.email_news#">
			<cfelse><cfset loc.msg.address = loc.QTran.cltEMail></cfif>
					
			<cfset loc.msg.name = "#loc.QTran.cltTitle# #loc.QTran.cltName#">
			<cfset loc.msg.subject = loc.QEmail.mailSubject>
			<cfset loc.msg.text = loc.QEmail.mailText>
			<cfset loc.msg.email = loc.QTran.cltEMail>
			<cfset loc.msg.cltRef = loc.QTran.cltRef>
			<cfset loc.msg.trnRef = loc.QTran.trnRef>
			<cfset loc.msg.url = "#application.site.url_invoices##loc.result.folderName#/inv-#loc.QTran.trnRef#.pdf">
			<cfset loc.msg.attach = "#application.site.dir_invoices##loc.result.folderName#/inv-#loc.QTran.trnRef#.pdf">
		<cffile action="append" addnewline="yes" 
			file="#application.site.dir_logs#email\mailcheck-#DateFormat(Now(),'yyyymmdd')#.txt"
				output="Message #loc.msg.name# #loc.msg.subject# #loc.msg.email# #loc.msg.cltRef# #loc.msg.trnRef# #loc.msg.url# #loc.msg.attach#">
			<cfif FileExists(loc.msg.attach)>
				<cfmail 
					to="#loc.msg.address#"
					bcc="#application.siteclient.cltMailOffice#"
					from="#application.siteclient.cltMailOffice#"
					server="#application.siteclient.cltMailServer#"
					username="#application.siteclient.cltMailAccount#" 
					<!--- replyto="news@shortlanesendstore.co.uk"		needs testing 10/12/25 --->
					password="#args.srchPwd#"
					subject="#loc.msg.subject# - #application.siteclient.cltCompanyName#">
					<cfmailpart charset="utf-8" type="text/plain">#textMessage(loc.msg.text)#</cfmailpart>
					<cfmailpart charset="utf-8" type="text/html">#loc.msg.text#</cfmailpart>
					<cfmailparam type="application/pdf" disposition="attachment" file="#loc.msg.attach#"></cfmailparam>
					<cfif len(args.attachFile)>
						<cfmailparam type="application/pdf" disposition="attachment" file="#args.attachFile#"></cfmailparam>								
					</cfif>
				</cfmail>
				<cfset loc.result.msg = "sent successfully">
				<cffile action="append" addnewline="yes" 
					file="#application.site.dir_logs#email\mail-#DateFormat(Now(),'yyyymmdd')#.txt"
						output="Message sent to: #loc.msg.address# - #loc.msg.subject# - #loc.msg.trnRef# for #loc.msg.name# 
							#loc.msg.cltRef# #application.siteclient.cltMailAccount# #loc.result.msg#">
			<cfelse>
				<cfset loc.result.msg = "file missing">
				<cffile action="append" addnewline="yes" 
					file="#application.site.dir_logs#email\mail-#DateFormat(Now(),'yyyymmdd')#.txt"
						output="Message failed to: #loc.msg.address# - #loc.msg.subject# - #loc.msg.trnRef# for #loc.msg.name# 
							#loc.msg.cltRef# #application.siteclient.cltMailAccount# #loc.result.msg#">
			</cfif>
			<cfset loc.result.data = loc.msg>			

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
			<cfset loc.result.msg = "an error occured">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>