<cfcomponent displayname="Import" extends="code/core">

<!---
	Requires jsoup-1.8.2.jar (or later) file installed in C:\ColdFusion9\lib folder.
	Make sure ColdFusion is restarted after copying the file in.

--->

	<cffunction name="processFile" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result=[]>

		<cftry>
			<cffile action="read" file="#args.fileDir##args.sourcefile#" variable="loc.content">
			<cfscript>
				loc.jsoup = createObject("java","org.jsoup.Jsoup");
				loc.doc = loc.jsoup.parse(loc.content);
				loc.headers=loc.doc.select("h2");
				//	WriteOutput("<p>"&headers.text()&"</p>");
				for (loc.head in loc.headers) {
				//	WriteOutput("<h2>"&head.text()&"</h2>");
					loc.items=loc.head.nextElementSibling();
					if (NOT IsNull(loc.items)){
						loc.rows = loc.items.select("tr.genericListItem");
						for (loc.row in loc.rows) {
							loc.count=0;
							loc.cells=loc.row.select("td");	// get the TDs
							loc.image=loc.row.select("img"); // get product image reference
							loc.fields={"supplierID"=args.supplierID,"stockOrderID"=args.stockOrderID,"markup"=args.markup,
								"validTo"=args.validTo,"orderDate"=args.orderDate};	// struct to store data
							StructInsert(loc.fields,"barcode",loc.image.attr("alt")); // store barcode text
							loc.headText=ReReplace(loc.head.text(),"\(\d?\)","","all"); // remove counter
							loc.headText=Replace(loc.headText,"(Ret.)","","one"); // remove "(Ret.)"
							StructInsert(loc.fields,"category",loc.headText); // store header text
							for (loc.cell in loc.cells)	{ // loop cells
								loc.count++;
								loc.fld=loc.cell.text();	// get text in field
							//	WriteOutput(loc.count & ":" & fld&"<br>");
								if (FindNoCase(chr(194),loc.fld,1)) { // odd character
									loc.fld=Replace(loc.fld,chr(194),"","all"); // remove it
								}
								if (loc.count eq 3) { // description
									loc.pm=ReFind("PM\d{0,4}",loc.fld) gt 0;	// contains price mark e.g. PM159
									StructInsert(loc.fields,"PM",loc.pm);	// set the PM flag
									if (loc.pm) {
										loc.fld=ReReplace(loc.fld,"PM\d{0,4}","");	// remove PMnnn from title
									}
								}
								if (loc.count eq 4) { // qty field	e.g 12 x 100g
									loc.packQty=Trim(ListFirst(loc.fld,"x"));	// get first item (qty)
									StructInsert(loc.fields,"packQty",loc.packQty);	// add qty to struct
									loc.fld=Trim(ListRest(loc.fld,"x")); // get unit size
								}
								if (loc.count eq 5) { // WSP field
									if (Find("Now",loc.fld)) { // found price change e.g. Was: £4.99 Now: £4.69
										loc.fld=ReReplace(ListLast(loc.fld," "),"[^0-9.]","","all"); // get now price and remove £
									} else {
										loc.fld=ReReplace(loc.fld,"[^0-9.]","","all"); // remove £
									}
								}
								if (loc.count eq 6) { // RRP remove £
									loc.fld=ReReplace(loc.fld,"[^0-9.]","","all"); // remove £
								}
								if (loc.count eq 7) { // VAT Rate
									loc.fld=Replace(loc.fld,"%",""); // remove %
								}
								//	WriteOutput(fld);
								StructInsert(loc.fields,"fld#NumberFormat(loc.count,"00")#",loc.fld);	// add modified fld item to fields struct
							}
							ArrayAppend(loc.result,loc.fields); // add row data to array
						}
					}
				}
			</cfscript>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#imp-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="determineQtyFld" access="public" returntype="string">
		<cfargument name="recs" type="array" required="yes">
		<cfset var loc={}>
		<cfset loc.result={"f10"=0,"f11"=0,"f12"=0,"f13"=0}>
		<cfset loc.value=0>
		<cfset loc.field=10>
		<cfif ArrayLen(recs)>
			<cfloop array="#recs#" index="loc.item">
				<cfloop from="10" to="13" index="loc.i">
					<cfset loc.value=StructFind(loc.result,"f#loc.i#")>
					<cfset StructUpdate(loc.result,"f#loc.i#",loc.value+val(StructFind(loc.item,"fld#loc.i#")))>
				</cfloop>
			</cfloop>
			<cfset loc.value=0>
			<cfset loc.field=10>
			<cfloop from="10" to="13" index="loc.i">
				<cfif StructFind(loc.result,"f#loc.i#") GT loc.value>
					<cfset loc.value=StructFind(loc.result,"f#loc.i#")>
					<cfset loc.field=loc.i>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn "fld#loc.field#">
	</cffunction>

	<cffunction name="CheckStockOrder" access="public" returntype="struct" hint="checks existence of/or creates stock order header record">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.stockOrderID=0>
		<cfset loc.validTo="">
		<cftry>
			<cfset loc.orderDate=createdate(mid(args.orderDate,1,2),mid(args.orderDate,3,2),mid(args.orderDate,5,2))>
			<cfif len(args.validTo)>
				<cfset loc.validTo=createdate(mid(args.validTo,1,2),mid(args.validTo,3,2),mid(args.validTo,5,2))>
			</cfif>
			<cfquery name="loc.QStockOrder" datasource="#application.site.datasource1#">
				SELECT *
				FROM tblstockOrder
				WHERE soRef='#args.orderRef#'
				LIMIT 1;
			</cfquery>
			<cfif loc.QStockOrder.recordcount eq 1>
				<cfset loc.stockOrderID=loc.QStockOrder.soID>
				<cfquery name="loc.QStockOrder" datasource="#application.site.datasource1#" result="loc.QStockOrderResult">
					UPDATE tblstockOrder
					SET soScanned=#Now()#,
						<cfif len(loc.validTo)>soValidTo='#LSDateFormat(loc.validTo,"yyyy-mm-dd")#',</cfif>
						soDate='#LSDateFormat(loc.orderDate,"yyyy-mm-dd")#'
					WHERE soRef='#args.orderRef#'
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
						'#args.orderRef#',
						#loc.orderDate#,
						<cfif len(loc.validTo)>#loc.validTo#,</cfif>
						#Now()#
					)
				</cfquery>
				<cfset loc.stockOrderID=loc.QStockOrderResult.generatedKey>
			</cfif>
			<cfreturn loc>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="UpdateRecord" access="public" returntype="struct" hint="Inserts category, product, barcode and stock item if not found">
		<cfargument name="args" type="struct" required="yes">
		<cfargument name="qtyField" type="string" required="yes">

		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.result.action="">
		<cftry>
			<cfset loc.result.WSP=val(args.fld05)>	<!--- get values from extracted data --->
			<cfset loc.result.RRP=RoundDec(args.fld06)>
			<cfset loc.result.VAT=val(args.fld07)>
			<cfset loc.result.ordQty=IIf(val(StructFind(args,qtyField)) IS 0,1,val(StructFind(args,qtyField)))>
			<cfif loc.result.RRP IS 0>		<!--- not all products are priced --->
				<cfset loc.result.RRP=RoundDec((loc.result.WSP*1.43)/val(args.packQty))> <!--- so mark up to 30% POR --->
			</cfif>
			<cfset loc.result.unitTrade=loc.result.WSP/val(args.packQty)>	<!--- get trade price per item --->
			<cfset loc.result.ourPrice=loc.result.RRP>	<!--- copy RRP in case it's PM --->
			<cfif int(args.pm) IS 0>
				<!--- determine POR from given values --->
				<cfset loc.retailNet=RoundDec(loc.result.RRP/(1+(loc.result.VAT/100)))>		<!--- net unit price per item --->
				<cfset loc.totalValue=loc.retailNet*val(args.packQty)>			<!--- net retail value of pack --->
				<cfif loc.totalValue neq 0>	<!--- sanity check --->
					<cfset loc.profit=loc.totalValue-loc.result.WSP>					<!--- profit on sale of pack --->
					<cfset loc.POR=RoundDec((loc.profit/loc.totalValue)*100)>	<!--- POR % --->
					<cfif loc.POR lt 30>	<!--- POR too low? --->
						<cfset loc.unitPrice=loc.result.RRP*args.markup>	<!--- add specified markup and convert to pence --->
						<cfset loc.unitInPence=int(loc.unitPrice)>	<!--- get whole pence --->
						<cfset loc.remainder=loc.unitPrice - loc.unitInPence> <!--- get penny fraction --->
						<cfset loc.result.ourPrice=(loc.unitInPence + int(loc.remainder GT 0))/100> <!--- add extra penny if fraction gt 0 then convert to pounds/pence--->
					</cfif>
				</cfif>
			</cfif>
			<!---<cfdump var="#loc.result#" label="result" expand="true">--->
			<!--- re-evaluate POR --->
			<cfset loc.result.retailNet=RoundDec(loc.result.ourPrice/(1+(loc.result.VAT/100)))>	<!--- net unit price per item --->
			<cfset loc.result.totalValue=val(args.packQty)*loc.result.retailNet>		<!--- net retail value of pack --->
			<cfset loc.result.profit=loc.result.totalValue-loc.result.WSP>
			<cfset loc.result.POR=DecimalFormat((loc.result.profit/loc.result.totalValue)*100)>
			
			<!--- category record --->
			<cfquery name="loc.categoryExists" datasource="#application.site.datasource1#">
				SELECT pCatID
				FROM tblProductCats
				WHERE pcatTitle='#Trim(args.category)#'
				LIMIT 1;
			</cfquery>
			<cfif loc.categoryExists.recordcount eq 1>
				<cfset loc.categoryID=loc.categoryExists.pCatID>
				<cfset loc.result.action="#loc.result.action#cat found<br>">
			<cfelse>
				<cfquery name="loc.QAddCategory" datasource="#application.site.datasource1#" result="loc.QAddCategoryResult">
					INSERT INTO tblProductCats (pCatTitle) 
					VALUES ('#args.category#')
				</cfquery>
				<cfset loc.categoryID=loc.QAddCategoryResult.generatedKey>
				<cfset loc.result.action="#loc.result.action#cat added<br>">
			</cfif>
			
			<!--- product record --->
			<cfquery name="loc.prodExists" datasource="#application.site.datasource1#">
				SELECT prodID,prodLastBought,prodMinPrice
				FROM tblProducts
				WHERE prodRef='#args.fld02#'
				LIMIT 1;
			</cfquery>
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
						<cfif len(args.validTo)>prodValidTo,</cfif>
						prodUnitTrade,
						prodVatRate,
						prodPackPrice,
						prodPOR
					) VALUES (
						#args.supplierID#,
						#loc.categoryID#,
						'#args.fld02#',
						'#args.fld03#',
						'#args.fld03#',
						#int(args.pm)#,
						#args.packQty#,
						'#args.fld04#',
						#loc.result.RRP#,
						#loc.result.ourPrice#,
						<cfif len(args.validTo)>'#LSDateFormat(args.validTo,"yyyy-mm-dd")#',</cfif>
						#loc.result.unitTrade#,
						#loc.result.VAT#,
						#loc.result.WSP#,
						#loc.result.POR#
					)
				</cfquery>
				<cfset loc.productID=loc.QAddProductResult.generatedKey>
				<cfset loc.result.action="#loc.result.action#prod added<br>">
			<cfelse>
				<cfset loc.productID=loc.prodExists.prodID>
				<cfif loc.prodExists.prodMinPrice gt loc.result.ourPrice>
					<cfset loc.result.ourPrice = loc.prodExists.prodMinPrice>
				</cfif>
			</cfif>
			
			<!--- barcode record (remove leading zeroes --->
			<cfif len(args.barcode) eq 15 AND left(args.barcode,2) eq "00">
				<cfset args.barcode = mid(args.barcode,3,13)>
			</cfif>
			<cfquery name="loc.barcodeExists" datasource="#application.site.datasource1#">
				SELECT barID
				FROM tblBarcodes
				WHERE barcode='#args.barcode#'
				LIMIT 1;
			</cfquery>
			<!---#Trim(NumberFormat(args.barcode,"_____________"))#--->
			<cfif loc.barcodeExists.recordcount eq 1>
				<cfquery name="loc.QUpdateStockBarcode" datasource="#application.site.datasource1#">
					UPDATE tblBarcodes
					SET barProdID=#loc.productID#,
						barcode='#trim(args.barcode)#'
					WHERE barID=#loc.barcodeExists.barID#
				</cfquery>
				<cfset loc.result.action="#loc.result.action#barcode updated<br>">			
			<cfelse>
				<cfquery name="loc.QAddStockBarcode" datasource="#application.site.datasource1#">
					INSERT INTO tblBarcodes (barCode,barType,barProdID) 
					VALUES ('#NumberFormat(trim(args.barcode),"0000000000000")#','product',#loc.productID#)
				</cfquery>
				<cfset loc.result.action="#loc.result.action#barcode added<br>">
			</cfif>
			
			<!--- stock item record --->
			<cfset loc.status=GetToken("open,promo",int(len(args.validTo) GT 0)+1,",")>
			<cfquery name="loc.stockItemExists" datasource="#application.site.datasource1#">
				SELECT siID
				FROM tblStockItem
				WHERE siOrder=#args.stockOrderID#
				AND siProduct=#loc.productID#
				LIMIT 1;
			</cfquery>
			<cfset loc.qtyItems = args.packQty * loc.result.ordQty>
			<cfif loc.stockItemExists.recordcount eq 1>
				<cfquery name="loc.QUpdateStockItem" datasource="#application.site.datasource1#">
					UPDATE tblStockItem
					SET 
						siPackQty=#args.packQty#,
						siQtyPacks=#loc.result.ordQty#,
						siQtyItems=#loc.qtyItems#,
						siWSP=#loc.result.WSP#,
						siUnitTrade=#loc.result.unitTrade#,
						siRRP=#loc.result.RRP#,
						siOurPrice=#loc.result.ourPrice#,
						siPOR=#loc.result.POR#,
						siStatus='#loc.status#',
						siUnitSize='#args.fld04#',
						siRef='#args.fld02#'
					WHERE siID=#loc.stockItemExists.siID#
				</cfquery>
				<cfset loc.result.action="#loc.result.action#stock item updated<br>">
			<cfelse>
				<cfquery name="loc.QAddStockItem" datasource="#application.site.datasource1#">
					INSERT INTO tblStockItem (siOrder,siProduct,siQtyPacks,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siStatus,siUnitSize,siPackQty,siRef,siQtyItems) 
					VALUES (#args.stockOrderID#,#loc.productID#,#loc.result.ordQty#,#loc.result.WSP#,#loc.result.unitTrade#,
						#loc.result.RRP#,#loc.result.ourPrice#,#loc.result.POR#,'#loc.status#','#args.fld04#',#args.packQty#,'#args.fld02#',#loc.qtyItems#)
				</cfquery>
				<cfset loc.result.action="#loc.result.action#stock item added<br>">
			</cfif>
			<cfif loc.prodExists.prodLastBought LT args.orderDate>
				<cfquery name="loc.QUpdateProduct" datasource="#application.site.datasource1#" result="loc.QUpdateProductResult">
					UPDATE tblProducts
					SET
						prodCatID=#loc.categoryID#,
						prodRecordTitle='#args.fld03#',
						prodPriceMarked=#int(args.pm)#,
						prodPackQty=#args.packQty#,
						prodUnitSize='#args.fld04#',
						prodRRP=#loc.result.RRP#,
						prodOurPrice=#loc.result.ourPrice#,
						prodLastBought=#args.orderDate#,
						<cfif len(args.validTo)>prodValidTo='#LSDateFormat(args.validTo,"yyyy-mm-dd")#',</cfif>
						prodUnitTrade=#loc.result.unitTrade#,
						prodVatRate=#loc.result.VAT#,
						prodPackPrice=#loc.result.WSP#,
						prodPOR=#loc.result.POR#
					WHERE
						prodID=#loc.productID#
				</cfquery>
				<cfset loc.result.action="#loc.result.action#prod updated<br>">
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>