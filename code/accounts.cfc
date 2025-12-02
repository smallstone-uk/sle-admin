<cfcomponent displayname="accounts" extends="core">
	<cffunction name="DeleteNominalTransaction" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.del" datasource="#args.datasource#">
			DELETE FROM tblTrans
			WHERE trnID = #val(args.tranID)#
		</cfquery>
	</cffunction>
	<cffunction name="LoadNominalTransaction" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.tran" datasource="#args.datasource#">
			SELECT *
			FROM tblTrans
			WHERE trnID = #val(args.tranID)#
		</cfquery>
		
		<cfset loc.result.header = KQueryToStruct(loc.tran)>
		
		<cfquery name="loc.items" datasource="#args.datasource#">
			SELECT *
			FROM tblNomItems
			WHERE niTranID = #val(args.tranID)#
		</cfquery>
		
		<cfset loc.result.items = QueryToArrayOfStruct(loc.items)>
		
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="MoveTranToAccount" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.move" datasource="#args.datasource#">
			UPDATE tblTrans
			SET trnAccountID = #val(args.newAccount)#
			WHERE trnID = #val(args.tranID)#
		</cfquery>
	</cffunction>
	<cffunction name="SaveNominalTransRecord" access="public" returntype="struct" hint="developed for importing data from spreadsheet">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.newTranDate = LSDateFormat(args.header.trnDate, "yyyy-mm-dd")>

		<cftry>
			<!---Set flag if tran exists in database--->
			<cfquery name="loc.tranExists" datasource="#args.database#" result="loc.tranExists_result">
				SELECT trnID, trnPayAcc, trnDate
				FROM tblTrans
				WHERE trnID = #val(args.header.trnID)#
			</cfquery>
			<cfset loc.isNew = loc.tranExists.recordcount eq 0>
			<cfif loc.isNew>	<!--- add transaction --->
				<cfset loc.netAmount = val(args.header.trnAmnt1)>
				<cfset loc.vatAmount = val(args.header.trnAmnt2)>
				<cfquery name="loc.newTrans" datasource="#args.database#" result="loc.newTrans_result">
					INSERT INTO tblTrans (
						trnLedger,
						trnAccountID,
						trnRef,
						trnDesc,
						trnDate,
						trnAmnt1,
						trnAmnt2,
						trnAlloc,
						trnType
					) VALUES (
						'#args.header.accType#',
						3,
						'#args.header.trnRef#',
						'#args.header.trnDesc#',
						'#loc.newTranDate#',
						#val(loc.netAmount)#,
						#val(loc.vatAmount)#,
						1,
						'#args.header.tranType#'
					)
				</cfquery>
				<cfset loc.result.tranID = loc.newTrans_result.generatedKey>
			</cfif>
			<cfset loc.newItemStr = "">
			<cfloop array="#args.items#" index="loc.item">
				<cfif loc.item.nomAmount neq 0>
					<cfif len(loc.newItemStr)><cfset loc.newItemStr = loc.newItemStr & ","></cfif>
					<cfset loc.newItemStr = loc.newItemStr & "(#val(loc.item.nomID)#,#val(loc.result.tranID)#, #val(loc.item.nomAmount)#,0,0,0)">
				</cfif>
			</cfloop>
			
			<!--- Insert new items --->
			<cfquery name="loc.newItem" datasource="#args.database#" result="loc.newItem_result">
				INSERT INTO tblNomItems (
					niNomID,
					niTranID,
					niAmount,
					niVATAmount,
					niVATRate,
					niActive
				) VALUES #loc.newItemStr#
			</cfquery>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<!---<cfdump var="#loc#" label="SaveNominalTransRecord" expand="yes" format="html" 
		output="#application.site.dir_logs#dump-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">--->
		
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="LoadNominalTransactions" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.thisMonth = CreateDate(Year(Now()), Month(Now()), 1)>

		<cfquery name="loc.trans" datasource="#args.datasource#" result="loc.result.transResult">
			SELECT *
			FROM tblTrans, tblNominal, tblNomItems
			WHERE niTranID = trnID
			AND niNomID = nomID
			AND nomID = #val(args.form.nominal_account)#
			<cfswitch expression="#args.form.srchRange#">
				<cfcase value="0">
					<!--- all records --->
				</cfcase>
				<cfcase value="1">
					AND trnDate >= '#LSDateFormat(DateAdd("d",-7,Now()),"yyyy-mm-dd")#'
				</cfcase>
				<cfcase value="2">
					AND trnDate >= '#LSDateFormat(loc.thisMonth,"yyyy-mm-dd")#'
				</cfcase>
				<cfcase value="3">
					AND trnDate >= '#LSDateFormat(DateAdd("m",-1,loc.thisMonth),"yyyy-mm-dd")#'
				</cfcase>
				<cfcase value="4">
					AND trnDate >= '#LSDateFormat(DateAdd("m",-2,loc.thisMonth),"yyyy-mm-dd")#'
				</cfcase>
				<cfcase value="5">
					AND trnDate >= '#LSDateFormat(DateAdd("m",-3,loc.thisMonth),"yyyy-mm-dd")#'
				</cfcase>
				<cfcase value="6">
					AND trnDate >= '#LSDateFormat(DateAdd("m",-6,loc.thisMonth),"yyyy-mm-dd")#'
				</cfcase>
				<cfcase value="12">
					AND trnDate >= '#LSDateFormat(DateAdd("m",-12,loc.thisMonth),"yyyy-mm-dd")#'
				</cfcase>
				<cfdefaultcase>
					<cfif len(args.form.srchRange)>
						<cfif Left(args.form.srchRange,2) eq 'FY'>
							<cfset loc.fyDate=StructFind(application.site.FYDates,args.form.srchRange)>
							AND trnDate >= '#loc.fyDate.start#'
							AND trnDate <= '#loc.fyDate.end#'
						<cfelseif Left(args.form.srchRange,4) eq 'YEAR'>
							<cfset loc.thisYear = ListRest(args.form.srchRange,"-")>
							<cfset loc.fromYear = CreateDate(loc.thisYear,1,1)>
							<cfset loc.toYear = CreateDate(loc.thisYear,12,31)>
							AND trnDate >= '#LSDateFormat(loc.fromYear,"yyyy-mm-dd")#' 
							AND trnDate <= '#LSDateFormat(loc.toYear,"yyyy-mm-dd")#'
						<cfelse>
							AND trnDate >= '#args.form.srchRange#-01'
							AND trnDate <= '#args.form.srchRange#-31'
						</cfif>
					</cfif>
				</cfdefaultcase>
			</cfswitch>
			<cfif len(args.form.nominal_ref)>
				AND trnDesc LIKE '%#args.form.nominal_ref#%'
			</cfif>
			ORDER BY trnDate ASC, trnType, trnID ASC
		</cfquery>
		<cfset loc.startdate=DateFormat(loc.trans.trnDate[1],"yyyy-mm-dd")>
		<cfset loc.filter="AND trnDate < '#loc.startdate#'">
		<cfset loc.result.args=args>
		<cfset loc.result.trans=loc.trans>
		<cfquery name="loc.broughtforward" datasource="#args.datasource#">
			SELECT SUM(niAmount) AS bfwdTotal
			FROM tblTrans, tblNominal, tblNomItems
			WHERE niTranID = trnID
			AND niNomID = nomID
			AND nomID = #val(args.form.nominal_account)#
			#PreserveSingleQuotes(loc.filter)#
			GROUP BY nomID
		</cfquery>
		<cfset loc.result.bfwd=val(loc.broughtforward.bfwdTotal)>
		<cfquery name="loc.nomTitles" datasource="#args.datasource#">
			SELECT nomCode, nomTitle
			FROM tblNominal
			WHERE nomID = #val(args.form.nominal_account)#
		</cfquery>
		<cfset loc.result.nomAccount = {"nomCode" = "#loc.nomTitles.nomCode#", "nomTitle" = "#loc.nomTitles.nomTitle#"}>
		<cfquery name="loc.sorted" dbtype="query">
			SELECT *
			FROM loc.trans
			<cfswitch expression="#args.form.sortOrder#">
				<cfcase value="1">
					ORDER BY trnDate ASC
				</cfcase>
				<cfcase value="2">
					ORDER BY trnID ASC
				</cfcase>
				<cfcase value="3">
					ORDER BY trnRef ASC, trnID ASC
				</cfcase>
			</cfswitch>
		</cfquery>
		
		<cfif loc.trans.recordcount is 0>
			<cfset loc.result.tranList = []>
		<cfelse>
			<cfset loc.result.tranList = QueryToArrayOfStruct(loc.sorted)>
		</cfif>
		<cfset loc.result.rowCount = loc.sorted.recordcount>
		
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="LoadNominalAccounts" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.nominal" datasource="#args.datasource#">
			SELECT nomID,nomCode,nomTitle,nomGroup
			FROM tblNominal
			WHERE nomStatus=1
			ORDER BY nomGroup, nomTitle
		</cfquery>
