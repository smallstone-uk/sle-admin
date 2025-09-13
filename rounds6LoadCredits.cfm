
<cfset parm = {}>
<cfset parm.form = form>
<cfset parm.datasource = application.site.datasource1>

	<cffunction name="FindCredit" access="public" returntype="string">
		<cfargument name="args" type="struct" required="yes">
		<cfset var msg = "">
		
		<cftry>
			<cfquery name="loc.QCredit" datasource="#args.datasource#">
				SELECT *
				FROM tblDelItems
				WHERE DICLIENTID = #args.credit.diClientID#
				AND DIDATE = '#args.credit.DIDATE#'
				AND DIPUBID = #args.credit.DIPUBID#
				AND DIISSUE = '#args.credit.DIISSUE#'
				AND DITYPE = 'credit'
			</cfquery>
			<cfif loc.QCredit.recordcount neq 0>
				<cfset msg = 'credited'>
				<cfset args.credit.creditcheck = "credited">
			<cfelse>
				<cfset args.credit.creditcheck = "normal">
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn msg>
	</cffunction>

	<cffunction name="ProcessCredits" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.inserts = 0>
		<cfset loc.result.skips = 0>
		<cftry>
			<cfloop array="#args.dataArray#" index="loc.item">
				<cfif loc.item.creditCheck eq 'normal'>
					<cfset loc.result.inserts++>
					<cfquery name="loc.QAddCredit" datasource="#args.datasource#">
						INSERT INTO tblDelItems (
							DIBATCHID,
							DICHARGE,
							DICLIENTID,
							DIDATE,
							DIINVOICEID,
							DIISSUE,
							DIORDERID,
							DIPRICE,
							DIPRICETRADE,
							DIPUBID,
							DIQTY,
							DIREASON,
							DIROUNDID,
							DITYPE,
							DIVATAMOUNT,
							DIVOUCHER
						
						) VALUES (
							#loc.item.DIBATCHID#,
							#loc.item.DICHARGE#,
							#loc.item.DICLIENTID#,
							'#loc.item.DIDATE#',
							#loc.item.DIINVOICEID#,
							'#loc.item.DIISSUE#',
							#loc.item.DIORDERID#,
							#loc.item.DIPRICE#,
							#loc.item.DIPRICETRADE#,
							#loc.item.DIPUBID#,
							#loc.item.DIQTY#,
							'#loc.item.DIREASON#',
							#loc.item.DIROUNDID#,
							'#loc.item.DITYPE#',
							#loc.item.DIVATAMOUNT#,
							#loc.item.DIVOUCHER#
						)
					</cfquery>
				<cfelse>
					<cfset loc.result.skips++>
				</cfif>
			</cfloop>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadDelItems" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QDelItems" datasource="#args.datasource#">
				SELECT cltRef,cltName, pubID,pubTitle, rndTitle, tblDelItems.*
				FROM tblDelItems
				INNER JOIN tblPublication ON pubID = diPubID
				INNER JOIN tblClients ON cltID = diClientID
				INNER JOIN tblRounds ON diRoundID = rndID
				WHERE diDate = '#args.form.rounddate#'
				AND pubGroup = 'News'
				<!---LIMIT 0,10;--->
			</cfquery>
			<cfset loc.result.QDelItems = loc.QDelItems>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cfset data = LoadDelItems(parm)>
	<cfset dataArray = []>
	<cfoutput>
		<table class="tableList">
			<tr>
				<th>rndTitle</th>
				<th>cltRef</th>
				<th>cltName</th>
				<th>pubID</th>
				<th>pubTitle</th>
				<th>diIssue</th>
				<th>diType</th>
				<th>diPrice</th>
				<th>diCharge</th>
				<th>diPriceTrade</th>
				<th>diInvoiceID</th>
				<th>rndTitle</th>
				<th>lineTotal</th>
				<th>Status</th>
			</tr>
			<cfset totalCount = 0>
			<cfset totalCredits = 0>
			<cfset totalDebits = 0>
			<cfloop query="data.QDelItems">
				<cfset totalCount++>
				<cfset lineTotal = diPrice + diCharge>
				<cfif lineTotal gt 0>
					<cfset totalDebits += lineTotal>
				<cfelse>
					<cfset totalCredits -= lineTotal>
				</cfif>
				<cfset credit = {
					DIBATCHID = DIBATCHID,
					DICHARGE = -DICHARGE,
					DICLIENTID = DICLIENTID,
					DIDATE = DIDATE,
					DIINVOICEID = DIINVOICEID,
					DIISSUE	= DIISSUE,
					DIORDERID = DIORDERID,
					DIPRICE	= -DIPRICE,
					DIPRICETRADE = -DIPRICETRADE,
					DIPUBID = DIPUBID,
					DIQTY = DIQTY,
					DIREASON = 'missed',
					DIROUNDID = DIROUNDID,
					DITYPE = 'credit',
					DIVATAMOUNT = DIVATAMOUNT,
					DIVOUCHER = 0
				}>
				<cfset parm.credit = credit>
				<cfset creditCheck = FindCredit(parm)>
				<cfset ArrayAppend(dataArray,credit)>
				<tr>
					<td>#rndTitle#</td>
					<td>#cltRef#</td>
					<td>#cltName#</td>
					<td>#pubID#</td>
					<td>#pubTitle#</td>
					<td>#diIssue#</td>
					<td>#diType#</td>
					<td>#diPrice#</td>
					<td>#diCharge#</td>
					<td>#diPriceTrade#</td>
					<td>#diInvoiceID#</td>
					<td>#rndTitle#</td>
					<td align="right">#DecimalFormat(lineTotal)#</td>
					<td>#creditCheck#</td>
				</tr>
			</cfloop>
			<tr>
				<th colspan="10">Totals</th>
				<th>#totalCount#</th>
				<th align="right">#DecimalFormat(totalDebits)#</th>
				<th align="right">#DecimalFormat(totalCredits)#</th>
				<th>#DecimalFormat(totalDebits - totalCredits)#</th>
			</tr>
		</table>
		<cfset parm.dataArray = dataArray>
		<cfif StructKeyExists(form,"processCredits")>
			<cfset result = ProcessCredits(parm)>
			<cfdump var="#result#" label="ProcessCredits" expand="true">
		</cfif>
	</cfoutput>
	