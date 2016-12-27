<cfcomponent displayname="accounts" extends="core">
	<cffunction name="AddNominal" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.check" datasource="#args.database#">
			SELECT nomID
			FROM tblNominal
			WHERE nomCode = '#UCase(args.form.Code)#'
		</cfquery>
		
		<cfquery name="loc.max" datasource="#args.database#">
			SELECT nomRef
			FROM tblNominal
			ORDER BY nomRef DESC
			LIMIT 1;
		</cfquery>
		
		<cfif loc.check.recordcount is 0>
			<cfquery name="loc.newNominal" datasource="#args.database#">
				INSERT INTO tblNominal (
					nomRef,
					nomCode,
					nomTitle,
					nomType,
					nomVATCode
				) VALUES (
					#val(loc.max.nomRef) + 1#,
					'#UCase(args.form.Code)#',
					'#args.form.Title#',
					'#args.form.Type#',
					#val(args.form.vatCode)#
				)
			</cfquery>
		</cfif>
		
	</cffunction>
	<cffunction name="LoadNominalTotalsDump" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cfquery name="loc.account_purch" datasource="#args.database#">
			SELECT *
			FROM tblAccount
			WHERE accCode = 'JAM1'
		</cfquery>
		
		<cfquery name="loc.account_sales" datasource="#args.database#">
			SELECT *
			FROM tblAccount
			WHERE accCode = 'JAM2'
		</cfquery>
		
		<cfset loc.result.purch.account = QueryToStruct(loc.account_purch)>
		<cfset loc.result.sales.account = QueryToStruct(loc.account_sales)>
		
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="LoadTransactionHeader" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cfquery name="loc.trans" datasource="#args.database#">
			SELECT *
			FROM tblTrans
			WHERE trnID = #val(args.tranID)#
			LIMIT 1;
		</cfquery>
		
		<cfloop query="loc.trans">
			<cfset loc.result.trnID = trnID>
			<cfset loc.result.trnLedger = trnLedger>
			<cfset loc.result.trnAccountID = trnAccountID>
			<cfset loc.result.trnClientRef = trnClientRef>
			<cfset loc.result.trnType = trnType>
			<cfset loc.result.trnRef = trnRef>
			<cfset loc.result.trnDesc = trnDesc>
			<cfset loc.result.trnMethod = trnMethod>
			<cfset loc.result.trnDate = trnDate>
			
			<cfif trnType eq "jnl">
				<cfset loc.result.trnAmnt1 = -trnAmnt1>
				<cfset loc.result.trnAmnt2 = -trnAmnt2>
			<cfelse>
				<cfset loc.result.trnAmnt1 = abs(trnAmnt1)>
				<cfset loc.result.trnAmnt2 = abs(trnAmnt2)>
			</cfif>
			
			<cfset loc.result.trnAlloc = trnAlloc>
			<cfset loc.result.trnPaidIn = trnPaidIn>
			<cfset loc.result.trnTest = trnTest>
			<cfset loc.result.trnActive = trnActive>
			<cfset loc.result.trnPayAcc = trnPayAcc>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="AddAccount" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfif NOT CheckAccountCodeExists(args.form.Code)>
			<cfquery name="loc.newAccount" datasource="#args.database#">
				INSERT INTO tblAccount (
					accCode,
					accGroup,
					accName,
					accType,
					accNomAcct
				) VALUES (
					'#UCase(args.form.Code)#',
					#val(args.form.Group)#,
					'#args.form.Name#',
					'#args.form.Type#',
					#val(args.form.NominalAccount)#
				)
			</cfquery>
		</cfif>
		
	</cffunction>
	<cffunction name="CheckAccountCodeExists" access="public" returntype="boolean">
		<cfargument name="code" type="string" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.account" datasource="#GetDatasource()#">
			SELECT accID
			FROM tblAccount
			WHERE accCode = '#UCase(code)#'
		</cfquery>
		
		<cfif loc.account.recordcount is 0>
			<cfreturn false>
		<cfelse>
			<cfreturn true>
		</cfif>
		
	</cffunction>
	<cffunction name="BalanceNominalItems" access="private" returntype="string">
		<cfset var loc = {}>
		<cfset loc.itemArray = []>

		<cfquery name="loc.trans" datasource="#GetDatasource()#" result="loc.trans_result">
			SELECT trnID, accNomAcct, trnAmnt1, trnAmnt2, accType, trnType
			FROM tblTrans, tblAccount
			WHERE trnAccountID = accID
			ORDER BY trnID ASC
		</cfquery>
		
		<cfloop query="loc.trans">
			<cfset loc.ledgerSign = (2 * int(loc.trans.accType eq "sales")) - 1>
			<cfset loc.tranSign = (2 * int(loc.trans.trnType eq "crn")) - 1>
			<cfset loc.balanceSign = 2 * (NOT loc.ledgerSign * loc.tranSign) - 1>
			
			<cfset loc.netAmount = val(loc.trans.trnAmnt1) * loc.ledgerSign * loc.tranSign>
			<cfset loc.vatAmount = val(loc.trans.trnAmnt2) * loc.ledgerSign * loc.tranSign>
			<cfset loc.balanceAmount = (loc.netAmount + loc.vatAmount) * loc.balanceSign>
			
			<cfquery name="loc.getItems" datasource="#GetDatasource()#" result="loc.getItems_result">
				SELECT *
				FROM tblNomItems
				WHERE niTranID = #val(trnID)#
				ORDER BY niID ASC
			</cfquery>
			
			<cfset loc.vatID = 0>
			<cfset loc.balID = 0>
			
			<cfloop query="loc.getItems">
				<cfset loc.item = {}>
				
				<cfif niNomID eq 11 OR niNomID eq 1>	<!---DEBT or CRED--->
					<cfset loc.item.Amount = loc.balanceAmount>
					<cfset loc.balID = niNomID>
				<cfelseif niNomID eq 21>				<!---VAT--->
					<cfset loc.item.Amount = loc.vatAmount>
					<cfset loc.vatID = niNomID>
				<cfelse>
					<cfset loc.item.Amount = niAmount>
				</cfif>
				
				<cfset loc.item.NomID = niNomID>
				<cfset loc.item.TranID = niTranID>
			</cfloop>
			
			<cfif loc.vatID is 0>
				<cfset ArrayAppend(loc.itemArray, {"NomID" = 21, "Amount" = loc.vatAmount, "TranID" = loc.trans.trnID})>
			</cfif>
			
			<cfif loc.balID is 0>
				<cfset ArrayAppend(loc.itemArray, {"NomID" = loc.trans.accNomAcct, "Amount" = loc.balanceAmount, "TranID" = loc.trans.trnID})>
			</cfif>
		</cfloop>
		
		<cfif ArrayLen(loc.itemArray)>
			<cfquery name="loc.addItems" datasource="#GetDatasource()#" result="loc.addItems_result">
				INSERT INTO tblNomItems (
					niNomID,
					niTranID,
					niAmount,
					niVATAmount,
					niVATRate,
					niActive
				) VALUES
				<cfset loc.counter = 0>
				<cfloop array="#loc.itemArray#" index="i">
					<cfset loc.counter++>
					<cfif loc.counter neq 1>,</cfif>(
						#val(i.NomID)#,
						#val(i.TranID)#,
						#val(i.Amount)#,
						0,
						0,
						0
					)
				</cfloop>
			</cfquery>
		</cfif>
		
		<cfreturn "BalanceNominalItems() Complete.">
	</cffunction>
	<cffunction name="NominalTotalWipe" access="private" returntype="string">
		<cfset var loc = {}>
		<cfset loc.itemArray = []>
		
		<cfquery name="loc.clearTotals" datasource="#GetDatasource()#" result="loc.clearTotals_result">
			DELETE FROM tblNomTotal
		</cfquery>
		
		<cfquery name="loc.nominals" datasource="#GetDatasource()#" result="loc.nominals_result">
			SELECT nomID
			FROM tblNominal
		</cfquery>
		
		<cfloop query="loc.nominals">
			<cfquery name="loc.nomItems" datasource="#GetDatasource()#" result="loc.nomItems_result">
				SELECT tblNomItems.*,
					DATE_FORMAT(trnDate, "%y%m") AS TranDate,
					SUM(niAmount) AS MonthTotal
				FROM tblNomItems, tblTrans
				WHERE niNomID = #val(nomID)#
				AND niTranID = trnID
				GROUP BY TranDate
			</cfquery>
			
			<cfloop query="loc.nomItems">
				<cfset loc.item = {}>
				<cfset loc.item.NomID = niNomID>
				<cfset loc.item.Period = val(TranDate)>
				<cfset loc.item.Balance = val(MonthTotal)>
				<cfset ArrayAppend(loc.itemArray, loc.item)>
			</cfloop>
		</cfloop>
		
		<cfquery name="loc.newTotals" datasource="#GetDatasource()#" result="loc.newTotals_result">
			INSERT INTO tblNomTotal (
				ntNomID,
				ntPrd,
				ntBal
			) VALUES
			<cfset loc.counter = 0>
			<cfloop array="#loc.itemArray#" index="i">
				<cfset loc.counter++>
				<cfif loc.counter neq 1>,</cfif>(
					#val(i.NomID)#,
					#val(i.Period)#,
					#val(i.Balance)#
				)
			</cfloop>
		</cfquery>
		
		<cfreturn "NominalTotalWipe() Complete.">
	</cffunction>
	<cffunction name="TriggerNominalTotalWipe" access="public" returntype="string">
		<cfargument name="confirmation" type="string" required="yes">
		<cfset var loc = {}>
		<cfif confirmation eq "start">
			<cfset loc.bni = BalanceNominalItems()>
			<cfset loc.ntw = NominalTotalWipe()>
		</cfif>
		<cfreturn "#loc.ntw#<br>#loc.bni#">
	</cffunction>
	<cffunction name="LoadNominalTotalsBetweenDates" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.items = []>
		<cfset loc.result.header = {}>
		
		<cftry>
		
		<cfset loc.parsedDateStart = val(DateFormat("#args.form.Date_Start_Year#-#args.form.Date_Start_Month#-1", "yymm"))>
		<cfset loc.parsedDateEnd = val(DateFormat("#args.form.Date_End_Year#-#args.form.Date_End_Month#-#DaysInMonth('#args.form.Date_End_Year#-#args.form.Date_End_Month#-1')#", "yymm"))>
		
		<cfquery name="loc.totals" datasource="#args.database#">
			SELECT *,
				(SELECT nomCode FROM tblNominal WHERE nomID = ntNomID) AS NomCode,
				(SELECT nomTitle FROM tblNominal WHERE nomID = ntNomID) AS NomTitle
			FROM tblNomTotal
			WHERE ntPrd >= #val(loc.parsedDateStart)#
			AND ntPrd <= #val(loc.parsedDateEnd)#
		</cfquery>
		
		<cfset loc.result.header.drTotal = 0>
		<cfset loc.result.header.crTotal = 0>
		
		<cfloop query="loc.totals">
			<cfset loc.item = {}>
			<cfset loc.item.ID = ntID>
			<cfset loc.item.NomID = ntNomID>
			<cfset loc.item.Prd = ntPrd>
			<cfset loc.item.Bal = ntBal>
			<cfset loc.item.NomCode = NomCode>
			<cfset loc.item.NomTitle = NomTitle>
			
			<cfif loc.item.Bal lt 0>
				<cfset loc.result.header.crTotal += loc.item.Bal>
			<cfelse>
				<cfset loc.result.header.drTotal += loc.item.Bal>
			</cfif>
			
			<cfset ArrayAppend(loc.result.items, loc.item)>
		</cfloop>
		
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="false">
		</cfcatch>
		</cftry>
		
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="UpdateNomTotals" access="public" returntype="void">
		<cfargument name="tranDate" type="any" required="yes" hint="Date period">
		<cfargument name="nomID" type="any" required="yes" hint="Nominal ID">
		<cfset var loc = {}>
		<cfset loc.args=arguments>
		<cftry>
		<cfquery name="loc.checkNomExists" datasource="#GetDatasource()#" result="loc.checkNomExistsResult">
			SELECT ntID
			FROM tblNomTotal
			WHERE ntNomID = #val(nomID)#
			AND ntPrd = #val(LSDateFormat(tranDate, "yymm"))#
		</cfquery>
		
		<cfquery name="loc.nomSum" datasource="#GetDatasource()#">
			SELECT SUM(niAmount) AS amountTotal
			FROM tblNomItems, tblTrans
			WHERE niNomID = #val(nomID)#
			AND niTranID = trnID
			AND MONTH(trnDate) = #val(LSDateFormat(tranDate, "mm"))#
			AND YEAR(trnDate) = #val(LSDateFormat(tranDate, "yyyy"))#
		</cfquery>
		
		<cfif loc.nomSum.amountTotal neq 0>
			<cfset loc.sum = loc.nomSum.amountTotal>
		<cfelse>
			<cfset loc.sum = 0>
		</cfif>
		
		<cfif loc.checkNomExists.recordcount is 0>
			<cfquery name="loc.newNomTotal" datasource="#GetDatasource()#" result="loc.newNomTotalResult">
				INSERT INTO tblNomTotal (
					ntNomID,
					ntPrd,
					ntBal
				) VALUES (
					#val(nomID)#,
					#val(LSDateFormat(tranDate, "yymm"))#,
					#val(loc.sum)#
				)
			</cfquery>
		<cfelse>
			<cfquery name="loc.updateNomTotal" datasource="#GetDatasource()#" result="loc.updateNomTotalResult">
				UPDATE tblNomTotal
				SET ntBal = #val(loc.sum)#
				WHERE ntNomID = #val(nomID)#
				AND ntPrd = #val(LSDateFormat(tranDate, "yymm"))#
			</cfquery>
		</cfif>
		
		<cfcatch type="any">
			<cfdump var="#cfcatch#" output="#application.site.baseDir#cfcatch.html" format="html">
		</cfcatch>
		</cftry>
		
 	</cffunction>
	<cffunction name="DeleteAccountTransRecord" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.getTranDate" datasource="#args.database#">
			SELECT trnDate
			FROM tblTrans
			WHERE trnID = #val(args.tranID)#
		</cfquery>
		
		<cfquery name="loc.getNomItems" datasource="#args.database#" result="loc.getNomItemsResult">
			SELECT niNomID
			FROM tblNomItems
			WHERE niTranID = #val(args.tranID)#
			AND niNomID != #val(args.accID)#
		</cfquery>
		
		<cfquery name="loc.delete" datasource="#args.database#">
			DELETE FROM tblTrans
			WHERE trnID = #val(args.tranID)#
		</cfquery>
		
		<cfloop query="loc.getNomItems">
			<cfset UpdateNomTotals(loc.getTranDate.trnDate, loc.getNomItems.niNomID)>
		</cfloop>
		
	</cffunction>
	<cffunction name="SaveAccountTransRecord" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		
		<!---WORKING AS OF 15/08/2014 13:21 LWEB--->
		
		<cftry>
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.tranID = 0>
		<cfset loc.args = arguments>
		<cfset loc.isOld = false>
		<cfset loc.typeList = "crn,pay,jnl">
		<cfset loc.newTranDate = LSDateFormat(args.form.header.trnDate, "yyyy-mm-dd")>
		
		<!---Set flag if tran exists in database--->
		<cfquery name="loc.tranExists" datasource="#args.database#" result="loc.tranExists_result">
			SELECT trnID, trnPayAcc, trnDate
			FROM tblTrans
			WHERE trnID = #val(args.form.header.trnID)#
		</cfquery>
		<cfset loc.isOld = loc.tranExists.recordcount gt 0>
		
		<!---Set signs for both new and old transaction headers and items--->
		<cfif Len(args.form.header.trnType)>
			<!---Set type if popup was disabled--->
			<cfset loc.type = args.form.header.trnType>
		<cfelse>
			<!---Use type selected by user--->
			<cfset loc.type = args.form.header.tranType>
		</cfif>
		
		<cfset loc.typeInt = listFind(loc.typeList, loc.type, ",")>
		<cfset loc.tranSign = (2 * int(loc.typeInt gt 0)) - 1>
		<cfset loc.ledgerSign = (2 * int(args.form.header.accType eq "sales")) - 1>
		<cfset loc.balanceSign = 2 * (NOT loc.ledgerSign * loc.tranSign) - 1>
		
		<cfset loc.netAmount = val(args.form.header.trnAmnt1) * loc.ledgerSign * loc.tranSign>
		<cfset loc.vatAmount = val(args.form.header.trnAmnt2) * loc.ledgerSign * loc.tranSign>
		<cfset loc.balanceAmount = (loc.netAmount + loc.vatAmount) * loc.balanceSign>
				
		<cfif NOT loc.isOld>
			<!---
				if new tran do this:
					insert tran record
					insert nom items
					insert balance items
					update totals
			--->
			<cfquery name="loc.newTrans" datasource="#args.database#" result="loc.newTrans_result">
				INSERT INTO tblTrans (
					trnLedger,
					trnAccountID,
					trnClientRef,
					trnRef,
					trnDesc,
					trnMethod,
					trnDate,
					trnAmnt1,
					trnAmnt2,
					trnAlloc,
					trnPaidIn,
					trnTest,
					trnActive,
					trnType,
					trnPayAcc
				) VALUES (
					'#args.form.header.accType#',
					#val(args.form.header.accID)#,
					0,		<!---IGNORE--->
					'#args.form.header.trnRef#',
					'#args.form.header.trnDesc#',
					'null',	<!---IGNORE--->
					'#loc.newTranDate#',
					#val(loc.netAmount)#,
					#val(loc.vatAmount)#,
					0,		<!---DEFAULT TO 0--->
					0,		<!---IGNORE--->
					0,		<!---IGNORE--->
					0,		<!---IGNORE--->
					'#args.form.header.tranType#',
					#val(args.form.header.paymentAccounts)#
				)
			</cfquery>
			
			<cfif args.form.header.paymentAccounts neq "null">
				<!---Payment Account--->
				<cfset ArrayAppend(args.form.items, {
					"nomID" = val(args.form.header.paymentAccounts),
					"netAmount" = loc.netAmount,
					"vatAmount" = 0,
					"vatRate" = 0
				})>
			</cfif>
			
			<!---Balance--->
			<cfset ArrayAppend(args.form.items, {
				"nomID" = val(args.form.header.accNomAcct),
				"netAmount" = loc.balanceAmount,
				"vatAmount" = 0,
				"vatRate" = 0
			})>
			
			<!---VAT--->
			<cfif args.form.header.tranType eq "pay">
				<cfset ArrayAppend(args.form.items, {
					"nomID" = 111,
					"netAmount" = loc.vatAmount,
					"vatAmount" = 0,
					"vatRate" = 0
				})>
			<cfelse>
				<cfset ArrayAppend(args.form.items, {
					"nomID" = GetNominalVATRecordID(),
					"netAmount" = loc.vatAmount,
					"vatAmount" = 0,
					"vatRate" = 0
				})>
			</cfif>
			
			<cfquery name="loc.newItem" datasource="#args.database#" result="loc.newItem_result">
				INSERT INTO tblNomItems (
					niNomID,
					niTranID,
					niAmount,
					niVATAmount,
					niVATRate,
					niActive
				) VALUES
					<cfset loc.itemCounter = 0>
					<cfloop array="#args.form.items#" index="item">
						<cfset loc.itemCounter++>
						<cfif item.netAmount neq 0>
							(
								#val(item.nomID)#,
								#val(loc.newTrans_result.generatedKey)#,
								#val(item.netAmount) * loc.ledgerSign * loc.tranSign#,
								#val(item.vatAmount) * loc.ledgerSign * loc.tranSign#,
								#val(item.vatRate)#,
								0
							)<cfif loc.itemCounter neq ArrayLen(args.form.items)>,</cfif>
						</cfif>
					</cfloop>
			</cfquery>
			
			<cfset UpdateNomTotals(loc.newTranDate, val(item.nomID))>
			<cfset loc.result.tranID = loc.newTrans_result.generatedKey>
		<cfelse>
			<!---
				if old tran do this:
					load existing transaction and items
					update existing transaction
					delete all old items
					update totals for existing items with old date
					insert nom items
						update totals for each
			--->
			
			<cfquery name="loc.originalTran" datasource="#args.database#" result="loc.originalTran_result">
				SELECT *
				FROM tblTrans
				WHERE trnID = #val(args.form.header.trnID)#
			</cfquery>
			
			<cfset loc.oldTranDate = LSDateFormat(loc.originalTran.trnDate, "yyyy-mm-dd")>
			
			<cfquery name="loc.originalItems" datasource="#args.database#" result="loc.originalItems_result">
				SELECT *
				FROM tblNomItems
				WHERE niTranID = #val(args.form.header.trnID)#
			</cfquery>
			
			<cfquery name="loc.updateTrans" datasource="#args.database#" result="loc.updateTrans_result">
				UPDATE tblTrans
				SET trnLedger = '#args.form.header.accType#',
					trnAccountID = #val(args.form.header.accID)#,
					trnClientRef = 0,
					trnRef = '#args.form.header.trnRef#',
					trnDesc = '#args.form.header.trnDesc#',
					trnMethod = 'null',
					trnDate = '#loc.newTranDate#',
					trnAmnt1 = #val(loc.netAmount)#,
					trnAmnt2 = #val(loc.vatAmount)#,
					trnAlloc = 0,
					trnPaidIn = 0,
					trnTest = 0,
					trnActive = 0,
					trnType = '#args.form.header.tranType#',
					trnPayAcc = #val(args.form.header.paymentAccounts)#
				WHERE trnID = #val(args.form.header.trnID)#
			</cfquery>
			
			<cfquery name="loc.delItemsAll" datasource="#args.database#" result="loc.delItemsAll_result">
				DELETE FROM tblNomItems
				WHERE niTranID = #val(args.form.header.trnID)#
			</cfquery>
			
			<cfloop query="loc.originalItems">
				<cfset UpdateNomTotals(loc.oldTranDate, val(niNomID))>
			</cfloop>
			
			<cfif args.form.header.paymentAccounts neq "null">
				<!---Payment Account--->
				<cfset ArrayAppend(args.form.items, {
					"nomID" = val(args.form.header.paymentAccounts),
					"netAmount" = loc.netAmount,
					"vatAmount" = 0,
					"vatRate" = 0
				})>
			</cfif>
			
			<!---Balance--->
			<cfset ArrayAppend(args.form.items, {
				"nomID" = val(args.form.header.accNomAcct),
				"netAmount" = loc.balanceAmount,
				"vatAmount" = 0,
				"vatRate" = 0
			})>
			
			<!---VAT--->
			<cfif args.form.header.tranType eq "pay">
				<cfset ArrayAppend(args.form.items, {
					"nomID" = 111,
					"netAmount" = loc.vatAmount,
					"vatAmount" = 0,
					"vatRate" = 0
				})>
			<cfelse>
				<cfset ArrayAppend(args.form.items, {
					"nomID" = GetNominalVATRecordID(),
					"netAmount" = loc.vatAmount,
					"vatAmount" = 0,
					"vatRate" = 0
				})>
			</cfif>
			
			<cfquery name="loc.newItem" datasource="#args.database#" result="loc.newItem_result">
				INSERT INTO tblNomItems (
					niNomID,
					niTranID,
					niAmount,
					niVATAmount,
					niVATRate,
					niActive
				) VALUES
					<cfset loc.itemCounter = 0>
					<cfloop array="#args.form.items#" index="item">
						<cfset loc.itemCounter++>
						<cfif item.netAmount neq 0>
							(
								#val(item.nomID)#,
								#val(args.form.header.trnID)#,
								#val(item.netAmount)#,	<!--- * loc.ledgerSign * loc.tranSign--->
								#val(item.vatAmount)#,	<!--- * loc.ledgerSign * loc.tranSign--->
								#val(item.vatRate)#,
								0
							)<cfif loc.itemCounter neq ArrayLen(args.form.items)>,</cfif>
						</cfif>
					</cfloop>
			</cfquery>
			
			<cfset UpdateNomTotals(loc.newTranDate, val(item.nomID))>
			<cfset loc.result.tranID = args.form.header.trnID>
		</cfif>
		<cfdump var="#loc#" label="SaveAccountTransRecord" expand="no">
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="no">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="SaveAccountTransRecordOLD" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.parsedItems = []>
		<cfset loc.newTransHeaderID = 0>
		<cfset loc.typeList = "crn,pay,jnl">
		<cfset loc.newTranDate = LSDateFormat(args.form.header.trnDate, "yyyy-mm-dd")>
		
		<cftry>
		<cfif Len(args.form.header.trnType)>
			<cfset loc.type = args.form.header.trnType>
		<cfelse>
			<cfset loc.type = args.form.header.type>
		</cfif>
		
		<cfset loc.typeInt = listFind(loc.typeList, loc.type, ",")>
		<cfset loc.ledgerSign = (2 * int(args.form.header.accType eq "sales")) - 1>
		<cfset loc.tranSign = (2 * int(loc.typeInt gt 0)) - 1>
		<cfset loc.balanceSign = 2 * (NOT loc.ledgerSign * loc.tranSign) - 1>
		
		<cfset loc.netAmount = val(args.form.header.trnAmnt1) * loc.ledgerSign * loc.tranSign>
		<cfset loc.vatAmount = val(args.form.header.trnAmnt2) * loc.ledgerSign * loc.tranSign>
		<cfset loc.balanceAmount = (loc.netAmount + loc.vatAmount) * loc.balanceSign>
		
		<cfloop array="#args.form.items#" index="item">
			<cfset loc.pItem = {}>
			<cfset loc.pItem.nomID = item.nomID>
			<cfset loc.pItem.tranID = args.form.header.trnID>
			<cfif StructKeyExists(item, "recID")>
				<cfset loc.pItem.recID = item.recID>
			<cfelse>
				<cfset loc.pItem.recID = 0>
			</cfif>
			<cfset loc.pItem.nomTitle = item.nomTitle>
			<cfset loc.pItem.vatRate = item.vatRate>
			<cfset loc.pItem.netAmount = val(item.netAmount) * loc.ledgerSign * loc.tranSign>
			<cfset loc.pItem.vatAmount = val(item.vatAmount) * loc.ledgerSign * loc.tranSign>
			<cfset ArrayAppend(loc.parsedItems, loc.pItem)>
		</cfloop>
		
		<cfquery name="loc.check" datasource="#args.database#" result="loc.checkResult">
			SELECT trnID, trnPayAcc, trnDate
			FROM tblTrans
			WHERE trnID = #val(args.form.header.trnID)#
		</cfquery>
		
		<cfset loc.oldTranDate = LSDateFormat(loc.check.trnDate, "yyyy-mm-dd")>
		
		<cfif loc.check.recordcount is 0>
			<cfquery name="loc.newTrans" datasource="#args.database#" result="loc.newTransResult">
				INSERT INTO tblTrans (
					trnLedger,
					trnAccountID,
					trnClientRef,
					trnRef,
					trnDesc,
					trnMethod,
					trnDate,
					trnAmnt1,
					trnAmnt2,
					trnAlloc,
					trnPaidIn,
					trnTest,
					trnActive,
					trnType,
					trnPayAcc
				) VALUES (
					'#args.form.header.accType#',
					#val(args.form.header.accID)#,
					0,		<!---IGNORE--->
					'#args.form.header.trnRef#',
					'#args.form.header.trnDesc#',
					'null',	<!---IGNORE--->
					'#loc.newTranDate#',
					#val(loc.netAmount)#,
					#val(loc.vatAmount)#,
					0,		<!---DEFAULT TO 0--->
					0,		<!---IGNORE--->
					0,		<!---IGNORE--->
					0,		<!---IGNORE--->
					'#args.form.header.Type#',
					#val(args.form.header.paymentAccounts)#
				)
			</cfquery>
			<cfset loc.newTransHeaderID = loc.newTransResult.GeneratedKey>
		<cfelse>
			<cfquery name="loc.updateTrans" datasource="#args.database#" result="loc.updateTransResult">
				UPDATE tblTrans
				SET trnLedger = '#args.form.header.accType#',
					trnAccountID = #val(args.form.header.accID)#,
					trnClientRef = 0,
					trnRef = '#args.form.header.trnRef#',
					trnDesc = '#args.form.header.trnDesc#',
					trnMethod = 'null',
					trnDate = '#loc.newTranDate#',
					trnAmnt1 = #val(loc.netAmount)#,
					trnAmnt2 = #val(loc.vatAmount)#,
					trnAlloc = 0,
					trnPaidIn = 0,
					trnTest = 0,
					trnActive = 0,
					trnType = '#args.form.header.Type#',
					trnPayAcc = #val(args.form.header.paymentAccounts)#
				WHERE trnID = #val(args.form.header.trnID)#
			</cfquery>
			<cfif args.form.header.paymentAccounts gt 0>
				<cfset UpdateNomTotals(loc.newTranDate, val(args.form.header.paymentAccounts))>
			</cfif>
			<cfset loc.newTransHeaderID = val(args.form.header.trnID)>
		</cfif>
		
		<cfif loc.check.trnPayAcc gt 0>
			<cfset UpdateNomTotals(loc.oldTranDate, val(loc.check.trnPayAcc))>
		</cfif>
		
		<cfquery name="loc.originalItems" datasource="#args.database#">
			SELECT niID, niNomID
			FROM tblNomItems
			WHERE niTranID = #val(loc.check.trnID)#
		</cfquery>
		
		<cfquery name="loc.delItemsAll" datasource="#args.database#">
			DELETE FROM tblNomItems
			WHERE niTranID = #val(loc.check.trnID)#
		</cfquery>
		
		<cfif loc.originalItems.recordcount gt 0>
			<cfloop query="loc.originalItems">
				<cfset UpdateNomTotals(loc.oldTranDate, val(niNomID))>
			</cfloop>
		</cfif>
		
		<cfloop array="#loc.parsedItems#" index="item">
			<cfquery name="loc.newItem" datasource="#args.database#" result="loc.newItemResult">
				INSERT INTO tblNomItems (
					niNomID,
					niTranID,
					niAmount,
					niVATAmount,
					niVATRate,
					niActive
				) VALUES (
					#val(item.nomID)#,
					#val(loc.newTransHeaderID)#,
					#val(item.netAmount)#,
					#val(item.vatAmount)#,
					#val(item.vatRate)#,
					0
				)
			</cfquery>
			<cfset UpdateNomTotals(loc.newTranDate, val(item.nomID))>
		</cfloop>
		
		<cfquery name="loc.checkNomTotalFinal" datasource="#args.database#">
			SELECT niID
			FROM tblNomItems
			WHERE niNomID = #val(args.form.header.accNomAcct)#
		</cfquery>
		
		<cfif loc.checkNomTotalFinal.recordcount is 0>
			<cfquery name="loc.newNomItemTotal" datasource="#args.database#">
				INSERT INTO tblNomItems (
					niNomID,
					niTranID,
					niAmount,
					niVATAmount,
					niVATRate,
					niActive
				) VALUES (
					#val(args.form.header.accNomAcct)#,
					#val(loc.newTransHeaderID)#,
					#val(loc.balanceAmount)#,
					0,
					0,
					0
				)
			</cfquery>
		<cfelse>
			<cfquery name="loc.newNomItemTotal" datasource="#args.database#">
				UPDATE tblNomItems
				SET niTranID = #val(loc.newTransHeaderID)#,
					niAmount = #val(loc.balanceAmount)#,
					niVATAmount = 0,
					niVATRate = 0,
					niActive = 0
				WHERE niNomID = #val(args.form.header.accNomAcct)#
			</cfquery>
		</cfif>
		
		<cfset UpdateNomTotals(loc.oldTranDate, val(args.form.header.accNomAcct))>
		<cfset UpdateNomTotals(loc.newTranDate, val(args.form.header.accNomAcct))>
		
		<cfquery name="loc.checkNomVAT" datasource="#args.database#">
			SELECT niID
			FROM tblNomItems
			WHERE niNomID = #GetNominalVATRecordID()#
			AND niTranID = #val(loc.newTransHeaderID)#
		</cfquery>
		
		<cfif loc.checkNomVAT.recordcount is 0>
			<cfquery name="loc.newNomVAT" datasource="#args.database#">
				INSERT INTO tblNomItems (
					niNomID,
					niTranID,
					niAmount,
					niVATAmount,
					niVATRate,
					niActive
				) VALUES (
					#GetNominalVATRecordID()#,
					#val(loc.newTransHeaderID)#,
					#val(loc.vatAmount)#,
					0,
					0,
					0
				)
			</cfquery>
		<cfelse>
			<cfquery name="loc.updateNomVAT" datasource="#args.database#">
				UPDATE tblNomItems
				SET niNomID = #GetNominalVATRecordID()#,
					niTranID = #val(loc.newTransHeaderID)#,
					niAmount = #val(loc.vatAmount)#,
					niVATAmount = 0,
					niVATRate = 0,
					niActive = 0
				WHERE niNomID = #GetNominalVATRecordID()#
				AND niTranID = #val(loc.newTransHeaderID)#
			</cfquery>
		</cfif>
		
		<cfset UpdateNomTotals(loc.oldTranDate, val(GetNominalVATRecordID()))>
		<cfset UpdateNomTotals(loc.newTranDate, val(GetNominalVATRecordID()))>
		
		<cfif args.form.header.paymentAccounts neq "null">
			<cfquery name="loc.checkPayAccounts" datasource="#args.database#">
				SELECT niID
				FROM tblNomItems
				WHERE niNomID = #val(args.form.header.paymentAccounts)#
				AND niTranID = #val(loc.newTransHeaderID)#
			</cfquery>
			<cfif loc.checkPayAccounts.recordcount is 0>
				<cfquery name="loc.newPayAcc" datasource="#args.database#">
					INSERT INTO tblNomItems (
						niNomID,
						niTranID,
						niAmount,
						niVATAmount,
						niVATRate,
						niActive
					) VALUES (
						#val(args.form.header.paymentAccounts)#,
						#val(loc.newTransHeaderID)#,
						#val(loc.netAmount)#,
						0,
						0,
						0
					)
				</cfquery>
			<cfelse>
				<cfquery name="loc.updatePayAcc" datasource="#args.database#">
					UPDATE tblNomItems
					SET niNomID = #val(args.form.header.paymentAccounts)#,
						niTranID = #val(loc.newTransHeaderID)#,
						niAmount = #val(loc.netAmount)#,
						niVATAmount = 0,
						niVATRate = 0,
						niActive = 0
					WHERE niNomID = #val(args.form.header.paymentAccounts)#
					AND niTranID = #val(loc.newTransHeaderID)#
				</cfquery>
			</cfif>
			<cfset UpdateNomTotals(loc.oldTranDate, val(args.form.header.paymentAccounts))>
			<cfset UpdateNomTotals(loc.newTranDate, val(args.form.header.paymentAccounts))>
		</cfif>
		
		<cfset loc.result.tranID = loc.newTransHeaderID>
		<cfdump var="#loc#" label="SaveAccountTransRecord" expand="no">
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="no">
		</cfcatch>
		</cftry>
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadAccount" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset var result={}>
		
		<cfif len(args.form.tranRef)>
			<cfquery name="loc.QAccount" datasource="#args.datasource#">
				SELECT tblAccount.*,
					(SELECT nomCode FROM tblNominal WHERE nomID = accPayAcc) AS PayAccNomCode,
					(SELECT nomCode FROM tblNominal WHERE nomID = accNomAcct) AS BalAccCode
				FROM tblAccount, tblTrans
				WHERE trnAccountID=accID
				AND (trnID=#val(args.form.tranRef)# OR trnRef='#args.form.tranRef#')
			</cfquery>
			<cfset result.account=QueryToStruct(loc.QAccount)>
		<cfelseif val(args.form.accountID)>
			<cfquery name="loc.QAccount" datasource="#args.datasource#">
				SELECT *,
					(SELECT nomCode FROM tblNominal WHERE nomID = accPayAcc) AS PayAccNomCode,
					(SELECT nomCode FROM tblNominal WHERE nomID = accNomAcct) AS BalAccCode
				FROM tblAccount
				WHERE accID=#args.form.accountID#
			</cfquery>
			<cfset result.account=QueryToStruct(loc.QAccount)>
		<cfelse>
			<cfset result.account={}>
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadAccounts" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QAccounts="">
		
		<cfquery name="QAccounts" datasource="#args.datasource#">
			SELECT *
			FROM tblAccount
			<cfif structKeyExists(args, "nomType") AND len(args.nomType)>
				WHERE accType='#args.nomType#'
			<cfelse>
				WHERE 1
			</cfif>
			ORDER BY accCode
		</cfquery>
		<cfset result.accounts=QueryToArrayOfStruct(QAccounts)>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadSuppliers" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QSuppliers="">
		
		<cfquery name="QSuppliers" datasource="#args.datasource#">
			SELECT *
			FROM tblAccount
			WHERE accType='#args.nomType#'
			ORDER BY accCode
		</cfquery>
		<cfset result.suppliers=QueryToArrayOfStruct(QSuppliers)>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadNominalCodes" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QNominal="">
		<cfset var rec={}>
		<cfquery name="QNominal" datasource="#args.datasource#">
			SELECT *,
				(SELECT vatRate FROM tblVATRates WHERE vatCode = nomVATCode) AS VATRate
			FROM tblNominal
			WHERE true
			<cfif StructKeyExists(args,"nomType") AND Len(args.nomType)>AND nomType='#args.nomType#'</cfif>
			<cfif StructKeyExists(args,"nomGroup")>AND nomGroup IN (#args.nomGroup#)</cfif>
			ORDER BY nomCode
		</cfquery>
		
		<cfloop query="QNominal">
			<cfset rec={}>
			<cfset rec.nomID=nomID>
			<cfset rec.nomCode=nomCode>
			<cfset rec.nomTitle=nomTitle>
			<cfset rec.nomGroup=nomGroup>
			<cfset rec.nomVATCode=nomVATCode>
			<cfset rec.nomVATRate=VATRate>
			<cfset StructInsert(result,nomCode,rec)>
		</cfloop>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadTransactionList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cfquery name="loc.trans" datasource="#args.datasource#">
			SELECT *
			FROM tblTrans
			WHERE trnAccountID = #val(args.account.accID)#
			AND trnClientRef = 0
			<cfswitch expression="#args.form.sortOrder#">
				<cfcase value="date">
					ORDER BY trnDate DESC
				</cfcase>
				<cfcase value="id">
					ORDER BY trnID DESC
				</cfcase>
				<cfcase value="ref">
					ORDER BY trnRef ASC
				</cfcase>
			</cfswitch>
			<cfif val(args.form.rowLimit)>
				LIMIT 0,#val(args.form.rowLimit)#;
			</cfif>
		</cfquery>
		
		<cfquery name="loc.sorted" dbtype="query">
			SELECT *
			FROM loc.trans
			ORDER BY trnDate ASC
		</cfquery>
		
		<cfif loc.trans.recordcount is 0>
			<cfset loc.result.tranList = []>
		<cfelse>
			<cfset loc.result.tranList = QueryToArrayOfStruct(loc.sorted)>
		</cfif>
		<cfset loc.result.rowCount = loc.sorted.recordcount>
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadTransactionListOld" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var QAccount="">
		
		<cfquery name="QAccount" datasource="#args.datasource#">
			SELECT *
			FROM tblAccount
			WHERE accID=#val(args.accountID)#
			LIMIT 1;
		</cfquery>
		<cfquery name="QTrans" datasource="#args.datasource#">
			SELECT *
			FROM tblTrans
			WHERE trnAccountID=#val(args.accountID)#
		</cfquery>
		<cfset result.account=QueryToArrayOfStruct(QAccount)>
		<cfset result.tranList=QueryToArrayOfStruct(QTrans)>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadTransaction" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.error = 0>
		<cfset loc.result.items = []>
		<cfset loc.vatRate = 0>
		
		<cftry>
			<cfquery name="loc.tran" datasource="#args.datasource#">
				SELECT *
				FROM tblTrans, tblAccount
				WHERE trnID = #val(args.tranID)#
				<cfif StructKeyExists(args.form, "accID")>
					AND trnAccountID = #val(args.form.accID)#
				<cfelse>
					AND trnAccountID = accID
				</cfif>
				<cfif StructKeyExists(args.form, "type")>
					AND trnType = '#args.form.type#'
				</cfif>
				LIMIT 1;
			</cfquery>
			
			<cfset loc.result.tran = QueryToArrayOfStruct(loc.tran)>
			
			<cfif loc.tran.trnType eq "jnl">
				<cfset loc.result.NetAmount = -loc.tran.trnAmnt1>
				<cfset loc.result.VatAmount = -loc.tran.trnAmnt2>
			<cfelse>
				<cfset loc.result.NetAmount = abs(loc.tran.trnAmnt1)>
				<cfset loc.result.VatAmount = abs(loc.tran.trnAmnt2)>
			</cfif>
			
			<cfif loc.tran.recordcount is 0>
				<cfset loc.result.error = 1>
				<cfset loc.result.msg = "Transaction not found">
			</cfif>
			
			<cfquery name="loc.nomItems" datasource="#args.datasource#" result="loc.nomItemsResult">
				SELECT *
				FROM tblNomItems, tblNominal
				WHERE niTranID = #val(args.tranID)#
				AND niNomID = nomID
				AND niNomID != #val(args.form.accNomAcct)#
				AND niNomID != #GetNominalVATRecordID()#
				ORDER BY niID asc
			</cfquery>
			
			<cfset loc.tranTotal = 0>
			<cfset loc.vatTotal = 0>
			
			<cfloop query="loc.nomItems">
				<cfset loc.item = {}>
				<cfset loc.item.niID = niID>
				<cfset loc.item.niNomID = niNomID>
				<cfset loc.item.nomTitle = nomTitle>
				<cfset loc.item.nomCode = nomCode>
				<cfset loc.item.nomVATRate = StructFind(application.site.vat, nomVATCode) * 100>
				<cfset loc.item.niTranID = niTranID>

				<cfif args.form.accType IS "sales" OR (StructKeyExists(args.form, "type") AND (args.form.type IS "crn"))>
					<cfset loc.item.niAmount =- niAmount>
				<cfelse>
					<cfset loc.item.niAmount = niAmount>
				</cfif>

				<cfset loc.vatRate = StructFind(application.site.vat, nomVATCode)>
				<cfset loc.item.vat = round(loc.item.niAmount * loc.vatRate * 100) / 100>
				<cfset loc.tranTotal = loc.tranTotal + loc.item.niAmount>
				<cfset loc.vatTotal = loc.vatTotal + loc.item.vat>
				<cfset ArrayAppend(loc.result.items, loc.item)>
			</cfloop>
			
			<cfset loc.result.GrandTotal = loc.tranTotal>
			<cfset loc.result.GrandVatTotal = loc.vatTotal>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="UpdateNewsItem" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.html">
			<cfset loc.result.error = 2>
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadSalesTransaction" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var result.items=ArrayNew(1)>
		<cfset var QTran="">
		<cfset var QNomItems="">
		<cfset var tranTotal=0>
		<cfset var vatTotal=0>
		<cfset var vatRate=0>
		<cfset var result.mode=1>
		<cfset var result.error=0>

		<cfquery name="QTran" datasource="#args.datasource#">
			SELECT *
			FROM tblTrans,tblAccount
			WHERE trnID=#val(args.tranID)#
			<cfif StructKeyExists(args.form,"accID")>AND trnAccountID=#val(args.form.accID)#<cfelse>AND trnAccountID=accID</cfif>
			<cfif StructKeyExists(args.form,"type")>AND trnType='#args.form.type#'</cfif>
			LIMIT 1;
		</cfquery>
		<cfset result.tran=QueryToArrayOfStruct(QTran)>
		<cfset result.NetAmount=abs(QTran.trnAmnt1)>
		<cfset result.VatAmount=abs(QTran.trnAmnt2)>
		<cfquery name="QNomItems" datasource="#args.datasource#">
			SELECT *
			FROM tblNomItems,tblNominal
			WHERE niTranID=#val(args.tranID)#
			AND niNomID=nomID
			AND nomType='sales'
			ORDER BY niID asc
		</cfquery>
		<cfif QNomItems.recordcount gt 0>
			<cfset tranTotal=0>
			<cfset vatTotal=0>
			<cfloop query="QNomItems">
				<cfset item={}>
				<cfset item.niID=niID>
				<cfset item.niNomID=niNomID>
				<cfset item.nomTitle=nomTitle>
				<cfset item.nomVATRate=StructFind(application.site.vat,nomVATCode)*100>
				<cfset item.nomType=nomType>
				<cfset item.niTranID=niTranID>
				<cfif args.form.accType IS "sales" OR (StructKeyExists(args.form,"type") AND (args.form.type IS "crn"))>
					<cfset item.niAmount=-niAmount>
				<cfelse>
					<cfset item.niAmount=niAmount>
				</cfif>

				<cfset vatRate=StructFind(application.site.vat,nomVATCode)>
				<cfset item.vat=round(item.niAmount*vatRate*100)/100>
				<cfset tranTotal=tranTotal+item.niAmount>
				<cfset vatTotal=vatTotal+item.vat>
				<cfset ArrayAppend(result.items,item)>
			</cfloop>
			<cfset result.error=0>
			<cfset result.mode=2>
		<cfelse>
			<cfset result.error=0>
			<cfset result.mode=1>
		</cfif>
		<cfset result.GrandTotal=tranTotal>
		<cfset result.GrandVatTotal=vatTotal>
		<cfreturn result>
	</cffunction>

	<cffunction name="AddTransaction" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTran="">
		<cfset var QNewTran="">
		<cfset var amount1=val(REReplace(args.form.trnAmnt1,"[^-0-9.]","","all"))>
		<cfset var amount2=val(REReplace(args.form.trnAmnt2,"[^-0-9.]","","all"))>	
<!---
		<cfif args.form.type eq "crn">
			<cfset amount1="-#REReplace(args.form.trnAmnt1,"�","","all")#">
			<cfset amount2="-#REReplace(args.form.trnAmnt2,"�","","all")#">
		<cfelse>
			<cfset amount1=REReplace(args.form.trnAmnt1,"�","","all")>
			<cfset amount2=REReplace(args.form.trnAmnt2,"�","","all")>
		</cfif>
--->
		<cfif args.form.accType IS "sales" OR (StructKeyExists(args.form,"type") AND (args.form.type IS "crn"))>
			<cfset amount1=-amount1>
			<cfset amount2=-amount2>
		</cfif>
		<cfquery name="QTran" datasource="#args.datasource#" result="QNewTran">
			INSERT INTO tblTrans (
				trnLedger,
				trnAccountID,
				trnClientRef,
				trnType,
				trnRef,
				trnMethod,
				trnDate,
				trnAmnt1,
				trnAmnt2,
				trnAlloc,
				trnPaidIn,
				trnActive
			) VALUES (
				'#args.form.accType#',
				#args.form.accID#,
				0,
				'#args.form.type#',
				'#args.form.trnRef#',
				'',
				'#LSDateFormat(args.form.trnDate,"YYYY-MM-DD")#',
				#amount1#,
				#amount2#,
				0,
				0,
				0
			)
		</cfquery>
		<cfset result.ID=QNewTran.generatedKey>
		<cfset result.msg="Transaction added">
		
		<cfreturn result>
	</cffunction>

	<cffunction name="UpdateTransaction" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTran="">
		<cfset var amount1=val(REReplace(args.form.trnAmnt1,"[^-0-9.]","","all"))>
		<cfset var amount2=val(REReplace(args.form.trnAmnt2,"[^-0-9.]","","all"))>
		<cfif args.form.accType IS "sales" OR args.form.type eq "crn">
			<cfset amount1=-amount1>
			<cfset amount2=-amount2>
		</cfif>	
<!---
		<cfif args.form.accType IS "sales" OR args.form.type eq "crn">
			<cfset amount1="-#REReplace(args.form.trnAmnt1,"�","","all")#">
			<cfset amount2="-#REReplace(args.form.trnAmnt2,"�","","all")#">
		<cfelse>
			<cfset amount1=REReplace(args.form.trnAmnt1,"�","","all")>
			<cfset amount2=REReplace(args.form.trnAmnt2,"�","","all")>
		</cfif>
--->
		<cfquery name="QTran" datasource="#args.datasource#">
			UPDATE tblTrans
			SET trnRef='#args.form.trnRef#',
				trnDate='#LSDateFormat(args.form.trnDate,"YYYY-MM-DD")#',
				trnAmnt1=#val(amount1)#,
				trnAmnt2=#val(amount2)#
			WHERE trnID=#val(args.tranID)#
		</cfquery>
		<cfset result.msg="Transaction updated">
		
		<cfreturn result>
	</cffunction>

	<cffunction name="AddItem" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QNom="">
		<cfset var QNewNom="">
		<cfset var amount=val(REReplace(args.form.niAmount,"[^-0-9.]","","all"))>
		
		<cfif args.form.type eq "crn" OR args.form.accType is "sales">
			<cfset amount=-amount>
		</cfif>
		<cfquery name="QNom" datasource="#args.datasource#" result="QNewNom">
			INSERT INTO tblNomItems (
				niNomID,
				niTranID,
				niAmount,
				niActive
			) VALUES (
				#args.form.nomID#,
				#args.form.transID#,
				#amount#,
				0
			)
		</cfquery>
		<cfset result.ID=QNewNom.generatedKey>
		<cfset result.msg="Item added">
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddListItem" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QNom="">
		<cfset var QNewNom="">
		<cfset var itemAmount=0>
		<cfset var amount=0>
		<cfset var i=0>
		
		<cfloop list="#args.form.niNomID#" delimiters="," index="i">
			<cfset itemAmount=StructFind(args.form,"niAmount_#i#")>
			<cfset amount=val(REReplace(itemAmount,"[^-0-9.]","","all"))>
			<cfif args.form.type eq "crn" OR args.form.accType is "sales">
				<cfset amount=-amount>
			</cfif>
			<cfquery name="QNom" datasource="#args.datasource#" result="QNewNom">
				INSERT INTO tblNomItems (
					niNomID,
					niTranID,
					niAmount,
					niActive
				) VALUES (
					#i#,
					#args.form.transID#,
					#amount#,
					0
				)
			</cfquery>
		</cfloop>
		<cfset result.msg="Item added">
		<cfset result.QNewNom=QNewNom>
		<cfreturn result>
	</cffunction>

	<cffunction name="UpdateListItem" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QNom="">
		<cfset var QNewNom="">
		<cfset var itemAmount=0>
		<cfset var amount=0>
		<cfset var i=0>
		
		<cfloop list="#args.form.niID#" delimiters="," index="i">
			<cfset itemAmount=StructFind(args.form,"niAmount_#i#")>
			<cfset amount=val(REReplace(itemAmount,"[^-0-9.]","","all"))>
			<cfif args.form.type eq "crn" OR args.form.accType is "sales">
				<cfset amount=-amount>
			</cfif>
			<cfquery name="QNom" datasource="#args.datasource#">
				UPDATE tblNomItems
				SET niAmount=#amount#
				WHERE niID=#i#
			</cfquery>
		</cfloop>
		<cfset result.msg="Item added">
		
		<cfreturn result>
	</cffunction>

	<cffunction name="DeleteItem" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QNom="">
		<cfset var QNomItem="">
		
		<cfquery name="QNomItem" datasource="#args.datasource#">
			SELECT niTranID
			FROM tblNomItems
			WHERE niID=#args.itemID#
			LIMIT 1;
		</cfquery>
		<cfquery name="QTrans" datasource="#args.datasource#">
			UPDATE tblTrans 
			SET trnActive=0
			WHERE trnID=#QNomItem.niTranID#
		</cfquery>
		<cfquery name="QNomItems" datasource="#args.datasource#">
			UPDATE tblNomItems 
			SET niActive=0
			WHERE niTranID=#QNomItem.niTranID#
		</cfquery>
		<cfquery name="QNom" datasource="#args.datasource#">
			DELETE FROM tblNomItems
			WHERE niID=#args.itemID#
		</cfquery>
		<cfset result.msg="Item Deleted">
		
		<cfreturn result>
	</cffunction>

	<cffunction name="ActivateTransaction" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var QNomItems="">
		
		<cfquery name="QTrans" datasource="#args.datasource#">
			UPDATE tblTrans 
			SET trnActive=#args.set#
			WHERE trnID=#args.tranID#
		</cfquery>
		<cfquery name="QNomItems" datasource="#args.datasource#">
			UPDATE tblNomItems 
			SET niActive=#args.set#
			WHERE niTranID=#args.tranID#
		</cfquery>
		<cfset result.msg="Transaction Activated">
		
		<cfreturn result>
	</cffunction>

	<cffunction name="TranList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var QAccount="">
		
		<cfquery name="QAccount" datasource="#args.datasource#">
			SELECT *
			FROM tblAccount
			WHERE accID=#val(args.accountID)#
			LIMIT 1;
		</cfquery>
		<cfset result.supplier=QueryToArrayOfStruct(QAccount)>
		<cfquery name="QTrans" datasource="#args.datasource#">
			SELECT *
			FROM tblTrans 
			WHERE trnLedger='#args.nomType#'
			AND trnAccountID=#args.accountID#
			ORDER by trnDate
			<!---LIMIT 0,50;--->
		</cfquery>
		<cfif QTrans.recordcount gt 0>
			<cfset result.trans=QueryToArrayOfStruct(QTrans)>
		<cfelse>
			<cfset result.msg="No transactions found.">
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="TranSummary" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QNomItems="">
		<cfset var thisLedger="">
		<cfset var thisCode="">
		<cfset var ledgerDates="">
		<cfset var dateStruct={}>
		
		<cfquery name="QNomItems" datasource="#args.datasource#">
			SELECT trnLedger, trnDate, nomCode, nomTitle, Sum(niAmount) AS Amount, DATE_FORMAT(trnDate,'%Y%m') AS YYMM
			FROM tblNomItems, tblNominal, tblTrans
			WHERE nomID=niNomID
			AND trnID=niTranID
			<cfif StructKeyExists(args.form,"dateFrom")>
				AND trnDate >= '#LSDateFormat(args.form.dateFrom,'yyyy-mm-dd')#' AND trnDate <= '#LSDateFormat(args.form.dateTo,'yyyy-mm-dd')#'
			</cfif>
			<cfif StructKeyExists(args.form,"accountID") AND val(args.form.accountID) gt 0>
				AND trnAccountID=#val(args.form.accountID)#
			</cfif>
			GROUP BY trnLedger, MONTH(trnDate), nomCode
		</cfquery>
		<cfloop query="QNomItems">
			<cfif NOT StructKeyExists(result,trnLedger)>
				<cfset StructInsert(result,trnLedger,{codes={},dates={}})>
			</cfif>
			<cfset thisLedger=StructFind(result,trnLedger)>
			<cfif NOT StructKeyExists(thisLedger.codes,nomCode)>
				<cfset StructInsert(thisLedger.codes,nomCode,{"Title"=nomTitle,"Values"={},"Total"=0})>			
			</cfif>
			<cfset thisCode=StructFind(thisLedger.codes,nomCode)>
			<cfset thisCode.Total=thisCode.Total+Amount>
			
			<cfset ledgerDates=StructFind(thisLedger,"dates")>
			<cfif NOT StructKeyExists(thisLedger.dates,"D#YYMM#")>
				<cfset StructInsert(thisLedger.dates,"D#YYMM#",{"colHeader"=DateFormat(trnDate,"mmm yyyy"),"monthTotal"=0})>
			</cfif>
			<cfset dateStruct=StructFind(thisLedger.dates,"D#YYMM#")>
			<cfset StructUpdate(dateStruct,"monthTotal",dateStruct.monthTotal+Amount)>
			<cfset StructInsert(thisCode.Values,"D#YYMM#",Amount)>
		</cfloop>
		<cfreturn result>
	</cffunction>

	<cffunction name="TranDetails" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans=0>
		<cfset var QResult=0>
		
		<cfquery name="QTrans" datasource="#args.datasource#" result="QResult">
			SELECT accCode, accName, trnID, trnLedger, trnRef, trnDate, trnAmnt1, trnAmnt2, nomCode, nomTitle, niID, niAmount, abs(niAmount) AS absAmount
			FROM tblNomItems, tblNominal, tblTrans, tblAccount
			<cfif StructKeyExists(args,"url")>WHERE nomCode='#args.url.code#'
				<cfelseif StructKeyExists(args.form,"srchNom") AND len(args.form.srchNom)>WHERE nomID='#args.form.srchNom#'
				<cfelse>WHERE nomType='sales'</cfif>
			<cfif len(args.form.srchDateFrom)>
				AND trnDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateFrom#"> 
				AND <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateTo#"></cfif>
			AND nomID=niNomID
			AND trnID=niTranID
			AND accID=trnAccountID
			AND niAmount<>0
			ORDER BY accCode, trnDate
		</cfquery>
		<cfset result.QTrans=QTrans>
		<cfset result.QResult=QResult>
		<cfset result.nom.code=QTrans.nomCode>
		<cfset result.nom.title=QTrans.nomTitle>
		<cfreturn result>
	</cffunction>

<!--- Nominal Accounts --->

	<cffunction name="AddTran" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTran=0>
		<cfset var QTranItems=0>
		<cfset var QResult="">
		<cfset var i=0>
		<cfset var nomCode="">
		<cfset var drValue=0>
		<cfset var crValue=0>
		<cfset var drTotal=0>
		<cfset var crTotal=0>
		<cfset var amount=0>
		
		<cfif len(args.form.trnDate) eq 0>
			<cfset args.form.trnDate=Now()>
		</cfif>
		<cfset result.sqltran="INSERT INTO tblTrans (trnLedger,trnAccountID,trnType,trnRef,trnDesc,trnDate,trnAmnt1,trnAmnt2,trnAlloc,trnActive)">
		<cfset result.sqltran="#result.sqltran# VALUES ('#args.form.ledger#',#args.form.accountID#,'#args.form.tranType#','#args.form.trnRef#',">
		<cfset result.sqltran="#result.sqltran# '#args.form.trnDesc#','#DateFormat(args.form.trnDate,'yyyy-mm-dd')#',#val(args.form.trnAmnt1)#,#val(args.form.trnAmnt2)#,1,1)">
		<cfset result.tranID="TRANID">
		<cfset result.sqlitems="">
		<cfloop from="1" to="#args.form.maxRows#" index="i">
			<cfset nomCode=StructFind(args.form,'nomID#i#')>
			<cfif len(nomCode)>
				<cfset drValue=val(StructFind(args.form,'drValue#i#'))>
				<cfset drTotal=drTotal+drValue>
				<cfset crValue=val(StructFind(args.form,'crValue#i#'))>
				<cfset crTotal=crTotal+crValue>
				<cfif drValue gt 0><cfset amount=drValue>
					<cfelse><cfset amount=-crValue></cfif>
				<cfif len(result.sqlitems)><cfset result.sqlitems="#result.sqlitems#,"></cfif>
				<cfset result.sqlitems="#result.sqlitems# (null,#nomCode#,#result.tranID#,#amount#,1)">
			</cfif>
		</cfloop>
		<cfset result.sqlitems="INSERT INTO tblNomItems VALUES #result.sqlitems#">
		<cfif drTotal eq crTotal AND crTotal eq args.form.trnTotal>
			<cftry>
				<cfquery name="QTran" datasource="#args.datasource#" result="QResult">
					#PreserveSingleQuotes(result.sqltran)#
				</cfquery>
				<cfset result.tranID=QResult.generatedkey>
				<cfset result.sqlitems=Replace(result.sqlitems,"TRANID",result.tranID,"all")>
				<cfquery name="QTranItems" datasource="#args.datasource#">
					#PreserveSingleQuotes(result.sqlitems)#
				</cfquery>
				<cfquery name="QTran" datasource="#args.datasource#" result="QResult">
					SELECT tblTrans.*, trnAmnt1+trnAmnt2 AS trnTotal
					FROM tblTrans WHERE trnID=#result.tranID#
				</cfquery>
				<cfset result.QTran=QTran>
				<cfquery name="QTranItems" datasource="#args.datasource#">
					SELECT tblNomItems.*,nomCode FROM tblNomItems, tblNominal WHERE nomID=niNomID AND niTranID=#result.tranID#
				</cfquery>
				<cfset result.QTranItems=QTranItems>
			<cfcatch type="any">
				<cfset result.cfcatch=cfcatch>
				<cfdump var="#cfcatch#" label="TranDetails" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.html">
			</cfcatch>
			</cftry>
		<cfelse>
			<cfset result.msg="Transaction analysis does not balance. dr=#drTotal# cr=#crTotal# total=#args.form.trnTotal#">
			<cfset result.dummy="SELECT * FROM tblControl WHERE 1 LIMIT 1">
			<cfquery name="QTran" datasource="#args.datasource#" result="QResult">
				#PreserveSingleQuotes(result.dummy)#
			</cfquery>
			<cfset result.QTran=QTran>
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadBlank" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTran="">
		
		<cfquery name="QTran" datasource="#args.datasource#">
			SELECT accCode, accName, tblTrans.*, trnAmnt1+trnAmnt2 AS trnTotal
			FROM tblNomItems, tblNominal, tblTrans, tblAccount
			WHERE nomCode=''
			AND nomID=niNomID
			AND trnID=niTranID
			AND accID=trnAccountID
			ORDER BY accCode, trnDate
			LIMIT 0,1;
		</cfquery>
		<cfset result.QTran=QTran>
		<cfset QueryAddRow(result.QTran,1)>
		<cfreturn result>
	</cffunction>

	<cffunction name="TranSearch" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var parms={}>
		<cfset var QTrans="">
		<cfdump var="#args#" label="TranSearch" expand="no">
		<cfset parms.srchDateFrom="">
		<cfset parms.srchDateTo="">
		<cfset parms.srchAccountID="">
		<cfset parms.srchName="">
		<cfset parms.srchType="">
		<cfset parms.limitRecs="">
		<cfset parms.srchSort="">

		<cfset result.records=0>
		<cfif StructKeyExists(args.search,"srchDateFrom") AND len(args.search.srchDateFrom)>
			<cfset parms.srchDateFrom=args.search.srchDateFrom>
		</cfif>
		<cfif StructKeyExists(args.search,"srchDateTo") AND len(args.search.srchDateTo)>
			<cfset parms.srchDateTo=args.search.srchDateTo>
		</cfif>
		<cfif StructKeyExists(args.search,"srchAccountID") AND args.search.srchAccountID gt 0>
			<cfset parms.srchAccountID=args.search.srchAccountID>
		</cfif>
		<cfif StructKeyExists(args.search,"srchName") AND len(args.search.srchName)>
			<cfset parms.name=args.search.srchName>
		</cfif>
		<cfset parms.sql="SELECT * FROM tblTrans,tblAccount WHERE trnAccountID=accID AND trnClientRef=0 ">
		<cfif len(parms.srchDateFrom) gt 0><cfset parms.sql="#parms.sql#AND trnDate>='#LSDateFormat(parms.srchDateFrom,"yyyy-mm-dd")#' "></cfif>
		<cfif len(parms.srchDateTo) gt 0><cfset parms.sql="#parms.sql#AND trnDate<='#LSDateFormat(parms.srchDateTo,"yyyy-mm-dd")#' "></cfif>
		<cfif parms.srchAccountID gt 0><cfset parms.sql="#parms.sql#AND trnAccountID=#parms.srchAccountID# "></cfif>
		<cfif len(parms.srchName) gt 0><cfset parms.sql="#parms.sql#AND accName LIKE '%#parms.srchName#%' "></cfif>
		<cfset parms.sql="#parms.sql# ORDER BY #args.search.srchSort#">
		<cfif val(args.search.limitRecs) gt 0><cfset parms.sql="#parms.sql# LIMIT 0,#args.search.limitRecs#; "></cfif>
		<cftry>
			<cfquery name="QTrans" datasource="#args.datasource#">
				#PreserveSingleQuotes(parms.sql)#
			</cfquery>
			<cfset result.sql=parms.sql>
			<cfset result.rowMax=QTrans.recordcount>
			<cfset result.records=QTrans>
		<cfcatch type="any">
			<cfset result.err=cfcatch>
		</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="BackupEntry" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		
		<cfset session.accounts.backup=args.form>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="UpdateNomTotal" access="private" returntype="struct">
		<cfargument name="nomID" type="numeric" required="yes">
		<cfargument name="oldAmount" type="numeric" required="yes">
		<cfargument name="newAmount" type="numeric" required="yes">
		<cfargument name="tranDate" type="date" required="yes">
		<cfargument name="datasource" type="string" required="yes">
		<cfset var result={}>
		<cfset var QNomTotal="">
		<cfset var dateCode=LSDateFormat(tranDate,"yymm")>
		
		<cfquery name="QNomTotal" datasource="#datasource#">
			SELECT * 
			FROM tblNomTotal 
			WHERE ntNomID=#nomID#
			AND ntPrd=#dateCode#
		</cfquery>
		<cfif QNomTotal.recordcount IS 0>
			<cfquery name="QNomTotal" datasource="#datasource#">
				INSERT INTO tblNomTotal (ntNomID,ntPrd,ntBal) VALUES (#nomID#,#dateCode#,#newAmount-oldAmount#)
			</cfquery>
		<cfelse>
			<cfquery name="QNomTotal" datasource="#datasource#">
				UPDATE tblNomTotal
				SET ntBal=#newAmount-oldAmount#
				WHERE ntNomID=#nomID#
				AND ntPrd=#dateCode#
			</cfquery>
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="InsertNominalLedger" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTran="">
		<cfset var QNewTran="">
		<cfset var QNomItem="">
		
		<cftry>
			<cfquery name="QTran" datasource="#args.datasource#" result="QNewTran">
				INSERT INTO tblTrans (
					trnLedger,
					trnType,
					trnRef,
					trnDesc,
					trnDate,
					trnAmnt1,
					trnAmnt2,
					trnTest
				) VALUES (
					'nom',
					'nom',
					'#args.form.trnRef#',
					'#args.form.trnDesc#',
					'#LSDateFormat(args.form.trnDate,"yyyy-mm-dd")#',
					#DecimalFormat(args.form.trnAmnt1)#,
					#DecimalFormat(args.form.trnAmnt2)#,
					1
				)
			</cfquery>
			<cfif StructKeyExists(args.form,"rowID")>
				<cfloop list="#args.form.rowID#" delimiters="," index="i">
					<cfset nomID=StructFind(args.form,"nomID#i#")>
					<cfif val(nomID) neq 0>
						<cfif StructKeyExists(args.form,"drValue#i#")>
							<cfset niAmount=StructFind(args.form,"drValue#i#")>
						<cfelse>
							<cfset niAmount=-StructFind(args.form,"crValue#i#")>
						</cfif>
						<cfquery name="QNomItem" datasource="#args.datasource#">
							INSERT INTO tblNomItems (
								niNomID,
								niTranID,
								niAmount,
								niActive
							) VALUES (
								#val(nomID)#,
								#QNewTran.generatedKey#,
								#DecimalFormat(niAmount)#,
								9
							)
						</cfquery>
						<cfset UpdateNomTotal(nomID,0,niAmount,args.form.trnDate,args.datasource)>
					</cfif>
				</cfloop>
			</cfif>
			<cfset result.tranID=QNewTran.generatedKey>
			<cfset result.msg="Transaction Inserted">
	
			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="UpdateNominalLedger" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTran="">
		<cfset var QNomItem="">
		<cfset var QNomItems="">
		<cfset var item="">
		
		<cftry>
			<cfquery name="QTran" datasource="#args.datasource#">
				UPDATE tblTrans
				SET 
					trnRef='#args.form.trnRef#',
					trnDesc='#args.form.trnDesc#',
					trnDate='#LSDateFormat(args.form.trnDate,"yyyy-mm-dd")#',
					trnAmnt1=#DecimalFormat(args.form.trnAmnt1)#,
					trnAmnt2=#DecimalFormat(args.form.trnAmnt2)#
				WHERE trnID=#val(args.form.trnID)#
			</cfquery>
			<cfquery name="QNomItems" datasource="#args.datasource#">
				SELECT niID,niNomID,niAmount FROM tblNomItems
				WHERE niTranID=#val(args.form.trnID)#
			</cfquery>
			<cfset result.items={}>
			<cfloop query="QNomItems">
				<cfif NOT StructKeyExists(result.items,niNomID)>
					<cfset StructInsert(result.items,niNomID,niAmount)>
				<cfelse>
					<cfset item=StructFind(result.items,niNomID)>
					<cfset StructUpdate(result.items,niNomID,item.niAmount+niAmount)>
				</cfif>
			</cfloop>
			<cfif StructKeyExists(args.form,"rowID")>
				<cfloop list="#args.form.rowID#" delimiters="," index="i">
					<cfset nomID=StructFind(args.form,"nomID#i#")>
					<cfif val(nomID) neq 0>
						<cfif StructKeyExists(args.form,"drValue#i#")>
							<cfset niAmount=StructFind(args.form,"drValue#i#")>
						<cfelse>
							<cfset niAmount=-StructFind(args.form,"crValue#i#")>
						</cfif>
						<cfif StructKeyExists(result.items,nomID)>
						
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
			<!---
						<cfquery name="QNomItem" datasource="#args.datasource#">
							INSERT INTO tblNomItems (
								niNomID,
								niTranID,
								niAmount,
								niActive
							) VALUES (
								#val(nomID)#,
								#args.form.trnID#,
								#DecimalFormat(niAmount)#,
								9
							)
						</cfquery>
			--->
			<cfset result.tranID=args.form.trnID>
			<cfset result.msg="Transaction Updated">
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadNomData" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var QTran="">
		<cfset var QNomItems="">

		<cfquery name="QTran" datasource="#args.datasource#">
			SELECT *
			FROM tblTrans
			WHERE trnID=#val(args.form.ID)#
			LIMIT 1;
		</cfquery>
		<cfif QTran.recordcount is 1>
			<cfquery name="QNomItems" datasource="#args.datasource#">
				SELECT *
				FROM tblNomItems
				WHERE niTranID=#val(args.form.ID)#
			</cfquery>
			<cfset result.ID=QTran.trnID>
			<cfset result.Date=LSDateFormat(QTran.trnDate,"yyyy-mm-dd")>
			<cfset result.Ref=QTran.trnRef>
			<cfset result.Desc=QTran.trnDesc>
			<cfset result.Amnt1=QTran.trnAmnt1>
			<cfset result.Amnt2=QTran.trnAmnt2>
			<cfset result.items=[]>
			<cfloop query="QNomItems">
				<cfset item={}>
				<cfset item.NomID=QNomItems.niNomID>
				<cfset item.Amount=DecimalFormat(QNomItems.niAmount)>
				<cfset ArrayAppend(result.items,item)>
			</cfloop>
		<cfelse>
			<cfset result.error=true>
		</cfif>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="SavePayments" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var setFlag=0>
		<cfset var QResult="">
		<cfset var QNomItem="">
		<cfset var i=0>
		<cfset var actParms={}>
		
		<cftry>
			<cfset result.tickList="">
			<cfloop from="1" to="#args.form.tranCount#" index="i">
				<cfif StructKeyExists(args.form,"tick#i#")>
					<cfset result.tickList=ListAppend(result.tickList,StructFind(args.form,"tick#i#"),",")>
				</cfif>
			</cfloop>
			<cfset result.preticked=ListLen(result.tickList,",")>
			<cfif StructKeyExists(args.form,"btnClicked") AND args.form.btnClicked eq "btnSavePayment">
				<cfquery name="QTrans" datasource="#args.datasource#" result="QResult">
					INSERT INTO tblTrans (
						trnAccountID,
						trnClientRef,
						trnRef,
						trnDate,
						trnMethod,
						trnType,
						trnAlloc,
						trnAmnt1,
						trnAmnt2
					) VALUES (
						#val(args.form.clientID)#,
						#val(args.form.clientRef)#,
						'#args.form.trnRef#',
						'#LSDateFormat(args.form.trnDate,"yyyy-mm-dd")#',
						<cfif args.form.trnType eq 'pay'>'#args.form.trnMethod#'<cfelse>''</cfif>,
						'#args.form.trnType#',
						#int(result.preticked gt 0)#,
						#-1*val(args.form.trnAmnt1)#,
						#-1*val(args.form.trnAmnt2)#
					)
				</cfquery>
				<cfquery name="QNomItem" datasource="#args.datasource#">
					INSERT INTO tblNomItems (
						niNomID,niTranID,niAmount
					) VALUES (
						41,#qresult.generatedkey#,#val(args.form.trnAmnt1)#
					)
				</cfquery>
				<cfset result.qresult=qresult>
				<cfset result.tickList=ListAppend(result.tickList,qresult.generatedkey,",")>
			</cfif>
			<cfquery name="QTrans" datasource="#args.datasource#">
				SELECT *
				FROM tblTrans
				WHERE trnClientRef=#val(args.form.clientRef)#
				<cfif NOT StructKeyExists(args.form,"allTrans")>AND trnAlloc=0</cfif>
				ORDER BY trnDate
			</cfquery>
			<cfset result.trans=qtrans>
			<cfloop query="QTrans">
				<cfif result.preticked AND ListFind(result.tickList,trnID,",")>
					<cfset setFlag=1>
				<cfelse><cfset setFlag=0></cfif>
				<cfquery name="QPub" datasource="#args.datasource#">
					UPDATE tblTrans
					SET trnAlloc=#setFlag#
					WHERE trnID=#trnID#
					LIMIT 1;
				</cfquery>				
			</cfloop>
	
			<cfset actParms={}>
			<cfset actParms.datasource=args.datasource>
			<cfset actParms.type="payment">
			<cfset actParms.class="added">
			<cfset actParms.clientID=args.form.clientID>
			<cfset actParms.pubID=0>
			<cfset actParms.Text="">
			<cfset actInsert=AddActivity(actParms)>
								
		<cfcatch type="any">
			<cfset result.error=cfcatch>
			<cfdump var="#cfcatch#" label="SavePayments" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="SaveCreditPayment" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		
		<cftry>
			<cfquery name="QTrans" datasource="#args.datasource#">
				INSERT INTO tblTrans (
					trnAccountID,
					trnClientRef,
					trnRef,
					trnDate,
					trnMethod,
					trnDesc,
					trnType,
					trnAmnt1,
					trnAmnt2
				) VALUES (
					#val(args.form.clientID)#,
					#val(args.form.clientRef)#,
					'#args.form.crnRef#',
					'#LSDateFormat(args.form.crnDate,"yyyy-mm-dd")#',
					'',
					'#args.form.crnDesc#',
					'crn',
					-#val(args.form.crnAmnt1)#,
					-#val(args.form.crnAmnt2)#
				)
			</cfquery>
				
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
</cfcomponent>
