<cfcomponent displayname="purchase reports" extends="accounts">

	<cfset this.nomAccounts={}>
	<cfset this.nomBalanceAccounts={}>
	
	<cffunction name="LoadSuppliers" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QSuppliers="">
		<cfset var rec={}>
		
		<cfset result.list=[]>
		<cfquery name="QSuppliers" datasource="#args.datasource#">
			SELECT accID,accCode,accName
			FROM tblAccount
			WHERE accType IN ('purch','sales')
			ORDER BY accCode
		</cfquery>
		<cfloop query="QSuppliers">
			<cfset rec={}>
			<cfset rec.accID=accID>
			<cfset rec.accCode=accCode>
			<cfset rec.accName=accName>
			<cfset ArrayAppend(result.list,rec)>
		</cfloop>
		<cfreturn result>
	</cffunction>

	<cffunction name="PurchReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.result.suppliers=[]>
		<cfset loc.result.QTransResult="">
		<cfset loc.skipZeros=StructKeyExists(args.form,"srchIgnoreZero")>
		<cfset loc.gross=StructKeyExists(args.form,"srchGrossFigures")>
		
		<cfquery name="loc.QSuppliers" datasource="#args.datasource#">
			SELECT accID,accCode,accGroup,accPayType,accIndex,accName,accType
			FROM tblAccount
			WHERE true
			<cfif len(StructFind(args.form,"srchName"))>AND accName LIKE "%#args.form.srchName#%"</cfif>
			<cfif len(StructFind(args.form,"srchLedger"))>AND accType="#args.form.srchLedger#"</cfif>
			<cfif len(StructFind(args.form,"srchGroup"))>AND accGroup=#val(args.form.srchGroup)#</cfif>
			<cfif len(StructFind(args.form,"srchPayType"))>AND accPayType=#val(args.form.srchPayType)#</cfif>
			ORDER BY accName
		</cfquery>
		<cfif loc.QSuppliers.recordcount GT 0>
			<cfloop query="loc.QSuppliers">
				<cfset loc.item={}>
				<cfset loc.item.ID=accID>
				<cfset loc.item.ref=accCode>
				<cfset loc.item.name=accName>
				<cfset loc.item.type=accType>
				<cfset loc.item.balance0=0>
				<cfset loc.item.balance1=0>
				<cfset loc.item.balance2=0>
				<cfset loc.item.balance3=0>
				<cfset loc.item.balance4=0>
				<cfset loc.item.balance5=0>
				<cfset loc.item.balance6=0>
				<cfset loc.item.balance7=0>
				<cfset loc.item.balance8=0>
				<cfset loc.item.balance9=0>
				<cfset loc.item.balance10=0>
				<cfset loc.item.balance11=0>
				<cfset loc.item.balance12=0>
				<cfquery name="loc.QTrans" datasource="#args.datasource#" result="loc.result.QTransResult">
					SELECT trnAccountID,trnDate,trnType,TRUNCATE(trnAmnt1,2) AS amount1,TRUNCATE(trnAmnt2,2) AS amount2
					FROM tblTrans
					WHERE trnAccountID=#val(loc.item.ID)#
					<cfif len(args.form.srchDateFrom)>
						AND trnDate>='#args.form.srchDateFrom#'
						AND trnDate<='#args.form.srchDateTo#'
					</cfif>
					<cfif len(StructFind(args.form,"srchType"))>
						<cfif args.form.srchType eq 'debits'>AND trnType IN ('inv','crn')
						<cfelseif args.form.srchType eq 'credits'>AND trnType IN ('pay','jnl')</cfif>
					</cfif>
					<cfif StructKeyExists(args.form,"srchAllocated")>AND trnAlloc=0</cfif>
					ORDER BY trnDate
				</cfquery>
				<cfset loc.result.QTrans=loc.QTrans>
				<cfset loc.item.balance0=0>
				<cfloop query="loc.QTrans">
					<cfif loc.gross><cfset loc.amount=precisionEvaluate(amount1+amount2)>
						<cfelse><cfset loc.amount=precisionEvaluate(amount1)></cfif>
					<cfset loc.item.balance0=precisionEvaluate(loc.item.balance0+loc.amount)>
					<cfswitch expression="#Month(trnDate)#">
						<cfcase value="1"><cfset loc.item.balance1=precisionEvaluate(loc.item.balance1+loc.amount)></cfcase>
						<cfcase value="2"><cfset loc.item.balance2=precisionEvaluate(loc.item.balance2+loc.amount)></cfcase>
						<cfcase value="3"><cfset loc.item.balance3=precisionEvaluate(loc.item.balance3+loc.amount)></cfcase>
						<cfcase value="4"><cfset loc.item.balance4=precisionEvaluate(loc.item.balance4+loc.amount)></cfcase>
						<cfcase value="5"><cfset loc.item.balance5=precisionEvaluate(loc.item.balance5+loc.amount)></cfcase>
						<cfcase value="6"><cfset loc.item.balance6=precisionEvaluate(loc.item.balance6+loc.amount)></cfcase>
						<cfcase value="7"><cfset loc.item.balance7=precisionEvaluate(loc.item.balance7+loc.amount)></cfcase>
						<cfcase value="8"><cfset loc.item.balance8=precisionEvaluate(loc.item.balance8+loc.amount)></cfcase>
						<cfcase value="9"><cfset loc.item.balance9=precisionEvaluate(loc.item.balance9+loc.amount)></cfcase>
						<cfcase value="10"><cfset loc.item.balance10=precisionEvaluate(loc.item.balance10+loc.amount)></cfcase>
						<cfcase value="11"><cfset loc.item.balance11=precisionEvaluate(loc.item.balance11+loc.amount)></cfcase>
						<cfcase value="12"><cfset loc.item.balance12=precisionEvaluate(loc.item.balance12+loc.amount)></cfcase>
					</cfswitch>
				</cfloop>
				<cfif loc.item.balance0 neq 0 OR NOT loc.skipZeros>
					<cfset ArrayAppend(loc.result.suppliers,loc.item)>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="VATAnalysis" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var QTransResult="">
		<cfset var rec={}>
		<cfset var monthData={}>
		<cfset var key="">
		<cfset var loNum=12>
		<cfset var hiNum=0>
		
		<cfquery name="QTrans" datasource="#args.datasource#" result="QTransResult">
			SELECT nomCode, nomTitle, nomVATCode, vatRate, niAmount, round(niAmount*vatRate/100,2) AS vatAmnt, Month(trnDate) AS Mnth
			FROM (((tblNominal 
				INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID) 
					INNER JOIN tblVATRates ON tblNominal.nomVATCode = tblVATRates.vatCode) 
						INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID) 
			WHERE trnClientRef=0	<!--- pass option --->
			<cfif val(args.form.srchAccount) gt 0>AND trnAccountID=#args.form.srchAccount#</cfif>
			<cfif len(args.form.srchLedger) gt 0>
				AND trnLedger='#args.form.srchLedger#'
				AND nomType='#args.form.srchLedger#'
			</cfif>
			<cfif len(args.form.srchDept) gt 0>AND nomClass='#args.form.srchDept#'</cfif>
			<cfif len(args.form.srchDateFrom)>
				AND trnDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#' </cfif>
			ORDER BY nomCode, trnDate, trnAccountID
		</cfquery>
		<cfset result.QTransResult=QTransResult>
		<cfset result.titleLedger=args.titleLedger>
		<cfset result.analysis={}>
		<cfset result.VAT={}>
		<cfset result.TotalNet=0>
		<cfset result.TotalVAT=0>
		<cfset result.columnCount=0>
		<cfloop query="QTrans">
			<cfset loNum=Min(loNum,mnth)>
			<cfset hiNum=Max(hiNum,mnth)>
			<cfset key=NumberFormat(mnth,"00")>
			<cfset result.TotalNet=result.TotalNet+niAmount>
			<cfset result.TotalVAT=result.TotalVAT+vatAmnt>
			<cfif NOT StructKeyExists(result.analysis,nomCode)>
				<cfset StructInsert(result.analysis,nomCode,{"Title"=nomTitle,"Rate"=vatRate})>
			</cfif>
			
			<cfif NOT StructKeyExists(result.VAT,vatRate)>
				<cfset StructInsert(result.VAT,vatRate,{"Rate"=vatRate, "Net"=0, "VAT"=0})>
			</cfif>
			<cfset rec=StructFind(result.VAT,vatRate)>
			<cfset rec.Net=rec.Net+niAmount>
			<cfset rec.VAT=rec.VAT+vatAmnt>
			<cfset StructUpdate(result.VAT,vatRate,rec)>
			
			<cfset rec=StructFind(result.analysis,nomCode)>
			<cfif StructKeyExists(rec,"month#key#")>
				<cfset monthData=StructFind(rec,"month#key#")>
				<cfset monthData.count++>
				<cfset monthData.net=monthData.net+niAmount>
				<cfset monthData.vat=monthData.vat+vatAmnt>
				<cfset StructUpdate(rec,"month#key#",monthData)>
				<cfset StructUpdate(result,"net#key#",StructFind(result,"net#key#")+niAmount)>
				<cfset StructUpdate(result,"vat#key#",StructFind(result,"vat#key#")+vatAmnt)>
			<cfelse>
				<cfset monthData={}>
				<cfset monthData.count=1>
				<cfset monthData.net=niAmount>
				<cfset monthData.vat=vatAmnt>
				<cfset StructInsert(rec,"month#key#",monthData)>
				<cfif NOT StructKeyExists(result,"net#key#")>
					<cfset result.columnCount++>
					<cfset StructInsert(result,"net#key#",niAmount)>
					<cfset StructInsert(result,"vat#key#",vatAmnt)>
				<cfelse>
					<cfset StructUpdate(result,"net#key#",StructFind(result,"net#key#")+niAmount)>
					<cfset StructUpdate(result,"vat#key#",StructFind(result,"vat#key#")+vatAmnt)>					
				</cfif>
			</cfif>
		</cfloop>
		<cfloop collection="#result.VAT#" item="key">
			<cfset rec=StructFind(result.VAT,key)>
			<cfset rec.prop=DecimalFormat((rec.Net/result.TotalNet)*100)>
		</cfloop>
		<cfset result.firstMonth=val(loNum)>
		<cfset result.lastMonth=val(hiNum)>
		<cfreturn result>
		<cfdump var="#result#" label="result" expand="no">
	</cffunction>

	<cffunction name="ApportionSales" access="private" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		
		<cfset args.sales.ports={}>
		<cfloop collection="#args.purch.vat#" item="loc.key">
			<cfset loc.rec=StructFind(args.purch.vat,loc.key)>
			<cfset StructInsert(args.sales.ports,loc.key,{"prop"=loc.rec.prop})>
			<cfset loc.rateStruct=StructFind(args.sales.ports,loc.key)>
			<cfloop from="#args.sales.firstMonth#" to="#args.sales.lastMonth#" index="loc.i">
				<cfset loc.mnth=NumberFormat(loc.i,"00")>
				<cfset loc.monthNet=StructFind(args.sales,"net#loc.mnth#")>
				<cfset loc.propGross=loc.monthNet*loc.rec.prop/100>
				<cfset loc.propVAT=loc.propGross-(loc.propGross/(1+(loc.key/100)))>
				<cfset loc.propNet=loc.propGross-loc.propVAT>
				<cfset StructInsert(loc.rateStruct,"net#loc.mnth#",{"gross"=loc.propGross,"vat"=loc.propVAT,"net"=loc.propNet})>
			</cfloop>
		</cfloop>
	</cffunction>

	<cffunction name="vatReturn2" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.parms=args>
		
		
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="vatReturn" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.parms=args>

		<cfset loc.result.shop.title="Shop">
			<cfset loc.parms.form.srchDept="shop">
			<cfset loc.parms.form.srchLedger="purch">
			<cfset loc.parms.titleLedger="Purchases">
		<cfset loc.result.shop.purch=VATAnalysis(loc.parms)>
		<cfset loc.result.shop.colCount=loc.result.shop.purch.columncount>
		
			<cfset loc.parms.form.srchDept="shop">
			<cfset loc.parms.form.srchLedger="sales">
			<cfset loc.parms.titleLedger="Sales">
		<cfset loc.result.shop.sales=VATAnalysis(loc.parms)>
		<cfset ApportionSales(loc.result.shop)>

		<cfset loc.result.news.title="Distribution">
			<cfset loc.parms.form.srchDept="news">
			<cfset loc.parms.form.srchLedger="purch">
			<cfset loc.parms.titleLedger="Purchase">
		<cfset loc.result.news.purch=VATAnalysis(loc.parms)>
		<cfset loc.result.news.colCount=loc.result.news.purch.columncount>
		
			<cfset loc.parms.form.srchDept="news">
			<cfset loc.parms.form.srchLedger="sales">
			<cfset loc.parms.titleLedger="Sales">
		<cfset loc.result.news.sales=VATAnalysis(loc.parms)>
		
