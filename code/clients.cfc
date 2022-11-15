<cfcomponent displayname="clientFunctions" extends="code/core" hint="clients functions 2015">

	<cffunction name="EmailLatestInvoice" access="public" returntype="struct">
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

</cfcomponent>