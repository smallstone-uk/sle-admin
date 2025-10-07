<cfcomponent>

	<cffunction name="Correct" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.x = {}>
		
		<cfset loc.x.waste = 0>
		<cfif args.ehMode eq "wst">
			<cfset loc.x.eiNet = 0>
			<cfset loc.x.eiVAT = 0>
			<cfset loc.x.eiTrade = args.eiTrade>
			<cfset loc.x.profit = loc.x.eiNet - loc.x.eiTrade>
			<cfset loc.x.POR = 0>
		<cfelseif args.ehMode eq "rfd">
			<cfset loc.x.eiNet = -args.eiNet>
			<cfset loc.x.eiVAT = -args.eiVAT>
			<cfset loc.x.eiTrade = -args.eiTrade>
			<cfset loc.x.profit = loc.x.eiNet - loc.x.eiTrade>
			<cfif loc.x.eiNet neq 0><cfset loc.x.POR = -int((loc.x.profit / loc.x.eiNet) * 10000) / 100></cfif>
		<cfelse>
			<cfset loc.x.eiNet = -args.eiNet>
			<cfset loc.x.eiVAT = -args.eiVAT>
			<cfset loc.x.eiTrade = args.eiTrade>
			<cfset loc.x.profit = loc.x.eiNet - loc.x.eiTrade>				
			<cfif loc.x.eiNet neq 0><cfset loc.x.POR = int((loc.x.profit / loc.x.eiNet) * 10000) / 100></cfif>
		</cfif>	
		<cfreturn loc.x>
	</cffunction>
	
	<cffunction name="VATSummary" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.data = {}>

		<cftry>
			<cfif !IsDate(args.form.srchDateTo)>
				<cfreturn loc.result>
			</cfif>
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
				<cfset loc.rec = {}>
				<cfset loc.rec.ehMode = ehMode>
				<cfset loc.rec.eiNet = Net>
				<cfset loc.rec.eiVAT = VAT>
				<cfset loc.rec.eiTrade = Trade>
				<cfset loc.clean = Correct(loc.rec)>

				<cfif !StructKeyExists(loc.data,loc.x.key)>
					<cfset StructInsert(loc.data,loc.x.key, {
						"mode" = ehMode,
						"groupID" = pgID,
						"group" = pgNomGroup,
						"title" = pgTitle,
						"qty" = Qty,
						"net" = loc.clean.eiNet,
						"VAT" = loc.clean.eiVAT,
						"trade" = loc.clean.eiTrade,
						"waste" = loc.clean.waste,
						"profit" = loc.clean.profit,
						"POR" = loc.clean.POR
					})>
				<cfelse>
					<cfset loc.item = StructFind(loc.data,loc.x.key)>
					<cfset loc.item.waste += loc.clean.waste>
					<cfset loc.item.net += loc.clean.eiNet>
					<cfset loc.item.VAT += loc.clean.eiVAT>
					<cfset loc.item.trade += loc.clean.eiTrade>
					<cfset loc.item.profit = (loc.clean.eiNet - loc.clean.eiTrade)>
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
			<cfset loc.srchDateTo = DateAdd("d",1,args.form.srchDateTo)>
			<cfset loc.midnight = DateFormat(loc.srchDateTo,'yyyy-mm-dd')>
			<cfquery name="loc.QPurTrans" datasource="#args.datasource#">
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
			<cfset loc.result.QPurTrans = loc.QPurTrans>
			<cfset loc.result.totals = {}>
			<cfset StructInsert(loc.result.totals,"zzGrand", {
				"Title" = "Grand Total",
				"Net" = 0,
				"VAT" = 0,
				"Num" = 0
			})>
			<cfif args.form.srchSort eq 1>
				<cfloop query="loc.QPurTrans">
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
			
			<cfquery name="loc.QEPOSTrans" datasource="#args.datasource#">
				SELECT pgNomGroup,pcatID,pcatTitle, prodID,prodTitle, ehMode, eiTimeStamp,eiClass,eiType,eiNet,eiVAT,eiTrade, -(eiNet + eiTrade) AS profit
				FROM tblepos_items
				INNER JOIN tblepos_header ON eiParent = ehID
				INNER JOIN tblProducts ON prodID = eiProdID
				INNER JOIN tblproductcats ON pcatID = prodCatID
				INNER JOIN tblProductGroups ON pcatGroup = pgID
				WHERE eiTimestamp BETWEEN '#args.form.srchDateFrom#' AND '#loc.midnight#'
				AND eiClass = 'sale'
				ORDER BY eiClass, pcatTitle, eiTimeStamp;
			</cfquery>
			<cfset loc.result.QEPOSTrans = loc.QEPOSTrans>
			<cfset loc.result.analysis = {}>
			<cfset loc.result.anTotals = {count = 0,eiNet = 0,eiVAT = 0,eiTrade = 0,profit = 0}>
			<cfloop query="loc.QEPOSTrans">
				<cfset loc.rec = {}>
				<cfset loc.rec.ehMode = ehMode>
				<cfset loc.rec.eiNet = eiNet>
				<cfset loc.rec.eiVAT = eiVAT>
				<cfset loc.rec.eiTrade = eiTrade>
				<cfset loc.rec.profit = profit>
				<cfset loc.clean = Correct(loc.rec)>
				<cfset loc.hashKey = "#pgNomGroup#-#pcatID#">
				<cfif !StructKeyExists(loc.result.analysis,loc.hashKey)>
					<cfset StructInsert(loc.result.analysis,loc.hashKey, {
						count = 0,
						eiNet = 0,
						eiVAT = 0,
						eiTrade = 0,
						profit = 0,
						pgNomGroup = pgNomGroup,
						pcatTitle = pcatTitle,
						eiClass = eiClass
					})>
				</cfif>
				<cfset loc.annie = StructFind(loc.result.analysis,loc.hashKey)>
				<cfset loc.annie.count++>
				<cfset loc.annie.eiNet += loc.clean.eiNet>
				<cfset loc.annie.eiVAT += loc.clean.eiVAT>
				<cfset loc.annie.eiTrade += loc.clean.eiTrade>
				<cfset loc.annie.profit += loc.clean.profit>
				<cfset loc.result.anTotals.count++>
				<cfset loc.result.anTotals.eiNet += loc.clean.eiNet>
				<cfset loc.result.anTotals.eiVAT += loc.clean.eiVAT>
				<cfset loc.result.anTotals.eiTrade += loc.clean.eiTrade>
				<cfset loc.result.anTotals.profit += loc.clean.profit>
			</cfloop>

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
				
				<cfset loc.tot = {net=0,vat=0,trade=0,qty=0,profit=0}>
				<cfset loc.x = {}>
				<cfloop query="loc.QSales">
					<cfset loc.x.key = "#ehMode#-#prodID#">
					<cfset loc.rec = {}>
					<cfset loc.rec.ehMode = ehMode>
					<cfset loc.rec.eiNet = Net>
					<cfset loc.rec.eiVAT = VAT>
					<cfset loc.rec.eiTrade = Trade>
					<cfset loc.clean = Correct(loc.rec)>
					<cfif !StructKeyExists(loc.products,loc.x.key)>
						<cfset StructInsert(loc.products,loc.x.key, {
							"mode" = ehMode,
							"prodID" = prodID,
							"prodTitle" = prodTitle,
							"pcatTitle" = pcatTitle,
							"siUnitSize" = siUnitSize,
							"siOurPrice" = siOurPrice,
							"qty" = Qty,
							"net" = loc.clean.eiNet,
							"VAT" = loc.clean.eiVAT,
							"trade" = loc.clean.eiTrade,
							"profit" = loc.clean.profit,
							"POR" = loc.clean.POR
						})>
					<cfelse>
						<cfset loc.item = StructFind(loc.products,loc.x.key)>
						<cfset loc.item.net += loc.clean.eiNet>
						<cfset loc.item.VAT += loc.clean.eiVAT>
						<cfset loc.item.trade += loc.clean.eiTrade>
						<cfset loc.item.profit = (loc.item.net - loc.item.trade)>
						<cfif loc.item.net neq 0><cfset loc.x.POR = loc.item.profit / loc.item.net></cfif>
					</cfif>
					<cfset loc.tot.net += loc.clean.eiNet>
					<cfset loc.tot.VAT += loc.clean.eiVAT>
					<cfset loc.tot.trade += loc.clean.eiTrade>
					<cfset loc.tot.qty += qty>
					<cfset loc.tot.profit += (loc.clean.eiNet - loc.clean.eiTrade)>
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

	<cffunction name="EPOSTrans" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfset loc.srchDateTo = DateAdd("d",1,args.form.srchDateTo)>
			<cfset loc.midnight = DateFormat(loc.srchDateTo,'yyyy-mm-dd')>
			<cfquery name="loc.result.QDeals" datasource="#args.datasource#">
				SELECT prodTitle, tblepos_dealitems.*, tblepos_deals.*
				FROM tblepos_deals
				INNER JOIN tblepos_dealitems ON ediParent = edID
				INNER JOIN tblproducts ON ediProduct = prodID
				WHERE edStarts <= '#args.form.srchDateFrom#'
				AND edEnds >= '#args.form.srchDateTo#'
				AND edStatus = 'active'
			</cfquery>
			<cfset loc.result.deals = {}>
			<cfloop query="loc.result.QDeals">
				<cfif !StructKeyExists(loc.result.deals,ediProduct)>
					<cfset StructInsert(loc.result.deals,ediProduct, {
						edDealType = edDealType,
						edAmount = edAmount,
						edQty = edQty,
						edTitle = edTitle,
						edStarts = edStarts,
						edEnds = edEnds
					})>
				</cfif>
			</cfloop>
			<cfquery name="loc.QEPOSTrans" datasource="#args.datasource#">
				SELECT prodTitle,prodVATRate, tblepos_items.*,
					-ROUND(eiRetail / (1 + (prodVATRate/100)),2) AS NET,
					-(eiRetail - ROUND(eiRetail / (1 + (prodVATRate/100)),2)) AS VAT
				FROM tblepos_items
				INNER JOIN tblproducts ON eiProdID = prodID
				WHERE eiTimestamp BETWEEN '#args.form.srchDateFrom#' AND '#loc.midnight#'
				AND eiVAT != 0
				ORDER BY eiParent
			</cfquery>
			<cfset loc.result.QEPOSTrans = loc.QEPOSTrans>
			<cfset loc.result.trans = {}>
			<cfloop query="loc.QEPOSTrans">
				<cfset loc.deal = {}>
				<cfif StructKeyExists(loc.result.deals,eiProdID)>
					<cfset loc.deal = StructFind(loc.result.deals,eiProdID)>
				</cfif>
				<cfif !StructKeyExists(loc.result.trans,eiParent)>
					<cfset StructInsert(loc.result.trans,eiParent, {
						items = {},
						deals = {}
					})>
				</cfif>
				<cfset loc.tran = StructFind(loc.result.trans,eiParent)>
				<cfif !StructKeyExists(loc.tran.deals,EIPRODID) AND !StructIsEmpty(loc.deal)>
					<cfset StructInsert(loc.tran.deals,EIPRODID,loc.deal)>
				</cfif>
				<cfset StructInsert(loc.tran.items,eiID,{
					prodTitle = prodTitle,
					prodVATRate = prodVATRate,
					EIPRODID = EIPRODID,
					EIQTY = EIQTY,
					EIRETAIL = EIRETAIL,
					EITRADE = EITRADE,
					EITYPE = EITYPE,
					EINET = EINET,
					EIVAT = EIVAT				
				})>
			</cfloop>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="EPOSUpdate" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QEPOSUpdate" datasource="#args.datasource#">
				UPDATE tblepos_items
				SET eiNet = args.NET,
					eiVAT = args.VAT
				WHERE eiID = #val(args.EPOSID)#
			</cfquery>
			<cfset loc.result = {msg = "OK"}>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>
