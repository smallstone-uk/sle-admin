<cfcomponent displayname="EPOS" hint="EPOS Till Functions">
	
	<cffunction name="ZTill" access="public" returntype="void" hint="initialise till at start of day.">
		<cfargument name="loadDate" type="date" required="yes">
		<cfset StructDelete(session,"till",false)>
		<cfset session.till = {}>
		<cfset session.till.header = {}>
		<cfset session.till.total = {}>
		<cfset session.till.trans = []>
		<cfset session.till.total.float = -200>
		<cfset session.till.total.cashINDW = 200>
		<cfset session.till.prefs.mincard = 3.00>
		<cfset session.till.prefs.service = 0.50>
		<cfset session.till.prefs.discount = 0.10>
		<cfset session.till.prefs.reportDate = LSDateFormat(loadDate,"yyyy-mm-dd")>
		<cfif StructKeyExists(application,"siteclient")>
			<cfset session.till.prefs.vatno = application.siteclient.cltvatno>
		<cfelse>
			<cfset session.till.prefs.vatno = "152 5803 21">
		</cfif>
		<cfset ClearBasket()>
	</cffunction>

	<cffunction name="ClearBasket" access="public" returntype="void" hint="clear current transaction without affecting till totals.">
		<cfset StructDelete(session,"basket",false)>
		<cfset session.basket = {}>
		<cfset session.basket.mode = "reg">
		<cfset session.basket.type = "SALE">
		<cfset session.basket.bod = "Customer">
		<cfset session.basket.errMsg = "">
        <cfset session.basket.prodKeys = {}>
		<cfset session.basket.products = []>
		<cfset session.basket.suppliers = []>
		<cfset session.basket.payments = []>
		<cfset session.basket.prizes = []>
		<cfset session.basket.vouchers = []>
		<cfset session.basket.paypoint = []>
		<cfset session.basket.news = []>
		<cfset session.basket.items = 0>
		<cfset session.basket.received = 0>
		<cfset session.basket.service = 0>
		<cfset session.basket.staff = false>
		<cfset session.basket.vatAnalysis = {}>
				
		<cfset session.basket.header = {}>
		<cfset session.basket.header.retailcash = 0>
		<cfset session.basket.header.retailcredit = 0>
<!---
		<cfset session.basket.header.vat = 0>
		<cfset session.basket.header.cashback = 0>
		<cfset session.basket.header.change = 0>
		<cfset session.basket.header.cashtaken = 0>
		<cfset session.basket.header.cardsales = 0>
		<cfset session.basket.header.chqsales = 0>
		<cfset session.basket.header.accsales = 0>
		<cfset session.basket.header.balance = 0>
		<cfset session.basket.header.supplies = 0>
		<cfset session.basket.header.prize = 0>
		<cfset session.basket.header.voucher = 0>
		<cfset session.basket.header.paypoint = 0>
