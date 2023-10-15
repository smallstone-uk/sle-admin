<cfcomponent displayname="Import" extends="code/core">

<!---
	Requires jsoup-1.8.2.jar (or later) file installed in C:\ColdFusion9\lib folder.
	Make sure ColdFusion is restarted after copying the file in.

--->

	<cffunction name="processFile" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cftry>
			<cffile action="read" file="#args.fileDir##args.sourcefile#" variable="loc.content">
			<cfscript>
			//	WriteOutput("<p>#args.fileDir##args.sourcefile#</p>");
				loc.jsoup = createObject("java","org.jsoup.Jsoup");
				loc.doc = loc.jsoup.parse(loc.content);
				loc.table = loc.doc.select("table").get(0); //select the first table.
				loc.rows = loc.table.select("tr");
				loc.result.header={"supplierID"=args.supplierID,"stockOrderID"=args.stockOrderID,"markup"=args.markup,
					"validTo"=args.validTo,"orderDate"=args.orderDate,"orderRef"=args.orderRef};	// struct to store data
				loc.result.basket = [];
				loc.category = "";
				loc.cell = "";
				for (loc.i = 0; loc.i < loc.rows.size(); loc.i++) {
					loc.record={};
					loc.row = loc.rows.get(loc.i);
        			loc.cols = loc.row.select("td");
					loc.qty = 0;
				//	WriteOutput(loc.i & "<br />");
					if (loc.cols.size() gt 2) {
						for (loc.j = 0; loc.j < loc.cols.size(); loc.j++) {
							loc.cell = loc.cols.get(loc.j).text();
							if (loc.j eq 0) {
								StructInsert(loc.record,"barcode",loc.cell);
							} else if (loc.j eq 1){ // product code
								StructInsert(loc.record,"code",loc.cell);
							} else if (loc.j eq 2){ // description
								loc.pm = (Find("PM",loc.cell) gt 0) OR (Find("#chr(163)#",loc.cell) gt 0);	// contains price mark e.g. PM159
								StructInsert(loc.record,"description",loc.cell);
								StructInsert(loc.record,"PM",loc.pm);	// set the PM flag
							} else if (loc.j eq 3) { // qty field	e.g 12 x 100g
								loc.packQty = Trim(ListFirst(loc.cell,"x"));	// get first item (qty)
								StructInsert(loc.record,"packQty",loc.packQty);	// add pack qty to struct
								loc.packSize = Trim(ListRest(loc.cell,"x")); // get unit size
								StructInsert(loc.record,"packSize",loc.packSize);	// add size to struct
							} else if (loc.j eq 4) { // WSP field
								if (Find("Now",loc.cell)) { // found price change e.g. Was: £4.99 Now: £4.69
									loc.WSP = ReReplace(ListLast(loc.cell," "),"[^0-9.]","","all"); // get now price and remove £
								} else {
									loc.WSP = ReReplace(loc.cell,"[^0-9.]","","all"); // remove £
								}
								StructInsert(loc.record,"WSP",loc.WSP);	// add WSP to struct
							} else if (loc.j eq 5) { // RRP remove £
								loc.retail = ReReplace(loc.cell,"[^0-9.]","","all"); // remove £
								StructInsert(loc.record,"retail",loc.retail);	// add WSP to struct
							} else if (loc.j eq 6) { // VAT Rate
								loc.vat=Replace(loc.cell,"%",""); // remove %
								StructInsert(loc.record,"vat",loc.vat);	// add VAT to struct
							} else if (loc.j eq 7) { // ordered Qty-4
									loc.qty4 = val(loc.cell);
							} else if (loc.j eq 8) { // ordered Qty-3
									loc.qty3 = val(loc.cell);
							} else if (loc.j eq 9) { // ordered Qty-2
									loc.qty2 = val(loc.cell);
							} else if (loc.j eq 10) { // ordered Qty-1
									loc.qty1 = val(loc.cell);
							} else { // other fields
								if (val(loc.cell) gt 0) {
									loc.info = val(loc.cell);
								}
							}
						//	WriteOutput(loc.j & " ["& loc.cell &"]<br />");
						}
						StructInsert(loc.record,"category",loc.category);	// add product category to record
						StructInsert(loc.record,"qty1",loc.qty1);	// add qtys found
						StructInsert(loc.record,"qty2",loc.qty2);
						StructInsert(loc.record,"qty3",loc.qty3);
						StructInsert(loc.record,"qty4",loc.qty4);
						ArrayAppend(loc.result.basket,loc.record);
						//WriteOutput("<br />");
					} else {
						loc.category = ReReplace(loc.cols.text(),"\( \d+ \)","","all");// category title
						if (len(loc.category)) 
							loc.category = Replace(loc.category,"Retail","","one"); // remove 'Retail' title
					}
				}
			</cfscript>
		<cfcatch type="any">
			An error occurred.
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#imp-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
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

	<cffunction name="UpdateRecord" access="public" returntype="struct" hint="Inserts category, product, barcode and stock item if not found">
		<cfargument name="header" type="struct" required="yes">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.result.action="">
		<cfset loc.doUpdate = true>		<!--- DO NOT USE - does not work --->

		<cftry>		
			<!--- category record --->
			<cfset loc.newCat = ReReplaceNoCase(args.category,'(Cat.)',"Catering")>		<!--- replace cat with catering --->
			<cfset loc.newCat = ReReplaceNoCase(args.category,'Retail',"")>				<!--- remove retail word --->
			<cfquery name="loc.category" datasource="#application.site.datasource1#">
				SELECT pCatID,pcatTitle,pgTarget,pgTitle
				FROM tblProductCats
				INNER JOIN tblproductgroups ON pcatGroup=pgID
				WHERE pcatTitle='#Trim(loc.newCat)#'
				LIMIT 1;
			</cfquery>
			<cfif loc.category.recordcount eq 1>
				<cfset loc.result.action = "Group: #loc.category.pgTitle#<br />
					Category: #loc.category.pcatTitle#<br />Target: #loc.category.pgTarget#%<br />">
			<cfelse>
				<cfquery name="loc.QAddCategory" datasource="#application.site.datasource1#">
					INSERT INTO tblProductCats (pCatTitle) 
					VALUES ('#Trim(loc.newCat)#')
				</cfquery>
				<cfquery name="loc.category" datasource="#application.site.datasource1#">
					SELECT pCatID,pcatTitle,pgTarget,pgTitle
					FROM tblProductCats
					INNER JOIN tblproductgroups ON pcatGroup=pgID
					WHERE pcatTitle='#Trim(loc.newCat)#'
					LIMIT 1;
				</cfquery>
				<cfset loc.result.action = "#loc.result.action#Category added<br />">
			</cfif>
			<cfset loc.categoryID = loc.category.pCatID>
			<cfset loc.target = val(loc.category.pgTarget)>
			<cfif loc.target IS 0><cfset loc.target = 43></cfif>
			
			<!--- get existing product if any --->
			<cfset loc.result.prevPM = false>
			<cfquery name="loc.prodExists" datasource="#application.site.datasource1#">
				SELECT prodID,prodLastBought,prodMinPrice,prodPriceMarked,prodLocked
				FROM tblProducts
				WHERE prodRef='#args.code#'
				LIMIT 1;
			</cfquery>
			<cfif loc.prodExists.recordcount gt 0>
				<cfset loc.result.prevPM = loc.prodExists.prodPriceMarked>
				<cfif loc.prodExists.prodPriceMarked>
					<cfset args.pm = true>
				</cfif>
			</cfif>
			
			<!--- sanitize data --->
			<cfset args.packQty = Iif(val(args.packQty) eq 0,1,val(args.packQty))>
			<cfif Find(args.packsize,args.description,0)>
				<cfset args.description = Replace(args.description,args.packsize,"")>
			</cfif>
			<cfif Find("RRP",args.description,0)>	<!--- remove RRP --->
				<cfset args.description = Replace(args.description,"RRP","")>
			</cfif>
			<cfif Find("#chr(163)#",args.description,1) gt 0>	<!--- remove price in pounds e.g. £3.49 assume price marked --->
				<cfset args.description = ReReplace(args.description,"#chr(163)#\d+\.?\d*","")>
				<cfset args.pm = true>
			</cfif>
			<cfif ReFind("\d+p",args.description) gt 0>	<!--- remove price in pence e.g. 49p assume price marked --->
				<cfset args.description = ReReplace(args.description,"\d+p","")>
				<cfset args.pm = true>
			</cfif>
			<cfif ReFind("PM[P]?\d*",args.description) gt 0>	<!--- remove PM or PMP and numbers following --->
				<cfset args.description = ReReplace(args.description,"PM[P]?\d*","")>
				<cfset args.pm = true>
			</cfif>
			<cfif ReFind("\d+ x ",args.description) gt 0>	<!--- remove case qty --->
				<cfset args.description = ReReplace(args.description,"\d+ x ","")>
			</cfif>
			<cfif ReFind("\d+\.?\d*\s?g",args.description) gt 0>	<!--- remove pack weight --->
				<cfset args.description = ReReplace(args.description,"\d+\.?\d*\s?g","")>
			</cfif>
			<cfif ReFind("\(\)",args.description) gt 0>	<!--- remove empty brackets --->
				<cfset args.description = ReReplace(args.description,"\(\)","")>
			</cfif>
			<cfif FindNoCase("Happy Shopper",args.description) gt 0>	<!--- remove long text --->
				<cfset args.description = ReplaceNoCase(args.description,"Happy Shopper","HS")>
			</cfif>
			<cfif FindNoCase("Euro Shopper",args.description) gt 0>	<!--- remove long text --->
				<cfset args.description = ReplaceNoCase(args.description,"Euro Shopper","ES")>
			</cfif>
			<cfif FindNoCase("Cadbury Dairy Milk",args.description) gt 0>	<!--- remove long text --->
				<cfset args.description = ReplaceNoCase(args.description,"Cadbury Dairy Milk","CDM")>
			</cfif>
			<cfif FindNoCase("Discover The Choice",args.description) gt 0>	<!--- remove long text --->
				<cfset args.description = ReplaceNoCase(args.description,"Discover The Choice","DTC")>
			</cfif>
			<cfif FindNoCase("Delicatessen Fine Eating",args.description) gt 0>	<!--- remove long text --->
				<cfset args.description = ReplaceNoCase(args.description,"Delicatessen Fine Eating","DFE")>
			</cfif>
			<!--- calculate price --->
			<cfset loc.result.netUnitPrice = RoundDec(args.WSP / val(args.packQty))>
			<cfset loc.result.grossUnitPrice = RoundDec(loc.result.netUnitPrice * (1 + args.VAT / 100))>
			<cfset loc.netRetailPrice = RoundDec(loc.result.netUnitPrice * (1 + loc.target / 100))>
			<cfset loc.grossRetailPrice = RoundDec(loc.netRetailPrice * (1 + args.VAT / 100))>
			<cfset loc.result.profit = loc.netRetailPrice - loc.result.netUnitPrice>
			<tr>
				<td colspan="16">
                	<cfdump var="#loc#" expand="no" label="#args.description#">
                </td>
            </tr>
			<cfif args.pm OR (loc.grossRetailPrice - args.retail) lt 0.03>	<!--- if our price < retail --->
				<cfset loc.grossRetailPrice = args.retail>
				<cfset loc.netRetailPrice = RoundDec(loc.grossRetailPrice / (1 + args.VAT / 100))>
			</cfif>
			<cfset loc.result.retail = args.retail>
			<cfset loc.result.ourPrice = loc.grossRetailPrice>
			<cfset loc.result.netTotalValue = loc.netRetailPrice * args.packQty>
			<cfset loc.result.POR = RoundDec((loc.result.profit / loc.netRetailPrice) * 100)>

			<cfset loc.result.class = "ourPrice">
			<cfset loc.result.classQty = "">
			<cfif loc.result.ourPrice neq args.retail><cfset loc.result.class = "different"></cfif>
			<cfset loc.lastDigit = (loc.result.ourPrice * 100) MOD 10>
			<cfif loc.lastDigit neq 0>
				<cfif loc.lastDigit lt 6>
					<cfset loc.lastDigit = 5>
				<cfelse>
					<cfset loc.lastDigit = 9>
				</cfif>
				<cfset loc.result.ourPrice = (int(loc.result.ourPrice * 10) * 10 + loc.lastDigit) / 100>
			</cfif>
			<cfset loc.result.profit = loc.result.ourPrice - loc.result.grossUnitPrice>
			<cfset loc.result.POR = RoundDec((loc.result.profit / loc.result.ourPrice) * 100)>

			<!--- product record --->
			<cfif NOT loc.doUpdate>
				<cfdump var="#loc#" label="#args.description#" expand="false">
			<cfelse>
				<cfif loc.prodExists.recordcount eq 0>
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
							<cfif len(header.validTo)>prodValidTo,</cfif>
							prodUnitTrade,
							prodVatRate,
							prodPackPrice,
							prodPOR
						) VALUES (
							#header.supplierID#,
							#loc.categoryID#,
							'#args.code#',
							'#args.description#',
							'#Left(args.description,40)#',
							#int(args.pm)#,
							#args.packQty#,
							'#args.packsize#',
							#args.retail#,
							#loc.result.ourPrice#,
							<cfif len(header.validTo)>'#LSDateFormat(header.validTo,"yyyy-mm-dd")#',</cfif>
							#loc.result.netUnitPrice#,
							#args.VAT#,
							#args.WSP#,
							#loc.result.POR#
						)
					</cfquery>
					<cfset loc.result.productID = loc.QAddProductResult.generatedKey>
					<cfset loc.result.action = "#loc.result.action#product added<br>">
				<cfelse>
					<cfset loc.result.productID = loc.prodExists.prodID>
					<cfif loc.prodExists.prodMinPrice gt loc.result.ourPrice>
						<cfset loc.result.ourPrice = loc.prodExists.prodMinPrice>
					</cfif>
					<cfif loc.prodExists.prodLocked eq 0>
						<cfquery name="loc.QUpdateProduct" datasource="#application.site.datasource1#">
							UPDATE tblProducts
							SET prodPriceMarked = #int(args.pm)#,
								prodOurPrice = #loc.result.ourPrice#,
								prodRecordTitle = '#args.description#',
								prodTitle = '#Left(args.description,40)#'
							WHERE prodID = #loc.result.productID#
						</cfquery>
						<cfset loc.result.action = "#loc.result.action#Product Update 1<br>">
					<cfelse>
						<cfset loc.result.action = "#loc.result.action#Product UNCHANGED<br>">				
					</cfif>
				</cfif>
			
				<!--- barcode record (remove leading zeroes --->
				<cfset loc.result.barcode = "">
				<cfif len(args.barcode) eq 15 AND left(args.barcode,2) eq "00">
					<cfset args.barcode = mid(args.barcode,3,13)>
				</cfif>
				<cfif len(args.barcode)>
					<cfset loc.result.barcode = NumberFormat(trim(args.barcode),"0000000000000")>
					<cfquery name="loc.barcodeExists" datasource="#application.site.datasource1#">
						SELECT barID
						FROM tblBarcodes
						WHERE barcode = '#loc.result.barcode#'
						LIMIT 1;
					</cfquery>
					<!---#Trim(NumberFormat(loc.result.barcode,"_____________"))#--->
					<cfif loc.barcodeExists.recordcount eq 1>
						<cfquery name="loc.QUpdateStockBarcode" datasource="#application.site.datasource1#">
							UPDATE tblBarcodes
							SET barProdID=#loc.result.productID#,
								barcode='#loc.result.barcode#'
							WHERE barID=#loc.barcodeExists.barID#
						</cfquery>
						<cfset loc.result.action="#loc.result.action#barcode updated<br>">			
					<cfelse>
						<cfquery name="loc.QAddStockBarcode" datasource="#application.site.datasource1#">
							INSERT INTO tblBarcodes (barCode,barType,barProdID) 
							VALUES ('#loc.result.barcode#','product',#loc.result.productID#)
						</cfquery>
						<cfset loc.result.action="#loc.result.action#barcode added<br>">
					</cfif>
				<cfelse>
					<cfset loc.result.action="#loc.result.action#NO BARCODE<br>">				
				</cfif>
				
				<cfset loc.result.days = -1>
				<cfset loc.result.lastQty = 0>
				<cfset loc.result.qty1 = args.qty1>
				<cfif args.qty1 gt 1>	<!--- get most recent stock item --->
					<cfset loc.result.classQty = "more">
					<cfquery name="loc.QProduct" datasource="#application.site.datasource1#">
						SELECT 	prodID,prodRef,prodTitle,prodLastBought,prodPriceMarked,prodVATRate,prodStatus,
								siID,siUnitSize,siPackQty,siQtyPacks,siQtyItems,siOurPrice,siReceived,siBookedIn,siStatus,
                                soDate,soRef
						FROM tblProducts
						LEFT JOIN tblStockItem ON prodID = siProduct
                        INNER JOIN tblstockorder ON soID = siOrder
						AND tblStockItem.siID = (
							SELECT MAX(siID)
							FROM tblStockItem
                            INNER JOIN tblstockorder so ON soID = siOrder
							WHERE prodID = siProduct
                            AND so.soRef != '#header.orderRef#'
							AND so.soDate < '#LSDateFormat(header.orderDate,"yyyy-mm-dd")#'
                        )
						WHERE prodRef='#args.code#'
						LIMIT 1;
					</cfquery>
					<cfset loc.result.QProduct = loc.QProduct>
					<cfif IsDate(loc.QProduct.soDate)>
						<cfset loc.result.days = DateDiff("d",loc.QProduct.soDate,header.orderDate)>
					</cfif>
					<cfif loc.result.days lt 8>
						<cfset loc.result.lastQty = val(loc.QProduct.siQtyPacks)>
						<cfset loc.result.qty1 = args.qty1 - loc.result.lastQty>
						<cfset loc.result.qty1 = Iif(loc.result.qty1 lte 0,1,loc.result.qty1)>
						<cfset loc.result.classQty = "changed">
					</cfif>
					<cfif loc.result.qty1 lte 0>
						<cfset loc.result.qty1 = 1>
						<cfset loc.result.classQty = "changed">
					</cfif>
					<!---<cfdump var="#loc#" label="qty #loc.QProduct.prodTitle#" expand="yes" format="html" 
						output="#application.site.dir_logs#qty-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
					<cfdump var="#header#" label="qtyh #loc.QProduct.prodTitle#" expand="yes" format="html" 
						output="#application.site.dir_logs#qtyh-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">--->
				</cfif>
				
				<!--- stock item record --->
				<cfset loc.status=GetToken("open,promo",int(len(header.validTo) GT 0)+1,",")>
				<cfquery name="loc.stockItemExists" datasource="#application.site.datasource1#">
					SELECT siID
					FROM tblStockItem
					WHERE siOrder=#header.stockOrderID#
					AND siProduct=#loc.result.productID#
					LIMIT 1;
				</cfquery>
				<!---<cfset loc.qtyItems = args.packQty * args.qty1>--->
				<cfif loc.stockItemExists.recordcount eq 1>
					<cfquery name="loc.QUpdateStockItem" datasource="#application.site.datasource1#">
						UPDATE tblStockItem
						SET 
							siPackQty=#args.packQty#,
							siQtyPacks=#loc.result.qty1#,
							<!---siQtyItems=#loc.qtyItems#, this is done when booking in --->
							siWSP=#args.WSP#,
							siUnitTrade=#loc.result.netUnitPrice#,
							siRRP=#loc.result.retail#,
							siOurPrice=#loc.result.ourPrice#,
							siPOR=#loc.result.POR#,
						<!---	siStatus='#loc.status#', don't change status, may already be booked in --->
							siUnitSize='#args.packsize#',
							siRef='#args.code#'
						WHERE siID=#loc.stockItemExists.siID#
					</cfquery>
					<cfset loc.result.action="#loc.result.action#stock item updated<br>">
				<cfelse>
					<cfquery name="loc.QAddStockItem" datasource="#application.site.datasource1#">
						INSERT INTO tblStockItem (siOrder,siProduct,siQtyPacks,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siStatus,siUnitSize,siPackQty,siRef) 
						VALUES (#header.stockOrderID#,#loc.result.productID#,#loc.result.qty1#,#args.WSP#,#loc.result.netUnitPrice#,
							#loc.result.retail#,#loc.result.ourPrice#,#loc.result.POR#,'#loc.status#','#args.packsize#',#args.packQty#,'#args.code#')
					</cfquery>
					<cfset loc.result.action="#loc.result.action#stock item added<br>">
				</cfif>
				<!---<cfset loc.result.action="#loc.result.action##loc.prodExists.prodLastBought# LTE #header.orderDate# AND NOT #loc.prodExists.prodLocked#<br>">--->
				<cfif loc.prodExists.prodLastBought LTE header.orderDate AND NOT loc.prodExists.prodLocked>
					<cfquery name="loc.QUpdateProduct" datasource="#application.site.datasource1#" result="loc.QUpdateProductResult">
						UPDATE tblProducts
						SET
							prodCatID=#loc.categoryID#,
							prodRecordTitle='#args.description#',
							<!---prodPriceMarked=#int(args.pm)#,	LEAVE FLAG ALONE UNTIL BUG IS FIXED 24/01/21 --->
							prodPackQty=#args.packQty#,
							prodUnitSize='#args.packSize#',
							prodRRP=#loc.result.retail#,
							prodOurPrice=#loc.result.ourPrice#,
							prodLastBought=#header.orderDate#,
							<cfif len(header.validTo)>prodValidTo='#LSDateFormat(header.validTo,"yyyy-mm-dd")#',</cfif>
							prodUnitTrade=#loc.result.netUnitPrice#,
							prodVatRate=#args.VAT#,
							prodPackPrice=#args.WSP#,
							prodPOR=#loc.result.POR#
						WHERE
							prodID=#loc.result.productID#
					</cfquery>
					<cfset loc.result.action="#loc.result.action#Product update 2<br>">
				</cfif>

			</cfif>
				
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>