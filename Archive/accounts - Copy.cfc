<cfcomponent displayname="accounts" extends="core">
	<cffunction name="SaveAccountTransRecord" access="public" returntype="string">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = "">
		
		<!---<cfquery name="loc.save" datasource="#args.database#">
			SQL CONTENT NEEDED
			
		</cfquery>--->
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadAccount" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset var result={}>
		
		<cfif len(args.form.tranRef)>
			<cfquery name="loc.QAccount" datasource="#args.datasource#">
				SELECT tblAccount.*
				FROM tblAccount,tblTrans
				WHERE trnAccountID=accID
				AND (trnID=#val(args.form.tranRef)# OR trnRef='#args.form.tranRef#')
			</cfquery>
			<cfset result.account=QueryToStruct(loc.QAccount)>
		<cfelseif val(args.form.accountID)>
			<cfquery name="loc.QAccount" datasource="#args.datasource#">
				SELECT *
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
			<cfif len(args.nomType)>WHERE accType='#args.nomType#'
				<cfelse>WHERE 1</cfif>
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
			SELECT *
			FROM tblNominal
			WHERE true
			<cfif StructKeyExists(args,"nomType")>AND nomType='#args.nomType#'</cfif>
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
			<cfset StructInsert(result,nomCode,rec)>
		</cfloop>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadTransactionList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">

		<cfquery name="QTrans" datasource="#args.datasource#">
			SELECT *
			FROM tblTrans
			WHERE trnAccountID=#val(args.account.accID)#
			AND trnClientRef=0
			<cfswitch expression="#args.form.sortOrder#">
				<cfcase value="date">
					ORDER BY trnDate ASC
				</cfcase>
				<cfcase value="id">
					ORDER BY trnID DESC
				</cfcase>
				<cfcase value="ref">
					ORDER BY trnRef ASC
				</cfcase>
			</cfswitch>
			<cfif val(args.form.rowLimit)>
				LIMIT 0,#val(args.form.rowLimit)#;</cfif>
		</cfquery>
		<cfset result.tranList=QueryToArrayOfStruct(QTrans)>
		<cfset result.rowCount=QTrans.recordcount>
		<cfreturn result>
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
		<cfset var result={}>
		<cfset var item={}>
		<cfset var result.items=ArrayNew(1)>
		<cfset var QTran="">
		<cfset var QNomItems="">
		<cfset var vatRate=0>
		
		<cftry>
			<cfset result.error=0>
			<cfquery name="QTran" datasource="#args.datasource#">
				SELECT *
				FROM tblTrans,tblAccount
				WHERE trnID=#val(args.tranID)#
				<cfif StructKeyExists(args.form,"accID")>AND trnAccountID=#val(args.form.accID)#<cfelse>AND trnAccountID=accID</cfif>
				<cfif StructKeyExists(args.form,"type")>AND trnType='#args.form.type#'</cfif>
				LIMIT 1;
			</cfquery>
			<cfset result.tran=QueryToArrayOfStruct(QTran)>
	<!---
			<cfset result.NetAmount=REReplace(QTran.trnAmnt1,"-","","all")>
			<cfset result.VatAmount=REReplace(QTran.trnAmnt2,"-","","all")>
	--->
			<cfset result.NetAmount=abs(val(QTran.trnAmnt1))>
			<cfset result.VatAmount=abs(val(QTran.trnAmnt2))>
			<cfif QTran.recordcount is 0>
				<cfset result.error=1>
				<cfset result.msg="Transaction not found">
			</cfif>
			<cfquery name="QNomItems" datasource="#args.datasource#">
				SELECT *
				FROM tblNomItems,tblNominal
				WHERE niTranID=#val(args.tranID)#
				AND niNomID=nomID
				ORDER BY niID asc
			</cfquery>
			<cfset tranTotal=0>
			<cfset vatTotal=0>
			<cfloop query="QNomItems">
				<cfset item={}>
				<cfset item.niID=niID>
				<cfset item.niNomID=niNomID>
				<cfset item.nomTitle=nomTitle>
				<cfset item.nomVATRate=StructFind(application.site.vat,nomVATCode)*100>
				<cfset item.niTranID=niTranID>
	<!---
				<cfif StructKeyExists(args.form,"type") AND args.form.type eq "crn">
					<cfset item.niAmount=REReplace(niAmount,"-","","all")>
				<cfelse>
					<cfset item.niAmount=niAmount>
				</cfif>
	--->
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
			<cfset result.GrandTotal=tranTotal>
			<cfset result.GrandVatTotal=vatTotal>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="UpdateNewsItem" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.html">
			<cfset result.error=2>
		</cfcatch>
		</cftry>
		<cfreturn result>
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