<!---		<cfset loc.parms.titleDept="Shop Sales">
		<cfset loc.result.sales.titleLedger="Sales">
		<cfset loc.parms.form.srchLedger="sales">
		<cfset loc.parms.form.srchDept="shop">
		<cfset loc.result.shop.sales=VATAnalysis(loc.parms)>
		<cfset loc.result.sales.colCount=loc.result.shop.sales.columncount>
		
--->		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="TranList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var rec={}>
		
		<cftry>
			<cfquery name="QTrans" datasource="#args.datasource#">
				SELECT accID,accName,accType,accNomAcct,accPayAcc, trnID,trnLedger,trnRef,trnDesc,trnDate,trnAccountID,trnClientRef,trnType,trnMethod,trnAmnt1,trnAmnt2
				FROM tblTrans,tblAccount
				WHERE trnAccountID=accID
				<cfif val(args.form.srchAccount) lt 0>AND trnClientRef=0</cfif>
				<cfif val(args.form.srchAccount) gt 0>
					AND trnAccountID=#args.form.srchAccount#
					AND trnClientRef=0
				</cfif>
				<cfif len(args.form.srchDateFrom)>
					AND trnDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#' </cfif>
				<cfif val(args.form.srchAccount) gt 0>AND trnAccountID=#args.form.srchAccount#</cfif>
				<cfif len(args.form.srchLedger) gt 0>AND trnLedger='#args.form.srchLedger#'</cfif>
				
				<cfif StructKeyExists(args.form, "srchTranType") AND len(args.form.srchTranType)>
					AND trnType IN ('#REReplaceNoCase(args.form.srchTranType, ",", "','", "all")#')
				</cfif>
				
				<cfif args.form.srchSort eq 'trnAccountID'>
					ORDER BY accName ASC, trnDate ASC
				<cfelse>
					ORDER BY #args.form.srchSort#
				</cfif>
			</cfquery>
			<cfset result.tranArray=[]>
			<cfset result.totAmnt1=0>
			<cfset result.totAmnt2=0>
			<cfloop query="QTrans">
				<cfset rec={}>
				<cfset rec.accID=accID>
				<cfset rec.accName=accName>
				<cfset rec.accType=accType>
				<cfset rec.accNomAcct=accNomAcct>
				<cfset rec.accPayAcc=accPayAcc>
				<cfset rec.trnID=trnID>
				<cfset rec.trnClientRef=trnClientRef>
				<cfset rec.trnRef=trnRef>
				<cfset rec.trnDesc=trnDesc>
				<cfset rec.trnDate=trnDate>
				<cfset rec.trnType=trnType>
				<cfset rec.trnMethod=trnMethod>
				<cfset rec.trnAmnt1=trnAmnt1>
				<cfset rec.trnAmnt2=trnAmnt2>
				<cfset rec.trnTotal=trnAmnt1+trnAmnt2>
				<cfset ArrayAppend(result.tranArray,rec)>
				<cfset result.totAmnt1=result.totAmnt1+trnAmnt1>
				<cfset result.totAmnt2=result.totAmnt2+trnAmnt2>
			</cfloop>		
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>

	<cffunction name="TranDetail" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var rec={}>
		<cfset var QItems="">
		<cfset var QResult="">
		
		<cfset result.args=args>
		<cfquery name="QTrans" datasource="#args.datasource#" result="QResult">
			SELECT accID,accName, trnID, trnLedger, trnRef,trnDate, trnAccountID, trnType,trnAmnt1,trnAmnt2
			FROM tblTrans,tblAccount
			WHERE trnAccountID=accID
			
			<cfif val(args.form.srchAccount) gt 0>AND trnAccountID=<cfqueryparam cfsqltype="cf_sql_integer" value="#args.form.srchAccount#"></cfif>
			<cfif len(args.form.srchLedger) gt 0>AND trnLedger=<cfqueryparam cfsqltype="cf_sql_varchar" value="#args.form.srchLedger#"></cfif>
			<cfif len(args.form.srchDateFrom)>
				AND trnDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateFrom#"> 
				AND <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateTo#"></cfif>
			ORDER BY trnAccountID,trnDate,trnID
		</cfquery>
		<cfset result.QTrans=QTrans>
		<cfset result.QResult=QResult>
		<cfset result.tranArray=[]>
		<cfloop query="QTrans">
			<cfset rec={}>
			<cfset rec.accID=accID>
			<cfset rec.accName=accName>
			<cfset rec.trnID=trnID>
			<cfset rec.trnRef=trnRef>
			<cfset rec.trnDate=trnDate>
			<cfset rec.trnType=trnType>
			<cfset rec.trnAmnt1=trnAmnt1>
			<cfset rec.trnAmnt2=trnAmnt2>
			<cfquery name="QItems" datasource="#args.datasource#">
				SELECT nomCode,nomTitle,niID,niAmount
				FROM tblNominal,tblNomItems
				WHERE nomID=niNomID
				AND niTranID=<cfqueryparam cfsqltype="cf_sql_integer" value="#trnID#">
			</cfquery>
			<cfset rec.items=QItems>
			<cfset ArrayAppend(result.tranArray,rec)>
		</cfloop>		
		<cfreturn result>
	</cffunction>

	<cffunction name="NomTrans" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var rec={}>
		<cfset var nomAcc={}>
		<cfset var QTrans_result="">
		<cfquery name="QTrans" datasource="#args.datasource#" result="QTrans_result">
			SELECT nomCode,nomTitle,trnID,trnLedger,trnRef,trnClientRef,trnDate,trnAccountID,trnType,niAmount
			FROM ((tblNominal 
			INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID)
			INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID)
			WHERE 1
			<cfif val(args.form.srchAccount) gt 0>
				AND trnAccountID=#args.form.srchAccount#
				AND trnClientRef=0
			</cfif>
			<cfif len(args.form.srchLedger) gt 0>AND trnLedger='#args.form.srchLedger#'</cfif>
			<cfif len(args.form.srchDept) gt 0>AND nomClass='#args.form.srchDept#'</cfif>
			<cfif val(args.form.srchNom) gt 0>AND nomID=<cfqueryparam cfsqltype="cf_sql_integer" value="#args.form.srchNom#"></cfif>
			<cfif len(args.form.srchDateFrom)>
				AND trnDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateFrom#"> 
				AND <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateTo#"></cfif>
			ORDER BY nomCode,trnDate,trnID
		</cfquery>
		<cfset result.QTrans=QTrans>
		<cfset result.QTrans_result=QTrans_result>
		<cfset result.total=0>
		<cfset result.nomAccount={}>
		<cfloop query="QTrans">
			<cfif NOT StructKeyExists(result.nomAccount,nomCode)>
				<cfset StructInsert(result.nomAccount,nomCode,{"Title"=nomTitle,"Total"=0,"tranArray"=[]})>
			</cfif>
			<cfset nomAcc=StructFind(result.nomAccount,nomCode)>
			<cfset rec={}>
			<cfset rec.nomCode=nomCode>
			<cfset rec.nomTitle=nomTitle>
			<cfset rec.trnID=trnID>
			<cfset rec.trnLedger=trnLedger>
			<cfset rec.trnRef=trnRef>
			<cfset rec.trnClientRef=trnClientRef>
			<cfset rec.trnDate=LSDateFormat(trnDate,"ddd dd-mmm-yyyy")>
			<cfset rec.accID=trnAccountID>
			<cfset rec.trnAccountID=trnAccountID>
			<cfset rec.trnType=trnType>
			<cfset rec.niAmount=niAmount>
			<cfset ArrayAppend(nomAcc.tranArray,rec)>
			<cfset nomAcc.total=nomAcc.total+niAmount>
			<cfset result.total=result.total+niAmount>
		</cfloop>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="NomTranSummary" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var rec={}>
		<cfset var nomAcc={}>
		<cfset result.ledgers="">
		
		<cfquery name="QTrans" datasource="#args.datasource#">
			SELECT nomCode,nomType,nomTitle,trnLedger,SUM(niAmount) AS nomTotal
			FROM ((tblNominal 
			INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID)
			INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID)
			WHERE 1
			<cfif val(args.form.srchAccount) gt 0>AND trnAccountID=#args.form.srchAccount#</cfif>
			<cfif len(args.form.srchLedger) gt 0>AND trnLedger='#args.form.srchLedger#'</cfif>
			<cfif len(args.form.srchDept) gt 0>AND nomClass='#args.form.srchDept#'</cfif>
			<cfif val(args.form.srchNom) gt 0>AND nomID=<cfqueryparam cfsqltype="cf_sql_integer" value="#args.form.srchNom#"></cfif>
			<cfif len(args.form.srchDateFrom)>
				AND trnDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateFrom#"> 
				AND <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateTo#"></cfif>
			GROUP BY trnLedger,nomCode
		</cfquery>

		<cfif len(args.form.srchDateFrom)>
			<cfset result.dateFrom=LSDateFormat(args.form.srchDateFrom,"dd-mmm-yyyy")>
			<cfset result.dateTo=LSDateFormat(args.form.srchDateTo,"dd-mmm-yyyy")>
		</cfif>
		<cfloop query="QTrans">
			<cfset rec={}>
			<cfset rec.nomCode=nomCode>
			<cfset rec.nomTitle=nomTitle>
			<cfset rec.nomTotal=nomTotal>
			<cfif NOT StructKeyExists(result,nomType)>
				<cfset StructInsert(result,nomType,{})>
				<cfset result.ledgers="#result.ledgers#,#nomType#">
			</cfif>
			<cfset nomAcc=StructFind(result,nomType)>
			<cfif StructKeyExists(nomAcc,nomCode)>
				<cfset rec=StructFind(nomAcc,nomCode)>
				<cfset rec.nomTotal=rec.nomTotal+nomTotal>
				<cfset StructUpdate(nomAcc,nomCode,rec)>
			<cfelse>
				<cfset StructInsert(nomAcc,nomCode,rec)>
			</cfif>
		</cfloop>
		<cfset result.QTrans=QTrans>
		<cfset result.total=0>
		<cfreturn result>
	</cffunction>

	<cffunction name="GetNomTable" access="private" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.QNominals" datasource="#args.datasource#" result="loc.QNominals_result">
			SELECT accNomAcct, (SELECT NomCode from tblNominal where nomID=accNomAcct) as nominalCode
			FROM `tblAccount` WHERE accNomAcct>0
			GROUP BY accNomAcct
			UNION
			SELECT accPayAcc, (SELECT NomCode from tblNominal where nomID=accPayAcc) as nominalCode
			FROM `tblAccount` WHERE accPayAcc>0
			GROUP BY accPayAcc
			UNION
			SELECT nomID, NomCode
			FROM tblNominal WHERE nomGroup='R3'
		</cfquery>
		<cfloop query="loc.QNominals">
			<cfset StructInsert(this.nomBalanceAccounts,accNomAcct,nominalCode)>
		</cfloop>
		
		<cfquery name="loc.QNominals" datasource="#args.datasource#" result="loc.QNominals_result">
			SELECT nomID,nomCode
			FROM tblNominal
			ORDER BY nomCode
		</cfquery>
		<cfloop query="loc.QNominals">
			<cfset StructInsert(this.nomAccounts,nomCode,nomID)>
		</cfloop>
	</cffunction>

	<cffunction name="ValidateTransRecord" access="public" returntype="struct">
		<cfargument name="parms" type="struct" required="yes">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result={}>
		<cfset loc.itemsFound=[]>
		<cfset loc.itemsMissing=[]>
		<cfset loc.args=args>
		<cfset loc.typeList = "inv,rfd,dbt">
		<cfset loc.TranNomCodes="">
		<cfset loc.itemTotal=0>
		<cfset loc.tranTotal=0>
		<cfset loc.analysisFound=false>

		<!--- set sign--->
		<cfset loc.typeInt = ListFind(loc.typeList, args.trnType, ",")>
		<cfset loc.signTranType = (2 * int(loc.typeInt gt 0)) - 1>
		<cfset loc.signLedger = (2 * int(args.accType eq "purch")) - 1>
		<cfset loc.signTran = loc.signLedger * loc.signTranType>
		<!--- calculate tran totals --->
		<cfset loc.netAmount = abs(args.trnAmnt1) * loc.signTran>
		<cfset loc.vatAmount = abs(args.trnAmnt2) * loc.signTran>
		<cfset loc.balanceAmount = -(loc.netAmount + loc.vatAmount)>	<!--- inverts --->
		<cfset loc.empties=[]>
		
		<cfif StructCount(this.nomBalanceAccounts) EQ 0>
			<cfset GetNomTable({"datasource"=args.datasource})>
		</cfif>
		<cfquery name="loc.originalItems" datasource="#args.datasource#">
			SELECT CEIL(niAmount*100) AS amount, niAmount,nomCode,nomTitle,nomType, niID
			FROM tblNomItems,tblNominal
			WHERE niNomID=nomID
			AND niTranID=#val(args.trnID)#
		</cfquery>
		<cfloop query="loc.originalItems">
			<cfset loc.itemTotal=loc.itemTotal+amount>
			<cfset loc.tranTotal=loc.tranTotal+niAmount>
			<cfset loc.TranNomCodes="#loc.TranNomCodes#,#nomCode#">
			<cfif nomType neq "nom">
				<cfset loc.analysisFound=true>
				<cfset loc.amnt=abs(amount/100)*loc.signTran>
				<cfset ArrayAppend(loc.itemsFound,{
					"nomCode"=nomCode,
					"nomTitle"=nomTitle,
					"nomType"=nomType,
					"niAmount"=loc.amnt,
					"niID"=niID
				})>
			<cfelse>
				<cfswitch expression="#nomCode#">
					<cfcase value="DEBT|CRED|SHOP" delimiters="|">	<!--- balance amount --->
						<cfset ArrayAppend(loc.itemsFound,{
							"nomCode"=nomCode,
							"nomTitle"=nomTitle,
							"nomType"=nomType,
							"niAmount"=loc.balanceAmount,
							"niID"=niID
						})>
					</cfcase>
					<cfcase value="SDCL|SDAL|VAT" delimiters="|">
						<cfset ArrayAppend(loc.itemsFound,{
							"nomCode"=nomCode,
							"nomTitle"=nomTitle,
							"nomType"=nomType,
							"niAmount"=loc.vatAmount,
							"niID"=niID
						})>					
					</cfcase>
					<cfcase value="SUSP|BANK|CASH|CARD|COLL|CHQ" delimiters="|">
						<cfset ArrayAppend(loc.itemsFound,{
							"nomCode"=nomCode,
							"nomTitle"=nomTitle,
							"nomType"=nomType,
							"niAmount"=loc.netAmount,
							"niID"=niID
						})>
					</cfcase>
					<cfdefaultcase>
						<cfset ArrayAppend(loc.itemsFound,{
							"nomCode"=nomCode,
							"nomTitle"=nomTitle,
							"nomType"=nomType,
							"niAmount"=niAmount,
							"niID"=niID
						})>					
					</cfdefaultcase>
				</cfswitch>
			</cfif>
		</cfloop>
		<cfif loc.itemTotal neq 0 OR loc.originalItems.recordcount IS 0>
			<cfset loc.itemTotal=loc.itemTotal/100>
			<cfset loc.error="item imbalance #loc.itemTotal#">
			<cfset loc.missing="">
			<cfswitch expression="#args.trnType#">
				<cfcase value="inv|crn" delimiters="|">
					<cfif ArrayLen(loc.itemsFound) IS 0 OR NOT loc.analysisFound>	<!--- no transaction analysis found --->
						<cfif args.accType IS "purch">
							<cfset loc.missing=loc.missing&",PURCH">
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"="PURCH",
								"niAmount"=loc.netAmount
							})>
						<cfelseif args.trnClientRef GT 0>
							<cfset loc.missing=loc.missing&",NEWS">
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"="NEWS",
								"niAmount"=loc.netAmount
							})>
						<cfelse>
							<cfset loc.missing=loc.missing&",SALES">
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"="SALES",
								"niAmount"=loc.netAmount
							})>
						</cfif>
					</cfif>
					<cfif StructKeyExists(this.nomBalanceAccounts,args.accNomAcct)>
						<cfset loc.nomCode=StructFind(this.nomBalanceAccounts,args.accNomAcct)>
						<cfif NOT ListFind(loc.TranNomCodes,loc.nomCode,",")>
							<cfset loc.missing=loc.missing&","&loc.nomCode>
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"=loc.nomCode,
								"niAmount"=loc.balanceAmount
							})>
						</cfif>
						<cfif NOT ListFind(loc.TranNomCodes,"VAT",",")>
							<cfset loc.missing=loc.missing&",VAT">
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"="VAT",
								"niAmount"=loc.vatAmount
							})>					
						</cfif>
					</cfif>
				</cfcase>
				<cfcase value="pay|rfd" delimiters="|">
					<cfif StructKeyExists(this.nomBalanceAccounts,args.accNomAcct)>
						<cfset loc.nomCode=StructFind(this.nomBalanceAccounts,args.accNomAcct)>
						<cfif NOT ListFind(loc.TranNomCodes,loc.nomCode,",")>
							<cfset loc.missing=loc.missing&","&loc.nomCode>
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"=loc.nomCode,
								"niAmount"=loc.balanceAmount
							})>
						</cfif>
					<cfelse>
						<cfset loc.method="Balance account unknown for #args.trnMethod#">
					</cfif>
					
					<cfif StructKeyExists(this.nomBalanceAccounts,args.accPayAcc)>
						<cfset loc.nomCode=StructFind(this.nomBalanceAccounts,args.accPayAcc)>
						<cfif NOT ListFind(loc.TranNomCodes,loc.nomCode,",")>
							<cfset loc.missing=loc.missing&","&loc.nomCode>
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"=loc.nomCode,
								"niAmount"=loc.netAmount
							})>
						</cfif>
					<cfelse>
						<cfswitch expression="#args.trnMethod#">
							<cfcase value="coll">
								<cfif NOT ListFind(loc.TranNomCodes,"COLL")>
									<cfset ArrayAppend(loc.itemsMissing,{
										"nomCode"="COLL",
										"niAmount"=loc.netAmount
									})>
								</cfif>							
							</cfcase>
							<cfcase value="cash">
								<cfif NOT ListFind(loc.TranNomCodes,"CASH")>
									<cfset ArrayAppend(loc.itemsMissing,{
										"nomCode"="CASH",
										"niAmount"=loc.netAmount
									})>
								</cfif>					
							</cfcase>
							<cfcase value="card">
								<cfif NOT ListFind(loc.TranNomCodes,"CARD")>
									<cfset ArrayAppend(loc.itemsMissing,{
										"nomCode"="CARD",
										"niAmount"=loc.netAmount
									})>
								</cfif>				
							</cfcase>
							<cfcase value="ib">
								<cfif NOT ListFind(loc.TranNomCodes,"BANK")>
									<cfset ArrayAppend(loc.itemsMissing,{
										"nomCode"="BANK",
										"niAmount"=loc.netAmount
									})>
								</cfif>							
							</cfcase>
							<cfcase value="sv|dv" delimiters="|">
								<cfif NOT ListFind(loc.TranNomCodes,"VCHN")>
									<cfset ArrayAppend(loc.itemsMissing,{
										"nomCode"="VCHN",
										"niAmount"=loc.netAmount
									})>
								</cfif>							
							</cfcase>
							<cfcase value="chq|chqs" delimiters="|">
								<cfif NOT ListFind(loc.TranNomCodes,"CHQ")>
									<cfset ArrayAppend(loc.itemsMissing,{
										"nomCode"="CHQ",
										"niAmount"=loc.netAmount
									})>
								</cfif>							
							</cfcase>
							<cfcase value="qchq|qs|qsib|qlost" delimiters="|">
								<cfif NOT ListFind(loc.TranNomCodes,"QS")>
									<cfset ArrayAppend(loc.itemsMissing,{
										"nomCode"="QS",
										"niAmount"=loc.netAmount
									})>
								</cfif>			
							</cfcase>
							<cfdefaultcase>
								<cfset ArrayAppend(loc.itemsMissing,{
									"nomCode"="ORPH",
									"niAmount"=loc.netAmount
								})>								
							</cfdefaultcase>
						</cfswitch>
					</cfif>
					
					<cfif args.accType IS "purch">
						<cfif NOT ListFind(loc.TranNomCodes,"SDCL",",")>
							<cfset loc.missing=loc.missing&",SDCL">
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"="SDCL",
								"niAmount"=loc.vatAmount
							})>					
						</cfif>
					<cfelse>
						<cfif NOT ListFind(loc.TranNomCodes,"SDAL",",")>
							<cfset loc.missing=loc.missing&",SDAL">
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"="SDAL",
								"niAmount"=loc.vatAmount
							})>					
						</cfif>
					</cfif>
				</cfcase>
				<cfcase value="jnl|dbt" delimiters="|">
					<cfif StructKeyExists(this.nomBalanceAccounts,args.accNomAcct)>
						<cfset loc.nomCode=StructFind(this.nomBalanceAccounts,args.accNomAcct)>
						<cfif NOT ListFind(loc.TranNomCodes,loc.nomCode,",")>
							<cfset loc.missing=loc.missing&","&loc.nomCode>
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"=loc.nomCode,
								"niAmount"=loc.balanceAmount
							})>
						</cfif>
						<cfif NOT ListFind(loc.TranNomCodes,"SUSP",",")>
							<cfset loc.missing=loc.missing&",SUSP">
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"="SUSP",
								"niAmount"=loc.netAmount
							})>
						</cfif>
					</cfif>
				</cfcase>
			</cfswitch>
		</cfif>
		<cfif StructKeyExists(parms.form,"srchFixData")>
			<cfset loc.queries=[]>
			<cfif ArrayLen(loc.itemsFound)>
				<cfloop array="#loc.itemsFound#" index="loc.rec">
					<cfif loc.rec.niAmount neq 0>
						<cfquery name="loc.QUpdateItem" datasource="#args.datasource#" result="loc.QUpdateItemResult">
							UPDATE tblNomItems
							SET niAmount=#loc.rec.niAmount#
							WHERE niID=#val(loc.rec.niID)#
							LIMIT 1;
						</cfquery>
						<cfset ArrayAppend(loc.queries,loc.QUpdateItemResult)>
					<cfelse>
						<cfset ArrayAppend(loc.empties,loc.rec)>						
					</cfif>
				</cfloop>
			</cfif>
			<cfif ArrayLen(loc.itemsMissing)>
				<cfloop array="#loc.itemsMissing#" index="loc.rec">
					<cfquery name="loc.QInsertItem" datasource="#args.datasource#" result="loc.QInsertItemResult">
						INSERT INTO tblNomItems (
							niAmount,
							niNomID,
							niTranID
						) VALUES (
							#loc.rec.niAmount#,
							#StructFind(this.nomAccounts,loc.rec.nomCode)#,
							#args.trnID#
						)
					</cfquery>
					<cfset ArrayAppend(loc.queries,loc.QInsertItemResult)>
				</cfloop>
			</cfif>
		</cfif>
		<!---<cfdump var="#loc#" label="#args.trnID# #args.trnType#" expand="yes">--->
		<cfset loc.result.tran=args>
		<cfset loc.result.itemsFound=loc.itemsFound>
		<cfset loc.result.itemsMissing=loc.itemsMissing>		
		<cfreturn loc.result>
	</cffunction>		

	<cffunction name="NomTotalReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		
		<cftry>
			<cfif len(args.form.srchDateFrom)>
				<cfset loc.prdFrom=LSDateFormat(args.form.srchDateFrom,"YYMM")>
				<cfset loc.prdTo=LSDateFormat(args.form.srchDateTo,"YYMM")>
			</cfif>
			<cfquery name="loc.result.QQuery" datasource="#args.datasource#">
				SELECT nomCode,nomTitle,tblNomTotal.*
				FROM tblNominal,tblNomTotal
				WHERE ntNomID=nomID
				AND ntPrd>=#loc.prdFrom#
				AND ntPrd<=#loc.prdTo#
				ORDER BY nomCode,ntPrd
			</cfquery>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
</cfcomponent>