--->		
		<cfset session.basket.total = {}>
		<cfset session.basket.total.cashINDW = 0>
		<cfset session.basket.total.cardINDW = 0>
		<cfset session.basket.total.chqINDW = 0>
		<cfset session.basket.total.accINDW = 0>
		<cfset session.basket.total.sales = 0>
		<cfset session.basket.total.supplies = 0>
		<cfset session.basket.total.prize = 0>
		<cfset session.basket.total.voucher = 0>
		<cfset session.basket.total.paypoint = 0>
		<cfset session.basket.total.news = 0>
		<cfset session.basket.total.vat = 0>
		<cfset session.basket.total.discount = 0>
		<cfset session.basket.total.staff = 0>
	</cffunction>
	
	<cffunction name="LoadTillTotals" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<h1>Loading till</h1>
			<cfset ZTill(args.form.reportDate)>
			<cfquery name="loc.QTotals" datasource="#GetDataSource()#" result="loc.QQueryResult">
				SELECT *
				FROM tblEPOS_Totals
				WHERE totDate='#session.till.prefs.reportDate#'
			</cfquery>
			<cfloop query="loc.QTotals">
				<cfset StructInsert(session.till.total,totAcc,totValue,true)>
			</cfloop>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#\epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="GetAccounts" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.result.Accounts" datasource="#GetDataSource()#">
				SELECT accID,accName 
				FROM tblAccount
				WHERE accGroup =20
				AND accType =  'sales';
			</cfquery>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#\epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="GetDates" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.recs =[]>
		<cfset loc.today = false>
		<cftry>
			<cfquery name="loc.QDates" datasource="#GetDataSource()#">
				SELECT DATE(ehTimeStamp) AS dateOnly
				FROM tblEPOS_Header
				WHERE 1
				GROUP BY dateOnly
				ORDER BY dateOnly DESC
			</cfquery>
			<cfloop query="loc.QDates">
				<cfset loc.today = loc.today OR (LSDateFormat(dateOnly,"yyyy-mm-dd") eq LSDateFormat(Now(),"yyyy-mm-dd"))>
				<cfset ArrayAppend(loc.result.recs,{"value"=LSDateFormat(dateOnly,"yyyy-mm-dd"),"title"=LSDateFormat(dateOnly,"dd-mmm-yyyy")})>
			</cfloop>
			<cfif NOT loc.today>
				<cfset ArrayPrepend(loc.result.recs,{"value"=LSDateFormat(Now(),"yyyy-mm-dd"),"title"=LSDateFormat(Now(),"dd-mmm-yyyy")})>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#\epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="LoadProducts" access="public" returntype="query">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QProducts" datasource="#GetDataSource()#" result="loc.QProductsResult">
				(SELECT prodID,prodRef,prodTitle,prodOurPrice,prodVATRate,prodCashOnly
				FROM tblProducts
				WHERE prodLastBought > '2015-09-01'
				LIMIT 15)
				UNION
				(SELECT prodID,prodRef,prodTitle,prodOurPrice,prodVATRate,prodCashOnly
				FROM tblProducts
				WHERE prodLastBought > '2015-09-01'
				AND prodVatRate <> 0
				LIMIT 15)
				UNION
				(SELECT prodID,prodRef,prodTitle,prodOurPrice,prodVATRate,prodCashOnly
				FROM tblProducts
				WHERE prodLastBought > '2015-09-01'
				AND prodVatRate = 5
				LIMIT 5)
				UNION
				(SELECT prodID,prodRef,prodTitle,prodOurPrice,prodVATRate,prodCashOnly
				FROM tblProducts
				WHERE prodSuppID != 21
				LIMIT 20)				
			</cfquery>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#\epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.QProducts>
	</cffunction>
	
	<cffunction name="LoadDeals" access="public" returntype="void" hint="Load deal info.">
		<cfargument name="args" type="struct" required="yes">
		<cfset loc = {}>
		<cfquery name="loc.QActiveDeals" datasource="#GetDataSource()#">
			SELECT *
			FROM tblEPOS_Deals
			WHERE edStatus = 'active'
			AND edEnds > #Now()#
		</cfquery>
		<cfset session.deals = loc.QActiveDeals>
		<cfset session.dealdata = {}>
		<cfloop query="loc.QActiveDeals">
			<cfset StructInsert(session.dealdata,edID,{
				"edType" = #edType#,
				"edDealType" = #edDealType#,
				"edTitle" = #edTitle#,
				"edQty" = #edQty#,
				"edAmount" = #edAmount#,
				"edStarts" = #LSDateFormat(edStarts,'yyyy-mm-dd')#,
				"edEnds" = #LSDateFormat(edEnds,'yyyy-mm-dd')#
			})>
		</cfloop>
		<cfquery name="loc.QualifyingProducts" datasource="#GetDataSource()#">
			SELECT ediProduct,ediParent
			FROM tblEPOS_DealItems
			INNER JOIN tblEPOS_Deals ON ediParent = edID
			WHERE edStatus = 'active'
			AND edStarts <= #Now()#		<!--- TODO check time issues --->
			AND edEnds > #Now()#
		</cfquery>
		<cfset session.dealIDs = {}>
		<cfloop query="loc.QualifyingProducts">
			<cfif StructKeyExists(session.dealIDs,ediProduct)>
				<cfset loc.item = StructFind(session.dealIDs,ediProduct)>
				<cfset loc.item="#loc.item#,#ediParent#">
				<cfset StructUpdate(session.dealIDs,ediProduct,loc.item)>
			<cfelse>
				<cfset StructInsert(session.dealIDs,ediProduct,ediParent)>
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="CheckDeals" access="public" returntype="void" hint="check basket for qualifying deals.">
		<cfset var loc = {}>
		<cfloop collection="#session.basket.prodKeys#" item="loc.key">
			<cfset loc.item = StructFind(session.basket.prodKeys,loc.key)>
			<cfif loc.item.dealID gt 0>
				<cfset loc.deal = StructFind(session.dealdata,loc.item.dealID)>
				<cfif loc.item.qty gte loc.deal.edQty>
					<cfset loc.item.dealQty = loc.deal.edQty>
					<cfset loc.item.edAmount = loc.deal.edAmount>
					<cfswitch expression="#loc.deal.edDealType#">
						<cfcase value="nodeal">
						</cfcase>
						<cfcase value="bogof">
							<cfset loc.item.dealQty = int(loc.item.qty / 2)>
							<cfset loc.item.dealTotal = loc.item.dealQty * loc.item.unitPrice>
							<cfset loc.item.dealTitle = loc.deal.edTitle>
						</cfcase>
						<cfcase value="twofor">
							<cfset loc.item.dealQty = int(loc.item.qty / 2)>
							<cfset loc.item.remQty = loc.item.qty mod 2>
							<cfset loc.dealTotal = loc.item.dealQty * loc.deal.edAmount + (loc.item.remQty * loc.item.unitPrice)>
							<cfset loc.item.dealTotal = -(loc.item.totalGross + loc.dealTotal)>
							<cfset loc.item.dealTitle = "#loc.deal.edTitle# &pound;#loc.deal.edAmount#">
						</cfcase>
						<cfcase value="anyfor">
						</cfcase>
						<cfcase value="mealdeal">
						</cfcase>
						<cfcase value="halfprice">
						</cfcase>
					</cfswitch>
				<cfelse>
					<cfset loc.item.dealQty = 0>
					<cfset loc.item.dealTotal = 0>
					<cfset loc.item.dealTitle = ''>
					<cfset loc.item.dealDisc = 0>					
				</cfif>
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="CalculateTotals" access="public" returntype="struct">
		<cfset var loc = {}>
		
		<cfset session.basket.header = {}>
		<cfloop collection="#session.basket.prodKeys#" item="loc.key">
			<cfset loc.item = StructFind(session.basket.prodKeys,loc.key)>
			<cfset session.basket.header.retailCash += loc.item.retailCash>
			<cfset session.basket.header.retailCredit += loc.item.retailCredit>
			<cfset session.basket.header.retailTotal += loc.item.retailTotal>
		</cfloop>
	</cffunction>
	
	<cffunction name="UpdateProduct" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.insertItem = false>
		<cfset loc.discount = 0>
		<cfset loc.regMode = (2 * int(session.basket.mode eq "reg")) - 1>	<!--- modes: reg = 1 refund = -1 --->
		<cfset loc.tranType = -1>	<!--- probably all sales now --->

		<cfif Left(args.form.type,5) eq "prod-">
			<cfset args.form.prodID = val(mid(args.form.type,6,10))>
			<cfset args.form.type = "SALE">
		<cfelse>
			<cfset args.form.prodID = 1>
		</cfif>
		
		<!--- sanitise input fields --->
		<cfset args.form.discount = 0>
		<cfset args.form.qty = val(args.form.qty)>
		<cfset args.form.cash = abs(val(args.form.cash))>
		<cfset args.form.credit = abs(val(args.form.credit))>
		<cfset args.form.vrate = val(args.form.vrate)>
		<cfset loc.vatRate = 1 + (args.form.vrate / 100)>
		<cfset session.basket.errMsg = "">

		<cfif StructKeyExists(session.basket.prodKeys,args.form.prodID)>
			<cfset loc.rec = StructFind(session.basket.prodKeys,args.form.prodID)>
		<cfelse>
			<cfset loc.rec = {}>
			<cfset loc.rec.prodID = args.form.prodID>
			<cfset loc.rec.prodTitle = args.form.prodTitle>
			<cfset loc.rec.unitPrice = args.form.cash + args.form.credit>
			<cfset loc.rec.vrate = args.form.vrate>
			<cfset loc.rec.qty = 0>
			<cfset loc.rec.dealID = 0>
			<cfset loc.rec.dealTotal = 0>
			<cfset loc.rec.staffDisc = 0>
			<cfset StructInsert(session.basket.prodKeys,args.form.prodID,loc.rec)>
		</cfif>
								
		<cfif StructKeyExists(session.dealIDs,args.form.prodID)>
			<cfset loc.rec.dealID = StructFind(session.dealIDs,args.form.prodID)>
		</cfif>
		
		<cfset loc.rec.qty += args.form.qty> <!--- accumulate qty with any previous value. can be +/- --->
		<cfif loc.rec.qty lte 0> <!--- qty dropped to zero - delete item --->
			<cfset StructDelete(session.basket.prodKeys,args.form.prodID)>
		<cfelse>
			<cfset loc.rec.retailCash = args.form.cash * loc.rec.qty>
			<cfset loc.rec.retailCredit = args.form.credit * loc.rec.qty>
			<cfset loc.rec.retailTotal = (loc.rec.retailCash + loc.rec.retailCredit)>

			<!--- if staff sale and is a discountable and not on a deal --->
			<cfif session.basket.staff AND StructKeyExists(args.form,"discountable") AND loc.rec.dealID IS 0>
				<cfset loc.rec.staffDisc = round(loc.rec.retailTotal * session.till.prefs.discount)>	<!--- item discount in pence --->
			<cfelse>
				<cfset CheckDeals()>
			</cfif>
			<cfset loc.gross = (loc.rec.retailTotal - loc.rec.staffDisc - loc.rec.dealTotal) * 100>
			<cfset loc.rec.totalNet = round(loc.gross / loc.vatRate) / 100>
			<cfset loc.rec.gross = loc.gross / 100>
			<cfset loc.rec.totalVat = (loc.rec.gross - loc.rec.totalNet)> <!--- calc total vat amount --->
			
		<!---	<cfset CalculateTotals()>--->
			
			<!---<cfset session.basket.header.retailcash += loc.retailCash>
			<cfset session.basket.header.retailCredit += loc.retailCredit>--->
			
			<!--- convert back to pound & pence
			<cfset loc.rec.retailCash = loc.pRetailCash / 100>
			<cfset loc.rec.retailCredit = loc.pRetailCredit / 100>
			<cfset loc.rec.retailTotal = loc.pRetailTotal / 100> --->
			
