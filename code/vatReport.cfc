<cfcomponent>

	<cffunction name="TransactionList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cftry>
			<cfquery name="loc.QTrans" datasource="#args.datasource#">
				SELECT nomID,nomCode,nomTitle, trnID,trnDate,trnRef,trnDesc,trnAmnt1,trnAmnt2, niAmount,niVATAmount,niVATRate, accID,accCode,accName
				FROM tbltrans 
				INNER JOIN tblnomitems ON niTranID = trnID
				INNER JOIN tblnominal ON ninomID = nomID
				INNER JOIN tblAccount ON accID = trnAccountID
				WHERE trnLedger = 'purch' 
				AND trnDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#'
				AND trnType IN ('inv','crn')
				AND nomID NOT IN (11,21,201)
				<cfif args.form.srchSort eq 1>
					ORDER BY nomGroup,nomCode, accCode, trnDate;
				<cfelseif args.form.srchSort eq 2>
					ORDER BY accCode, nomGroup,nomCode, trnDate;
				</cfif>
			</cfquery>
			<cfset loc.result.QTrans = loc.QTrans>
			<cfset loc.result.totals = {}>
			<cfset StructInsert(loc.result.totals,"zzGrand", {
				"Title" = "Grand Total",
				"Net" = 0,
				"VAT" = 0,
				"Num" = 0
			})>
			<cfif args.form.srchSort eq 1>
				<cfloop query="loc.QTrans">
					<cfif !StructKeyExists(loc.result.totals,nomCode)>
						<cfset StructInsert(loc.result.totals,nomCode, {
							"Title" = nomTitle,
							"Net" = niAmount,
							"VAT" = niVATAmount,
							"Num" = 1
						})>
					<cfelse>
						<cfset loc.blk = StructFind(loc.result.totals,nomCode)>
						<cfset loc.blk.net += niAmount>
						<cfset loc.blk.vat += niVATAmount>
						<cfset loc.blk.num++>
					</cfif>
					<cfset loc.blk = StructFind(loc.result.totals,"zzGrand")>
					<cfset loc.blk.net += niAmount>
					<cfset loc.blk.vat += niVATAmount>
					<cfset loc.blk.num++>
				</cfloop>
			<cfelseif args.form.srchSort eq 2>
				<cfloop query="loc.QTrans">
					<cfif !StructKeyExists(loc.result.totals,accCode)>
						<cfset StructInsert(loc.result.totals,accCode, {
							"Title" = accName,
							"Net" = niAmount,
							"VAT" = niVATAmount,
							"Num" = 1
						})>
					<cfelse>
						<cfset loc.blk = StructFind(loc.result.totals,accCode)>
						<cfset loc.blk.net += niAmount>
						<cfset loc.blk.vat += niVATAmount>
						<cfset loc.blk.num++>
					</cfif>
					<cfset loc.blk = StructFind(loc.result.totals,"zzGrand")>
					<cfset loc.blk.net += niAmount>
					<cfset loc.blk.vat += niVATAmount>
					<cfset loc.blk.num++>
				</cfloop>
			</cfif>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
</cfcomponent>
