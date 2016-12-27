<cfcomponent displayname="productstock" extends="core">

	<cffunction name="FindProduct" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.msg = "">
		<cfset loc.result.action = "">
		<cfset loc.result.orders = []>
		<cfset loc.result.msgs = []>
		<cfset loc.barcode = Trim(args.form.barcode)>

		<cftry>
			<cfquery name="loc.result.groups" datasource="#args.datasource#">
				SELECT *
				FROM tblProductGroups
				ORDER BY pgTitle
			</cfquery>
			<cfquery name="loc.QBarcode" datasource="#args.datasource#">
				SELECT *
				FROM tblBarcodes
				WHERE barCode LIKE '%#loc.barcode#%'
				LIMIT 1;
			</cfquery>
			<cfif loc.QBarcode.recordCount IS 0>
				<cfset loc.result.msg = "Barcode not found">
				<cfif (len(loc.barcode) neq 8) AND (len(loc.barcode) neq 13)>
					<cfset loc.result.action = "clear">
				<cfelse>
					<cfset loc.result.barcode = loc.barcode>
					<cfset loc.result.action = "Add">
				</cfif>
			<cfelse>
				<cfset loc.result.barcode = loc.QBarcode.barcode>
				<cfset loc.result.QBarcode = loc.QBarcode>
				<cfif loc.QBarcode.barType neq args.form.source>
					<cfset loc.result.msg = "Invalid Barcode - that is a #loc.QBarcode.barType# barcode.">
					<cfset loc.result.action = "clear">
				<cfelse>
					<cfset loc.result.productID = loc.QBarcode.barProdID>
					<cfquery name="loc.QProduct" datasource="#args.datasource#">
						SELECT prodID,prodStaffDiscount,prodRef,prodRecordTitle,prodTitle,prodPackQty,prodPOR,prodCountDate,prodStockLevel,
							prodPackPrice,prodOurPrice,prodValidTo,prodLastBought,prodUnitSize,prodRRP,prodUnitTrade,prodPriceMarked,prodCatID,
							accName
						FROM tblProducts
						INNER JOIN tblAccount on prodSuppID = accID
						WHERE prodID=#val(loc.result.productID)#
						LIMIT 1;
					</cfquery>
					<cfif loc.QProduct.recordCount IS 0>
						<cfset loc.result.msg = "Barcode found but not the product record.">
						<cfset loc.result.action = "add">
					<cfelse>
						<cfset loc.result.msg = "Product found">
						<cfset loc.result.action = "found">
						<cfloop query="loc.QProduct">
							<cfset loc.rec = {}>
							<cfset loc.rec.prodID = prodID>
							<cfset loc.rec.prodStaffDiscount = prodStaffDiscount>
							<cfset loc.rec.prodRef = prodRef>
							<cfset loc.rec.prodRecordTitle = prodRecordTitle>
							<cfset loc.rec.prodTitle = prodTitle>
							<cfset loc.rec.prodPackQty = val(prodPackQty)+ int(val(prodPackQty) eq 0)>
							<cfset loc.rec.prodPackPrice = prodPackPrice>
							<cfset loc.rec.prodOurPrice = prodOurPrice>
							<cfset loc.rec.prodValidTo = prodValidTo>
							<cfset loc.rec.prodPriceMarked = GetToken(" |PM",prodPriceMarked+1,"|")>
							<cfset loc.rec.prodLastBought = LSDateFormat(prodLastBought)>
							<cfset loc.rec.prodUnitSize = prodUnitSize>
							<cfset loc.rec.prodRRP = prodRRP>
							<cfset loc.rec.prodUnitTrade = prodUnitTrade>
							<cfset loc.rec.prodPOR = prodPOR>
							<cfset loc.rec.prodCountDate = prodCountDate>
							<cfset loc.rec.prodStockLevel = prodStockLevel + int(prodStockLevel eq 0)>	<!--- add 1 if zero --->
							<cfset loc.rec.prodCatID = prodCatID>
							<cfset loc.rec.accName = accName>
						</cfloop>
						<cfset loc.result.product = loc.rec>
						<cfquery name="loc.CategoryGroup" datasource="#args.datasource#">
							SELECT pcatID,pgID,pcatTitle,pgTitle
							FROM tblProductCats
							INNER JOIN tblProductGroups ON pgID=pcatGroup
							WHERE pcatID=#loc.rec.prodCatID#
						</cfquery>
						<cfif loc.CategoryGroup.recordcount eq 1>
							<cfset loc.result.catID=loc.CategoryGroup.pcatID>
							<cfset loc.result.catTitle=loc.CategoryGroup.pcatTitle>
							<cfset loc.result.groupID=loc.CategoryGroup.pgID>
							<cfset loc.result.groupTitle=loc.CategoryGroup.pgTitle>
						</cfif>
						<cfquery name="loc.QOrders" datasource="#args.datasource#" result="loc.result.QOrderResult">
							SELECT siID,siQtyPacks,siQtyItems,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siReceived,siBookedIn,siExpires,siStatus,
								soID,soRef,soDate,soStatus
							FROM tblStockItem
							INNER JOIN tblStockOrder ON siOrder = soID
							WHERE siProduct = #loc.result.productID#
							ORDER BY soDate DESC, siID DESC
						</cfquery>
						<cfset loc.result.QOrders = loc.QOrders>
						<cfset loc.lastbought = false>
						<cfif loc.QOrders.recordcount gt 0>
							<cfloop query="loc.QOrders">
								<cfif NOT loc.lastbought AND siStatus IS "closed">
									<cfset ArrayAppend(loc.result.msgs,{msg="Last Bought",order=soRef,date=LSDateFormat(soDate),item=siID})>
									<cfset loc.lastbought = true>
								</cfif>
								<cfif soStatus eq "open" OR siStatus eq "open">
									<cfif siStatus eq "open"><cfset loc.title = "Product on order">
										<cfelse><cfset loc.title = "Product received"></cfif>
									<cfset ArrayAppend(loc.result.orders,{msg=loc.title,order=soRef,date=LSDateFormat(soDate),"OrderStatus"=soStatus,"ItemStatus"=siStatus})>
								</cfif>
								<cfif siStatus eq "outofstock">
									<cfset ArrayAppend(loc.result.msgs,{msg="Out of Stock",order=soRef,date=LSDateFormat(soDate),item=siID})>								
								</cfif>
							</cfloop>
						<cfelse>
							<cfset loc.result.msg = "No Stock orders found">
						</cfif>
					</cfif>
				</cfif>
			</cfif>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ProductDetails" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.result.QProduct" datasource="#args.datasource#">
				SELECT prodID,prodStaffDiscount,prodRef,prodRecordTitle,prodTitle,prodPackQty,prodPOR,prodCountDate,prodStockLevel,prodOurMarkup,prodSuppID,
					prodPackPrice,prodOurPrice,prodValidTo,prodLastBought,prodUnitSize,prodRRP,prodUnitTrade,prodPriceMarked,prodVATRate,prodPOR,
					accName
				FROM tblProducts
				INNER JOIN tblAccount on prodSuppID = accID
				WHERE prodID = #val(args.prodID)#
				LIMIT 1;
			</cfquery>
			<cfquery name="loc.result.QBarcodes" datasource="#args.datasource#">
				SELECT *
				FROM tblBarcodes
				WHERE barProdID = #val(args.prodID)#
			</cfquery>
			<cfquery name="loc.result.QOrders" datasource="#args.datasource#">
				SELECT siID,siQtyPacks,siQtyItems,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siReceived,siBookedIn,siExpires,siStatus,
					soID,soRef,soDate,soStatus
				FROM tblStockItem
				INNER JOIN tblStockOrder ON siOrder = soID
				WHERE siProduct = #val(args.prodID)#
				ORDER BY soDate DESC
			</cfquery>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ProductUpdate" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfset loc.unitTrade = args.form.prodPackPrice / args.form.prodPackQty>
			<cfquery name="loc.QUpdate" datasource="#args.datasource#" result="loc.result.QUpdateResult">
				UPDATE tblProducts
				SET prodPackPrice = #args.form.prodPackPrice#,
					prodPackQty = #args.form.prodPackQty#,
					prodRecordTitle= '#args.form.prodRecordTitle#',
					prodTitle= '#args.form.prodTitle#',
					prodRef = '#args.form.prodRef#',
					prodRRP = #args.form.prodRRP#,
					prodSuppID = #args.form.prodSuppID#,
					prodUnitSize = '#args.form.prodUnitSize#',
					prodUnitTrade = #loc.unitTrade#,
					prodVATRate = #args.form.prodVATRate#,
					prodPriceMarked = #Int(StructKeyExists(args.form,"prodPriceMarked"))#,
					prodOurMarkup = #val(hprodOurMarkup)#,
					prodOurPrice = #val(hprodOurPrice)#,
					prodPOR = #args.form.hRRPPOR#
				WHERE prodID = #args.prodID#
			</cfquery>
			<cfif args.form.stockItemID gt 0>
				<cfquery name="loc.QUpdateItem" datasource="#args.datasource#" result="loc.result.QUpdateItemResult">
					UPDATE tblStockItem
					SET siWSP = #args.form.prodPackPrice#,
						siUnitTrade = #loc.unitTrade#,
						siRRP = #args.form.prodRRP#,
						siOurPrice = #val(hprodOurPrice)#,
						siPOR = #args.form.hRRPPOR#
					WHERE siID = #args.form.stockItemID#
				</cfquery>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadSuppliers" access="public" returntype="query">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QSuppliers" datasource="#args.datasource#" result="loc.QQueryResult">
				SELECT accID,accName
				FROM  tblAccount
				WHERE accStockControl = 1
				AND accStatus = 'active'
				ORDER BY accName
			</cfquery>
			<cfset loc.result = loc.QSuppliers>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="AddProduct" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QQuery" datasource="#args.datasource#" result="loc.QQueryResult">
				SELECT *
				FROM table
				WHERE ID=#val(id)#
				LIMIT 1;
			</cfquery>
			<cfset loc.result.QQuery = loc.QQuery>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadOrderProductList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var=result={}>
		<cfset var i={}>
		<cfset var=QStockItems="">
		<cfset var=Qbarcode="">
		<cfset result.list=[]>
		
		<cftry>
			<cfquery name="QStockItems" datasource="#args.datasource#">
				SELECT *
				FROM tblStockItem,tblStockOrder,tblProducts
				WHERE siStatus='open'
				AND siOrder=soID
				AND siProduct=prodID
				AND soStatus='open'
				ORDER BY soID asc, prodTitle asc
			</cfquery>
			<cfloop query="QStockItems">
				<cfquery name="Qbarcode" datasource="#args.datasource#">
					SELECT *
					FROM tblBarcodes
					WHERE barProdID=#prodID#
					AND barType='product'
					ORDER BY barID desc
				</cfquery>
				<cfset i={}>
				<cfset i.ID=siID>
				<cfset i.prodID=prodID>
				<cfset i.prodRef=prodRef>
				<cfset i.Title=prodTitle>
				<cfset i.OrderRef=soRef>
				<cfset i.boxes=val(siQtyPacks)-val(siReceived)>
				<cfset i.UnitSize=prodUnitSize>
				<cfset i.RRP=prodRRP>
				<cfset i.Barcodes=[]>
				<cfloop query="Qbarcode">
					<cfset ArrayAppend(i.Barcodes,Qbarcode.barCode)>
				</cfloop>
				<cfset ArrayAppend(result.list,i)>
			</cfloop>
		
			<cfcatch type="any">
				 <cfset result.error=cfcatch>
			</cfcatch>
		</cftry>	
			
		<cfreturn result>
	</cffunction>
	
	<cffunction name="CheckProductOnOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var parm={}>
		<cfset var QStockItem="">
		<cfset var QProduct="">
		<cfset var QStockItem2="">
		<cfset result.error="">
		
		<cftry>
			<cfquery name="QStockItem" datasource="#args.datasource#">
				SELECT *
				FROM tblStockItem,tblStockOrder,tblProducts
				WHERE siProduct=#val(args.form.id)#
				AND siStatus='open'
				AND siOrder=soID
				AND siProduct=prodID
				AND soStatus='open'
				LIMIT 1;
			</cfquery>
			<cfset result.barcode=args.form.barcode>
			<cfif len(result.barcode) is 8>
				<cfset result.BarcodeType="ean8">
			<cfelseif len(result.barcode) is 13>
				<cfset result.BarcodeType="ean13">
			<cfelse>
				<cfset result.BarcodeType="upc">
			</cfif>
			<cfif QStockItem.recordcount is 1>
				<cfset result.ID=QStockItem.siID>
				<cfset result.prodID=QStockItem.siProduct>
				<cfset result.Title=QStockItem.prodTitle>
				<cfset result.PM=QStockItem.prodPriceMarked>
				<cfset result.OrderRef=QStockItem.soRef>
				<cfset result.boxes=QStockItem.siQtyPacks>
				<cfset result.received=QStockItem.siReceived+1>
				<cfset result.UnitSize=QStockItem.prodUnitSize>
				<cfset result.RRP=QStockItem.prodRRP>
				<cfset result.qtytotal=QStockItem.siQtyItems+QStockItem.prodPackQty>
				<cfset parm={}>
				<cfset parm.datasource=args.datasource>
				<cfset parm.id=result.ID>
				<cfset parm.due=result.boxes>
				<cfset parm.received=QStockItem.siReceived>
				<cfset parm.qtytotal=QStockItem.siQtyItems>
				<cfset parm.packqty=QStockItem.prodPackQty>
				<cfset bookin=BookInProductStock(parm)>
			<cfelse>
				<cfquery name="QProduct" datasource="#args.datasource#">
					SELECT *
					FROM tblProducts
					WHERE prodID=#val(args.form.id)#
					LIMIT 1;
				</cfquery>
				<cfquery name="QStockItem2" datasource="#args.datasource#">
					SELECT *
					FROM tblStockItem,tblStockOrder,tblProducts
					WHERE (siProduct=#val(args.form.id)# OR siSubs=#val(args.form.id)#)
					AND (siStatus='open' OR siStatus='closed')
					AND siOrder=soID
					AND siProduct=prodID
					AND soStatus='open'
					LIMIT 1;
				</cfquery>
				<cfset result.error="#QProduct.prodTitle# #QProduct.prodUnitSize#">
				<cfset result.prodID=args.form.id>
				<cfset result.RRP=QProduct.prodRRP>
				<cfif QStockItem2.siStatus is "closed">
					<cfset result.msg="<h3 style='font-size:44px;'>Already Booked In</h3><h3 style='font-size:34px;'>
						Number of Packs: #QStockItem2.siReceived#/#QStockItem2.siQtyPacks#</h3><h3>Total Products: #QStockItem2.siQtyItems#</h3>">
					<cfset result.img='<img src="images/tick.png" width="128" />'>
					<cfset result.sub=false>
				<cfelse>
					<cfset result.msg="<h3 style='font-size:34px;'>This product is not in any of the stock orders.</h3>
						<p style='font-size:22px;'><b>Is this a substitute for another product in the order?</b></p>">
					<cfset result.img='<img src="images/cross.png" width="128" />'>
					<cfset result.sub=true>
				</cfif>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>	
		<cfreturn result>
	</cffunction>

	<cffunction name="BookInProductStock" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QStockItem="">
		<cfset var received=0>
		
		<cfif val(args.received) lt val(args.due)>
			<cfset received=val(args.received)+1>
			<cfset qty=val(args.qtytotal)+val(args.packqty)>
			<cfquery name="QStockItem" datasource="#args.datasource#">
				UPDATE tblStockItem
				SET <cfif received is val(args.due)>siStatus='closed',</cfif>
					siBookedIn = #Now()#,
					siQtyItems=#qty#,
					siReceived=#received#
				WHERE siID=#val(args.ID)#
			</cfquery>
		<cfelse>
			<cfquery name="QStockItem" datasource="#args.datasource#">
				UPDATE tblStockItem
				SET siBookedIn = #Now()#,
					siStatus='closed'
				WHERE siID=#val(args.ID)#
			</cfquery>
		</cfif>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="MarkAsOutOfStock" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QStockItem="">
		
		<cfif StructKeyExists(args.form,"selectitem")>
			<cfquery name="QStockItem" datasource="#args.datasource#">
				UPDATE tblStockItem
				SET siBookedIn = #Now()#,
					siStatus='outofstock'
				WHERE siID IN (#args.form.selectitem#)
			</cfquery>
		</cfif>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="SetSubstitute" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var parm={}>
		<cfset var QStockItem="">
		<cfset var QProduct="">
		<cfset var QUpdate="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"siID")>
				<cfquery name="QProduct" datasource="#args.datasource#">
					SELECT *
					FROM tblProducts
					WHERE prodID=#val(args.form.prodID)#
					LIMIT 1;
				</cfquery>
				<cfquery name="QStockItem" datasource="#args.datasource#">
					SELECT *
					FROM tblStockItem
					WHERE siID=#val(args.form.siID)#
					LIMIT 1;
				</cfquery>
				<cfquery name="QUpdate" datasource="#args.datasource#">
					UPDATE tblStockItem
					SET siSubs=#val(args.form.prodID)#,
						siQtyItems=#QProduct.prodPackQty#,
						siWSP=#DecimalFormat(QProduct.prodPackPrice)#,
						siUnitTrade=#DecimalFormat(QProduct.prodUnitTrade)#,
						siRRP=#DecimalFormat(QProduct.prodRRP)#,
						siOurPrice=#DecimalFormat(QProduct.prodOurPrice)#,
						siPOR=#DecimalFormat(QProduct.prodPOR)#
					WHERE siID=#val(args.form.siID)#
				</cfquery>
				<cfset parm={}>
				<cfset parm.datasource=args.datasource>
				<cfset parm.id=args.form.siID>
				<cfset parm.due=QStockItem.siQtyPacks>
				<cfset parm.received=QStockItem.siReceived>
				<cfset parm.qtytotal=QStockItem.siQtyItems>
				<cfset parm.packqty=QProduct.prodPackQty>
				<cfset bookin=BookInProductStock(parm)>
			</cfif>
		
			<cfcatch type="any">
				 <cfset result.error=cfcatch>
			</cfcatch>
		</cftry>	
			
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadDealList" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var i={}>
		<cfset var QDeals="">
		<cfset var QDealItems="">
		
		<cftry>
			<cfquery name="QDeals" datasource="#args.datasource#">
				SELECT * 
				FROM tblDeals
				WHERE 1
				ORDER BY dealStarts desc
			</cfquery>
			<cfloop query="QDeals">
				<cfquery name="QDealItems" datasource="#args.datasource#">
					SELECT * 
					FROM tblDealItems,tblProducts
					WHERE dimDealID=#dealID#
					AND dimProdID=prodID
					ORDER BY prodTitle asc
				</cfquery>
				<cfset item={}>
				<cfset item.ID=dealID>
				<cfset item.RecordTitle=dealRecordTitle>
				<cfset item.Title=dealTitle>
				<cfset item.Datestamp=dealDatestamp>
				<cfset item.Starts=LSDateFormat(dealStarts,"yyyy-mm-dd")>
				<cfset item.Ends=LSDateFormat(dealEnds,"yyyy-mm-dd")>
				<cfset item.Type=dealType>
				<cfset item.Amount=dealAmount>
				<cfset item.Qty=dealQty>
				<cfset item.Status=dealStatus>
				<cfset item.items=[]>
				<cfloop query="QDealItems">
					<cfset i={}>
					<cfset i.ID=QDealItems.dimID>
					<cfset i.prodID=QDealItems.prodID>
					<cfset i.Title=prodTitle>
					<cfset i.amount=prodOurPrice>
					<cfset ArrayAppend(item.items,i)>
				</cfloop>
				<cfset ArrayAppend(result,item)>
			</cfloop>
		
			<cfcatch type="any">
				 <cfset ArrayAppend(result,cfcatch)>
			</cfcatch>
		</cftry>
				
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadDeal" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var i={}>
		<cfset var QDeal="">
		<cfset var QDealItems="">
		
		<cftry>
			<cfquery name="QDeal" datasource="#args.datasource#">
				SELECT * 
				FROM tblDeals
				WHERE dealID=#args.form.dealID#
				LIMIT 1;
			</cfquery>
			<cfquery name="QDealItems" datasource="#args.datasource#">
				SELECT * 
				FROM tblDealItems,tblProducts
				WHERE dimDealID=#QDeal.dealID#
				AND dimProdID=prodID
				ORDER BY prodTitle asc
			</cfquery>
			<cfset result.ID=QDeal.dealID>
			<cfset result.RecordTitle=QDeal.dealRecordTitle>
			<cfset result.Title=QDeal.dealTitle>
			<cfset result.Datestamp=QDeal.dealDatestamp>
			<cfset result.Starts=QDeal.dealStarts>
			<cfset result.Ends=QDeal.dealEnds>
			<cfset result.Type=QDeal.dealType>
			<cfset result.Amount=QDeal.dealAmount>
			<cfset result.Qty=QDeal.dealQty>
			<cfset result.Status=QDeal.dealStatus>
			<cfset result.items=[]>
			<cfloop query="QDealItems">
				<cfset i={}>
				<cfset i.ID=QDealItems.dimID>
				<cfset i.prodID=QDealItems.prodID>
				<cfset i.Title=prodTitle>
				<cfset i.size=prodUnitSize>
				<cfset i.amount=prodOurPrice>
				<cfset ArrayAppend(result.items,i)>
			</cfloop>
		
			<cfcatch type="any">
				 <cfset result.cfcatch=cfcatch>
			</cfcatch>
		</cftry>
				
		<cfreturn result>
	</cffunction>

	<cffunction name="AddDeal" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QDeal="">
		<cfset var QResult="">
		<cfset var dealID=args.form.dealID>

		<cfif args.form.dealID is 0>
			<cfquery name="QDeal" datasource="#args.datasource#" result="QResult">
				INSERT INTO tblDeals (
					dealRecordTitle,
					dealTitle,
					dealStarts,
					dealEnds,
					dealType,
					dealAmount,
					dealQty,
					dealStatus
				) VALUES (
					'#args.form.dealRecordTitle#',
					'#args.form.dealTitle#',
					'#LSDateFormat(args.form.dealStarts,"yyyy-mm-dd")#',
					'#LSDateFormat(args.form.dealEnds,"yyyy-mm-dd")#',
					'#args.form.dealType#',
					#val(args.form.dealAmount)#,
					#val(args.form.dealQty)#,
					'#args.form.dealStatus#'
				)
			</cfquery>
			<cfset dealID=val(QResult.generatedKey)>
		<cfelse>
			<cfquery name="QDeal" datasource="#args.datasource#">
				UPDATE tblDeals
				SET	dealRecordTitle='#args.form.dealRecordTitle#',
					dealTitle='#args.form.dealTitle#',
					dealStarts='#LSDateFormat(args.form.dealStarts,"yyyy-mm-dd")#',
					dealEnds='#LSDateFormat(args.form.dealEnds,"yyyy-mm-dd")#',
					dealType='#args.form.dealType#',
					dealAmount=#val(args.form.dealAmount)#,
					dealQty=#val(args.form.dealQty)#,
					dealStatus='#args.form.dealStatus#'
				WHERE dealID=#dealID#
			</cfquery>
		</cfif>
		<cfset result.ID=dealID>
		<cfset result.RecordTitle=args.form.dealRecordTitle>
		<cfset result.Title=args.form.dealTitle>
		<cfset result.Starts=LSDateFormat(args.form.dealStarts,"yyyy-mm-dd")>
		<cfset result.Ends=LSDateFormat(args.form.dealEnds,"yyyy-mm-dd")>
		<cfset result.Type=args.form.dealType>
		<cfset result.Amount=val(args.form.dealAmount)>
		<cfset result.Qty=val(args.form.dealQty)>
		<cfset result.Status=args.form.dealStatus>

		<cfreturn result>
	</cffunction>

	<cffunction name="AssignProductToDeal" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QProduct="">
		<cfset var QDealItemCheck="">
		<cfset var QDealItem="">
		
		<cfquery name="QDealItemCheck" datasource="#args.datasource#">
			SELECT *
			FROM tblDealItems
			WHERE dimDealID=#val(args.form.deal)#
			AND dimProdID=#val(args.form.id)#
			LIMIT 1;
		</cfquery>
		<cfquery name="QProduct" datasource="#args.datasource#">
			SELECT *
			FROM tblProducts
			WHERE prodID=#val(args.form.id)#
			LIMIT 1;
		</cfquery>
		<cfset result.Title="#QProduct.prodTitle# #QProduct.prodUnitSize#">
		<cfif QDealItemCheck.recordcount is 0>
			<cfquery name="QDealItem" datasource="#args.datasource#">
				INSERT INTO tblDealItems (
					dimDealID,
					dimProdID
				) VALUES (
					#val(args.form.deal)#,
					#val(args.form.id)#
				)
			</cfquery>
			<cfset result.msg="Product Assigned">
		<cfelse>
			<cfset result.msg="Product Already Assigned">
		</cfif>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="DeleteDeal" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		
		<cfif StructKeyExists(args.form,"selectitem")>
			<cfquery name="QDeal" datasource="#args.datasource#">
				DELETE FROM tblDeals
				WHERE dealID IN (#args.form.selectitem#)
			</cfquery>
		</cfif>

		<cfreturn result>
	</cffunction>

</cfcomponent>





