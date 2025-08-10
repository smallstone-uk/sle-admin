<cfcomponent>

	<cffunction name="VATSummary" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cftry>
			<cfset loc.srchDateTo = DateAdd("d",1,args.form.srchDateTo)>
			<cfset loc.midnight = DateFormat(loc.srchDateTo,'yyyy-mm-dd')>
			<cfquery name="loc.QSaleItems" datasource="#args.datasource#">
				SELECT ehMode, ehPayAcct,
				eiTimestamp,eiType,eiPayType,eiRetail,eiTrade, SUM(eiQty) AS Qty, SUM(eiNet) AS Net, SUM(eiVAT) AS VAT, SUM(eiTrade) AS Trade,
				pgID,pgTitle,pgNomGroup
				FROM tblepos_items
				INNER JOIN tblepos_header ON eiParent = ehID
				INNER JOIN tblProducts ON prodID = eiProdID
				INNER JOIN tblProductCats ON pcatID = prodCatID
				INNER JOIN tblProductGroups ON pgID = pcatGroup
				WHERE eiTimestamp BETWEEN '#args.form.srchDateFrom#' AND '#loc.midnight#'
				AND eiClass = 'sale'
				<cfif StructKeyExists(args.form,"srchAccount")>
					<cfif StructKeyExists(args.form,"srchExclude")>
						AND ehPayAcct NOT IN (#args.form.srchAccount#)
					<cfelse>
						AND ehPayAcct IN (#args.form.srchAccount#)
					</cfif>
				</cfif>
				GROUP BY ehMode, pgNomGroup,pgTitle
				ORDER BY CAST(ehMode AS CHAR), pgNomGroup,pgTitle
			</cfquery>
			<cfset loc.result.QSaleItems = loc.QSaleItems>
			<cfset loc.data = {}>
			<cfset loc.x = {}>
			<cfloop query="loc.QSaleItems">
				<cfset loc.x.key = "#pgNomGroup#-#NumberFormat(pgID,'000')#-#ehMode#">
				<!---<cfset loc.x.key = pgID>--->
				<cfset loc.x.waste = 0>
				<cfif ehMode eq "wst">
					<cfset loc.x.net = 0>
					<cfset loc.x.VAT = 0>
					<cfset loc.x.trade = trade>
					<cfset loc.x.profit = loc.x.net - loc.x.trade>
					<cfset loc.x.POR = 0>
				<cfelseif ehMode eq "rfd">
					<cfset loc.x.net = -net>
					<cfset loc.x.VAT = -VAT>
					<cfset loc.x.trade = -trade>
					<cfset loc.x.profit = loc.x.net - loc.x.trade>
					<cfif loc.x.net neq 0><cfset loc.x.POR = -int((loc.x.profit / loc.x.net) * 10000) / 100></cfif>
				<cfelse>
					<cfset loc.x.net = -net>
					<cfset loc.x.VAT = -VAT>
					<cfset loc.x.trade = trade>
					<cfset loc.x.profit = loc.x.net - loc.x.trade>				
					<cfif loc.x.net neq 0><cfset loc.x.POR = int((loc.x.profit / loc.x.net) * 10000) / 100></cfif>
				</cfif>	
				<cfif !StructKeyExists(loc.data,loc.x.key)>
					<cfset StructInsert(loc.data,loc.x.key, {
						"mode" = ehMode,
						"groupID" = pgID,
						"group" = pgNomGroup,
						"title" = pgTitle,
						"qty" = Qty,
						"net" = loc.x.net,
						"VAT" = loc.x.VAT,
						"trade" = loc.x.trade,
						"waste" = loc.x.waste,
						"profit" = loc.x.profit,
						"POR" = loc.x.POR
					})>
				<cfelse>
					<cfset loc.item = StructFind(loc.data,loc.x.key)>
					<cfset loc.item.waste += loc.x.waste>
					<cfset loc.item.net += loc.x.net>
					<cfset loc.item.VAT += loc.x.VAT>
					<cfset loc.item.trade += loc.x.trade>
					<cfset loc.item.profit = (loc.item.net - loc.item.trade)>
					<cfif loc.item.net neq 0><cfset loc.x.POR = loc.item.profit / loc.item.net></cfif>
				</cfif>
			</cfloop>
			<cfset loc.result.data = loc.data>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>


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
	
	<cffunction name="VATDetail" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.products = {}>
		
		<cftry>
			<cfif StructKeyExists(args.form,"group")>
				<cfquery name="loc.QGroup" datasource="#args.datasource#">
					SELECT pgID,pgTitle
					FROM tblProductGroups
					WHERE pgID = #val(args.form.group)#
				</cfquery>
				<cfset loc.result.Group = loc.QGroup.pgtitle>
				<cfset loc.srchDateTo = DateAdd("d",1,args.form.srchDateTo)>
				<cfset loc.midnight = DateFormat(loc.srchDateTo,'yyyy-mm-dd')>
				<cfquery name="loc.QSales" datasource="#args.datasource#">
					SELECT ehMode, pcatID,pcatTitle,prodID,prodTitle, SUM(eiNet) AS net, SUM(eiVAT) AS VAT, SUM(eiTrade) AS trade, SUM(eiQty) AS qty,
					siUnitSize,siOurPrice
					FROM tblepos_items
					INNER JOIN tblepos_header ON ehID = eiParent
					INNER JOIN tblProducts ON prodID = eiProdID
					INNER JOIN tblproductcats ON pcatID = prodCatID
					LEFT JOIN tblStockItem ON siProduct = prodID
						AND tblStockItem.siID = (
							SELECT MAX( siID )
							FROM tblStockItem
							WHERE prodID = siProduct
							AND siStatus = 'closed' )
					WHERE pcatGroup = #val(args.form.group)#
					AND eiTimestamp BETWEEN '#args.form.srchDateFrom#' AND '#loc.midnight#'
					GROUP BY ehMode,prodID
					ORDER BY CAST(ehMode AS CHAR), prodTitle
				</cfquery>
				<cfset loc.result.QSales = loc.QSales>
				
				<cfset loc.x = {}>
				<cfset loc.tot = {net=0,vat=0,trade=0,qty=0,profit=0}>
				<cfloop query="loc.QSales">
					<cfset loc.x.key = "#ehMode#-#prodID#">
					<cfif ehMode eq "wst">
						<cfset loc.x.net = 0>
						<cfset loc.x.VAT = 0>
						<cfset loc.x.trade = trade>
						<cfset loc.x.profit = loc.x.net - loc.x.trade>
						<cfset loc.x.POR = 0>
					<cfelseif ehMode eq "rfd">
						<cfset loc.x.net = -net>
						<cfset loc.x.VAT = -VAT>
						<cfset loc.x.trade = -trade>
						<cfset loc.x.profit = loc.x.net - loc.x.trade>
						<cfif loc.x.net neq 0><cfset loc.x.POR = -int((loc.x.profit / loc.x.net) * 10000) / 100></cfif>
					<cfelse>
						<cfset loc.x.net = -net>
						<cfset loc.x.VAT = -VAT>
						<cfset loc.x.trade = trade>
						<cfset loc.x.profit = loc.x.net - loc.x.trade>				
						<cfif loc.x.net neq 0><cfset loc.x.POR = int((loc.x.profit / loc.x.net) * 10000) / 100></cfif>
					</cfif>	
					<cfif !StructKeyExists(loc.products,loc.x.key)>
						<cfset StructInsert(loc.products,loc.x.key, {
							"mode" = ehMode,
							"prodID" = prodID,
							"prodTitle" = prodTitle,
							"pcatTitle" = pcatTitle,
							"siUnitSize" = siUnitSize,
							"siOurPrice" = siOurPrice,
							"qty" = Qty,
							"net" = loc.x.net,
							"VAT" = loc.x.VAT,
							"trade" = loc.x.trade,
							"profit" = loc.x.profit,
							"POR" = loc.x.POR
						})>
					<cfelse>
						<cfset loc.item = StructFind(loc.products,loc.x.key)>
						<cfset loc.item.net += loc.x.net>
						<cfset loc.item.VAT += loc.x.VAT>
						<cfset loc.item.trade += loc.x.trade>
						<cfset loc.item.profit = (loc.item.net - loc.item.trade)>
						<cfif loc.item.net neq 0><cfset loc.x.POR = loc.item.profit / loc.item.net></cfif>
					</cfif>

<!---
					<cfif !StructKeyExists(loc.products,loc.key)>
						<cfset StructInsert(loc.products,loc.key, {
							"mode" = ehMode,
							"prodID" = prodID,
							"prodTitle" = prodTitle,
							"pcatTitle" = pcatTitle,
							"siUnitSize" = siUnitSize,
							"siOurPrice" = siOurPrice,
							"net" = net,
							"VAT" = VAT,
							"trade" = trade,
							"qty" = qty,
							"profit" = net - trade
						})>
					<cfelse>
						<cfset loc.item = StructFind(loc.products,loc.key)>
						<cfset loc.item.net = net>
						<cfset loc.item.VAT = VAT>
						<cfset loc.item.trade = trade>
						<cfset loc.item.qty = qty>
						<cfset loc.item.profit = net - trade>
					</cfif>
					
--->
					<cfset loc.tot.net += loc.x.net>
					<cfset loc.tot.VAT += loc.x.VAT>
					<cfset loc.tot.trade += loc.x.trade>
					<cfset loc.tot.qty += qty>
					<cfset loc.tot.profit += (loc.x.net - loc.x.trade)>
					<cfif loc.tot.net neq 0><cfset loc.tot.POR = int((loc.tot.profit / loc.tot.net) * 10000) / 100></cfif>
				</cfloop>
				<cfset loc.result.products = loc.products>	
				<cfset loc.result.totals = loc.tot>
			</cfif>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
</cfcomponent>
