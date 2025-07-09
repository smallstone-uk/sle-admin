<!--- 08/06/2025 new version of news customer transaction management --->

<cfcomponent>
	<cffunction name="tranType" access="public" returntype="string">
		<cfargument name="arg" type="string" required="yes">
		<cfset var result="">
		<cfswitch expression="#arg#">
			<cfcase value="inv">
				<cfset result = "Invoice">
			</cfcase>
			<cfcase value="crn">
				<cfset result = "Credit">
			</cfcase>
			<cfcase value="pay">
				<cfset result = "Payment">
			</cfcase>
			<cfcase value="jnl">
				<cfset result = "Adjustment">
			</cfcase>
		</cfswitch>	
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadClient" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">

		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.args = args>
		<cfset loc.clientRef = val(args.form.clientRef)>
		<cfset loc.allTrans = StructKeyExists(args.form,"allTrans")>
		
		<cftry>
			<cfif loc.clientRef gt 0 AND loc.clientRef lt 9999>
				<cfquery name="loc.result.QClient" datasource="#args.datasource1#"> <!--- Get selected client record --->
					SELECT *
					FROM tblClients
					WHERE cltRef = #loc.clientRef#
					LIMIT 1;
				</cfquery>	
				<cfif loc.result.QClient.recordcount eq 1>
					<cfset loc.result.clientRef = loc.clientRef>
				<cfelse>
					<cfset loc.result.msg = "customer reference not found. (#loc.clientRef#)">
				</cfif>
			<cfelse>
				<cfset loc.result.msg = "Invalid range for customer reference. (#loc.clientRef#)">
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadTrans" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">

		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.args = args>
		<cfset loc.result.bfwd = 0>
		<cfset loc.clientRef = val(args.form.clientRef)>
		<cfset loc.allTrans = int(StructKeyExists(args.form,"allTrans"))>
		<cftry>
			<cfif loc.clientRef eq 0>
				<cfset loc.result.msg = "customer reference not found. (#loc.clientRef#)">
			<cfelse>
				<cfif loc.allTrans>
					<!--- Get bfwd balance --->
					<cfquery name="loc.QBfwd" datasource="#args.datasource1#"> 
						SELECT SUM(trnAmnt1 + trnAmnt2) AS total
						FROM tblTrans
						WHERE trnClientRef = #loc.clientRef#
						AND trnDate < '#args.form.srchDateFrom#'
						AND trnAllocID = 0	<!--- ignore allocated trans --->
					</cfquery>
					<cfset loc.result.bfwd = val(loc.QBfwd.total)>				
				</cfif>
				<!--- Get last allocID --->
				<cfquery name="loc.QClient" datasource="#args.datasource1#">
					SELECT cltID,cltRef,cltAllocID
					FROM tblClients
					WHERE cltRef = #loc.clientRef#
					LIMIT 1;
				</cfquery>	
				<cfset loc.result.cltID = val(loc.QClient.cltID)>				
				<cfset loc.result.cltRef = val(loc.QClient.cltRef)>				
				<cfset loc.result.cltAllocID = val(loc.QClient.cltAllocID) + 1>				
				<!--- Get transaction records --->
				<cfquery name="loc.result.QTrans" datasource="#args.datasource1#" result="loc.result.QTransResult"> 
					SELECT *
					FROM tblTrans
					WHERE trnClientRef = #loc.clientRef#
					<cfif loc.allTrans>
						<cfif len(args.form.srchDateFrom)>AND trnDate >= '#args.form.srchDateFrom#'</cfif>
						<cfif len(args.form.srchDateTo)>AND trnDate <= '#args.form.srchDateTo#'</cfif>
					<cfelse>
						AND (trnAlloc = 0 OR trnAllocID =0 )	<!--- either old or new system --->
					</cfif>
					ORDER BY trnDate, trnType DESC, trnID	<!--- show all payments before invoices on same date --->
					<!---LIMIT 100;--->
				</cfquery>
				<cfset loc.result.tranCount = loc.result.QTrans.recordcount>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadAllocatedTrans" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">

		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.args = args>
		<cfset loc.result.bfwd = 0>
		<cfset loc.clientRef = val(args.form.clientRef)>
		<cfset loc.allTrans = int(StructKeyExists(args.form,"allTrans"))>
		<cftry>
			<cfif loc.clientRef eq 0>
				<cfset loc.result.msg = "customer reference not found. (#loc.clientRef#)">
			<cfelse>
				<cfif loc.allTrans>
					<!--- Get bfwd balance --->
					<cfquery name="loc.QBfwd" datasource="#args.datasource1#"> 
						SELECT SUM(trnAmnt1 + trnAmnt2) AS total
						FROM tblTrans
						WHERE trnClientRef = #loc.clientRef#
						AND trnDate < '#args.form.srchDateFrom#'
						AND trnAllocID = 0	<!--- ignore allocated trans --->
					</cfquery>
					<cfset loc.result.bfwd = val(loc.QBfwd.total)>				
				</cfif>
				<!--- Get last allocID --->
				<cfquery name="loc.QClient" datasource="#args.datasource1#">
					SELECT cltID,cltRef,cltAllocID
					FROM tblClients
					WHERE cltRef = #loc.clientRef#
					LIMIT 1;
				</cfquery>	
				<cfset loc.result.cltID = val(loc.QClient.cltID)>				
				<cfset loc.result.cltRef = val(loc.QClient.cltRef)>				
				<cfset loc.result.cltAllocID = val(loc.QClient.cltAllocID) + 1>				
				<!--- Get transaction records --->
				<cfquery name="loc.result.QTrans" datasource="#args.datasource1#"> 
					SELECT *
					FROM tblTrans
					WHERE trnClientRef = #loc.clientRef#
					<!---<cfif loc.allTrans>--->
						<cfif len(args.form.srchDateFrom)>AND trnDate >= '#args.form.srchDateFrom#'</cfif>
						<cfif len(args.form.srchDateTo)>AND trnDate <= '#args.form.srchDateTo#'</cfif>
					<!---<cfelse>--->
						<!---AND trnAlloc = 0--->
					<!---</cfif>--->
					AND trnAllocID != 0
					ORDER BY trnAllocID, trnDate ASC, trnID	<!--- show all payments before invoices on same date --->
					<!---LIMIT 100;--->
				</cfquery>
				<cfset loc.result.tranCount = loc.result.QTrans.recordcount>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="SavePayment" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfif args.form.trnMethod eq "chqx">		<!--- bounced cheque --->
				<cfset loc.amnt1 = val(args.form.trnAmnt1)>
				<cfset loc.amnt2 = val(args.form.trnAmnt2)>
			<cfelse>
				<cfset loc.amnt1 = -val(args.form.trnAmnt1)>
				<cfset loc.amnt2 = -val(args.form.trnAmnt2)>
			</cfif>
			<cfquery name="loc.QTrans" datasource="#args.datasource#" result="loc.result.QTrans">
				INSERT INTO tblTrans (
					trnAccountID,
					trnClientID,
					trnClientRef,
					trnRef,
					trnDesc,
					trnDate,
					trnMethod,
					trnType,
					trnAlloc,
					trnAllocID,
					trnAmnt1,
					trnAmnt2
				) VALUES (
					4,
					#val(args.form.clientID)#,
					#val(args.form.clientRef)#,
					'#args.form.trnRef#',
					'#args.form.trnDesc#',
					'#LSDateFormat(args.form.trnDate,"yyyy-mm-dd")#',
					<cfif args.form.trnType eq 'pay'>'#args.form.trnMethod#'<cfelse>''</cfif>,
					'#args.form.trnType#',
					0,			<!---#int(result.preticked gt 0)#,--->
					0,
					#loc.amnt1#,
					#loc.amnt2#
				)
			</cfquery>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="SaveCreditPayment" access="public" result="loc.result.QTrans">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QTrans" datasource="#args.datasource#" result="loc.result.QTrans">
				INSERT INTO tblTrans (
					trnAccountID,
					trnClientID,
					trnClientRef,
					trnRef,
					trnDate,
					trnMethod,
					trnDesc,
					trnType,
					trnAlloc,
					trnAmnt1,
					trnAmnt2
				) VALUES (
					4,
					#val(args.form.clientID)#,
					#val(args.form.clientRef)#,
					'#args.form.crnRef#',
					'#LSDateFormat(args.form.crnDate,"yyyy-mm-dd")#',
					'',
					'#args.form.crnDesc#',
					'crn',
					0,
					-#val(args.form.crnAmnt1)#,
					-#val(args.form.crnAmnt2)#
				)
			</cfquery>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>