<!---		
		<cfreturn QueryToArrayOfStruct(loc.noms)>
		<cfquery name="loc.nominal" datasource="#args.datasource#">
			SELECT *
			FROM tblNominal
			ORDER BY nomType ASC, nomGroup ASC, nomCode ASC
		</cfquery>
		
--->
		<cfreturn QueryToArrayOfStruct(loc.nominal)>
	</cffunction>

	<cffunction name="AllocateItems" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cftry>
			<cfquery name="loc.QAccountID" datasource="#args.datasource#">
				SELECT accAllocID
				FROM tblAccount
				WHERE accID = #val(args.accID)#
				LIMIT 1;
			</cfquery>
			<cfif loc.QAccountID.recordcount eq 1>
				<cfset loc.newID = loc.QAccountID.accAllocID + 1>
				<cfloop array="#args.form#" index="loc.item">
					<cfquery name="loc.items" datasource="#args.datasource#">
						UPDATE tblTrans
						SET trnAllocID = #loc.newID#,
							trnAlloc = 1
						WHERE trnID = #val(loc.item.id)#
						AND trnAllocID = 0
						AND trnAlloc = 0
					</cfquery>
				</cfloop>
				<cfquery name="loc.QAccountIDUpdate" datasource="#args.datasource#">
					UPDATE tblAccount
					SET accAllocID = #loc.newID#
					WHERE accID = #val(args.accID)#
					LIMIT 1;
				</cfquery>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
		</cffunction>

<!--- Revised 13/06/2025 ---> 
	<cffunction name="EditAccount" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.edit" datasource="#args.datasource#">
			UPDATE tblAccount
			SET accGroup = #val(args.form.Group)#,
				accName = '#args.form.Name#',
				accIndex = '#args.form.accIndex#',
				accType = '#args.form.Type#',
				accPayType = '#args.form.PayType#',
				accNomAcct = #val(args.form.NominalAccount)#,
				accPayAcc = #val(args.form.FundSource)#
			WHERE accID = #val(args.form.accountID)#
		</cfquery>
	</cffunction>
	<cffunction name="LoadAccountByCode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.account" datasource="#args.datasource#">
			SELECT *
			FROM tblAccount
			WHERE accCode = '#args.code#'
		</cfquery>
		
		<cfreturn KQueryToStruct(loc.account)>
	</cffunction>
	<cffunction name="LoadFundSources" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.sources" datasource="#args.datasource#">
			SELECT *
			FROM tblNominal
			WHERE nomGroup IN ('R3','R4')
		</cfquery>
		
		<cfreturn QueryToArrayOfStruct(loc.sources)>
	</cffunction>
	<cffunction name="LoadPaymentTypes" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.sources" datasource="#args.datasource#">
			SELECT *
			FROM tblATitles
			WHERE ttlType = 2
		</cfquery>
		
		<cfreturn QueryToArrayOfStruct(loc.sources)>
	</cffunction>
	<cffunction name="LoadAccountGroups" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.groups" datasource="#args.datasource#">
			SELECT *
			FROM tblATitles
			WHERE ttlType = 1
		</cfquery>
		
		<cfreturn QueryToArrayOfStruct(loc.groups)>
	</cffunction>
	<cffunction name="RemoveNomFromGroup" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.remove" datasource="#args.datasource#">
			DELETE FROM tblNomGroupItems
			WHERE ngiParent = #val(args.grpID)#
			AND ngiChild = #val(args.nomID)#
		</cfquery>
	</cffunction>
	<cffunction name="AddNomToGroup" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.add" datasource="#args.datasource#">
			INSERT INTO tblNomGroupItems (
				ngiParent,
				ngiChild,
				ngiOrder
			) VALUES (
				#val(args.form.parent)#,
				#val(args.form.child)#,
				#val(args.form.order)#
			)
		</cfquery>
	</cffunction>
	<cffunction name="LoadNominalsNotInGroup" access="public" returntype="array">
		<cfargument name="grpID" type="numeric" required="yes">
		<cfset var loc = {}>
		
<!---

			SELECT *
			FROM tblNominal, tblNomGroupItems
			WHERE ngiChild = nomID
			AND ngiParent != #val(grpID)#
