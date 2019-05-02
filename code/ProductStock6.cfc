<cfcomponent displayname="productstock" extends="core">

	<cffunction name="FindProduct" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.productID = 0>
		<cfset loc.result.action = "nothing">
		<cfset loc.result.barcode = "">
		<cfset loc.result.msg = "">
		<cfset loc.result.msgs = []>
		
		<cftry>
			<cfif StructKeyExists(args.form,"barcode") AND LEN(args.form.barcode)>	<!--- barcode supplied --->
				<cfset loc.result.barcode = NumberFormat(Left(args.form.barcode,15),"0000000000000")>
				<cfquery name="loc.QBarcode" datasource="#args.datasource#">
					SELECT *
					FROM tblBarcodes
					WHERE barCode LIKE '%#loc.result.barcode#%'
					LIMIT 1;
				</cfquery>
				<cfif loc.QBarcode.recordCount IS 1>
					<cfset loc.result.productID = loc.QBarcode.barProdID>
					<cfif loc.QBarcode.barType neq args.form.source>
						<cfset loc.result.msg = "Invalid barcode - that is a #loc.QBarcode.barType# barcode.">
						<cfset loc.result.action = "Clear">
					</cfif>
				<cfelse>
					<cfset loc.result.msg = "Barcode not found">
					<cfset loc.result.action = "Add">
				</cfif>
			<cfelseif StructKeyExists(args.form,"productID") AND args.form.productID gt 0>	<!--- product ID supplied --->
				<cfset loc.result.productID = val(args.form.productID)>
				<cfquery name="loc.QBarcode" datasource="#args.datasource#">
					SELECT *
					FROM tblBarcodes
					WHERE barProdID = #loc.result.productID#
					ORDER BY barID DESC
					LIMIT 1;
				</cfquery>
				<cfif loc.QBarcode.recordCount IS 1>
					<cfset loc.result.barcode = loc.QBarcode.barcode>
					<cfif loc.QBarcode.barType neq args.form.source>
						<cfset loc.result.msg = "Invalid barcode - that is a #loc.QBarcode.barType# barcode.">
						<cfset loc.result.action = "Clear">
					</cfif>
				<cfelse>
					<cfset loc.result.msg = "This product has no barcode">
				</cfif>
			<cfelseif LEN(args.form.barcode) eq 0 AND args.form.productID eq 0>
				<cfset loc.result.msg = "To add a new product without a barcode, click Add Product.">
				<cfset loc.result.action = "New">				
			<cfelse>
				<cfset loc.result.msg = "Invalid information supplied">
				<cfset loc.result.action = "Clear">				
			</cfif>
			<cfset ArrayAppend(loc.result.msgs,loc.result.msg)>
			<cfif loc.result.productID>
				<cfquery name="loc.QProduct" datasource="#args.datasource#">
					SELECT prodID,prodStaffDiscount,prodRef,prodRecordTitle,prodTitle,prodCountDate,prodStockLevel,prodLastBought,prodStaffDiscount,prodMinPrice,
							prodPackPrice,prodOurPrice,prodValidTo,prodPriceMarked,prodCatID,prodEposCatID,prodVATRate,
							siID,siRef,siOrder,siUnitSize,siPackQty,siQtyPacks,siQtyItems,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siReceived,siBookedIn,siExpires,siStatus
					FROM tblProducts
					LEFT JOIN tblStockItem ON prodID = siProduct
					AND tblStockItem.siID = (
						SELECT MAX( siID )
						FROM tblStockItem
						WHERE prodID = siProduct
						AND siStatus NOT IN ("returned","inactive") )
					WHERE prodID=#val(loc.result.productID)#
					LIMIT 1;
				</cfquery>
				<!---<cf_dumptofile var="#loc#">--->
				<cfif loc.QProduct.recordCount IS 0>
					<cfset loc.result.msg = "Barcode found but not the product record.">
					<cfset loc.result.action = "Add">
				<cfelse>
					<cfset loc.result.msg = "Product found">
					<cfset loc.result.action = "Found">
					<cfloop query="loc.QProduct">
						<cfset loc.rec = {}>
						<cfset loc.rec.prodID = prodID>
						<cfset loc.rec.prodRef = prodRef>
						<cfset loc.rec.prodStaffDiscount = prodStaffDiscount>
						<cfset loc.rec.prodRecordTitle = prodRecordTitle>
						<cfset loc.rec.prodLastBought = LSDateFormat(prodLastBought,"dd-mmm-yyyy")>
						<cfset loc.rec.prodTitle = prodTitle>
						<cfset loc.rec.prodCountDate = LSDateFormat(prodCountDate,"dd-mmm-yyyy")>
						<cfset loc.rec.prodStockLevel = prodStockLevel> <!--- + int(prodStockLevel eq 0)	add 1 if zero --->
						<cfset loc.rec.prodCatID = prodCatID>
						<cfset loc.rec.prodEposCatID = prodEposCatID>
						<cfset loc.rec.prodPriceMarked = prodPriceMarked>
						<cfset loc.rec.prodVATRate = prodVATRate>
						<cfset loc.rec.prodStaffDiscount = prodStaffDiscount>
						<cfset loc.rec.PriceMarked = GetToken(" |PM",prodPriceMarked+1,"|")>
						<cfset loc.rec.prodMinPrice = prodMinPrice>
						<cfset loc.rec.prodOurPrice = prodOurPrice>
						
						<cfset loc.stockItem = {}>
						<cfset loc.stockItem.siID = siID>
						<cfset loc.stockItem.siRef = siRef>
						<cfset loc.stockItem.siUnitSize = siUnitSize>
						<cfset loc.stockItem.siPackQty = siPackQty>
						<cfset loc.stockItem.siQtyPacks = siQtyPacks>
						<cfset loc.stockItem.siQtyItems = siQtyItems>
						<cfset loc.stockItem.siWSP = siWSP>
						<cfset loc.stockItem.siUnitTrade = siUnitTrade>
						<cfset loc.stockItem.siRRP = siRRP>
						<cfset loc.stockItem.siOurPrice = siOurPrice>
						<cfset loc.stockItem.siPOR = siPOR>
						<cfset loc.stockItem.siReceived = siReceived>
						<cfset loc.stockItem.siBookedIn = LSDateFormat(siBookedIn)>
						<cfset loc.stockItem.siExpires = siExpires>
						<cfset loc.stockItem.siStatus = siStatus>						 	 	 	 	 	 	 	 	 	 	 	 	 
					</cfloop>
					<cfset loc.result.product = loc.rec>
					<cfset loc.result.stockItem = loc.stockItem>
					<cfset loc.result.supplier = "Unknown">
					<cfif val(loc.QProduct.siOrder) gt 0>
						<cfquery name="loc.StockOrder" datasource="#args.datasource#">
							SELECT tblStockOrder.*, accID,accName
							FROM tblStockOrder
							INNER JOIN tblAccount ON accID = soAccountID
							WHERE soID=#loc.QProduct.siOrder#
							LIMIT 1
						</cfquery>
						<cfif loc.StockOrder.recordcount eq 1>
							<cfset loc.result.supplier = loc.StockOrder.accName>
							<cfset loc.result.ordered = LSDateFormat(loc.StockOrder.soDate)>
						</cfif>
					</cfif>
					<cfquery name="loc.result.OtherBarcodes" datasource="#args.datasource#">
						SELECT barID,barcode
						FROM tblBarcodes
						WHERE barProdID = #val(loc.result.productID)#
						AND barType = 'product'
					</cfquery>
					<cfquery name="loc.CategoryGroup" datasource="#args.datasource#">
						SELECT pcatID,pgID,pcatTitle,pgTitle,pgTarget
						FROM tblProductCats
						INNER JOIN tblProductGroups ON pgID=pcatGroup
						WHERE pcatID=#loc.rec.prodCatID#
					</cfquery>
					<cfif loc.CategoryGroup.recordcount eq 1>
						<cfset loc.result.catID=loc.CategoryGroup.pcatID>
						<cfset loc.result.catTitle=loc.CategoryGroup.pcatTitle>
						<cfset loc.result.groupID=loc.CategoryGroup.pgID>
						<cfset loc.result.groupTitle=loc.CategoryGroup.pgTitle>
						<cfset loc.result.pgTarget=loc.CategoryGroup.pgTarget>
					</cfif>
				</cfif>
			</cfif>
			<cfquery name="loc.result.groups" datasource="#args.datasource#">
				SELECT *
				FROM tblProductGroups
				ORDER BY pgTitle
			</cfquery>
			<cfset ArrayAppend(loc.result.msgs,loc.result.msg)>
		
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="AddBarcode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.newCode = NumberFormat(Left(args.form.newCode,15),"0000000000000")>
		<cftry>
			<cfquery name="loc.QBarcode" datasource="#args.datasource#">
				SELECT *
				FROM tblBarcodes
				WHERE barCode LIKE '#loc.newCode#'
				AND barType = '#args.form.newType#'
				LIMIT 1;
			</cfquery>
			<cfif loc.QBarcode.recordcount eq 1>
				<cfset loc.result.msg = "#args.form.newCode# already exists">
			<cfelse>
				<cfquery name="loc.QBarcodeAdd" datasource="#args.datasource#" result="loc.QAddResult">
					INSERT INTO tblBarcodes
					(barCode,barType,barProdID)
					VALUES('#loc.newCode#','#args.form.newType#',#args.form.prodID#)
				</cfquery>
				<cfset loc.result.msg = "Barcode added: #loc.newCode#. ID: #loc.QAddResult.generatedkey#">
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="DeleteBarcode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.msg = "">
		<cftry>
			<cfquery name="loc.QBarcode" datasource="#args.datasource#">
				DELETE FROM tblBarcodes
				WHERE barID=#val(args.form.barID)#
			</cfquery>
			<cfset loc.result.msg = "Deleted barcode record: #args.form.barID#">
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadStockFromList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cfquery name="loc.stockItems" datasource="#args.datasource#" result="loc.stockResult">
			SELECT prodID,prodStaffDiscount,prodRef,prodRecordTitle,prodTitle,prodCountDate,prodStockLevel,prodLastBought,prodStaffDiscount
					prodPackPrice,prodOurPrice,prodValidTo,prodPriceMarked,prodCatID,prodVATRate,
					siID,siRef,siOrder,siUnitSize,siPackQty,siQtyPacks,siQtyItems,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siReceived,siBookedIn,siExpires,siStatus,
					barcode,soDate
			FROM tblProducts
			LEFT JOIN tblStockItem ON prodID = siProduct
			INNER JOIN tblStockOrder ON soID = siOrder
			AND tblStockItem.siID = (
				SELECT MAX( siID )
				FROM tblStockItem
				WHERE prodID = siProduct
				AND siStatus NOT IN ("returned","inactive")  )
			LEFT JOIN tblBarcodes ON prodID = barProdID
			AND tblBarcodes.barID = (
				SELECT MAX(barID)
				FROM tblBarcodes
				WHERE prodID = barProdID )
			WHERE prodID IN (#args.stockList#)
			ORDER BY prodCatID, prodTitle
		</cfquery>		
		<cfset loc.result.recordcount = loc.stockItems.recordcount>
		<cfset loc.result.stockItems = loc.stockItems>
		
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

	<cffunction name="AddProduct" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QAddProduct" datasource="#args.datasource#" result="loc.QAddProductResult">
				INSERT INTO tblProducts (
					prodRecordTitle,
					prodTitle,
					prodCatID,
					prodPriceMarked,
					prodMinPrice,
					prodOurPrice,
					prodVATRate,
					prodEposCatID
				) VALUES (
					'#args.form.prodRecordTitle#',
					'#args.form.prodTitle#',
					#val(args.form.prodCatID)#,
					#int(StructKeyExists(args.form,"prodPriceMarked"))#,
					#val(args.form.prodMinPrice)#,
					#val(args.form.prodOurPrice)#,
					#args.form.prodVATRate#,
					#val(args.form.prodEposCatID)#
				)
			</cfquery>
			<cfset loc.result.productID = loc.QAddProductResult.generatedkey>
			<cfset loc.result.barcode = Trim(args.form.barcode)>
			<cfif len(loc.result.barcode)>
				<cfquery name="loc.QBarcode" datasource="#args.datasource#" result="loc.result.QBarcodeResult">
					SELECT *
					FROM tblBarcodes
					WHERE barCode LIKE '%#loc.result.barcode#%'
					AND barType = 'product'
					LIMIT 1;
				</cfquery>
				<cfif loc.QBarcode.recordcount eq 1>
					<cfquery name="loc.QUpdateBarcode" datasource="#args.datasource#" result="loc.result.QBarcodeResult">
						UPDATE tblBarcodes
						SET barProdID = #loc.result.productID#
						WHERE barID = #loc.QBarcode.barID#
					</cfquery>
				<cfelse>
					<cfquery name="loc.QAddBarCode" datasource="#args.datasource#" result="loc.QAddBarcodeResult">
						INSERT INTO tblBarcodes (
							barCode,
							barType,
							barProdID
						) VALUES (
							'#NumberFormat(loc.result.barcode,"0000000000000")#',
							'product',
							#loc.result.productID#
						)
					</cfquery>
					<cfset loc.result.BarcodeID = loc.QAddBarcodeResult.generatedkey>
				</cfif>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="AmendProduct" access="public" returntype="string">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.resultStr = "An error occurred updating the record.">
		<cftry>
			<cfquery name="loc.QUpdate" datasource="#args.datasource#">
				UPDATE tblProducts
				SET prodRecordTitle= '#args.form.prodRecordTitle#',
					prodTitle= '#args.form.prodTitle#',
					prodCatID = #val(args.form.prodCatID)#,
					prodPriceMarked = #int(StructKeyExists(args.form,"prodPriceMarked"))#,
					prodMinPrice = #val(args.form.prodMinPrice)#,
					prodOurPrice = #val(args.form.prodOurPrice)#,
					prodCountDate = <cfif len(args.form.prodCountDate)>'#LSDateFormat(args.form.prodCountDate,"yyyy-mm-dd")#',<cfelse>null,</cfif>
					prodStockLevel = #val(args.form.prodStockLevel)#,
					prodVATRate = #args.form.prodVATRate#,
					prodEposCatID = #val(args.form.prodEposCatID)#
				WHERE prodID = #val(args.form.prodID)#
			</cfquery>
			<cfset loc.resultStr = "Product Updated.">
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>

		<cfreturn loc.resultStr>
	</cffunction>

	<cffunction name="AddStockItem" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.args = args>

		<cftry>
			<!--- locate manual order for specified date --->
			<cfquery name="loc.QFindOrder" datasource="#args.datasource#">
				SELECT * FROM tblStockOrder
				WHERE soDate = '#args.form.soDate#'
				AND soScanned IS NULL
				AND soAccountID = #args.form.accID#
			</cfquery>
			<cfif loc.QFindOrder.recordCount IS 0>
				<cfquery name="loc.QInsertOrder" datasource="#args.datasource#" result="loc.QInsertOrderResult">
					INSERT INTO tblStockOrder (
						soAccountID,soRef,soDate,soStatus
					) VALUES (
						#args.form.accID#,'#DateFormat(args.form.soDate,"yyyymmdd")#','#args.form.soDate#','closed'
					)
				</cfquery>
				<cfset loc.orderID = loc.QInsertOrderResult.generatedkey>
			<cfelse>
				<cfset loc.orderID = loc.QFindOrder.soID>
			</cfif>
				
			<cfset loc.vrate = args.form.prodVATRate / 100>
			<cfset loc.result.items = args.form.siPackQty * siQtyPacks>
			<cfset loc.result.totalTrade = val(args.form.siQtyPacks) * val(args.form.siWSP)>
			<cfset loc.result.unitNetTrade = val(args.form.siWSP) / args.form.siPackQty>
			<cfset loc.result.unitNetRetail = int(args.form.siOurPrice * 100 / (1 + loc.vrate)) / 100>
			<cfset loc.result.wspGross = loc.result.totalTrade * (1 + loc.vrate)>
			<cfset loc.result.totalRetail = loc.result.items * args.form.siOurPrice>
			<cfset loc.result.profit = loc.result.totalRetail - loc.result.wspGross>
			<cfset loc.result.POR = (loc.result.profit / loc.result.totalRetail) * 100>
			<cfif loc.result.items neq 0>
				<cfquery name="loc.QAddStockItem" datasource="#args.datasource#">
					INSERT INTO tblStockItem (
						siOrder,siProduct,siRef,siPackQty,siQtyPacks,siQtyItems,siWSP,siUnitTrade,siUnitSize,siRRP,siOurPrice,siPOR,siReceived,siBookedIn,siExpires,siStatus
					) VALUES (
						#loc.orderID#,
						#args.form.productID#,
						'#args.form.siRef#',
						#val(args.form.siPackQty)#,
						#val(args.form.siQtyPacks)#,
						#val(loc.result.items)#,
						#args.form.siWSP#,
						#loc.result.unitNetTrade#,
						'#args.form.siUnitSize#',
						#args.form.siRRP#,
						#args.form.siOurPrice#,
						#loc.result.POR#,
						#val(loc.result.items)#,
						<cfif len(args.form.soDate)>'#args.form.soDate#',<cfelse>null,</cfif>
						<cfif len(args.form.siExpires)>'#args.form.siExpires#',<cfelse>null,</cfif>
						'closed'
					)	
				</cfquery>

				<cfquery name="loc.QGetProduct" datasource="#args.datasource#">
					SELECT prodLastBought 
					FROM tblProducts
					WHERE prodID = #args.form.productID#
				</cfquery>
				<cfif args.form.soDate gt loc.QGetProduct.prodLastBought>
					<cfquery name="loc.QUpdateProduct" datasource="#args.datasource#">
						UPDATE tblProducts
						SET prodLastBought = '#args.form.soDate#'
						WHERE prodID = #args.form.productID#
					</cfquery>
				</cfif>	
				<cfset loc.result.msg = "Stock item added.">
				<cfset loc.result.barcode = args.form.barcode>
			<cfelse>
				<cfset loc.result.msg = "Stock quantity received was zero.">
			</cfif>
			
		<cfcatch type="any">
			<cfset loc.result.msg = "An error occurred adding this stock item.">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="SaveStockItem" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">

		<cfset var loc = {}>
		<cftry>
			<cfset loc.result = {}>
			<cfset loc.args = args>
			<cfif args.form.siStatus eq 'closed'>
				<cfset loc.qtyItems = args.form.siPackQty * args.form.siQtyPacks>
				<cfset loc.received = args.form.siReceived>
				<cfset loc.bookedIn = args.form.siBookedIn>
			<cfelse>
				<cfset loc.qtyItems = 0>
				<cfset loc.received = 0>
				<cfset loc.bookedIn = "">
			</cfif>
			<cfif IsDate(loc.bookedIn)>
				<cfset loc.bookedIn = LSDateFormat(loc.bookedIn,"yyyy-mm-dd")>
			</cfif>
			<cfset loc.tradeNet = args.form.siWSP / args.form.siPackQty>
			<cfset loc.tradeGross = loc.tradeNet * (1 + (args.form.vatRate / 100))>
			<cfif StructKeyExists(args.form,"siOurPrice")>
				<cfset loc.sellprice = args.form.siOurPrice>
			<cfelse><cfset loc.sellprice = args.form.siRRP></cfif>
			<cfset loc.profit = loc.sellprice - loc.tradeGross>
			<cfset loc.POR = (loc.profit / loc.sellprice) * 100>
			
			<cfquery name="loc.QStockItem" datasource="#args.datasource#" result="loc.QStockItemResult">
				UPDATE tblStockItem a
				INNER JOIN tblStockOrder b ON (a.siOrder = b.soID)
				SET 
					siOurPrice = #loc.sellprice#,
					siPackQty = #args.form.siPackQty#,
					siQtyPacks = #args.form.siQtyPacks#,
					siQtyItems = #loc.qtyItems#,
					siRef = '#args.form.siRef#',
					siRRP = #args.form.siRRP#,
					siUnitSize = '#args.form.siUnitSize#',
					siWSP = #args.form.siWSP#,
					siUnitTrade = #args.form.siWSP / args.form.siPackQty#,
					siExpires = <cfif len(args.form.siExpires)>'#LSDateFormat(args.form.siExpires,"yyyy-mm-dd")#',<cfelse>null,</cfif>
					siStatus = '#args.form.siStatus#',
					siReceived = #loc.received#,
					siBookedIn = <cfif len(loc.bookedIn)>'#loc.bookedIn#',<cfelse>null,</cfif>
					siPOR = #loc.POR#,
					soDate = '#LSDateFormat(args.form.soDate,"yyyy-mm-dd")#',
					soAccountID = #args.form.accID#
				WHERE siID = #args.form.siID#
			</cfquery>
			<cfset loc.result.barcode = args.form.barcode>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="DeleteStockItem" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QDeleteStockItem" datasource="#args.datasource#" result="loc.result.QDeleteStockItemResult">
				DELETE FROM tblStockItem
				WHERE siID = #val(args.form.stockitem)#
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

	<cffunction name="StockItemList" access="public" returntype="struct" hint="stock items for a given product record">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.result.action = "">
		<cfset loc.barcode = Trim(args.barcode)>

		<cftry>
			<cfif StructKeyExists(args,"productID") AND args.productID gt 0>
				<cfquery name="loc.QProduct" datasource="#args.datasource#">
					SELECT prodID,prodRef,prodTitle,prodPriceMarked,prodCatID,prodVATRate, pcatID,pgID,pcatTitle,pgTitle,pgTarget
					FROM tblProducts
					LEFT JOIN tblStockItem ON siProduct = prodID
					INNER JOIN tblProductCats ON prodCatID = pcatID
					INNER JOIN tblProductGroups ON pgID = pcatGroup
					WHERE prodID = #val(args.productID)#
					LIMIT 1;
				</cfquery>
			<cfelse>
				<cfquery name="loc.QProduct" datasource="#args.datasource#">
					SELECT prodID,prodTitle,prodPriceMarked,prodCatID,prodVATRate, pcatID,pgID,pcatTitle,pgTitle,pgTarget
					FROM tblProducts
					INNER JOIN tblBarcodes on prodID = barProdID
					LEFT JOIN tblStockItem ON siProduct = prodID
					INNER JOIN tblProductCats ON prodCatID = pcatID
					INNER JOIN tblProductGroups ON pgID = pcatGroup
					WHERE barcode = '#loc.barcode#'
					LIMIT 1;
				</cfquery>
			</cfif>
			<cfif loc.QProduct.recordcount gt 0>
				<cfset loc.rec = {}>
				<cfloop query="loc.QProduct">
					<cfset loc.rec.prodID=prodID>
					<cfset loc.rec.prodTitle=prodTitle>
					<cfset loc.rec.prodPriceMarked=prodPriceMarked>
					<cfset loc.rec.prodVATRate=prodVATRate>
					<cfset loc.rec.PriceMarked=GetToken(" |PM",val(prodPriceMarked)+1,"|")>
					<cfset loc.rec.catID=pcatID>
					<cfset loc.rec.catTitle=pcatTitle>
					<cfset loc.rec.groupID=pgID>
					<cfset loc.rec.groupTitle=pgTitle>
					<cfif pgTarget eq 0><cfset loc.rec.pgTarget = 0.43>
						<cfelse><cfset loc.rec.pgTarget = pgTarget / 100></cfif>
				</cfloop>
				<cfset loc.result.product = loc.rec>
				<cfquery name="loc.result.StockItems" datasource="#args.datasource#">
					SELECT tblStockItem.*, soRef,soDate,soStatus, accID,accName
					FROM tblStockItem
					INNER JOIN tblStockOrder ON siOrder = soID
					INNER JOIN tblAccount on soAccountID = accID
					WHERE siProduct = #loc.QProduct.prodID#
					ORDER BY soDate DESC, siID DESC
				</cfquery>
				<cfset loc.result.recordcount=loc.result.StockItems.recordcount>
			<cfelse>
				<cfset loc.result.barcode = loc.barcode>
				<cfset loc.result.msg = "Product not found">
				<cfset loc.result.action = "clear">
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadStockItem" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
<!---
						<cfquery name="loc.CategoryGroup" datasource="#args.datasource#">
							SELECT pcatID,pgID,pcatTitle,pgTitle,pgTarget
							FROM tblProductCats
							INNER JOIN tblProductGroups ON pgID=pcatGroup
							WHERE pcatID=#loc.rec.prodCatID#
						</cfquery>
						<cfif loc.CategoryGroup.recordcount eq 1>
							<cfset loc.result.catID=loc.CategoryGroup.pcatID>
							<cfset loc.result.catTitle=loc.CategoryGroup.pcatTitle>
							<cfset loc.result.groupID=loc.CategoryGroup.pgID>
							<cfset loc.result.groupTitle=loc.CategoryGroup.pgTitle>
							<cfset loc.result.pgTarget=loc.CategoryGroup.pgTarget>
						</cfif>
--->
		<cftry>
			<cfquery name="loc.QProduct" datasource="#args.datasource#">
				SELECT prodID,prodRef,prodTitle,prodPriceMarked,prodCatID,prodVATRate,prodMinPrice,prodCountDate,prodStockLevel, pcatID,pgID,pcatTitle,pgTitle,pgTarget
				FROM tblProducts
				INNER JOIN tblStockItem ON siProduct = prodID
				INNER JOIN tblProductCats ON prodCatID = pcatID
				INNER JOIN tblProductGroups ON pgID = pcatGroup
				WHERE siID = #args.id#
			</cfquery>
			<cfif loc.QProduct.recordcount gt 0>
				<cfset loc.rec = {}>
				<cfloop query="loc.QProduct">
					<cfset loc.rec.prodID=prodID>
					<cfset loc.rec.prodTitle=prodTitle>
					<cfset loc.rec.prodPriceMarked=prodPriceMarked>
					<cfset loc.rec.prodVATRate=prodVATRate>
					<cfset loc.rec.PriceMarked=GetToken(" |PM",val(prodPriceMarked)+1,"|")>
					<cfset loc.rec.prodMinPrice=prodMinPrice>
					<cfset loc.rec.prodCountDate=prodCountDate>
					<cfset loc.rec.prodStockLevel=prodStockLevel>
					<cfset loc.rec.catID=pcatID>
					<cfset loc.rec.catTitle=pcatTitle>
					<cfset loc.rec.groupID=pgID>
					<cfset loc.rec.groupTitle=pgTitle>
					<cfif pgTarget eq 0><cfset loc.rec.pgTarget = 0.43>
						<cfelse><cfset loc.rec.pgTarget = pgTarget / 100></cfif>
				</cfloop>
				<cfset loc.result.product = loc.rec>
				<cfquery name="loc.result.QStockItem" datasource="#args.datasource#">
					SELECT tblStockItem.*, soRef,soDate,soStatus, accID,accName
					FROM tblStockItem
					INNER JOIN tblStockOrder ON siOrder = soID
					INNER JOIN tblAccount on soAccountID = accID
					WHERE siID = #args.id#
				</cfquery>
			<cfelse>
				<cfset loc.result.msg = "Product or stock item not found.">
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="AddProductGroup" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QAddGroup" datasource="#args.datasource#">
				INSERT INTO tblProductGroups 
				(pgTitle) 
				VALUES ('#args.form.pgTitle#')
			</cfquery>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadProductGroup" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QGetGroup" datasource="#args.datasource#">
				SELECT *
				FROM tblProductGroups
				WHERE pgID = #args.pgID#
			</cfquery>
			<cfset loc.result.group = loc.QGetGroup>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="SaveProductGroup" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QSaveGroup" datasource="#args.datasource#">
				UPDATE tblProductGroups
				SET 
					pgTitle = '#args.form.pgTitle#',
					pgTarget = #args.form.pgTarget#
				WHERE pgID = #args.form.pgID#
			</cfquery>
			<cfset loc.result.msg = "Group saved">
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadProductGroups" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QGroups" datasource="#args.datasource#">
				SELECT pgID,pgTitle,pgTarget, Count(pcatID) AS Categories
				FROM tblProductGroups
				LEFT JOIN tblProductCats ON pcatGroup=pgID
				WHERE pgType != 'epos'
				GROUP BY pgID
				ORDER BY pgTitle
			</cfquery>
			<cfset loc.result.groups = loc.QGroups>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="AddProductCategory" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QAddCategory" datasource="#args.datasource#">
				INSERT INTO tblProductCats 
				(pcatGroup,pcatTitle) 
				VALUES (#args.form.pcatGroup#,'#args.form.pcatTitle#')
			</cfquery>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadProductCategory" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QGetCategory" datasource="#args.datasource#">
				SELECT *
				FROM tblProductCats
				WHERE pcatID = #args.pcatID#
			</cfquery>
			<cfset loc.result.category = loc.QGetCategory>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="SaveProductCategory" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QSaveGroup" datasource="#args.datasource#">
				UPDATE tblProductCats
				SET 
					pcatTitle = '#args.form.pcatTitle#',
					pcatGroup = #args.form.pcatGroup#
				WHERE pcatID = #args.form.pcatID#
			</cfquery>
			<cfset loc.result.msg = "Category saved">
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadCategories" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QCategories" datasource="#args.datasource#">
				SELECT tblProductCats.*, pgID,pgTitle, count(prodID) AS products
				FROM tblProductCats
				INNER JOIN tblProductGroups ON pgID=pcatGroup
				LEFT JOIN tblProducts ON pcatID=prodCatID
				WHERE pcatGroup = #args.form.group#
				GROUP BY pcatID
				ORDER BY pcatTitle
			</cfquery>
			<cfset loc.result.groupID = args.form.group>
			<cfset loc.result.categories = loc.QCategories>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadProducts" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QProducts" datasource="#args.datasource#" result="loc.QQueryResult">
				SELECT prodID,prodTitle,siUnitSize, siOurPrice, pcatID,pcatTitle
				FROM tblProducts
				INNER JOIN tblProductCats ON prodCatID = pcatID
				LEFT JOIN tblStockItem ON prodID = siProduct
				AND tblStockItem.siID = (
				SELECT MAX( siID )
				FROM tblStockItem
				WHERE prodID = siProduct 
				AND siStatus <> 'inactive')
				WHERE prodCatID=#val(args.form.category)#
				ORDER BY prodTitle, siUnitSize
			</cfquery>
			<cfset loc.result.products = loc.QProducts>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="DeleteGroup" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QGroup" datasource="#args.datasource#" result="loc.delGrp">
				DELETE FROM tblProductGroups
				WHERE pgID = #args.form.group#
			</cfquery>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="DeleteCategory" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QCategories" datasource="#args.datasource#" result="loc.delCat">
				DELETE FROM tblProductCats
				WHERE pcatID = #args.form.category#
			</cfquery>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="AddProductToList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.msg = "">
		<cftry>
			<cfquery name="loc.getList" datasource="#args.datasource#">
				SELECT ctlStockList
				FROM tblControl
				WHERE ctlID = 1
			</cfquery>
			<cfif ListFind(loc.getList.ctlStockList,args.product,",")>
				<cfset loc.result.msg = "Product already in list">
			<cfelse>
				<cfset loc.newList = ListAppend(loc.getList.ctlStockList,args.product,",")>
				<cfquery name="loc.saveToDB" datasource="#args.datasource#">
					UPDATE tblControl
					SET	ctlStockList = '#loc.newList#'
					WHERE ctlID = 1
				</cfquery>
				<cfset loc.result.msg = "Product added to list">
			</cfif>			
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadSavedStockList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cftry>
			<cfquery name="loc.loadstring" datasource="#args.datasource#">
				SELECT ctlStockList
				FROM tblControl
				WHERE ctlID = 1
			</cfquery>
			<cfset loc.result.stocklist = loc.loadstring.ctlStockList>
			<cfif ListLen(loc.result.stocklist,",") gt 0>
				<cfquery name="loc.QProductList" datasource="#args.datasource#">
					SELECT prodID,prodStaffDiscount,prodRef,prodRecordTitle,prodTitle,prodPOR,prodCountDate,prodStockLevel,prodLastBought,
							prodPackPrice,prodOurPrice,prodValidTo,prodPriceMarked,prodCatID,
							siID,siUnitSize,siPackQty,siQtyPacks,siQtyItems,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siReceived,siBookedIn,siExpires,siStatus,
							accID,accName,
							soDate
					FROM tblProducts
					INNER JOIN tblAccount on prodSuppID = accID
					INNER JOIN tblStockOrder ON soID = siOrder
					LEFT JOIN tblStockItem ON prodID = siProduct
					AND tblStockItem.siID = (
					SELECT MAX( siID )
						FROM tblStockItem
						WHERE prodID = siProduct
						AND siStatus NOT IN ("returned","inactive") )
					WHERE prodID IN (#loc.result.stocklist#)
				</cfquery>
				<cfset loc.result.stockItems = loc.QProductList>
				<cfset loc.result.records = loc.QProductList.recordcount>
			<cfelse>
				<cfset loc.result.records = 0>
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





