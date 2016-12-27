<cfcomponent displayname="bank" hint="handles function to manage banking transactions">

	<cffunction name="LoadBankSheet" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.item = {}>
		
		<cftry>
			<cfquery name="loc.QBanking" datasource="#args.datasource#">
				SELECT * 
				FROM tblTrans,tblClients
				WHERE trnType='pay'
				AND (trnMethod='coll' OR trnMethod='chq' OR trnMethod='chqs')
				AND trnClientRef=cltRef
				<cfif StructKeyExists(args.form,"date")>AND trnPaidIn=#LSDateFormat(args.form.date,"yymmdd")#<cfelse>AND trnPaidIn=0</cfif>
				ORDER BY trnID asc
			</cfquery>
			<cfset loc.result.TotalCash = 0>
			<cfset loc.result.TotalChq = 0>
			<cfset loc.result.cash = []>
			<cfset loc.result.chq = []>
			<cfloop query="loc.QBanking">
				<cfset loc.item = {}>
				<cfset loc.item.ID = trnID>
				<cfset loc.item.Ledger = trnLedger>
				<cfset loc.item.AccountID = trnAccountID>
				<cfset loc.item.ClientRef = trnClientRef>
				<cfif len(cltCompanyName)>
					<cfset loc.item.ClientName = cltCompanyName>
				<cfelse>
					<cfset loc.item.ClientName = cltName>
				</cfif>
				<cfset loc.item.Type = trnType>
				<cfset loc.item.Ref = trnRef>
				<cfset loc.item.Desc = trnDesc>
				<cfset loc.item.Method = trnMethod>
				<cfset loc.item.Date = LSDateFormat(trnDate,"dd/mm/yyyy")>
				<cfset loc.item.Amnt1 = trnAmnt1>
				<cfset loc.item.Amnt2 = trnAmnt2>
				<cfset loc.item.Alloc = trnAlloc>
				<cfset loc.item.PaidIn = trnPaidIn>
				<cfset loc.item.Active = trnActive>
				
				<cfif loc.item.Method is "coll">
					<cfset loc.result.TotalCash = loc.result.TotalCash + loc.item.Amnt1>
					<cfset ArrayAppend(loc.result.cash,loc.item)>
				<cfelse>
					<cfset loc.result.TotalChq = loc.result.TotalChq + loc.item.Amnt1>
					<cfset ArrayAppend(loc.result.chq,loc.item)>
				</cfif>
			</cfloop>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="LoadBankSheet" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="BankPayments" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.nomIDs = {}>
		<cftry>
			<cfif StructKeyExists(args.form,"selectitem")>
				<cfset loc.bankref = LSDateFormat(args.form.date,"yymmdd")>
				<cfquery name="loc.NomCodes" datasource="#args.datasource#">
					SELECT nomID,nomCode
					FROM tblNominal
					WHERE nomGroup LIKE 'R3'
				</cfquery>
				<cfloop query="loc.NomCodes">
					<cfset StructInsert(loc.nomIDs,"Method_#nomCode#",nomID,true)>
				</cfloop>
				<cfif listlen(args.form.selectitem,",") gt 0>
					<cfloop list="#args.form.selectitem#" delimiters="," index="loc.i">
						<cfquery name="loc.QBank" datasource="#args.datasource#">
							UPDATE tblTrans
							SET trnPaidIn="#LSDateFormat(args.form.date,"yymmdd")#"
							WHERE trnID=#loc.i#
							AND trnPaidIn=0
						</cfquery>
					</cfloop>
				</cfif>
				<cfquery name="loc.TranExists" datasource="#args.datasource#">
					SELECT trnID
					FROM tblTrans
					WHERE trnRef = 'DEP #loc.bankref#'
					LIMIT 1;
				</cfquery>
				<cfif loc.TranExists.recordcount eq 0>
					<cfquery name="loc.QInsertTran" datasource="#args.datasource#" result="loc.QIns">
						INSERT INTO tblTrans
							(trnRef,trnDate,trnDesc,trnPaidIn)
						VALUES
							('DEP #loc.bankref#','#args.form.date#','Deposit reallocation',#loc.bankref#)
					</cfquery>
					<cfset loc.postTranID = loc.QIns.generatedkey>
					<cfset loc.sqlValues = "">
					<cfset loc.balance = 0>
					<cfloop collection="#args.form#" item="loc.key">
						<cfif left(loc.key,7) eq "Method_">
							<cfset loc.value = StructFind(args.form,loc.key)>
							<cfset loc.balance -= loc.value>
							<cfif loc.key eq "Method_CHQS"><cfset loc.key = "Method_CHQ"></cfif>
							<cfset loc.ID = StructFind(loc.nomIDs,loc.key)>
							<cfset loc.sqlValues = "#loc.sqlValues#(#loc.ID#,#loc.postTranID#,#loc.value#),">
						</cfif>
					</cfloop>
					<cfset loc.sqlValues = "#loc.sqlValues#(1501,#loc.postTranID#,#loc.balance#)">
					<cfquery name="loc.QInsertItems" datasource="#args.datasource#">
						INSERT INTO tblNomItems
							(niNomID,niTranID,niAmount)
						VALUES
							#loc.sqlValues#
					</cfquery>
				<cfelse>
					<cfset loc.postTranID = loc.TranExists.trnID>
				</cfif>
			</cfif>
			<cfdump var="#loc#" label="BankPayments" expand="yes" format="html" 
				output="#application.site.dir_logs#bank-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="BankPayments" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>				
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="LoadBankedPayments" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.item={}>
		
		<cftry>
			<cfif StructKeyExists(args.form,"selectitem")>
				<cfquery name="loc.QBanking" datasource="#args.datasource#">
					SELECT * 
					FROM tblTrans,tblClients
					WHERE trnID IN ('#args.form.selectitem#')
					AND trnClientRef=cltRef
					ORDER BY trnID asc
				</cfquery>
				<cfset loc.result.TotalCash = 0>
				<cfset loc.result.TotalChq = 0>
				<cfset loc.result.cash = []>
				<cfset loc.result.chq = []>
				<cfloop query = "loc.QBanking">
					<cfset item = {}>
					<cfset loc.item.ID = trnID>
					<cfset loc.item.Ledger = trnLedger>
					<cfset loc.item.AccountID = trnAccountID>
					<cfset loc.item.ClientRef = trnClientRef>
					<cfif len(cltCompanyName)>
						<cfset loc.item.ClientName = cltCompanyName>
					<cfelse>
						<cfset loc.item.ClientName = cltName>
					</cfif>
					<cfset loc.item.Type = trnType>
					<cfset loc.item.Ref = trnRef>
					<cfset loc.item.Desc = trnDesc>
					<cfset loc.item.Method = trnMethod>
					<cfset loc.item.Date = LSDateFormat(trnDate,"dd/mm/yyyy")>
					<cfset loc.item.Amnt1 = trnAmnt1>
					<cfset loc.item.Amnt2 = trnAmnt2>
					<cfset loc.item.Alloc = trnAlloc>
					<cfset loc.item.PaidIn = trnPaidIn>
					<cfset loc.item.Active = trnActive>
					
					<cfif loc.item.Method is "coll">
						<cfset loc.result.TotalCash = loc.result.TotalCash + loc.item.Amnt1>
						<cfset ArrayAppend(loc.result.cash,loc.item)>
					<cfelse>
						<cfset loc.result.TotalChq = loc.result.TotalChq + loc.item.Amnt1>
						<cfset ArrayAppend(loc.result.chq,loc.item)>
					</cfif>
				</cfloop>
			</cfif>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="LoadBankedPayments" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
</cfcomponent>