--->
		<!--- #n.nomID#">#n.nomCode# - #n.nomTitle# --->
		<cfquery name="loc.noms" datasource="#GetDatasource()#">
			SELECT nomID,nomCode,nomTitle, ngiOrder, nomGroup
			FROM tblNominal
			LEFT JOIN tblNomGroupItems ON ngiChild = nomID
			WHERE ngiParent != #val(grpID)# OR ngiParent IS NULL
			ORDER BY nomGroup, nomCode, ngiOrder
		</cfquery>
		
		<cfreturn QueryToArrayOfStruct(loc.noms)>
	</cffunction>
	<cffunction name="DeleteGroup" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.del" datasource="#args.datasource#">
			DELETE FROM tblNomGroups
			WHERE ngID = #val(args.grpID)#
		</cfquery>
	</cffunction>
	<cffunction name="AddGroup" access="public" returntype="numeric">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cftry>
			<cfquery name="loc.check" datasource="#args.datasource#">
				SELECT *
				FROM tblNomGroups
				WHERE ngCode = '#UCase(args.form.name)#'
			</cfquery>
			
			<cfif loc.check.recordcount is 0>
				<cfquery name="loc.newgrp" datasource="#args.datasource#">
					INSERT INTO tblNomGroups (ngCode) VALUES ('#UCase(args.form.name)#')
				</cfquery>
				<cfreturn 1>
			<cfelse>
				<cfreturn 2>
			</cfif>
			
			<cfcatch type="any">
				<cfreturn 2>
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="DeleteNominalAccount" access="public" returntype="numeric">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cftry>
			<cfquery name="loc.checkItems" datasource="#args.datasource#">
				SELECT *
				FROM tblNomItems
				WHERE niNomID = #val(args.nomID)#
			</cfquery>
			<cfif loc.checkItems.recordcount is 0>
				<cfquery name="loc.del" datasource="#args.datasource#">
					DELETE FROM tblNominal
					WHERE nomID = #val(args.nomID)#
				</cfquery>
				<cfreturn 1>
			<cfelse>
				<cfreturn 2>
			</cfif>
			<cfcatch type="any">
				<cfreturn 2>
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="AddNominalAccount" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cftry>
			<cfquery name="loc.checkExists" datasource="#args.datasource#">
				SELECT nomID
				FROM tblNominal
				WHERE nomCode = <cfqueryparam value="#UCase(args.form.code)#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			
			<cfif loc.checkExists.recordcount is 0>
				<cfquery name="loc.maxRef" datasource="#args.datasource#">
					SELECT nomRef
					FROM tblNominal
					ORDER BY nomRef DESC
					LIMIT 1;
				</cfquery>
			
				<cfquery name="loc.newNominal" datasource="#args.datasource#" result="loc.newNominal_result">
					INSERT INTO tblNominal (
						nomRef,
						nomCode,
						nomTitle,
						nomType,
						nomGroup,
						nomClass,
						nomVATCode
					) VALUES (
						#val(loc.maxRef.nomRef) + 1#,
						<cfqueryparam value="#UCase(args.form.code)#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#args.form.title#" cfsqltype="CF_SQL_VARCHAR">,
						'#args.form.type#',
						'#UCase(args.form.group)#',
						'#args.form.class#',
						#val(args.form.vat)#
					)
				</cfquery>
				
				<cfquery name="loc.getGroupID" datasource="#args.datasource#">
					SELECT ngID
					FROM tblNomGroups
					WHERE ngCode = '#UCase(args.form.group)#'
				</cfquery>
				
				<cfquery name="loc.maxOrder" datasource="#args.datasource#">
					SELECT ngiOrder
					FROM tblNomGroupItems
					WHERE ngiParent = #val(loc.getGroupID.ngID)#
					ORDER BY ngiOrder DESC
					LIMIT 1;
				</cfquery>
				
				<cfquery name="loc.addGroupItem" datasource="#args.datasource#">
					INSERT INTO tblNomGroupItems (
						ngiParent,
						ngiChild,
						ngiOrder
					) VALUES (
						#val(loc.getGroupID.ngID)#,
						#val(loc.newNominal_result.generatedkey)#,
						#val(loc.maxOrder.ngiOrder) + 1#
					)
				</cfquery>
				<cfreturn {
					"msg" = "#args.form.title# added.",
					"type" = "success"
				}>
			<cfelse>
				<cfreturn {
					"msg" = "#UCase(args.form.code)# already exists.",
					"type" = "error"
				}>
			</cfif>
		
			<cfcatch type="any">
				<cfreturn {
					"msg" = "An error occurred.",
					"type" = "error"
				}>
			</cfcatch>
		</cftry>
		
	</cffunction>
	<cffunction name="LoadNominalRecordByCode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.nom" datasource="#args.datasource#">
			SELECT *
			FROM tblNominal
			WHERE nomCode = '#args.nomcode#'
		</cfquery>
		
		<cfreturn KQueryToStruct(loc.nom)>
	</cffunction>
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
					accNomAcct,
					accPayAcc
				) VALUES (
					'#UCase(args.form.Code)#',
					#val(args.form.Group)#,
					'#args.form.Name#',
					'#args.form.Type#',
					#val(args.form.NominalAccount)#,
					#val(args.form.FundSource)#
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
<!--- TODO Requires rewriting --->
		<cfquery name="loc.trans" datasource="#GetDatasource()#" result="loc.trans_result">
			SELECT trnID, accNomAcct, trnAmnt1, trnAmnt2, accType, trnType
			FROM tblTrans, tblAccount
			WHERE trnAccountID = accID
			ORDER BY trnID ASC
		</cfquery>
		
		<cfloop query="loc.trans">
			<cfset loc.signLedger = (2 * int(loc.trans.accType eq "sales")) - 1>
			<cfset loc.signTran = (2 * int(loc.trans.trnType eq "crn")) - 1>
			<cfset loc.signBalance = 2 * (NOT loc.signLedger * loc.signTran) - 1>
			
			<cfset loc.netAmount = val(loc.trans.trnAmnt1) * loc.signLedger * loc.signTran>
			<cfset loc.vatAmount = val(loc.trans.trnAmnt2) * loc.signLedger * loc.signTran>
			<cfset loc.balanceAmount = (loc.netAmount + loc.vatAmount) * loc.signBalance>
			
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
			
<!---			<cfif loc.vatID is 0>
				<cfset ArrayAppend(loc.itemArray, {"NomID" = 21, "Amount" = loc.vatAmount, "TranID" = loc.trans.trnID})>
			</cfif>
			
			<cfif loc.balID is 0>
				<cfset ArrayAppend(loc.itemArray, {"NomID" = loc.trans.accNomAcct, "Amount" = loc.balanceAmount, "TranID" = loc.trans.trnID})>
			</cfif>
--->		</cfloop>
		
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
				<!--- TODO CRASHES with SQL too big to execute --->
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

	<cffunction name="RebuildNomTotals" access="public" returntype="struct" hint="new version 06/12/2014">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset var clearTotals = "">
		<cfset var newTotals = "">
		<cfset loc.datasource=GetDatasource()>
		<cfif StructKeyExists(args.form,"srchNom")>
			<cfset loc.srchNomCount = ListLen(args.form.srchNom,",")>
		<cfelse>
			<cfset loc.srchNomCount = 0>
		</cfif>

		<cftry>		
			<cfquery name="clearTotals" datasource="#loc.datasource#">
				DELETE FROM tblNomTotal
				<cfif loc.srchNomCount gt 0>WHERE ntNomID IN (#args.form.srchNom#)</cfif>
			</cfquery>
			<cfquery name="loc.nominals" datasource="#loc.datasource#">
				SELECT nomID, nomTitle
				FROM tblNominal
				<cfif loc.srchNomCount gt 0>WHERE nomID IN (#args.form.srchNom#)</cfif>
			</cfquery>
		
			<table border="1" width="600" class="tableList">

			<cfoutput>
				<cfloop query="loc.nominals">

				<cfquery name="loc.nomItems" datasource="#loc.datasource#" result="loc.nomItems_result">
						SELECT nomTitle,niNomID, DATE_FORMAT(trnDate,"%y%m") AS TranDate, SUM(niAmount) AS MonthTotal
						FROM tblNomItems, tblTrans, tblNominal
						WHERE niNomID=#val(loc.nominals.nomID)#
						AND niTranID=trnID
						AND niNomID=nomID
						GROUP BY TranDate
					</cfquery>

					<cfif loc.nomItems.recordcount gt 0>
						<cfloop query="loc.nomItems">
							<cfif loc.nomItems.MonthTotal neq 0>
								<cfquery name="newTotals" datasource="#loc.datasource#" result="loc.newTotals_result">
									INSERT INTO tblNomTotal (
										ntNomID,
										ntPrd,
										ntBal
									) VALUES (
										#val(loc.nomItems.niNomID)#,
										#val(loc.nomItems.TranDate)#,
										#val(loc.nomItems.MonthTotal)#
									)
								</cfquery>
							</cfif>
						</cfloop>
					</cfif>
					<tr>
						<td>#loc.nominals.nomID#</td>
						<td>#loc.nominals.nomTitle#</td>
						<td>#loc.nomItems.TranDate#</td>
						<cfif loc.nomItems.MonthTotal gt 0>
							<td align="right">#loc.nomItems.MonthTotal#</td>
							<td></td>
						<cfelse>
							<td></td>
							<td align="right">#loc.nomItems.MonthTotal#</td>
						</cfif>
					</tr>
				</cfloop>
			</cfoutput>
			</table>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc>
	</cffunction>
	
	<cffunction name="TriggerNominalTotalWipe" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfif args.form.TriggerKeyword eq "start">
			<cfset loc.result = RebuildNomTotals(args)>
		</cfif>
		<cfreturn loc>
	</cffunction>
	
	<cffunction name="LoadNominalTransBetweenDates" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cfreturn loc.result>
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
		<cfset loc.args = arguments>
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
		
		<cftry>
		<cfquery name="loc.getTranDate" datasource="#args.database#">
			SELECT trnDate
			FROM tblTrans
			WHERE trnID = #val(args.tranID)#
		</cfquery>
		
		<cfquery name="loc.getNomItems" datasource="#args.database#" result="loc.getNomItemsResult">
			SELECT niNomID
			FROM tblNomItems
			WHERE niTranID = #val(args.tranID)#
			AND niNomID != #val(args.accNomAcct)#
		</cfquery>
		
		<cfquery name="loc.delete" datasource="#args.database#">
			DELETE FROM tblTrans
			WHERE trnID = #val(args.tranID)#
		</cfquery>
		
		<cfloop query="loc.getNomItems">
			<cfset UpdateNomTotals(loc.getTranDate.trnDate, loc.getNomItems.niNomID)>
		</cfloop>
		
		<cfset UpdateNomTotals(loc.getTranDate.trnDate, val(args.accNomAcct))>
		
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="no">
		</cfcatch>
		</cftry>
		
	</cffunction>
	
	<cffunction name="SaveNominalTransaction" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
<cfdump var="#args#" label="SaveNominalTransaction" expand="yes" format="html" 
	output="#application.site.dir_logs#dump-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		<cftry>
			<cfset loc.result = {}>
			<cfset loc.args = arguments>
			<cfset loc.isNew = true>
			<cfset loc.newTranDate = LSDateFormat(args.form.header.tranDate, "yyyy-mm-dd")>
			
			<cfquery name="loc.tranExists" datasource="#args.datasource#" result="loc.tranExists_result">
				SELECT trnID, trnPayAcc, trnDate
				FROM tblTrans
				WHERE trnID = #val(args.form.header.tranID)#
			</cfquery>
			
			<cfset loc.isNew = loc.tranExists.recordcount is 0>

			<cfif loc.isNew>
				<cfquery name="loc.newTrans" datasource="#args.datasource#" result="loc.newTrans_result">
					INSERT INTO tblTrans (
						trnAccountID,
						trnRef,
						trnDesc,
						trnDate,
						trnAmnt1,
						trnAmnt2,
						trnType,
						trnLedger
					) VALUES (
						3,
						'#args.form.header.tranRef#',
						'#args.form.header.tranDesc#',
						'#LSDateFormat(args.form.header.tranDate, "yyyy-mm-dd")#',
						#val(args.form.header.netAmount)#,
						#val(args.form.header.tranVAT)#,
						'nom',
						'nom'
					)
				</cfquery>
				
				<cfset loc.result.tranID = loc.newTrans_result.generatedKey>
			<cfelse>
				<cfquery name="loc.originalTran" datasource="#args.datasource#" result="loc.originalTran_result">
					SELECT *
					FROM tblTrans
					WHERE trnID = #val(args.form.header.tranID)#
				</cfquery>
				
				<cfset loc.result.tranID = val(args.form.header.tranID)>
				<cfset loc.oldTranDate = LSDateFormat(loc.originalTran.trnDate, "yyyy-mm-dd")>
				
				<cfquery name="loc.originalItems" datasource="#args.datasource#">
					SELECT *
					FROM tblNomItems
					WHERE niTranID = #val(args.form.header.tranID)#
				</cfquery>
				
				<cfquery name="loc.updateTrans" datasource="#args.datasource#" result="loc.updateTrans_result">
					UPDATE tblTrans
					SET trnAccountID = 3,
						trnRef = '#args.form.header.tranRef#',
						trnDesc = '#args.form.header.tranDesc#',
						trnDate = '#LSDateFormat(args.form.header.tranDate, "yyyy-mm-dd")#',
						trnAmnt1 = #val(args.form.header.netAmount)#,
						trnAmnt2 = #val(args.form.header.tranVAT)#,
						trnPaidIn = #val(args.form.header.tranPaidIn)#,
						<!---trnType = '#args.form.header.tranType#',--->
						trnMethod = '#args.form.header.tranMethod#',
						trnLedger = 'nom'
					WHERE trnID = #val(args.form.header.tranID)#
				</cfquery>
				
				<cfquery name="loc.delItemsAll" datasource="#args.datasource#">
					DELETE FROM tblNomItems
					WHERE niTranID = #val(args.form.header.tranID)#
				</cfquery>
				
				<cfif loc.originalItems.recordcount gt 0>
					<cfloop query="loc.originalItems">
						<cfset UpdateNomTotals(loc.oldTranDate, val(niNomID))>
					</cfloop>
				</cfif>
			</cfif>
			
			<cfset loc.newItemStr = "">
			<cfloop array="#args.form.items#" index="loc.i">
				<cfif val(loc.i.debit) gt 0>
					<cfset loc.i.amount = abs(val(loc.i.debit))>
				<cfelse>
					<cfset loc.i.amount = abs(val(loc.i.credit)) * -1>
				</cfif>
				
				<cfif loc.i.amount neq 0>
					<cfif len(loc.newItemStr)><cfset loc.newItemStr = loc.newItemStr & ","></cfif>
					<cfset loc.newItemStr = loc.newItemStr & "(#val(loc.i.account)#,#val(loc.result.tranID)#,#val(loc.i.amount)#)">
				</cfif>
			</cfloop>
			
			<cfquery name="loc.newItem" datasource="#args.datasource#" result="loc.newItem_result">
				INSERT INTO tblNomItems (
					niNomID,
					niTranID,
					niAmount
				) VALUES #loc.newItemStr#
			</cfquery>
			
			<cfloop array="#args.form.items#" index="loc.i">
				<cfset UpdateNomTotals(loc.newTranDate, val(loc.i.account))>
			</cfloop>

			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
			</cfcatch>
		</cftry>
		
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="SaveAccountTransRecord" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>

		<cftry>
			<cfset loc.result = {}>
			<cfset loc.result.isNew = true>
			<cfset loc.args = arguments>
			<cfset loc.typeList = "inv,rfd,dbt">
			<cfset loc.newTranDate = LSDateFormat(args.header.trnDate, "yyyy-mm-dd")>
		
			<!---Set flag if tran exists in database--->
			<cfquery name="loc.tranExists" datasource="#args.database#" result="loc.tranExists_result">
				SELECT trnID, trnPayAcc, trnDate
				FROM tblTrans
				WHERE trnID = #val(args.header.trnID)#
			</cfquery>
			<cfset loc.result.isNew = loc.tranExists.recordcount eq 0>
			
			<!---Set signs for both new and old transaction headers and items--->
			<cfif Len(args.header.trnType)>
				<!---Set type if popup was disabled--->
				<cfset loc.type = args.header.trnType>
			<cfelse>
				<!---Use type selected by user--->
				<cfset loc.type = args.header.tranType>
			</cfif>
			
			<!---set sign--->
			<cfset loc.typeInt = ListFind(loc.typeList, loc.type, ",")>
			<cfset loc.signTranType = (2 * int(loc.typeInt gt 0)) - 1>
			<cfset loc.signLedger = (2 * int(args.header.accType eq "purch")) - 1>
			<cfset loc.signTran = loc.signLedger * loc.signTranType>
			<cfset loc.signBalance = -loc.signTran>	<!--- not needed?--->
			
			<cfset loc.netAmount = val(args.header.trnAmnt1) * loc.signTranType>
			<cfset loc.vatAmount = val(args.header.trnAmnt2) * loc.signTranType>
			<cfset loc.balanceAmount = -(loc.netAmount + loc.vatAmount)>	<!--- inverts --->
			
			<!--- set analysis values --->
			<cfloop array="#args.items#" index="loc.item">
				<cfset loc.item.netAmount = loc.item.netAmount * loc.signTran>
			</cfloop>
			
			<!--- add balancing values --->
			
			<!---Balance--->
			<cfset ArrayAppend(args.items, {
				"nomID" = val(args.header.accNomAcct),
				"netAmount" = loc.balanceAmount*loc.signLedger,
				"vatAmount" = 0,
				"vatRate" = 0
			})>
			
			<cfif args.header.tranType eq "pay" OR args.header.tranType eq "rfd">
				<cfif args.header.paymentAccounts neq "null">
					<!---Payment Account--->
					<cfset ArrayAppend(args.items, {
						"nomID" = val(args.header.paymentAccounts),
						"netAmount" = loc.netAmount*loc.signLedger,
						"vatAmount" = 0,
						"vatRate" = 0
					})>
				</cfif>
				
				<!---Settlement--->
				<cfset ArrayAppend(args.items, {
					"nomID" = GetSettlementAccount(args.header.accType),
					"netAmount" = loc.vatAmount,
					"vatAmount" = 0,
					"vatRate" = 0
				})>
			<cfelseif args.header.tranType eq "jnl" OR args.header.tranType eq "dbt">
				<!---Suspense--->
				<cfset ArrayAppend(args.items, {
					"nomID" = GetSuspenseAccount(),
					"netAmount" = loc.netAmount,
					"vatAmount" = 0,
					"vatRate" = 0
				})>
			<cfelse>
				<!--- VAT Account --->
				<cfset ArrayAppend(args.items, {
					"nomID" = GetNominalVATRecordID(),
					"netAmount" = loc.vatAmount,
					"vatAmount" = 0,
					"vatRate" = 0
				})>
			</cfif>

			<cfif loc.result.isNew>	<!--- add transaction --->
				<cfquery name="loc.newTrans" datasource="#args.database#" result="loc.newTrans_result">
					INSERT INTO tblTrans (
						trnLedger,
						trnAccountID,
						trnClientID,
						trnClientRef,
						trnRef,
						trnDesc,
						trnMethod,
						trnDate,
						trnAmnt1,
						trnAmnt2,
						trnAlloc,
						trnAllocID,
						trnType,
						trnPayAcc
					) VALUES (
						'#args.header.accType#',
						#val(args.header.accID)#,
						#val(args.header.trnClientID)#,
						#val(args.header.trnClientRef)#,
						'#args.header.trnRef#',
						'#args.header.trnDesc#',
						'#args.header.trnMethod#',
						'#loc.newTranDate#',
						#val(loc.netAmount)#,
						#val(loc.vatAmount)#,
						#int(args.header.allocate)#,
						#int(args.header.allocID)#,
						'#args.header.tranType#',
						#val(args.header.paymentAccounts)#
					)
				</cfquery>
				<cfset loc.result.tranID = loc.newTrans_result.generatedKey>
				
			<cfelse>	<!--- Update transaction --->
				<cfquery name="loc.originalTran" datasource="#args.database#" result="loc.originalTran_result">
					SELECT *
					FROM tblTrans
					WHERE trnID = #val(args.header.trnID)#
				</cfquery>
				
				<cfset loc.result.tranID = val(args.header.trnID)>
				<cfset loc.oldTranDate = LSDateFormat(loc.originalTran.trnDate, "yyyy-mm-dd")>
				
				<cfquery name="loc.originalItems" datasource="#args.database#" result="loc.originalItems_result">
					SELECT *
					FROM tblNomItems
					WHERE niTranID = #val(args.header.trnID)#
				</cfquery>
				<cfif (StructKeyExists(args.header,"trnAlloc") AND args.header.trnAlloc) OR args.header.allocate>
					<cfset loc.allocate=1>
				<cfelse><cfset loc.allocate=0></cfif>
				
				<cfquery name="loc.updateTrans" datasource="#args.database#" result="loc.updateTrans_result">
					UPDATE tblTrans
					SET trnLedger = '#args.header.accType#',
						trnAccountID = #val(args.header.accID)#,
						trnClientRef = 0,	<!--- FIX --->
						trnRef = '#args.header.trnRef#',
						trnDesc = '#args.header.trnDesc#',
						trnMethod = '#args.header.trnMethod#',
						trnDate = '#loc.newTranDate#',
						trnAmnt1 = #val(loc.netAmount)#,
						trnAmnt2 = #val(loc.vatAmount)#,
						trnType = '#args.header.tranType#',
						trnPayAcc = #val(args.header.paymentAccounts)#,
						<cfif loc.allocate IS 0>trnAllocID = 0,</cfif>
						trnAlloc = #loc.allocate#
					WHERE trnID = #val(args.header.trnID)#
				</cfquery>
				
				<!--- Delete original nominal items --->
				<cfquery name="loc.delItemsAll" datasource="#args.database#" result="loc.delItemsAll_result">
					DELETE FROM tblNomItems
					WHERE niTranID = #val(args.header.trnID)#
				</cfquery>
				
				<cfif loc.originalItems.recordcount gt 0>
					<!--- update totals for old items using original date --->
					<cfloop query="loc.originalItems">
						<cfset UpdateNomTotals(loc.oldTranDate, val(niNomID))>
					</cfloop>
				</cfif>
			</cfif>
		<cfdump var="#args.items#" label="args.items" expand="yes" format="html" 
	output="#application.site.dir_logs#dump-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">	
			<cfset loc.newItemStr = "">
			<cfloop array="#args.items#" index="loc.item">
				<cfif loc.item.netAmount neq 0>
					<cfif len(loc.newItemStr)><cfset loc.newItemStr = loc.newItemStr & ","></cfif>
					<cfset loc.newItemStr = loc.newItemStr & "(#val(loc.item.nomID)#,#val(loc.result.tranID)#,#val(loc.item.netAmount)#,#val(loc.item.vatAmount)#,#val(loc.item.vatRate)#,0)">
				</cfif>
			</cfloop>
			
			<!--- Insert new items --->
			<cfquery name="loc.newItem" datasource="#args.database#" result="loc.newItem_result">
				INSERT INTO tblNomItems (
					niNomID,
					niTranID,
					niAmount,
					niVATAmount,
					niVATRate,
					niActive
				) VALUES #loc.newItemStr#
			</cfquery>
			
			<!--- update totals for new items --->
			<cfloop array="#args.items#" index="loc.item">
				<cfset UpdateNomTotals(loc.newTranDate, val(loc.item.nomID))>
			</cfloop>

			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
			</cfcatch>
		</cftry>
		<!---<cfdump var="#loc#" label="SaveAccountTransRecord" expand="yes" format="html" 
			output="#application.site.dir_logs#dump-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">--->
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
			<cfset result.account=KQueryToStruct(loc.QAccount)>
		<cfelseif val(args.form.accountID)>
			<cfquery name="loc.QAccount" datasource="#args.datasource#">
				SELECT *,
					(SELECT nomCode FROM tblNominal WHERE nomID = accPayAcc) AS PayAccNomCode,
					(SELECT nomCode FROM tblNominal WHERE nomID = accNomAcct) AS BalAccCode
				FROM tblAccount
				WHERE accID=#args.form.accountID#
			</cfquery>
			<cfset result.account=KQueryToStruct(loc.QAccount)>
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
			<cfif StructKeyExists(args, "nomType") AND len(args.nomType)>
				WHERE accType='#args.nomType#'
			<cfelse>
				WHERE 1
			</cfif>
			ORDER BY accType,accName
		</cfquery>
		<cfset result.accounts=QueryToArrayOfStruct(QAccounts)>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadFundList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		
		<cftry>
			<cfquery name="loc.QFundAccts" datasource="#args.datasource#">
				SELECT nomID,nomTitle
				FROM tblNominal
				WHERE nomGroup IN ('R3','R4')
				AND nomStatus=1
				ORDER BY nomTitle
			</cfquery>
			<cfset loc.result.FundAccts=loc.QFundAccts>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
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
	
	<cffunction name="FillNominalGroupItems" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.groups" datasource="#args.datasource#">
			SELECT *
			FROM tblNomGroups
		</cfquery>
		
		<cfloop query="loc.groups">
			<cfquery name="loc.items" datasource="#args.datasource#">
				SELECT nomID
				FROM tblNominal
				WHERE nomGroup = '#ngCode#'
			</cfquery>
			<cfloop query="loc.items">
				<cfquery name="loc.newItem" datasource="#args.datasource#">
					INSERT INTO tblNomGroupItems (
						ngiParent,
						ngiChild,
						ngiOrder
					) VALUES (
						#val(loc.groups.ngID)#,
						#val(loc.items.nomID)#,
						1
					)
				</cfquery>
			</cfloop>
		</cfloop>
	</cffunction>
	
	<cffunction name="SaveNominalGroupItemsOrder" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.group" datasource="#args.datasource#">
			SELECT ngID
			FROM tblNomGroups
			WHERE ngCode = '#args.form.group#'
		</cfquery>
		
		<cfloop array="#args.items#" index="item">
			<cfquery name="loc.nom" datasource="#args.datasource#">
				SELECT nomID
				FROM tblNominal
				WHERE nomCode = '#item.code#'
			</cfquery>
			<cfquery name="loc.updateIndex" datasource="#args.datasource#">
				UPDATE tblNomGroupItems
				SET ngiOrder = #val(item.index)#
				WHERE ngiParent = #val(loc.group.ngID)#
				AND ngiChild = #val(loc.nom.nomID)#
			</cfquery>
		</cfloop>
	</cffunction>
	
	<cffunction name="FillNominalGroups" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.groups" datasource="#args.datasource#">
			SELECT nomGroup
			FROM tblNominal
			WHERE nomGroup != "null"
		</cfquery>
		
		<cfquery name="loc.clear" datasource="#args.datasource#">
			DELETE FROM tblNomGroups
		</cfquery>
		
		<cfloop query="loc.groups">
			<cfquery name="loc.check" datasource="#args.datasource#">
				SELECT ngID
				FROM tblNomGroups
				WHERE ngCode = '#nomGroup#'
			</cfquery>
			
			<cfif loc.check.recordcount is 0>
				<cfquery name="loc.newGroup" datasource="#args.datasource#">
					INSERT INTO tblNomGroups (ngCode) VALUES ('#nomGroup#')
				</cfquery>
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="LoadAllNominalGroups" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.groups" datasource="#args.datasource#">
			SELECT *
			FROM tblNomGroups
			ORDER BY ngCode ASC
		</cfquery>
		
		<cfreturn QueryToArrayOfStruct(loc.groups)>
	</cffunction>
	
	<cffunction name="SaveNominalRecord" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.updateOriginal" datasource="#args.datasource#">
			UPDATE tblNominal
			SET nomTitle = '#args.form.title#',
				nomCode = '#UCase(args.form.code)#',
				nomGroup = '#UCase(args.form.group)#',
				nomType = '#args.form.type#',
				nomClass = '#args.form.class#',
				nomVATCode = #val(args.form.vat)#
			WHERE nomID = #val(args.form.id)#
		</cfquery>
		
		<cfquery name="loc.getGroupID" datasource="#args.datasource#">
			SELECT ngID
			FROM tblNomGroups
			WHERE ngCode = '#UCase(args.form.group)#'
		</cfquery>
		
		<cfquery name="loc.updateItem" datasource="#args.datasource#">
			UPDATE tblNomGroupItems
			SET ngiParent = #val(loc.getGroupID.ngID)#
			WHERE ngiChild = #val(args.form.id)#
		</cfquery>
		
	</cffunction>
	
	<cffunction name="LoadNominalGroupsWithItems" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		
		<cfquery name="loc.groups" datasource="#args.datasource#">
			SELECT *
			FROM tblNomGroups
			ORDER BY ngCode ASC
		</cfquery>
		
		<cfloop query="loc.groups">
			<cfset loc.item = {}>
			<cfset loc.item.group = {}>
			<cfset loc.item.group.id = ngID>
			<cfset loc.item.group.code = ngCode>
			<cfset loc.item.group.title = ngTitle>
			<cfset loc.item.items = []>
			
<!---
				SELECT tblNomGroupItems.*, nomID, nomRef, nomCode, nomTitle, nomType, nomGroup, nomClass, nomVATCode
				FROM tblNomGroupItems, tblNominal
				WHERE ngiParent = #val(loc.item.group.id)#
				AND ngiChild = nomID
				ORDER BY ngiOrder ASC
--->
			<cfquery name="loc.items" datasource="#args.datasource#">
				SELECT tblNomGroupItems.*, nomID, nomRef, nomCode, nomTitle, nomType, nomGroup, nomClass, nomVATCode
				FROM tblNominal
				LEFT JOIN tblNomGroupItems ON ngiChild = nomID
				WHERE ngiParent = #val(loc.item.group.id)#
				ORDER BY ngiOrder ASC
			</cfquery>
			
			<cfif loc.items.recordcount gt 0>
				<cfset loc.item.items = QueryToArrayOfStruct(loc.items)>
			</cfif>
			
			<cfset arrayAppend(loc.result, loc.item)>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadNominalGroupWithItems" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		
		<cfquery name="loc.groups" datasource="#args.datasource#">
			SELECT *
			FROM tblNomGroups
			WHERE ngCode = '#args.grpName#'
			ORDER BY ngCode ASC
		</cfquery>
		
		<cfloop query="loc.groups">
			<cfset loc.item = {}>
			<cfset loc.item.group = {}>
			<cfset loc.item.group.id = ngID>
			<cfset loc.item.group.code = ngCode>
			<cfset loc.item.group.title = ngTitle>
			<cfset loc.item.items = []>
			
			<cfquery name="loc.items" datasource="#args.datasource#">
				SELECT tblNomGroupItems.*, nomID, nomRef, nomCode, nomTitle, nomType, nomGroup, nomClass, nomVATCode
				FROM tblNomGroupItems, tblNominal
				WHERE ngiParent = #val(loc.item.group.id)#
				AND ngiChild = nomID
				ORDER BY ngiOrder ASC
			</cfquery>
			
			<cfif loc.items.recordcount gt 0>
				<cfset loc.item.items = QueryToArrayOfStruct(loc.items)>
			</cfif>
			
			<cfset arrayAppend(loc.result, loc.item)>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadSpecificNominalGroupWithItems" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		
		<cfquery name="loc.groups" datasource="#args.datasource#">
			SELECT *
			FROM tblNomGroups
			WHERE ngCode = '#args.grpName#'
			ORDER BY ngCode ASC
		</cfquery>
		
		<cfloop query="loc.groups">
			<cfset loc.item = {}>
			<cfset loc.item.group = {}>
			<cfset loc.item.group.id = ngID>
			<cfset loc.item.group.code = ngCode>
			<cfset loc.item.group.title = ngTitle>
			<cfset loc.item.items = []>
			
			<cfquery name="loc.items" datasource="#args.datasource#">
				SELECT tblNomGroupItems.*, nomID, nomRef, nomCode, nomTitle, nomType, nomGroup, nomClass, nomVATCode
				FROM tblNomGroupItems, tblNominal
				WHERE ngiParent = #val(loc.item.group.id)#
				AND ngiChild = nomID
				ORDER BY ngiOrder ASC
			</cfquery>
			
			<cfif loc.items.recordcount gt 0>
				<cfset loc.item.items = QueryToArrayOfStruct(loc.items)>
			</cfif>
			
			<cfset arrayAppend(loc.result, loc.item)>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadNominalCodesAsArray" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>

		<cfquery name="loc.noms" datasource="#args.datasource#">
			SELECT *,
				(SELECT vatRate FROM tblVATRates WHERE vatCode = nomVATCode) AS VATRate
			FROM tblNominal
			WHERE true
			<cfif StructKeyExists(args, "nomType") AND Len(args.nomType)>
				AND nomType = '#args.nomType#'
			</cfif>
			<cfif StructKeyExists(args, "nomGroup")>
				AND nomGroup IN (#args.nomGroup#)
			</cfif>
			<cfif StructKeyExists(args, "tillbtns") AND args.tillbtns>
				AND nomTillBtn=1
			</cfif>
			ORDER BY nomGroup, nomCode ASC
		</cfquery>
		
		<cfreturn QueryToArrayOfStruct(loc.noms)>
	</cffunction>

	<cffunction name="LoadNominalAccounts2" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.result.QNomList" datasource="#args.datasource#">
				SELECT nomID,nomCode,nomTitle,nomGroup, ngTitle
				FROM tblNominal
				LEFT JOIN tblnomgroups ON ngCode = nomGroup
				WHERE nomStatus = 1
				ORDER BY nomGroup, nomTitle
				LIMIT 10;		<!--- test only --->
			</cfquery>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadNominalCodes" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.rec={}>
		<cfset loc.result.codes = {}>
		<cfset loc.result.NomArray = []>
		<cftry>
			<cfquery name="loc.result.QNominal" datasource="#args.datasource#">
				SELECT *,
					(SELECT vatRate FROM tblVATRates WHERE vatCode = nomVATCode) AS VATRate
				FROM tblNominal
				WHERE true
				<cfif StructKeyExists(args,"nomType") AND Len(args.nomType)>AND nomType='#args.nomType#'</cfif>
				<cfif StructKeyExists(args,"nomGroup")>AND nomGroup IN (#args.nomGroup#)</cfif>
				<cfif StructKeyExists(args,"tillButtons")>AND nomTillBtn=#args.tillButtons#</cfif>
				ORDER BY nomGroup, nomCode ASC
			</cfquery>
			
			<cfloop query="loc.result.QNominal">
				<cfset loc.rec={}>
				<cfset loc.rec.nomID=nomID>
				<cfset loc.rec.nomCode=nomCode>
				<cfset loc.rec.nomTitle=nomTitle>
				<cfset loc.rec.nomGroup=nomGroup>
				<cfset loc.rec.nomVATCode=nomVATCode>
				<cfset loc.rec.nomVATRate=VATRate>
				<cfset StructInsert(loc.result.codes,nomCode,loc.rec)>
                <cfset ArrayAppend(loc.result.NomArray,loc.rec)>
			</cfloop>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadNominalCodesX" access="public" returntype="struct">
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
			<cfif StructKeyExists(args,"tillButtons")>AND nomTillBtn=#args.tillButtons#</cfif>
			ORDER BY nomGroup, nomCode ASC
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
		<cfset loc.thisMonth=CreateDate(Year(Now()),Month(Now()),1)>

		<cfquery name="loc.trans" datasource="#args.datasource#" result="loc.result.QTransResult">
			SELECT *
			FROM tblTrans
			WHERE trnAccountID = #val(args.account.accID)#
			AND trnClientRef = 0
			<cfswitch expression="#args.form.srchRange#">
				<cfcase value="0">
					<!--- all records --->
				</cfcase>
				<cfcase value="1">
					AND trnDate >= '#LSDateFormat(DateAdd("d",-7,Now()),"yyyy-mm-dd")#'
				</cfcase>
				<cfcase value="2">
					AND trnDate >= '#LSDateFormat(loc.thisMonth,"yyyy-mm-dd")#'
				</cfcase>
				<cfcase value="3">
					AND trnDate >= '#LSDateFormat(DateAdd("m",-1,loc.thisMonth),"yyyy-mm-dd")#'
				</cfcase>
				<cfcase value="4">
					AND trnDate >= '#LSDateFormat(DateAdd("m",-2,loc.thisMonth),"yyyy-mm-dd")#'
				</cfcase>
				<cfcase value="5">
					AND trnDate >= '#LSDateFormat(DateAdd("m",-3,loc.thisMonth),"yyyy-mm-dd")#'
				</cfcase>
				<cfcase value="6">
					AND trnDate >= '#LSDateFormat(DateAdd("m",-6,loc.thisMonth),"yyyy-mm-dd")#'
				</cfcase>
				<cfcase value="12">
					AND trnDate >= '#LSDateFormat(DateAdd("m",-12,loc.thisMonth),"yyyy-mm-dd")#'
				</cfcase>
				<cfdefaultcase>
					<cfif len(args.form.srchRange)>
						<cfif Left(args.form.srchRange,2) eq 'FY'>
							<cfset loc.fyDate=StructFind(application.site.FYDates,args.form.srchRange)>
							AND trnDate >= '#loc.fyDate.start#'
							AND trnDate <= '#loc.fyDate.end#'
						<cfelseif Left(args.form.srchRange,4) eq 'YEAR'>
							<cfset loc.thisYear = ListRest(args.form.srchRange,"-")>
							<cfset loc.fromYear = CreateDate(loc.thisYear,1,1)>
							<cfset loc.toYear = CreateDate(loc.thisYear,12,31)>
							AND trnDate >= '#LSDateFormat(loc.fromYear,"yyyy-mm-dd")#' 
							AND trnDate <= '#LSDateFormat(loc.toYear,"yyyy-mm-dd")#'
						<cfelse>
							AND trnDate >= '#args.form.srchRange#-01'
							AND trnDate <= '#args.form.srchRange#-31'
						</cfif>
					</cfif>
				</cfdefaultcase>
			</cfswitch>
			<cfif NOT StructKeyExists(args.form, "srchAllocated")>
				AND trnAlloc = 0
			</cfif>
			<cfif StructKeyExists(args.form, "srchType")>
				<cfswitch expression="#args.form.srchType#">
					<cfcase value="inv">
						AND trnType='inv'
					</cfcase>
					<cfcase value="crn">
						AND trnType='crn'
					</cfcase>
					<cfcase value="ic">
						AND trnType IN ('inv','crn')
					</cfcase>
					<cfcase value="pay">
						AND trnType='pay'
					</cfcase>
					<cfcase value="rfd">
						AND trnType='rfd'
					</cfcase>
					<cfcase value="jnl">
						AND trnType='jnl'
					</cfcase>
					<cfcase value="pj">
						AND trnType IN ('pay','jnl','rfd')
					</cfcase>
				</cfswitch>
			</cfif>
			ORDER BY trnDate ASC, trnID ASC
		</cfquery>
		<cfif loc.trans.recordcount GT 0>
			<cfset loc.startdate=DateFormat(loc.trans.trnDate[1],"yyyy-mm-dd")>
		<cfelse><cfset loc.startDate=DateFormat(loc.thisMonth,"yyyy-mm-dd")></cfif>
		<cfset loc.filter="AND trnDate < #loc.startdate#">
		<cfset loc.result.args=args>
		<cfset loc.result.trans=loc.trans>
		<cfquery name="loc.broughtforward" datasource="#args.datasource#" result="loc.result.bfwdResult">
			SELECT SUM(trnAmnt1+trnAmnt2) AS bfwdTotal
			FROM tblTrans
			WHERE trnAccountID = #val(args.account.accID)#
			AND trnDate < '#loc.startdate#'
			<cfif NOT StructKeyExists(args.form, "srchAllocated")>
				AND trnAlloc = 0
			</cfif>
			GROUP BY trnAccountID
		</cfquery>
		<cfif args.form.srchType eq "">
			<cfset loc.result.bfwd=val(loc.broughtforward.bfwdTotal)>
		<cfelse>
			<cfset loc.result.bfwd=0>
		</cfif>
		<cfquery name="loc.allocCheck" datasource="#args.datasource#">
			SELECT sum(trnAmnt1 + trnAmnt2) AS total
			FROM tblTrans
			WHERE trnAccountID = #val(args.account.accID)#
			AND trnAlloc = 1
		</cfquery>
		<cfif loc.allocCheck.total neq 0>
			<cfset loc.result.allocError=loc.allocCheck.total>
		</cfif>
		<cfquery name="loc.sorted" dbtype="query">
			SELECT *
			FROM loc.trans
			<cfswitch expression="#args.form.sortOrder#">
				<cfcase value="date">
					ORDER BY trnDate ASC, trnID ASC
				</cfcase>
				<cfcase value="id">
					ORDER BY trnID ASC
				</cfcase>
				<cfcase value="ref">
					ORDER BY trnRef ASC
				</cfcase>
			</cfswitch>
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
				AND niNomID NOT IN (11,21,201)	<!--- skip balancing accounts --->
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
				<cfset item.nomCode=nomCode>
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
			<cfset amount1="-#REReplace(args.form.trnAmnt1,"£","","all")#">
			<cfset amount2="-#REReplace(args.form.trnAmnt2,"£","","all")#">
		<cfelse>
			<cfset amount1=REReplace(args.form.trnAmnt1,"£","","all")>
			<cfset amount2=REReplace(args.form.trnAmnt2,"£","","all")>
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
			<cfset amount1="-#REReplace(args.form.trnAmnt1,"£","","all")#">
			<cfset amount2="-#REReplace(args.form.trnAmnt2,"£","","all")#">
		<cfelse>
			<cfset amount1=REReplace(args.form.trnAmnt1,"£","","all")>
			<cfset amount2=REReplace(args.form.trnAmnt2,"£","","all")>
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
		<cfif IsDate(args.toDate)>
			<cfset loc.toDate = args.toDate>
		<cfelse>
			<cfset loc.toDate = DateAdd("d",1,args.fromDate)>
		</cfif>
		<cfset result.supplier=KQueryToStruct(QAccount)>
		<cfquery name="QTrans" datasource="#args.datasource#">
			SELECT tblTrans.*, COUNT(niID) AS nomRecs, SUM( niAmount) AS Total
			FROM tblTrans 
			LEFT JOIN tblNomItems ON niTranID=trnID
			WHERE trnLedger='#args.nomType#'
			AND trnAccountID=#args.accountID#
			AND trnDate >= '#DateFormat(args.fromDate,"yyyy-mm-dd")#'
			AND trnDate <= '#DateFormat(loc.toDate,"yyyy-mm-dd")#'
			GROUP BY trnID
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

	<cffunction name="SalesItemTotal" access="public" returntype="numeric">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = 0>
		<cfif IsDate(args.fromDate)>
			<cfset loc.toDate = DateAdd("d",1,args.fromDate)>
		</cfif>
		<cfquery name="loc.QTrans" datasource="#args.datasource#">
			SELECT SUM( eiNet + eiVAT ) AS total
			FROM `tblepos_items`
			WHERE eiTimestamp
			BETWEEN '#DateFormat(args.fromDate,"yyyy-mm-dd")#'
			AND '#DateFormat(loc.toDate,"yyyy-mm-dd")#'
		</cfquery>
		<cfif loc.QTrans.recordcount gt 0>
			<cfset loc.result = val(loc.QTrans.total)>
		</cfif>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="SalesMissing" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		<cfif IsDate(args.toDate)>
			<cfset loc.toDate = args.toDate>
		<cfelse>
			<cfset loc.toDate = DateFormat(now(),'yyyy-mm-dd')>
		</cfif>
		<cfloop from="#args.fromDate#" to="#loc.toDate#" index="thisDate">
			<cfquery name="loc.QTrans" datasource="#args.datasource#">
				SELECT trnID FROM tbltrans 
				WHERE trnLedger = '#args.nomType#'
				AND trnAccountID = #args.accountID#
				AND trnDate = '#DateFormat(thisDate,"yyyy-mm-dd")#'
			</cfquery>
			<cfif loc.QTrans.recordCount IS 0>
				<cfset ArrayAppend(loc.result,DateFormat(thisDate,"ddd dd-mmm-yy"))>
			</cfif>
		</cfloop>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="SalesDuplicates" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfif IsDate(args.toDate)>
			<cfset loc.toDate = args.toDate>
		<cfelse>
			<cfset loc.toDate = DateFormat(now(),'yyyy-mm-dd')>
		</cfif>

		<cfquery name="loc.QTrans" datasource="#args.datasource#">
			SELECT trnID,trnDate,trnAmnt1,trnAmnt2, COUNT(niID) AS Items
			FROM tbltrans mto
			LEFT JOIN tblNomItems ON niTranID=trnID
			WHERE trnLedger = '#args.nomType#'
			AND trnAccountID = #args.accountID#
			AND trnDate >= '#args.fromDate#'
			AND trnDate <= '#loc.toDate#'
			AND EXISTS (
					SELECT 1
					FROM tbltrans mti
					WHERE trnLedger = '#args.nomType#'
					AND trnAccountID = #args.accountID#
					AND mti.trnDate = mto.trnDate
					LIMIT 1, 1
				)
			GROUP BY trnID
		</cfquery>
		<cfset loc.result.trans = QueryToArrayOfStruct(loc.QTrans)>
		<cfset loc.result.dupes = []>
		<cfloop query="loc.QTrans">
			<cfset ArrayAppend(loc.result.dupes,{
				trnID = trnID,
				trnDate = trnDate,
				trnAmnt1 = trnAmnt1,
				trnAmnt2 = trnAmnt2,
				Items = Items
			})>			
		</cfloop>
		<cfreturn loc.result>
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
		
		<cftry>
			<cfquery name="QTrans" datasource="#args.datasource#" result="QResult">
				SELECT accCode, accName, trnID, trnLedger, trnRef, trnDate, trnAmnt1, trnAmnt2, nomCode, nomTitle, niID, niAmount, abs(niAmount) AS absAmount
				FROM tblNomItems, tblNominal, tblTrans, tblAccount
				<cfif StructKeyExists(args,"url")>WHERE nomCode='#args.url.code#'
					<cfelseif StructKeyExists(args.form,"srchNom") AND len(args.form.srchNom)>WHERE nomID='#args.form.srchNom#'
					<cfelse>WHERE nomType='sales'</cfif>
				<cfif len(args.form.srchDateFrom)>
					AND trnDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateFrom#"> 
					AND <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateTo#">
					<cfif StructKeyExists(args.form,"srchSunday")>AND DayOfWeek(trnDate) <> 1</cfif>
				</cfif>
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
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
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
		<cfset result.trnTotalNum=val(Replace(args.form.trnTotal,",","","all"))>
		<cfif drTotal eq crTotal AND crTotal eq result.trnTotalNum>
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
		<cfset var loc = {}>
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
			<cfif args.form.trnMethod eq "chqx">		<!--- bounced cheque --->
				<cfset loc.amnt1 = val(args.form.trnAmnt1)>
				<cfset loc.amnt2 = val(args.form.trnAmnt2)>
			<cfelse>
				<cfset loc.amnt1 = -val(args.form.trnAmnt1)>
				<cfset loc.amnt2 = -val(args.form.trnAmnt2)>
			</cfif>
			<cfset result.preticked=ListLen(result.tickList,",")>
			<cfif StructKeyExists(args.form,"btnClicked") AND args.form.btnClicked eq "btnSavePayment">
				<cfquery name="QTrans" datasource="#args.datasource#" result="loc.QResult">
					INSERT INTO tblTrans (
						trnAccountID,
						trnClientRef,
						trnRef,
						trnDesc,
						trnDate,
						trnMethod,
						trnType,
						trnAlloc,
						trnAmnt1,
						trnAmnt2
					) VALUES (
						4,
						#val(args.form.clientRef)#,
						'#args.form.trnRef#',
						'#args.form.trnDesc#',
						'#LSDateFormat(args.form.trnDate,"yyyy-mm-dd")#',
						<cfif args.form.trnType eq 'pay'>'#args.form.trnMethod#'<cfelse>''</cfif>,
						'#args.form.trnType#',
						#int(result.preticked gt 0)#,
						#loc.amnt1#,
						#loc.amnt2#
					)
				</cfquery>
				
				<cfset loc.addItem = AddClientPayNomItems(loc.qresult.generatedkey,args.form.trnAmnt1,1)>
				<cfset result.tickList=ListAppend(result.tickList,loc.qresult.generatedkey,",")>
			</cfif>
			<cfquery name="QTrans" datasource="#args.datasource#">
				SELECT tblTrans.*, cltChase
				FROM tblTrans
				INNER JOIN tblClients ON trnClientRef=cltRef
				WHERE trnClientRef=#val(args.form.clientRef)#
				<cfif NOT StructKeyExists(args.form,"allTrans")>AND trnAlloc=0</cfif>
				<cfif len(args.form.srchDateFrom)>AND trnDate >= #args.form.srchDateFrom#</cfif>
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
			<cfif QTrans.cltChase gt 0>
				<cfquery name="loc.QClearChase" datasource="#args.datasource#">
					UPDATE tblClients
					SET cltChase=0
					WHERE cltRef=#args.form.clientRef#
					LIMIT 1;
				</cfquery>				
			</cfif>
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
	
<!---	<cffunction name="SavePayments" access="public" returntype="struct">
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
--->
	<cffunction name="SaveCreditPayment" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		
		<cftry>
			<cfquery name="QTrans" datasource="#args.datasource#">
				INSERT INTO tblTrans (
					trnAccountID,
					trnClientID,
					trnClientRef,
					trnRef,
					trnDate,
					trnMethod,
					trnDesc,
					trnType,
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
