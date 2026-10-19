<!--- version 4.0 - 01/07/2026 --->

<cfcomponent displayname="Import" extends="code/core">

	<cffunction name="setCaseQty" access="public" returntype="struct" description="updates number of cases ordered if changed in UI">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cftry>
			<cfquery name="loc.QUpdate" datasource="#application.site.datasource1#">
				UPDATE tblStockItem
				SET siQtyPacks = #val(args.form.QtyPacks)#
				WHERE siID = #val(args.form.stockItemID)#
			</cfquery>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="setValue" access="public" returntype="struct" description="sets PM flag if changed in UI">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cftry>
			<cfquery name="loc.QUpdate" datasource="#application.site.datasource1#">
				UPDATE tblProducts
				SET prodPriceMarked = #val(args.form.pm)#
				WHERE prodID = #val(args.form.productID)#
			</cfquery>
			<cfset loc.result.pm = val(args.form.pm)>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="getExistingProduct" access="public" returntype="struct" description="looks up product by Booker product code">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.pgTarget = 50>
		<cfset loc.result.action = "">
		
		<cftry>
			<cfquery name="loc.prodExists" datasource="#application.site.datasource1#">
				SELECT prodID,prodLastBought,prodMinPrice,prodPriceMarked,prodLocked, pcatID,pcatTitle, pgTitle,pgTarget
				FROM tblProducts
				INNER JOIN tblProductCats ON prodCatID = pcatID
				INNER JOIN tblProductGroups ON pcatGroup = pgID
				WHERE prodRef = '#args.productCode#'
				AND prodSuppID IN (21,2682)	<!--- booker accounts ---> 
				LIMIT 1;
			</cfquery>
			<cfif loc.prodExists.recordcount neq 0>
				<cfset loc.result.prodID = loc.prodExists.prodID>
				<cfset loc.result.prodLastBought = loc.prodExists.prodLastBought>
				<cfset loc.result.prodMinPrice = loc.prodExists.prodMinPrice>
				<cfset loc.result.prodPriceMarked = loc.prodExists.prodPriceMarked>
				<cfset loc.result.prodLocked = loc.prodExists.prodLocked>
				<cfset loc.result.pcatID = loc.prodExists.pcatID>
				<cfset loc.result.pcatTitle = loc.prodExists.pcatTitle>
				<cfset loc.result.pgTitle = loc.prodExists.pgTitle>
				<cfset loc.result.pgTarget = loc.prodExists.pgTarget>
				<cfset loc.result.action = "Product found">
			<cfelse>
				<cfset loc.result.action = "<span class='missing'>Product not found</span>">
				<cfset loc.result.prodID = 0>
				<cfset loc.result.prodPriceMarked = 0>
				<cfquery name="loc.catExists" datasource="#application.site.datasource1#">
					SELECT pcatID,pcatTitle, pgTitle, pgTarget
					FROM tblProductCats
					INNER JOIN tblProductGroups ON pcatGroup = pgID
					WHERE pcatTitle = '#args.category#'
					LIMIT 1;
				</cfquery>
				<cfif loc.catExists.recordcount neq 0>
					<cfset loc.result.action = "#loc.result.action# <br>Category found">
					<cfset loc.result.pcatID = loc.catExists.pcatID>
					<cfset loc.result.pcatTitle = loc.catExists.pcatTitle>
					<cfset loc.result.pgTitle = loc.catExists.pgTitle>
					<cfset loc.result.pgTarget = loc.catExists.pgTarget>				
				<cfelse>
					<cfset loc.result.action = "#loc.result.action# <br><span class='missing'>Category not found</span>">
					<cfset loc.result.pcatID = 0>
				</cfif>
			</cfif>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="getCategory" access="public" returntype="struct" description="get category by name and create if missing">
		<cfargument name="category" type="string" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.action = "">
		
		<cftry>
			<cfquery name="loc.catExists" datasource="#application.site.datasource1#">
				SELECT pcatID,pcatTitle, pgTitle, pgTarget
				FROM tblProductCats
				INNER JOIN tblProductGroups ON pcatGroup = pgID
				WHERE pcatTitle = '#category#'
				LIMIT 1;
			</cfquery>
			<cfif loc.catExists.recordcount neq 1>
				<cfset loc.result.action = "Category created">
				<cfquery name="loc.newCat" datasource="#application.site.datasource1#">
					INSERT INTO tblProductCats
						(pcatTitle,pcatGroup) VALUES ('#category#',1);
				</cfquery>
				<cfquery name="loc.catExists" datasource="#application.site.datasource1#">
					SELECT pcatID,pcatTitle, pgTitle, pgTarget
					FROM tblProductCats
					INNER JOIN tblProductGroups ON pcatGroup = pgID
					WHERE pcatTitle = '#category#'
					LIMIT 1;
				</cfquery>
			</cfif>
			<cfset loc.result.pcatID = loc.catExists.pcatID>
			<cfset loc.result.pcatTitle = loc.catExists.pcatTitle>
			<cfset loc.result.pgTitle = loc.catExists.pgTitle>
			<cfset loc.result.pgTarget = loc.catExists.pgTarget>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="getBarcode" access="public" returntype="struct" description="get product barcode or create if missing">
		<cfargument name="barcode" type="string" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.action = "">
		
		<cftry>
			<!--- standardize format --->
			<cfif len(barcode) lt 9>
				<cfset loc.result.barcode = NumberFormat(Left(barcode,8),"0000000000000")>
			<cfelseif len(barcode) lt 14>
				<cfset loc.result.barcode = NumberFormat(Left(barcode,13),"0000000000000")>
			<cfelse>
				<cfset loc.result.barcode = barcode>
			</cfif>

			<cfquery name="loc.barcodeExists" datasource="#application.site.datasource1#">
				SELECT barID,barcode,barType,barProdID
				FROM tblbarcodes
				WHERE barType LIKE 'product'
				AND barcode LIKE '#loc.result.barcode#'
				LIMIT 1;
			</cfquery>
			<cfif loc.barcodeExists.recordcount neq 1>
				<cfset loc.result.action = "Barcode created">
				<cfquery name="loc.newBarcode" datasource="#application.site.datasource1#">
					INSERT INTO tblbarcodes
						(barcode,barType) VALUES ('#loc.result.barcode#','product');
				</cfquery>
				<cfquery name="loc.barcodeExists" datasource="#application.site.datasource1#">
					SELECT barID,barcode,barType,barProdID
					FROM tblbarcodes
					WHERE barType LIKE 'product'
					AND barcode LIKE '#loc.result.barcode#'
					LIMIT 1;
				</cfquery>
			</cfif>
			<cfset loc.result.barID = loc.barcodeExists.barID>
			<cfset loc.result.barcode = loc.barcodeExists.barcode>
			<cfset loc.result.barType = loc.barcodeExists.barType>
			<cfset loc.result.barProdID = loc.barcodeExists.barProdID>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="CheckStockOrder" access="public" returntype="struct" hint="checks existence of/or creates stock order header record">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.stockOrderID = 0>
		<cfset loc.validTo = "">

		<cftry>
			<cfset loc.scandate = DateFormat(Now(),'yyyy-mm-dd')>
			<cfset loc.orderDate = args.orderDate>
			<cfif !IsDate(args.orderDate)>
				<cfset loc.orderDate = createdate(mid(args.orderDate,1,2),mid(args.orderDate,3,2),mid(args.orderDate,5,2))>
			</cfif>
			<cfif len(args.validTo)>
				<cfset loc.validTo = createdate(mid(args.validTo,1,2),mid(args.validTo,3,2),mid(args.validTo,5,2))>
			</cfif>
			<cfif FindNoCase("prom",args.orderRef,1)>
				<cfset loc.orderRef = DateFormat(loc.orderDate,"yyyymmdd")>
			<cfelse>
				<cfset loc.orderRef = args.orderRef>
			</cfif>
			<cfquery name="loc.QStockOrder" datasource="#application.site.datasource1#">
				SELECT *
				FROM tblstockOrder
				WHERE soRef = '#loc.orderRef#'
				LIMIT 1;
			</cfquery>

			<cfif loc.QStockOrder.recordcount eq 1>
				<cfset loc.stockOrderID = loc.QStockOrder.soID>
				<cfquery name="loc.QStockOrder" datasource="#application.site.datasource1#">
					UPDATE tblstockOrder
					SET soScanned = #Now()#,
						<cfif len(loc.validTo)>soValidTo='#LSDateFormat(loc.validTo,"yyyy-mm-dd")#',</cfif>
						soDate = '#LSDateFormat(loc.orderDate,"yyyy-mm-dd")#'
					WHERE soRef = '#loc.orderRef#'
				</cfquery>
			<cfelse>
				<cfquery name="loc.QStockOrder" datasource="#application.site.datasource1#" result="loc.QStockOrderResult">
					INSERT INTO tblstockOrder (
						soAccountID,
						soRef,
						soDate,
						<cfif len(loc.validTo)>soValidTo,</cfif>
						soScanned
					) VALUES (
						#args.supplierID#,
						'#loc.orderRef#',
						'#DateFormat(loc.orderDate,'yyyy-mm-dd')#',
						<cfif len(loc.validTo)>'#loc.validTo#',</cfif>
						'#loc.scandate#'
					)
				</cfquery>
				<cfset loc.stockOrderID = loc.QStockOrderResult.generatedKey>
			</cfif>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc>
	</cffunction>

	<cffunction name="StockOrderStatus" access="public" returntype="struct" description="checks status of stock order header record">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cftry>
			<cfset loc.scanDate = DateFormat(Now(),'yyyy-mm-dd')>
			<cfset loc.orderDate = args.orderDate>
			<cfif !IsDate(args.orderDate)>
				<cfset loc.orderDate = createdate(mid(args.orderDate,1,2),mid(args.orderDate,3,2),mid(args.orderDate,5,2))>
			</cfif>
			<cfif len(args.validTo)>
				<cfset loc.validTo = createdate(mid(args.validTo,1,2),mid(args.validTo,3,2),mid(args.validTo,5,2))>
			</cfif>
			<cfif FindNoCase("prom",args.orderRef,1)>
				<cfset loc.orderRef = DateFormat(loc.orderDate,"yyyymmdd")>
			<cfelse>
				<cfset loc.orderRef = args.orderRef>
			</cfif>
			<cfquery name="loc.QStockOrder" datasource="#application.site.datasource1#">
				SELECT *
				FROM tblstockOrder
				WHERE soRef = '#loc.orderRef#'
				LIMIT 1;
			</cfquery>
			<cfif loc.QStockOrder.recordcount eq 1>
				<cfloop query="loc.QStockOrder">
					<cfset loc.result.soID = soID>
					<cfset loc.result.stockOrderID = soID>
					<cfset loc.result.soAccountID = soAccountID>
					<cfset loc.result.soRef = soRef>
					<cfset loc.result.soDate = soDate>
					<cfset loc.result.soValidTo = soValidTo>
					<cfset loc.result.soScanned = soScanned>
					<cfset loc.result.soItems = soItems>
					<cfset loc.result.soStatus = soStatus>
				</cfloop>
				<cfif loc.result.soItems eq 0>
					<cfset loc.result.msg = "Import of this order has not yet been completed.">				
				<cfelse>
					<cfset loc.result.msg = "This order has already been imported.">
				</cfif>
			<cfelse>
				<cfset loc.result.msg = "This order has not yet been imported.">
			</cfif>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="CheckStockItem" access="public" returntype="struct">
		<cfargument name="product" type="struct" required="yes">
		<cfargument name="header" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.rec = {}>
		
		<cftry>
			<!---<cfdump var="#arguments#" label="CheckStockItem" expand="false">--->
			<cfset loc.rec = {}>
			<cfquery name="loc.QStockItem" datasource="#application.site.datasource1#">
				SELECT tblStockItem.*
				FROM tblStockItem
				INNER JOIN tblProducts ON prodID = siProduct
				WHERE prodRef = #val(product.productCode)#
				AND siOrder = #val(header.stockOrderID)#
				LIMIT 1;
			</cfquery>
			<cfif loc.QStockItem.recordCount gt 0>
				<cfset loc.rec.action = "stock item record found">
				<cfloop query="loc.QStockItem">
					<cfset loc.rec.siID = siID>
					<cfset loc.rec.siUnitSize = siUnitSize>
					<cfset loc.rec.siPackQty = siPackQty>
					<cfset loc.rec.siQtyPacks = siQtyPacks>
					<cfset loc.rec.siQtyItems = siQtyItems>
					<cfset loc.rec.siWSP = siWSP>
					<cfset loc.rec.siUnitTrade = siUnitTrade>
					<cfset loc.rec.siRRP = siRRP>
					<cfset loc.rec.siOurPrice = siOurPrice>
					<cfset loc.rec.siPOR = siPOR>
					<cfset loc.rec.siReceived = siReceived>
					<cfset loc.rec.siBookedIn = siBookedIn>
					<cfset loc.rec.siExpires = siExpires>
					<cfset loc.rec.siStatus = siStatus>
				</cfloop>
			<cfelse>
				<cfset loc.rec.action = "no stock item record found">
				<cfset loc.rec.siID = 0>
					<cfset loc.rec.siQtyPacks = 0>
			</cfif>
			<cfset loc.result = loc.rec>
						
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<!--- new version extracts json product array from saved page source --->
	<cffunction name="processFile4" access="public" returntype="struct" description="Extracts JSON data into an array of structs">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.count = 0>
		<cfset loc.result.totals.pricemarked = 0>
		<cfset loc.result.totals.rsp = 0>
		<cfset loc.result.totals.ambiguous = 0>
		<cfset loc.result.totals.productFound = 0>
		<cfset loc.result.totals.productMissing = 0>
		<cfset loc.parm = args>

		<cftry>
			<cfif !FileExists("#args.fileDir##args.sourcefile#")>
				<cfset loc.result.msg = "Requested file not found.">
				<cfset loc.result.file = "#args.fileDir##args.sourcefile#">
				<cfreturn loc.result>
				<cfexit>
			</cfif>
			<cfflush interval="200">
			<p>Analysing file content...</p>
			<cffile action="read" file="#args.fileDir##args.sourcefile#" variable="loc.content">
			<cfscript>			
				loc.result.header = {"supplierID"=args.supplierID,"stockOrderID"=args.stockOrderID,"markup"=args.markup,
					"validTo"=args.validTo,"orderDate"=args.orderDate,"orderRef"=args.orderRef, "srchMode"=args.srchMode, 
					"srchBarcodes"=StructKeyExists(args.form,"srchBarcodes")};	// struct to store data

				loc.regex = "products:\s*(\[.*?\])\s*\}\)";
				loc.match = REFind(loc.regex, loc.content, 1, true);
				
				if (loc.match.len[1] GT 0) {
					loc.productsJSON = Mid(loc.content, loc.match.pos[2], loc.match.len[2]);
				
					// Now it's proper JSON
					loc.products = DeserializeJSON(loc.productsJSON);
					//writedump(var="#loc.products#", label="products");

					for (loc.product in loc.products) {
						loc.count++;
						//	if (loc.count gt 90) { break; }
						loc.product.action = 'preview';
						loc.product.a_problem = 0;
						loc.product.a_status = 'unknown';
						loc.product.existing = getExistingProduct(loc.product);
						loc.result.totals.productFound += loc.product.existing.prodID gt 0;
						loc.result.totals.productMissing += loc.product.existing.prodID eq 0;
						
					//	writedump(loc.product.existing);
						loc.product.action = loc.product.existing.action;
						loc.product.catRec = getCategory(loc.product.category);
						if (loc.product.existing.prodID eq 0) {
							loc.product.category = loc.product.catRec.pcatTitle;
						}
						loc.product.ean = getBarcode(loc.product.barcode);
						loc.product.stock = CheckStockItem(loc.product,loc.result.header);
						
						loc.product.a_caseQty = Val(Trim(ListFirst(loc.product.packSize,"x")));	// get first item (qty)
						loc.product.a_unitSize = Trim(ListRest(loc.product.packSize,"x"));		// get unit size
						if (loc.product.a_caseQty eq 0) {
							loc.product.a_caseQty = 1;
						}
					//	loc.product.description = Replace(loc.product.description,"'","\'","all");
						loc.product.a_description = loc.product.description;
					//	loc.product.a_pm = (Find("PM",loc.product.description) gt 0) OR (Find("#chr(163)#",loc.product.description) gt 0) OR 
					//		(Find("\u00A3",loc.product.description) gt 0) OR (ReFind("\d+p",loc.product.description) gt 0);
						loc.product.a_pm = (ReFindNoCase("\bPMP?\b", loc.product.description) GT 0);
						if (int(loc.product.a_pm) GT loc.product.existing.prodPriceMarked) {
							loc.result.totals.ambiguous += (int(loc.product.a_pm) GT loc.product.existing.prodPriceMarked);												
						} else if (int(loc.product.a_pm eq 1)) {
							loc.result.totals.pricemarked += (int(loc.product.a_pm eq 1));
						} else if (int(loc.product.a_pm eq 0)) {
							loc.result.totals.rsp += (int(loc.product.a_pm eq 0));
						}
						loc.product.a_WSP = ReReplace(loc.product.wsp,"[^0-9.]","","all"); // remove non numerics
						loc.product.a_netUnitPrice = RoundDec(loc.product.a_WSP / loc.product.a_caseQty);
						loc.product.a_qtyInTrolley = loc.product.qtyInTrolley;
						if (loc.product.a_qtyInTrolley eq 0) {
							loc.product.a_qtyInTrolley = 1;
						}
						if (!StructKeyExists(loc.product,"rsp"))	{
							// catering item
							//writedump(loc.product);
							loc.product.a_RSP = 0;
							loc.product.a_ourPrice = 0;
							loc.product.a_vatRate = 0;
							loc.product.a_profit = 0;
							loc.product.a_POR = 0;
							loc.product.a_Markup = 0;
						} else {
	
							// cleanup description
							if (Find(loc.product.a_unitSize,loc.product.description,0)) {
								loc.product.a_description = Replace(loc.product.a_description,loc.product.a_unitSize,"");
							}
							if (Find("#chr(163)#",loc.product.a_description,1) gt 0) {	// remove price in pounds e.g. £3.49 assume price marked
								loc.product.a_description = ReReplace(loc.product.a_description,"#chr(163)#\d+\.?\d*","");
							}
							if (Find("\u00A3",loc.product.a_description,1) gt 0) {	// remove pound symbol
								loc.product.a_description = Replace(loc.product.a_description,"\u00A3","");
							}
							if (ReFind("PM[P]?\d*",loc.product.a_description) gt 0) {	// remove PM or PMP and numbers following
								loc.product.a_description = ReReplace(loc.product.a_description,"PM[P]?\d*","");
							}
							if (ReFind("\d+\.?\d*\s?g",loc.product.a_description) gt 0) {	// remove product weight
								loc.product.a_description = ReReplace(loc.product.a_description,"\d+\.?\d*\s?g","");
							}
							if (ReFind("\d+p",loc.product.a_description) gt 0) { // remove price in pence e.g. 49p assume price marked
								loc.product.a_description = ReReplace(loc.product.a_description,"\d+p","");
							}
						
							// cleanup other fields 
							loc.product.a_RSP = ReReplace(loc.product.rsp,"[^0-9.]","","all"); // remove non numerics
							if (IsNumeric(loc.product.a_RSP)) {
							} else {
								loc.product.a_RSP = 1;
							}
							loc.product.a_vatRate = ReReplace(loc.product.vat,"[^0-9.]","","all");
							loc.product.a_vatRate = loc.product.a_vatRate / 100;
	
							// calculate price
							loc.product.a_netRetailPrice = RoundDec(loc.product.a_RSP / (1 + loc.product.a_vatRate));
							loc.product.a_profit = RoundDec(loc.product.a_netRetailPrice - loc.product.a_netUnitPrice);
							loc.product.a_POR = RoundDec((loc.product.a_profit / loc.product.a_netRetailPrice) * 100);
							loc.product.a_Markup = RoundDec((loc.product.a_profit / loc.product.a_netUnitPrice) * 100);
	
							if (NOT loc.product.a_pm)	{
								if (loc.product.a_Markup lt loc.product.existing.pgTarget)	{
									loc.product.a_targetNetPrice = loc.product.a_netUnitPrice * (1 + loc.product.existing.pgTarget / 100);
									loc.product.a_profit = RoundDec(loc.product.a_targetNetPrice - loc.product.a_netUnitPrice);
									loc.product.a_POR = RoundDec((loc.product.a_profit / loc.product.a_targetNetPrice) * 100);
								} else	{
									loc.product.a_targetNetPrice = loc.product.a_netRetailPrice;
								}
								loc.product.a_ourPrice = RoundDec(loc.product.a_targetNetPrice * (1 + loc.product.a_vatRate));
	
								if (loc.product.a_ourPrice neq 0) {
									loc.product.a_priceInPence = loc.product.a_ourPrice * 100;
									loc.product.a_lastDigit = loc.product.a_priceInPence MOD 10;
									loc.product.a_basePrice = fix(loc.product.a_ourPrice * 10) / 10;
									loc.product.a_roundedPrice = (
										loc.product.a_lastDigit <= 5
										? loc.product.a_basePrice + 0.05
										: loc.product.a_basePrice + 0.09
									);
									loc.product.a_ourPrice = loc.product.a_roundedPrice;
									loc.product.a_netRetailPrice = RoundDec(loc.product.a_ourPrice / (1 + loc.product.a_vatRate));
									loc.product.a_profit = RoundDec(loc.product.a_netRetailPrice - loc.product.a_netUnitPrice);
									loc.product.a_POR = RoundDec((loc.product.a_profit / loc.product.a_netRetailPrice) * 100);
									loc.product.a_Markup = RoundDec((loc.product.a_profit / loc.product.a_netUnitPrice) * 100);
								}
							} else {
								loc.product.a_ourPrice = loc.product.a_RSP;
							}
						}
						loc.product.a_diff = RoundDec(loc.product.a_ourPrice - loc.product.a_RSP);
					};

				//	FileClose(loc.fileObj); & loc.filePath
					WriteOutput("Processed " & ArrayLen(loc.products) & " products.");
				} else {
					WriteOutput("Could not find products array in page");
				}
				loc.result.products = loc.products;
			//	writedump(loc.result.products);
			</cfscript>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<!--- output extracted data to view --->
	<cffunction name="outputData4" access="public" returntype="struct" description="output array of structs in UI">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.count = 0>
		<cfset loc.parm = args>
		<cfset loc.booker = "https://www.booker.co.uk/products/product-list">
		<cfset loc.pmClass = "pricemarked">
		<cfset loc.pmClassDiff = "">               
		<cfset loc.errors = {
			missing = 0	
		}>
		<cfset loc.barcodeList = []>
		<!--- 09/19/25,10:57:33,OB,8719200264007 --->
		<cfset loc.dateTime = "#DateFormat(Now(),'mm/dd/yyyy')#,#TimeFormat(Now(),'HH:MM:SS')#">
		<cfdump var="#args#" label="outputData4" expand="false">
		<cftry>
			<cfoutput>
				<cfif StructKeyExists(args,"msg")>
					<h1>#args.msg#</h1>
					<p>#args.file#</p>
				</cfif>
				
				<table class="dataTable" id="dataTable">
					<tr>
						<th>##</th>
						<th>Barcode / Ref</th>
						<th>Description / Category</th>
						<th>Unit Size</th>
						<th>Price&nbsp;Marked</th>
						<th>Case Qty</th>
						<th>RRP</th>
						<th>Our Price</th>
						<th>Diff</th>
						<th>Profit</th>
						<th>POR</th>
						<th>Markup</th>
						<th>ID</th>
						<th>POR</th>
						<th>Our Price</th>
						<th>Unit Trade</th>
						<th>Qty Packs</th>
						<th>Qty in Trolley</th>
						<th>WSP</th>
						<th>VAT Rate</th>
						<th>Unit Price</th>
						<th>Status</th>
						<th width="150">Info</th>
					</tr>
					<cfloop array="#args.products#" index="loc.item">
						<cfset loc.count++>
						<cfset loc.pmClass = "">
						<cfset loc.pmClassDiff = "">               
						<cfif loc.item.a_pm><cfset loc.pmClass = "pricemarked"></cfif>
						<cfif int(loc.item.a_pm) neq loc.item.existing.prodPriceMarked><cfset loc.pmClassDiff = "pricemarkdiff"></cfif>
						<cfset ArrayAppend(loc.barcodeList,"#loc.dateTime#,OB,#loc.item.ean.barcode#")>
						<tr data-id="#loc.count#">
							<td align="right">#loc.count#</td>
							<td>
								<p><a href="#loc.booker#?keywords=#loc.item.ean.barcode#" target="booker">#loc.item.ean.barcode#</a></p>
								<p>
									<cfif val(loc.item.productCode) eq 0>
										MISSING
										<cfset loc.errors.missing++>
									<cfelse>
										<a href="productStock6.cfm?product=#loc.item.existing.prodID#" 
											target="product" title="edit product & stock records manually">#loc.item.productCode#</a>
									</cfif>
								</p>
								<p>#loc.item.productCode#</p>
							</td>
							<td class="productPanel">
								<p>&nbsp;#loc.item.a_description#</p>
								<p>[#loc.item.description#]</p>
								<p>#loc.item.category#</p>
							</td>
							<td class="productPanel">#loc.item.a_unitsize#</td>
							<cfif args.header.srchMode eq 1>
								<td align="center">
									<p>Previous:#loc.item.existing.prodPriceMarked#<br>
									Found:#int(loc.item.a_pm)#</p>
									<!---<cfif int(loc.item.a_pm) gt loc.item.existing.prodPriceMarked>
										<cfset loc.marker = "warning">
										<p><span class="pm-flag" title="inconsistent price marked product."><i class="icon-img #loc.marker#"></i></span></p>
									</cfif>--->
									<cfif int(loc.item.existing.prodPriceMarked) EQ 1>
										<cfset loc.marker = "tick">
										<cfset loc.displayPM = 1>
									<cfelseif int(loc.item.a_pm) GT loc.item.existing.prodPriceMarked>
										<cfset loc.marker = "warning">
										<cfset loc.displayPM = 0>
									<cfelseif int(loc.item.a_pm) EQ 1>
										<cfset loc.marker = "tick">
										<cfset loc.displayPM = 1>
									<cfelse>
										<cfset loc.marker = "cross">
										<cfset loc.displayPM = 0>
									</cfif>
									<span class="pm-flag"
										  data-id="#loc.item.existing.prodID#"
										  data-pm="#loc.displayPM#"
										  title="click to toggle the price mark flag">
										<i class="icon-img #loc.marker#"></i>
										<!---<i class="icon-text">#loc.displayPM#</i>--->
									</span>
									<p>#loc.marker#</p>
								</td>
							<cfelse>
								<td align="center" class="#loc.pmClass# #loc.pmClassDiff#">
									<cfif val(loc.item.existing.prodPriceMarked) EQ 1>
										<cfset loc.marker = "tick">
										<cfset loc.displayPM = 1>
									<cfelseif val(loc.item.a_pm) EQ 1>
										<cfset loc.marker = "tick">
										<cfset loc.displayPM = 1>
									<cfelse>
										<cfset loc.marker = "cross">
										<cfset loc.displayPM = 0>
									</cfif>
									<span class="pm-flag"
										  data-id="#loc.item.existing.prodID#"
										  data-pm="#loc.displayPM#"
										  title="click to toggle the price mark flag">
										<i class="icon-img #loc.marker#"></i>
										<!---<i class="icon-text">#loc.displayPM#</i>--->
									</span>
								</td>
							</cfif>
							<td align="center">#loc.item.a_caseQty#</td>
							<td align="right">#loc.item.a_rsp#</td>
							<td align="right">#loc.item.a_ourPrice#</td>
							<td align="right">#loc.item.a_diff#</td>
							<td align="right">#loc.item.a_Profit#</td>
							<td align="right">#loc.item.a_POR#%</td>
							<td align="right">#loc.item.a_Markup#%</td>
							<cfif loc.item.stock.siID neq 0>
								<cfif loc.item.stock.siQtyPacks neq 0>
									<cfset loc.item.a_QtyPacks = loc.item.stock.siQtyPacks>
								<cfelse>
									<cfset loc.item.a_QtyPacks = loc.item.a_qtyInTrolley>
								</cfif>
								<td class="stockPanel">#loc.item.stock.siID#</td>
								<td class="stockPanel">#loc.item.stock.siPOR#%</td>
								<td class="stockPanel">#loc.item.stock.siOurPrice#</td>
								<td class="stockPanel">#loc.item.stock.siUnitTrade#</td>
								<td class="stockPanel">#loc.item.stock.siQtyPacks#</td>
								<td align="center" class="stockPanel">
									<input type="number" min="1" max="99" size="3" data-id="#loc.item.stock.siID#" 
										data-QtyPacks="#loc.item.a_QtyPacks#" name="QtyPacks" class="QtyPacks" 
										value="#loc.item.a_QtyPacks#" autocomplete="off">
								</td>
							<cfelse>
								<td class="stockPanel" colspan="5">#loc.item.stock.action#</td>
								<td align="center">#loc.item.a_qtyInTrolley#</td>
							</cfif>
<!---
							<cfif StructKeyExists(loc.item.stock,"siID")>
								<td align="center" class="stockPanel" class="">
									<input type="number" min="1" max="99" size="3" data-id="#loc.item.stock.siID#" 
										data-QtyPacks = "#loc.item.stock.siQtyPacks#" name="QtyPacks" class="QtyPacks" 
										value="#loc.item.stock.siQtyPacks#" autocomplete="off">
								</td>
							<cfelse>
								<td align="center">#loc.item.a_qtyInTrolley#</td>
							</cfif>
--->
							<td align="right">#loc.item.a_wsp#</td>
							<td align="right">#loc.item.vat#</td>
							<td align="right">#loc.item.a_netUnitPrice#</td>
							<td align="right">#loc.item.a_status#</td>
							<td align="right">#loc.item.action#</td>
						</tr>
					</cfloop>
				</table>
				<!---<cfdump var="#loc.errors#" label="errors" expand="true">--->
				<!---<cfdump var="#loc.barcodeList#" label="barcodeList" expand="false">--->
				<cfif args.header.srchBarcodes>
					<p>Barcode data export for importing into Booker website</p>
					<cfloop array="#loc.barcodeList#" index="loc.item">
						#loc.item#<br>
					</cfloop>
				</cfif>
			</cfoutput>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="saveData" access="public" returntype="struct" description="saves product & stock item record">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.updateCount = 0>
		<cfset loc.result.insertCount = 0>
		
		<cftry>
			<cfloop array="#args.products#" index="loc.item">
				<cfset loc.item.a_status = 'open'>
				<cfset loc.item.action = "">
				<cfif loc.item.existing.prodID gt 0>
					<!--- get existing product --->
					<cfquery name="loc.prodExists" datasource="#application.site.datasource1#">
						SELECT prodID,prodLastBought,prodMinPrice,prodPriceMarked,prodLocked
						FROM tblProducts
						WHERE prodID = #val(loc.item.existing.prodID)#
						AND prodSuppID = #val(args.header.supplierID)# 
						LIMIT 1;
					</cfquery>
					<cfset loc.item.action = "#loc.item.action# #loc.prodExists.recordcount# records found.<br>">
					<cfquery name="loc.QProductUpdate" datasource="#application.site.datasource1#">
						UPDATE tblProducts
						SET
							prodSuppID = #args.header.supplierID#,
							prodCatID = #loc.item.catrec.pcatID#,
							prodRef = '#loc.item.productCode#',
							prodRecordTitle = '#loc.item.description#',
							prodTitle = '#loc.item.a_description#',
							prodPriceMarked = #int(loc.item.a_pm)#,
							prodPackQty = #loc.item.a_caseQty#,
							prodUnitSize = '#loc.item.a_unitSize#',
							prodRRP = #loc.item.a_rsp#,
							prodOurPrice = #loc.item.a_ourPrice#,
							prodUnitTrade = #loc.item.a_netUnitPrice#,
							prodVatRate = #loc.item.a_VATRate * 100#,
							prodPackPrice = #loc.item.a_WSP#,
							prodPOR = #loc.item.a_POR#,
							prodUpdated = NOW()
						WHERE
							prodID = #val(loc.item.existing.prodID)#
					</cfquery>
					<cfset loc.result.updateCount++>
					<cfset loc.item.action = "#loc.item.action# <span class='update'>product record updated.</span><br>">
				<cfelse>
					<cfquery name="loc.QAddProduct" datasource="#application.site.datasource1#" result="loc.QAddProductResult">
						INSERT INTO tblProducts	(
							prodSuppID,
							prodCatID,
							prodRef,
							prodRecordTitle,
							prodTitle,
							prodPriceMarked,
							prodPackQty,
							prodUnitSize,
							prodRRP,
							prodOurPrice,
							prodUnitTrade,
							prodVatRate,
							prodPackPrice,
							prodPOR,
							prodUpdated
						) VALUES (
							#args.header.supplierID#,
							#loc.item.catrec.pcatID#,
							'#loc.item.productCode#',
							'#loc.item.description#',
							'#loc.item.a_description#',
							#int(loc.item.a_pm)#,
							#loc.item.a_caseQty#,
							'#loc.item.a_unitSize#',
							#loc.item.a_rsp#,
							#loc.item.a_ourPrice#,
							#loc.item.a_netUnitPrice#,
							#loc.item.a_VATRate * 100#,
							#loc.item.a_WSP#,
							#loc.item.a_POR#,
							NOW()
						)
					</cfquery>
					<cfset loc.result.insertCount++>
					<cfset loc.item.action = "#loc.item.action# <span class='insert'>product record inserted.<br></span>">
					<cfset loc.item.existing.prodID = loc.QAddProductResult.generatedkey>
				</cfif>
				
				<!--- stock item record --->
				<cfset loc.status = GetToken("open,promo",int(len(args.header.validTo) GT 0)+1,",")>
				<cfquery name="loc.stockItemExists" datasource="#application.site.datasource1#">
					SELECT siID
					FROM tblStockItem
					WHERE siOrder = #args.header.stockOrderID#
					AND siProduct = #val(loc.item.existing.prodID)#
					LIMIT 1;
				</cfquery>
				<!---<cfset loc.qtyItems = args.packQty * args.qty1>--->
				<cfif loc.stockItemExists.recordcount eq 1>
					<cfset loc.item.action = "#loc.item.action# stock record found.<br>">
					<cfset loc.item.a_stockItemID = loc.stockItemExists.siID>
					<cfquery name="loc.QUpdateStockItem" datasource="#application.site.datasource1#">
						UPDATE tblStockItem
						SET 
							siPackQty = #loc.item.a_caseQty#,
							siQtyPacks = #loc.item.qtyInTrolley#,
							siWSP = #loc.item.a_WSP#,
							siUnitTrade = #loc.item.a_netUnitPrice#,
							siRRP = #loc.item.a_rsp#,
							siOurPrice = #loc.item.a_ourPrice#,
							siPOR = #loc.item.a_POR#,
							<!---siQtyItems = #loc.qtyItems#, this is done when booking in --->
							<!---siStatus = '#loc.item.a_status#', don't change status, may already be booked in --->
							siUnitSize = '#loc.item.a_unitsize#',
							siRef = '#loc.item.productCode#'
						WHERE siID = #loc.stockItemExists.siID#
					</cfquery>
					<cfset loc.item.action = "#loc.item.action# <span class='update'>stock item updated</span><br>">
				<cfelse>
					<cfquery name="loc.QAddStockItem" datasource="#application.site.datasource1#" result="loc.QAddStockItemResult">
						INSERT INTO tblStockItem (
							siOrder,
							siProduct,
							siRef,
							siQtyPacks,
							siWSP,
							siUnitTrade,
							siRRP,
							siOurPrice,
							siPOR,
							siStatus,
							siUnitSize,
							siPackQty
						) VALUES (
							#args.header.stockOrderID#,
							#loc.item.existing.prodID#,
							'#loc.item.productCode#',
							#loc.item.qtyInTrolley#,
							#loc.item.a_WSP#,
							#loc.item.a_netUnitPrice#,
							#loc.item.a_rsp#,
							#loc.item.a_ourPrice#,
							#loc.item.a_POR#,
							'#loc.item.a_status#',
							'#loc.item.a_unitsize#',
							#loc.item.a_caseQty#
						)
					</cfquery>
					<cfset loc.item.a_stockItemID = loc.QAddStockItemResult.generatedkey>
					<cfset loc.item.action = "#loc.item.action# <span class='insert'>stock item added<br></span>">
				</cfif>
				<!--- barcode record update --->
				<cfif loc.item.ean.barProdID eq 0>
					<cfquery name="loc.QbarcodeUpdate" datasource="#application.site.datasource1#">
						UPDATE tblBarcodes
						SET barProdID = #loc.item.existing.prodID#
						WHERE barID = #loc.item.ean.barID#
						LIMIT 1;
					</cfquery>
					<cfset loc.item.action = "#loc.item.action# <span class='update'>barcode updated</span><br>">
				</cfif>
			</cfloop>
			<!--- stock order record update --->
			<cfif loc.result.insertCount neq 0 OR (loc.result.updateCount neq 0)>
				<cfquery name="loc.QstockOrderUpdate" datasource="#application.site.datasource1#">
					UPDATE tblstockOrder
					SET soItems = #loc.result.insertCount + loc.result.updateCount#
					WHERE soID = #args.header.stockOrderID#
				</cfquery>
				<cfset loc.item.action = "#loc.item.action# <span class='update'>stock order updated</span><br>">
			</cfif>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
</cfcomponent>