<!---
			<cfset loc.rec.totalGross = loc.gross>	<!--- item pence value less any discount --->
			<!--- <cfset loc.rec.totalGross = (loc.gross - loc.discount)>	item pence value less any discount --->
	
			<cfset loc.rec.cash = loc.cash / 100>
			<cfset loc.rec.credit = loc.credit / 100>
			<cfset loc.rec.totalDisc = (loc.discount / 100)>	<!--- total discount given --->
			<cfset loc.rec.totalNet = round(loc.rec.totalGross / loc.vatRate) / 100> <!--- calc net value of item in pounds & pence --->
			<cfset loc.rec.totalGross = round(loc.rec.totalGross) / 100>	<!--- convert value to money --->
			<cfset loc.rec.totalVat = (loc.rec.totalGross - loc.rec.totalNet)> <!--- calc total vat amount --->
			
			<cfset loc.rec.cash = loc.rec.cash * loc.tranType * loc.regMode>
			<cfset loc.rec.credit = loc.rec.credit * loc.tranType * loc.regMode>
			<cfset loc.rec.totalNet = loc.rec.totalNet * loc.tranType * loc.regMode>
			<cfset loc.rec.totalGross = loc.rec.totalGross * loc.tranType * loc.regMode>
			<cfset loc.rec.totalVat = loc.rec.totalVat * loc.tranType * loc.regMode>
			<cfset loc.rec.totalDisc = loc.rec.totalDisc * loc.tranType * loc.regMode>
	
			<cfset StructUpdate(session.basket.prodKeys,args.form.prodID,loc.rec)>

			<cfif args.form.type eq "SRV"><cfset session.basket.service = args.form.credit></cfif>
			<cfset session.basket.total.retailcash += 
--->			<!--- remember if service charge added
			<cfset session.basket.total.sales += loc.rec.totalNet> <!--- accumulate net sales total --->
			<cfset session.basket.total.discount += loc.rec.totalDisc> <!--- accumulate discount granted --->
			<cfset session.basket.total.staff -= loc.rec.totalDisc> <!--- balance accounts --->
			<cfset session.basket.header.acctcash += loc.rec.cash> <!--- store cash sale amount --->
			<cfset session.basket.header.acctcredit += loc.rec.credit> <!--- store credit a/c amount --->
			<cfset session.basket.header.vat += loc.rec.totalVat> <!--- accumulate VAT amounts --->
			<cfset session.basket.header.balance -= loc.rec.totalGross> <!--- accumulate customer balance --->
 --->
		</cfif>
		<cfdump var="#session.basket#" label="basket" expand="yes">
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>