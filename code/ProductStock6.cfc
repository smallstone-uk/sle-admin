<cfcomponent displayname="productstock" extends="core">

	<cffunction name="xformatNum" access="public" returntype="string">
		<cfargument name="num" type="numeric" required="yes">
		<cfif num lt 0>
			<cfreturn '<span class="negativeNum">#DecimalFormat(num)#</span>'>
		<cfelseif num gt 0>
			<cfreturn '<span class="">#DecimalFormat(num)#</span>'>
		<cfelse>
			<cfreturn "">	<!--- zero returns blank --->
		</cfif>
	</cffunction>

	<cffunction name="FindProductData" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.msg = "">
		<cfset loc.result.barcode = "">
		<cfset loc.result.productID = 0>
		
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
					</cfif>
				<cfelse>
					<cfset loc.result.msg = "Barcode not found">
				</cfif>
			<cfelse>
				<cfset loc.result.msg = "Barcode not passed to function.">
			</cfif>
		
			<cfif loc.result.productID>
				<cfquery name="loc.result.QProduct" datasource="#args.datasource#">		<!--- load product and latest stock item --->
					SELECT	prodID,prodRef,prodRecordTitle,prodTitle,prodCountDate,prodStockLevel,prodLastBought,prodStaffDiscount,prodMinPrice,
							prodPackPrice,prodOurPrice,prodValidTo,prodPriceMarked,prodCatID,prodEposCatID,prodVATRate,prodStatus,prodReorder,prodUnitSize,prodLocked,prodUnitTrade,
							siID,siRef,siOrder,siUnitSize,siPackQty,siQtyPacks,siQtyItems,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siReceived,siBookedIn,siExpires,siStatus,
							tblStockOrder.*
					FROM tblProducts
					LEFT JOIN tblStockItem ON prodID = siProduct
					INNER JOIN tblStockOrder ON soID = siOrder
					AND tblStockItem.siID = (
						SELECT MAX( siID )
						FROM tblStockItem
						WHERE prodID = siProduct
					)
					WHERE prodID = #val(loc.result.productID)#
					LIMIT 1;
				</cfquery>
				
				<cfquery name="loc.result.QDeals" datasource="#args.datasource#">	<!--- load current deals --->
					SELECT ercTitle, edTitle,edType,edStarts,edEnds,edQty,edStatus,edDealType,edAmount
					FROM tblepos_dealitems
					INNER JOIN tblepos_deals ON edID = ediParent
					INNER JOIN tblepos_retailclubs ON ercID = edRetailClub
					WHERE ediProduct = #val(loc.result.productID)#
					AND edStarts <= NOW()
					AND edEnds >= NOW()
					ORDER BY ediID DESC
				</cfquery>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>


	<cffunction name="LoadProductAndLatestStockItem" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QProduct" datasource="#args.datasource#" result="loc.QQueryResult">
				SELECT 	prodID,prodRef,prodRecordTitle,prodTitle,prodCountDate,prodStockLevel,prodLastBought,prodStaffDiscount,prodMinPrice,
						prodPackPrice,prodOurPrice,prodValidTo,prodPriceMarked,prodCatID,prodEposCatID,prodVATRate,prodStatus,prodReorder,prodUnitSize,
						siID,siRef,siOrder,siUnitSize,siPackQty,siQtyPacks,siQtyItems,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siReceived,siBookedIn,siExpires,siStatus
				FROM tblProducts
				LEFT JOIN tblStockItem ON prodID = siProduct
				AND tblStockItem.siID = (
					SELECT MAX( siID )
					FROM tblStockItem
					WHERE prodID = siProduct )
				WHERE prodID=#val(args.productID)#
				LIMIT 1;
			</cfquery>

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
				<cfset loc.rec.PriceMarked = GetToken(" |PM",prodPriceMarked+1,"|")>
				<cfset loc.rec.prodMinPrice = prodMinPrice>
				<cfset loc.rec.prodOurPrice = prodOurPrice>
				<cfset loc.rec.prodStatus = prodStatus>
				<cfset loc.rec.prodReorder = prodReorder>
				<cfset loc.rec.prodUnitSize = prodUnitSize>
				
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
				<cfset loc.stockItem.siBookedIn = LSDateFormat(siBookedIn,"yyyy-mm-dd")>
				<cfset loc.stockItem.siExpires = siExpires>
				<cfset loc.stockItem.siStatus = siStatus>						 	 	 	 	 	 	 	 	 	 	 	 	 
			</cfloop>
			<cfset loc.result.product = loc.rec>
			<cfset loc.result.stockItem = loc.stockItem>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

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
					SELECT prodID,prodRef,prodRecordTitle,prodTitle,prodCountDate,prodStockLevel,prodLastBought,prodStaffDiscount,prodMinPrice,
							prodPackPrice,prodOurPrice,prodValidTo,prodPriceMarked,prodCatID,prodEposCatID,prodVATRate,prodStatus,prodReorder,prodUnitSize,prodLocked,prodUnitTrade,
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
						<cfset loc.rec.PriceMarked = GetToken(" |PM",prodPriceMarked+1,"|")>
						<cfset loc.rec.prodMinPrice = prodMinPrice>
						<cfset loc.rec.prodOurPrice = prodOurPrice>
						<cfset loc.rec.prodUnitTrade = prodUnitTrade>
						<cfset loc.rec.prodStatus = prodStatus>
						<cfset loc.rec.prodReorder = prodReorder>
						<cfset loc.rec.prodLocked = prodLocked>
						<cfset loc.rec.prodUnitSize = prodUnitSize>
						
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
						<cfset loc.stockItem.siBookedIn = LSDateFormat(siBookedIn,"yyyy-mm-dd")>
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
					<cfquery name="loc.result.QDeals" datasource="#args.datasource#">
						SELECT ercTitle, edTitle,edType,edStarts,edEnds,edQty,edStatus,edDealType,edAmount
						FROM tblepos_dealitems
						INNER JOIN tblepos_deals ON edID = ediParent
						INNER JOIN tblepos_retailclubs ON ercID = edRetailClub
						WHERE ediProduct = #val(loc.result.productID)#
						AND edStarts <= NOW()
						AND edEnds >= NOW()
						ORDER BY ediID DESC
					</cfquery>
					<cfif loc.result.QDeals.recordcount gt 0>
						<cfset loc.result.deals = []>
						<cfloop query="loc.result.QDeals">
							<cfset loc.deal = {}>
							<cfset loc.deal.ercTitle = ercTitle>
							<cfset loc.deal.edTitle = edTitle>
							<cfset loc.deal.edType = edType>
							<cfset loc.deal.edStarts = edStarts>
							<cfset loc.deal.edEnds = edEnds>
							<cfset loc.deal.edQty = edQty>
							<cfset loc.deal.edStatus = edStatus>
							<cfset loc.deal.edDealType = edDealType>
							<cfset loc.deal.edAmount = edAmount>
							<cfset ArrayAppend(loc.result.deals,loc.deal)>
						</cfloop>
					</cfif>
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
				WHERE pgType = 'sale'
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
			SELECT 	pcatTitle,prodID,prodRef,prodRecordTitle,prodTitle,prodCountDate,prodStockLevel,prodLastBought,prodStaffDiscount
					prodPackPrice,prodOurPrice,prodValidTo,prodPriceMarked,prodCatID,prodVATRate,
					siID,siRef,siOrder,siUnitSize,siPackQty,siQtyPacks,siQtyItems,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siReceived,siBookedIn,siExpires,siStatus,
					barcode,soDate
			FROM tblProducts
			LEFT JOIN tblStockItem ON prodID = siProduct
			INNER JOIN tblStockOrder ON soID = siOrder
			INNER JOIN tblProductCats ON prodCatID = pcatID
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
			ORDER BY pcatTitle, prodTitle
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
					prodPackPrice,prodOurPrice,prodValidTo,prodLastBought,prodUnitSize,prodRRP,prodUnitTrade,prodPriceMarked,prodVATRate,
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
					prodRef,
					prodRecordTitle,
					prodTitle,
					prodCatID,
					prodPriceMarked,
					prodMinPrice,
					prodOurPrice,
					prodVATRate,
					prodStaffDiscount,
					prodEposCatID
				) VALUES (
					'#args.form.prodRef#',
					'#args.form.prodRecordTitle#',
					'#args.form.prodTitle#',
					#val(args.form.prodCatID)#,
					#int(StructKeyExists(args.form,"prodPriceMarked"))#,
					#val(args.form.prodMinPrice)#,
					#val(args.form.prodOurPrice)#,
					#args.form.prodVATRate#,
					'#StructKeyExists(args.form,"prodStaffDiscount")#',
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
				SET prodRef = '#args.form.prodRef#',
					prodRecordTitle = '#args.form.prodRecordTitle#',
					prodTitle = '#args.form.prodTitle#',
					prodCatID = #val(args.form.prodCatID)#,
					prodPriceMarked = #int(StructKeyExists(args.form,"prodPriceMarked"))#,
					prodMinPrice = #val(args.form.prodMinPrice)#,
					prodOurPrice = #val(args.form.prodOurPrice)#,
					prodCountDate = <cfif len(args.form.prodCountDate)>'#LSDateFormat(args.form.prodCountDate,"yyyy-mm-dd")#',<cfelse>null,</cfif>
					prodStockLevel = #val(args.form.prodStockLevel)#,
					prodVATRate = #args.form.prodVATRate#,
					prodEposCatID = #val(args.form.prodEposCatID)#,
					prodStaffDiscount = '#StructKeyExists(args.form,"prodStaffDiscount")#',
					prodLocked = '#int(StructKeyExists(args.form,"prodLocked"))#',
					prodStatus = '#args.form.prodStatus#',
					prodUnitSize = '#args.form.prodUnitSize#',
					prodUnitTrade = '#val(args.form.prodUnitTrade)#',
					prodReorder = '#args.form.prodReorder#'
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
				<cfset loc.result.prodID = args.form.productID>
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

<!---
			<cfif IsDate(loc.bookedIn)>
				<cfset loc.bookedIn = LSDateFormat(loc.bookedIn,"yyyy-mm-dd")>
			</cfif>
--->
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
					<!---siBookedIn = <cfif len(loc.bookedIn)>'#loc.bookedIn#',<cfelse>null,</cfif>--->
					siPOR = #loc.POR#,
					soDate = '#LSDateFormat(args.form.soDate,"yyyy-mm-dd")#',
					soAccountID = #args.form.accID#
				WHERE siID = #args.form.siID#
			</cfquery>
			<cfset loc.result.barcode = args.form.barcode>
			<cfset loc.result.prodID = args.form.prodID>
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

	<cffunction name="FormatDate" returntype="string">
		<cfargument name="dateStr" type="string" required="yes">
		<cfargument name="returnStr" type="string" required="no" default="dd-mmm-yyyy">
		
		<cfset var loc = {}>
		<cfset loc.result = "">
		<!--- <cfset loc.pattern = "^(?:(\d{4})[-\/.](\d{2})[-\/.](\d{2})|(\d{2})[-\/.](\d{2})[-\/.](\d{4}))$">	--->
		<cfset loc.pattern = "^(?:(\d{4})[-\/.](\d{2})[-\/.](\d{2})|(\d{2})[-\/.](\d{2})[-\/.](\d{4})|\{ts '\s*(\d{4})-(\d{2})-(\d{2})\s+\d{2}:\d{2}:\d{2}'\})$">
		<cfset loc.matchGroups = REFind(loc.pattern, dateStr, 1, "TRUE")>
		<cfif ArrayLen(loc.matchGroups.len) gt 1>
			<cfif loc.matchGroups.len[2] GT 0>
				<!--- Format is YYYY-MM-DD --->
				<cfset loc.lyear  = Mid(dateStr, loc.matchGroups.pos[2], loc.matchGroups.len[2])>
				<cfset loc.lmonth = Mid(dateStr, loc.matchGroups.pos[3], loc.matchGroups.len[3])>
				<cfset loc.lday   = Mid(dateStr, loc.matchGroups.pos[4], loc.matchGroups.len[4])>
			<cfelseif loc.matchGroups.len[5] GT 0>
				<!--- Format is DD-MM-YYYY --->
				<cfset loc.lday   = Mid(dateStr, loc.matchGroups.pos[5], loc.matchGroups.len[5])>
				<cfset loc.lmonth = Mid(dateStr, loc.matchGroups.pos[6], loc.matchGroups.len[6])>
				<cfset loc.lyear  = Mid(dateStr, loc.matchGroups.pos[7], loc.matchGroups.len[7])>
			<cfelseif loc.matchGroups.len[8] GT 0>
				<!--- Format is {ts '2025-03-07 00:00:00'} --->
				<cfset loc.lday   = Mid(dateStr, loc.matchGroups.pos[10], loc.matchGroups.len[10])>
				<cfset loc.lmonth = Mid(dateStr, loc.matchGroups.pos[9], loc.matchGroups.len[9])>
				<cfset loc.lyear  = Mid(dateStr, loc.matchGroups.pos[8], loc.matchGroups.len[8])>
			</cfif>
			<cfset loc.dateCheck = loc.lyear & "-" & loc.lmonth & "-" & loc.lday>
			<cfif IsDate(loc.dateCheck)>
				<cfset loc.realDate = CreateDate(loc.lyear,loc.lmonth,loc.lday)>
				<cfset loc.result = LSDateFormat(loc.realDate,returnStr)>
			</cfif>
		</cfif>
		<cfreturn loc.result> 
	</cffunction>

	<cffunction name="ListSalesItems" access="public" returntype="struct" hint="sales items for a given product record">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.action = "">
		<cfset loc.tot = {count=0,sold=0,waste=0,net=0,VAT=0,trade=0,wasteValue=0,profit=0,POR=0}>
		<cfset loc.data = {}>
		<cftry>
			<cfif !StructKeyExists(args.form,"srchDateFrom") OR len(args.form.srchDateFrom) IS 0>
				<cfset loc.srchDateFrom = FormatDate("2013-01-01",'yyyy-mm-dd')>
			<cfelseif IsDate(args.form.srchDateFrom)>
				<cfset loc.srchDateFrom = FormatDate(args.form.srchDateFrom,'yyyy-mm-dd')>
			<cfelse>
				<cfset loc.srchDateFrom = "">
			</cfif>
			<cfif !StructKeyExists(args.form,"srchDateTo") OR len(args.form.srchDateTo) IS 0>
				<cfset loc.srchDateTo = LSDateFormat(Now(),"yyyy-mm-dd")>
			<cfelseif IsDate(args.form.srchDateTo)>
				<cfset loc.srchDateTo = DateAdd("d",1,args.form.srchDateTo)>
				<cfset loc.srchDateTo = FormatDate(args.form.srchDateTo,'yyyy-mm-dd')>
			<cfelse>
				<cfset loc.srchDateTo = "">
			</cfif>
			<cfset loc.midnight = FormatDate(loc.srchDateTo,'yyyy-mm-dd')>
			<cfset loc.productID = val(args.form.productID)>
			<cfif loc.productID neq 0>
				<cfquery name="loc.result.QProdInfo" datasource="#args.datasource#">	<!--- general info of this product and latest stock item --->
					SELECT prodID,prodRef,prodTitle,prodPriceMarked,prodCatID,prodVATRate,prodCountDate,prodStockLevel,prodStatus,
						pcatID,pgID,pcatTitle,pgTitle,pgTarget, 
						siID,siUnitSize,siUnitTrade,siOurPrice,siPackQty
					FROM tblProducts
					LEFT JOIN tblStockItem ON prodID = siProduct
					AND tblStockItem.siID = (
						SELECT MAX( siID )
						FROM tblStockItem
						WHERE prodID = siProduct )
					INNER JOIN tblProductCats ON prodCatID = pcatID
					INNER JOIN tblProductGroups ON pgID = pcatGroup
					WHERE prodID = #loc.productID#
				</cfquery>
				<cfif loc.result.QProdInfo.recordcount gt 0>
					<cfset loc.result.priceMarked = GetToken(" |PM",loc.result.QProdInfo.prodPriceMarked+1,"|")>
					<cfquery name="loc.result.QSalesItems" datasource="#args.datasource#">
						SELECT *
						FROM tblepos_items
						INNER JOIN tblEpos_Header ON ehID = eiParent
						WHERE eiProdID = #loc.productID#
						AND eiTimeStamp BETWEEN '#loc.srchDateFrom#' AND '#loc.midnight#'
						ORDER BY eiTimeStamp DESC;
					</cfquery>
					<cfloop query="loc.result.QSalesItems">
						<cfset loc.tot.count++>
						<cfset loc.profit = 0>
						<cfset loc.POR = 0>
						<cfset loc.class = ehMode>
						<cfif eiNet neq 0>
							<cfset loc.profit = -eiNet - eiTrade>
							<!---<cfset loc.POR = (loc.profit / -eiNet) * 100>--->
							<cfset loc.POR = INT(loc.profit / -eiNet * 10000) / 100>
						</cfif>
						<cfif ehMode eq "reg"> <!--- reg mode --->
							<cfset loc.item = {
								ehID = ehID,								
								eiTimeStamp = eiTimeStamp,
								ehMode = ehMode,
								ehPayAcct = ehPayAcct,
								eiClass = eiClass,
								sold = eiQty, 
								waste = 0, 
								net = eiNet * -1, 
								VAT = eiVAT * -1, 
								trade = eiTrade,
								wasteValue = 0,
								profit = loc.profit,
								POR = loc.POR
							}>
						<cfelseif ehMode eq "wst"> <!--- waste mode --->
							<cfset loc.item = {
								ehID = ehID,								
								eiTimeStamp = eiTimeStamp,
								ehMode = ehMode,
								ehPayAcct = ehPayAcct,
								eiClass = eiClass,
								sold=0, 
								waste = eiQty,
								net=0, 
								VAT=0, 
								trade = eiTrade,
								wasteValue = eiTrade,
								profit = loc.profit,
								POR = 0
							}>
						<cfelse> <!--- refund mode --->
							<cfset loc.item = {
								ehID = ehID,								
								eiTimeStamp = eiTimeStamp,
								ehMode = ehMode,
								ehPayAcct = ehPayAcct,
								eiClass = eiClass,
								sold = eiQty, 
								waste = 0, 
								net = eiNet * -1, 
								VAT = eiVAT * -1, 
								trade = eiTrade * -1,
								wasteValue = 0,
								profit = loc.profit,
								POR = loc.POR
							}>
						</cfif>
						<cfset loc.item.profit = loc.item.net - loc.item.trade>
						<cfset loc.tot.sold += loc.item.sold>
						<cfset loc.tot.waste += loc.item.waste>
						<cfset loc.tot.net += loc.item.net>
						<cfset loc.tot.VAT += loc.item.VAT>
						<cfset loc.tot.trade += loc.item.trade>
						<cfset loc.tot.wasteValue += loc.item.wasteValue>
						<cfset loc.tot.profit += loc.item.profit>
						<cfset StructInsert(loc.data,eiID,loc.item)>
					</cfloop>
					<cfif loc.tot.net neq 0>
						<cfset loc.tot.POR = INT(loc.tot.profit / loc.tot.net * 10000) / 100>
					</cfif>
					<cfset loc.result.totals = loc.tot>
					<cfset loc.result.data = loc.data>
				</cfif>
			</cfif>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="AnalysisSalesItems" access="public" returntype="struct" hint="detailed analysis for a given product record">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.action = "">

		<cftry>
			<cfif !StructKeyExists(args.form,"srchDateFrom") OR len(args.form.srchDateFrom) IS 0>
				<cfset loc.srchDateFrom = FormatDate("2013-01-01",'yyyy-mm-dd')>
			<cfelseif IsDate(args.form.srchDateFrom)>
				<cfset loc.srchDateFrom = FormatDate(args.form.srchDateFrom,'yyyy-mm-dd')>
			<cfelse>
				<cfset loc.srchDateFrom = "">
			</cfif>
			<cfif !StructKeyExists(args.form,"srchDateTo") OR len(args.form.srchDateTo) IS 0>
				<cfset loc.srchDateTo = LSDateFormat(Now(),"yyyy-mm-dd")>
			<cfelseif IsDate(args.form.srchDateTo)>
				<cfset loc.srchDateTo = DateAdd("d",1,args.form.srchDateTo)>
				<cfset loc.srchDateTo = FormatDate(args.form.srchDateTo,'yyyy-mm-dd')>
			<cfelse>
				<cfset loc.srchDateTo = "">
			</cfif>
			<cfset loc.midnight = FormatDate(loc.srchDateTo,'yyyy-mm-dd')>
			<cfset loc.productID = val(args.form.productID)>
			<cfif loc.productID neq 0>
				<cfquery name="loc.result.QProdInfo" datasource="#args.datasource#">	<!--- general info of this product and latest stock item --->
					SELECT prodID,prodRef,prodTitle,prodPriceMarked,prodCatID,prodVATRate,prodCountDate,prodStockLevel,prodStatus,
						pcatID,pgID,pcatTitle,pgTitle,pgTarget, 
						siID,siUnitSize,siUnitTrade,siOurPrice,siPackQty
					FROM tblProducts
					LEFT JOIN tblStockItem ON prodID = siProduct
					AND tblStockItem.siID = (
						SELECT MAX( siID )
						FROM tblStockItem
						WHERE prodID = siProduct )
					INNER JOIN tblProductCats ON prodCatID = pcatID
					INNER JOIN tblProductGroups ON pgID = pcatGroup
					WHERE prodID = #loc.productID#
				</cfquery>
				<cfif loc.result.QProdInfo.recordcount gt 0>
					<cfset loc.result.priceMarked = GetToken(" |PM",loc.result.QProdInfo.prodPriceMarked+1,"|")>
					<cfquery name="loc.result.QSalesItems" datasource="#args.datasource#">
						SELECT *
						FROM tblepos_items
						INNER JOIN tblEpos_Header ON ehID = eiParent
						WHERE eiProdID = #loc.productID#
						AND eiTimeStamp BETWEEN '#loc.srchDateFrom#' AND '#loc.midnight#'
						ORDER BY YEAR(eiTimeStamp) DESC, MONTH(eiTimeStamp) DESC, eiTimeStamp DESC;
					</cfquery>

					<cfset loc.tot = {count=0,sold=0,waste=0,wasteValue=0,net=0,VAT=0,trade=0,profit=0,POR=0}>
					<cfset loc.da = {}>
					<cfloop query="loc.result.QSalesItems">
						<cfset loc.tot.count++>
						<cfset loc.class = ehMode>
						<cfset loc.period = LSDateFormat(eiTimeStamp,"yyyymm")>
						<cfif ehMode eq "reg"> <!--- reg mode --->
							<cfset loc.item = {sold=eiQty, waste=0, net=eiNet * -1, VAT=eiVAT * -1, trade=eiTrade}>
						<cfelseif ehMode eq "wst"> <!--- waste mode --->
							<cfset loc.item = {sold=0, waste=eiQty ,net=0, VAT=0, trade=eiTrade}>
							<cfset loc.tot.waste += loc.item.waste>
							<cfset loc.tot.wasteValue += loc.item.trade>
						<cfelse> <!--- refund mode --->
							<cfset loc.item = {sold=eiQty, waste=0, net=eiNet * -1, VAT=eiVAT * -1, trade=eiTrade * -1}>
						</cfif>
						<cfset loc.item.profit = loc.item.net - loc.item.trade>
						<cfset loc.tot.sold += loc.item.sold>
						<cfset loc.tot.net += loc.item.net>
						<cfset loc.tot.VAT += loc.item.VAT>
						<cfset loc.tot.trade += loc.item.trade>
						<cfset loc.tot.profit += loc.item.profit>
						<cfif loc.tot.net neq 0>
							<cfset loc.tot.POR = INT(loc.tot.profit / loc.tot.net * 10000) / 100>
						<cfelse>
							<cfset loc.tot.POR = 0>
						</cfif>
						
						<cfif not StructKeyExists(loc.da,loc.period)>
							<cfset StructInsert(loc.da,loc.period,{dateTitle = LSDateFormat(eiTimeStamp,"mmmm yyyy"),valueNet = 0,valueVAT = 0,
								valueTrade = 0,valueProfit = 0,valueWaste = 0,numSales = 0,numWaste = 0})>
						</cfif>
						<cfset loc.mdata = StructFind(loc.da,loc.period)>
						<cfset loc.mdata.valueNet += loc.item.net>
						<cfset loc.mdata.valueVAT += loc.item.VAT>
						<cfset loc.mdata.valueTrade += loc.item.trade>
						<cfset loc.mdata.valueProfit += loc.item.profit>
						<cfif ehMode eq "wst">
							<cfset loc.mdata.numWaste += loc.item.waste>
							<cfset loc.mdata.valueWaste += loc.item.trade>
						<cfelse>
							<cfset loc.mdata.numSales += loc.item.sold>
						</cfif>
						<cfif loc.mdata.valueNet neq 0>
							<cfset loc.mdata.POR = INT(loc.mdata.valueProfit / loc.mdata.valueNet * 10000) / 100>
						<cfelse>
							<cfset loc.mdata.POR = 0>
						</cfif>
						<cfset StructUpdate(loc.da,loc.period,loc.mdata)>
						
					</cfloop>
					<cfset loc.result.data = loc.da>
					<cfset loc.result.totals = loc.tot>
				</cfif>
			</cfif>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="AnalyseProduct" access="public" returntype="struct" hint="analysis for a given product record">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.data = 
			{" BFwd" = {"stockQty" = 0, "stockValue" = 0, "salesQty" = 0, "salesValue" = 0,"tradeValue" = 0,
				"unitTrade" = 0,"profit" = 0,"wasteQty" = 0,"wasteValue" = 0,"POR" = 0},
			 "Total" = {"stockQty" = 0, "stockValue" = 0, "salesQty" = 0, "salesValue" = 0,"tradeValue" = 0,
			 	"unitTrade" = 0,"profit" = 0,"wasteQty" = 0,"wasteValue" = 0,"POR" = 0}
		}>		
		<cfif !StructKeyExists(args.form,"srchDateFrom") OR len(args.form.srchDateFrom) IS 0>
			<cfset loc.srchDateFrom = FormatDate("2013-01-01",'yyyy-mm-dd')>
		<cfelseif IsDate(args.form.srchDateFrom)>
			<cfset loc.srchDateFrom = FormatDate(args.form.srchDateFrom,'yyyy-mm-dd')>
		<cfelse>
			<cfset loc.srchDateFrom = "">
		</cfif>
		<cfif !StructKeyExists(args.form,"srchDateTo") OR len(args.form.srchDateTo) IS 0>
			<cfset loc.srchDateTo = LSDateFormat(Now(),"yyyy-mm-dd")>
		<cfelseif IsDate(args.form.srchDateTo)>
			<cfset loc.srchDateTo = DateAdd("d",1,args.form.srchDateTo)>
			<cfset loc.srchDateTo = FormatDate(args.form.srchDateTo,'yyyy-mm-dd')>
		<cfelse>
			<cfset loc.srchDateTo = LSDateFormat(Now(),"yyyy-mm-dd")>
		</cfif>
		<cfset loc.midnight = FormatDate(loc.srchDateTo,'yyyy-mm-dd')>
		<cfset loc.productID = val(args.form.productID)>
		
		<cfset loc.lastDate = DateFormat(loc.srchDateTo,'yyyy-mm')>
		<cfloop from="1" to="12" index="loc.i">
			<cfset StructInsert(loc.data,loc.lastDate,{
				"stockQty" = 0,
				"stockValue" = 0,
				"salesQty" = 0,
				"salesValue" = 0,
				"wasteQty" = 0,
				"wasteValue" = 0,
				"tradeValue" = 0,
				"unitTrade" = 0,
				"profit" = 0,
				"POR" = 0
			})>
			<cfset loc.lastDate = DateFormat(DateAdd("m",-1,loc.lastDate),'yyyy-mm')>
		</cfloop>
		<cfset loc.result.data = loc.data>	<!--- ? --->
		<cfset loc.result.datalist = ListSort(StructKeyList(loc.data,","),"text","ASC")>

		<cfquery name="loc.result.QProdInfo" datasource="#args.datasource#">	<!--- general info of this product --->
			SELECT prodID,prodRef,prodTitle,prodPriceMarked,prodCatID,prodVATRate,prodCountDate,prodStockLevel,prodStatus,
				pcatID,pgID,pcatTitle,pgTitle,pgTarget, 
				siID,siUnitSize,siUnitTrade,siOurPrice,siPackQty
			FROM tblProducts
			LEFT JOIN tblStockItem ON prodID = siProduct
			AND tblStockItem.siID = (
				SELECT MAX( siID )
				FROM tblStockItem
				WHERE prodID = siProduct
				AND siStatus = 'closed' )
			INNER JOIN tblProductCats ON prodCatID = pcatID
			INNER JOIN tblProductGroups ON pgID = pcatGroup
			WHERE prodID = #loc.productID#
		</cfquery>
		<cfquery name="loc.result.QStockBFwd" datasource="#args.datasource#">	<!--- items received prior to first date --->
			SELECT Max(soDate) AS lastDate, SUM(siQtyItems) AS purchQty, SUM(siWSP) AS WSP
			FROM tblStockItem
			INNER JOIN tblstockorder ON soID = siOrder
			WHERE siProduct = #loc.productID#
			AND soDate < '#loc.srchDateFrom#'
			AND siStatus = 'closed'
		</cfquery>
		<cfquery name="loc.result.QStockReceived" datasource="#args.datasource#">	<!--- stock received in specified period --->
			SELECT SUM(siQtyItems) AS Received, AVG(siUnitTrade) AS avgUnitTrade, DATE_FORMAT( soDate, '%Y-%m' ) AS YYMM
			FROM tblStockItem
			INNER JOIN tblstockorder ON soID = siOrder
			WHERE siProduct = #loc.productID#
			AND soDate BETWEEN '#loc.srchDateFrom#' AND '#loc.midnight#'
			AND siStatus = 'closed'
			GROUP BY YYMM
		</cfquery>
		<cfloop query="loc.result.QStockReceived">
			<cfif !StructKeyExists(loc.data,YYMM)>
				<cfset loc.prd = StructFind(loc.data," BFwd")>
				<cfset loc.prd.unitTrade = avgUnitTrade>
				<cfset loc.prd.stockQty += Received>
				<cfset loc.prd.stockValue += (Received * avgUnitTrade)>
				<!---<cfif loc.prd.stockQty neq 0><cfset loc.prd.unitTrade = loc.prd.stockValue / loc.prd.stockQty></cfif>--->
			<cfelse>
				<cfset loc.prd = StructFind(loc.data,YYMM)>
				<cfset loc.prd.unitTrade = avgUnitTrade>
				<cfset loc.prd.stockQty += Received>
				<cfset loc.prd.stockValue += (Received * avgUnitTrade)>
				<!---<cfif loc.prd.stockQty neq 0><cfset loc.prd.unitTrade = loc.prd.stockValue / loc.prd.stockQty></cfif>--->
			</cfif>
			<cfset loc.prd = StructFind(loc.data,"Total")>
			<cfset loc.prd.unitTrade = avgUnitTrade>
			<cfset loc.prd.stockQty += Received>
			<cfset loc.prd.stockValue += (Received * avgUnitTrade)>
			<!---<cfif loc.prd.stockQty neq 0><cfset loc.prd.unitTrade = loc.prd.stockValue / loc.prd.stockQty></cfif>--->
		</cfloop>
		
		<cfquery name="loc.result.QStockHistory" datasource="#args.datasource#">	<!--- overall history of this product --->
			SELECT SUM(siQtyItems) AS totalReceived, MIN(soDate) AS firstDate, MAX(soDate) AS lastDate
			FROM tblStockItem
			INNER JOIN tblstockorder ON soID = siOrder
			WHERE siProduct = #loc.productID#
			AND siStatus = 'closed'
		</cfquery>
		<cfquery name="loc.result.QSalesBFwd" datasource="#args.datasource#">	<!--- sales prior to specified period --->
			SELECT ehMode,SUM(eiQty) AS salesQty, SUM(eiNet) AS salesValue, SUM(eiTrade) AS tradeValue
			FROM tblepos_items
			INNER JOIN tblEpos_Header ON ehID = eiParent
			WHERE eiProdID = #loc.productID#
			AND eiTimeStamp < '#loc.srchDateFrom#'
			GROUP BY ehMode
		</cfquery>
		<cfquery name="loc.result.QSalesItems" datasource="#args.datasource#">	<!--- sales in specified period --->
			SELECT ehMode, SUM(eiQty) AS salesQty, SUM(-eiNet) AS salesValue, SUM(eiTrade) AS tradeValue, DATE_FORMAT( eiTimeStamp, '%Y-%m' ) AS YYMM
			FROM tblepos_items
			INNER JOIN tblEpos_Header ON ehID = eiParent
			WHERE eiProdID = #loc.productID#
			AND eiTimeStamp BETWEEN '#loc.srchDateFrom#' AND '#loc.midnight#'
			GROUP BY YYMM, ehMode
		</cfquery>
		<cfloop query="loc.result.QSalesItems">
			<cfif !StructKeyExists(loc.data,YYMM)>	<!--- data is too far back so add it to BFwd --->
				<cfset loc.prd = StructFind(loc.data," BFwd")>
			<cfelse>
				<cfset loc.prd = StructFind(loc.data,YYMM)>
			</cfif>
			<cfif ehMode eq 'wst'>
				<cfset loc.prd.wasteQty += salesQty>
				<cfset loc.prd.wasteValue += tradeValue>
			<cfelse>
				<cfset loc.prd.salesQty += salesQty>
				<cfset loc.prd.salesValue += salesValue>
				<cfset loc.prd.tradeValue += tradeValue>			
			</cfif>
			<cfset loc.prd.profit = loc.prd.salesValue - loc.prd.tradeValue - loc.prd.wasteValue>
			<cfif loc.prd.salesValue neq 0><cfset loc.prd.POR = Round((loc.prd.profit / loc.prd.salesValue) * 100) & "%"></cfif>
			<cfset loc.prd = StructFind(loc.data,"Total")>
			<cfif ehMode eq 'wst'>
				<cfset loc.prd.wasteQty += salesQty>
				<cfset loc.prd.wasteValue += tradeValue>
			<cfelse>
				<cfset loc.prd.salesQty += salesQty>
				<cfset loc.prd.salesValue += salesValue>
				<cfset loc.prd.tradeValue += tradeValue>
			</cfif>
			<cfset loc.prd.profit = loc.prd.salesValue - loc.prd.tradeValue - loc.prd.wasteValue>
			<cfif loc.prd.salesValue neq 0><cfset loc.prd.POR = Round((loc.prd.profit / loc.prd.salesValue) * 100) & "%"></cfif>
		</cfloop>
		
<!---
		<cfloop query="loc.result.QSalesItems">
			<cfif !StructKeyExists(loc.data,YYMM)>	<!--- data is too far back so add it to BFwd --->
				<cfset loc.prd = StructFind(loc.data," BFwd")>
				<cfset loc.prd.salesQty += salesQty>
				<cfset loc.prd.salesValue += salesValue>
				<cfset loc.prd.tradeValue += tradeValue>
				<cfset loc.prd.profit = loc.prd.salesValue - loc.prd.tradeValue - loc.prd.wasteValue>
				<cfif loc.prd.salesValue neq 0><cfset loc.prd.POR = Round((loc.prd.profit / loc.prd.salesValue) * 100) & "%"></cfif>
			<cfelse>
				<cfset loc.prd = StructFind(loc.data,YYMM)>
				<cfif ehMode eq 'wst'>
					<cfset loc.prd.wasteQty += salesQty>
					<cfset loc.prd.wasteValue += tradeValue>
				<cfelse>	<!--- sale --->
					<cfset loc.prd.salesQty += salesQty>
					<cfset loc.prd.tradeValue += tradeValue>
					<cfset loc.prd.salesValue += salesValue>
				</cfif>
				<cfset loc.prd.profit = loc.prd.salesValue - loc.prd.tradeValue - loc.prd.wasteValue>
				<cfif loc.prd.salesValue neq 0><cfset loc.prd.POR = Round((loc.prd.profit / loc.prd.salesValue) * 100) & "%"></cfif>
			</cfif>
			<cfset loc.prd = StructFind(loc.data,"Total")>
			<cfif ehMode eq 'wst'>
				<cfset loc.prd.wasteQty += salesQty>
				<cfset loc.prd.wasteValue += tradeValue>
			<cfelse>
				<cfset loc.prd.salesQty += salesQty>
				<cfset loc.prd.tradeValue += tradeValue>
				<cfset loc.prd.salesValue += salesValue>
				<cfset loc.prd.profit = loc.prd.salesValue - loc.prd.tradeValue - loc.prd.wasteValue>
				<cfif loc.prd.salesValue neq 0><cfset loc.prd.POR = Round((loc.prd.profit / loc.prd.salesValue) * 100) & "%"></cfif>
			</cfif>
		</cfloop>
--->		
		<cfset loc.prd = StructFind(loc.data," BFwd")>
		<cfset loc.unitTrade = loc.prd.unitTrade>
		<cfset loc.tradeAvg = 0>
		<cfset loc.accumStockQty = loc.prd.stockQty>
		<cfset loc.tradeCount = loc.accumStockQty neq 0>
		<cfloop list="#loc.result.datalist#" index="loc.key">
			<cfset loc.prd = StructFind(loc.data,loc.key)>
			<cfset loc.accumStockQty += loc.prd.stockQty>
			<cfif loc.key NEQ "Total">
				<cfif loc.prd.unitTrade neq 0 AND loc.prd.unitTrade neq loc.unitTrade>
					<cfset loc.unitTrade = loc.prd.unitTrade>			
				</cfif>
				<cfset loc.tradeAvg += loc.unitTrade>
				<cfif loc.accumStockQty gt 0><cfset loc.tradeCount++></cfif>
			</cfif>
			<cfset loc.prd.unitTrade = loc.unitTrade>
		</cfloop>
		<cfset loc.prd = StructFind(loc.data,"Total")>
		<cfif loc.tradeCount neq 0><cfset loc.prd.unitTrade = loc.tradeAvg / loc.tradeCount></cfif>	
		<cfset loc.result.priceMarked = GetToken(" |PM",loc.result.QProdInfo.prodPriceMarked+1,"|")>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="StockItemList2" access="public" returntype="struct" hint="stock items for a given product record">
		<cfargument name="args" type="struct" required="yes">

		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.action = "">
		<cftry>
			<cfif !StructKeyExists(args.form,"srchDateFrom") OR len(args.form.srchDateFrom) IS 0>
				<cfset loc.srchDateFrom = FormatDate("2013-01-01",'yyyy-mm-dd')>
			<cfelseif IsDate(args.form.srchDateFrom)>
				<cfset loc.srchDateFrom = FormatDate(args.form.srchDateFrom,'yyyy-mm-dd')>
			<cfelse>
				<cfset loc.srchDateFrom = "">
			</cfif>
			<cfif !StructKeyExists(args.form,"srchDateTo") OR len(args.form.srchDateTo) IS 0>
				<cfset loc.srchDateTo = LSDateFormat(Now(),"yyyy-mm-dd")>
			<cfelseif IsDate(args.form.srchDateTo)>
				<cfset loc.srchDateTo = DateAdd("d",1,args.form.srchDateTo)>
				<cfset loc.srchDateTo = FormatDate(args.form.srchDateTo,'yyyy-mm-dd')>
			<cfelse>
				<cfset loc.srchDateTo = "">
			</cfif>
			<cfset loc.productID = val(args.form.productID)>
			<cfif loc.productID neq 0>
				<cfquery name="loc.result.QProdInfo" datasource="#args.datasource#">	<!--- general info of this product and latest stock item --->
					SELECT prodID,prodRef,prodTitle,prodPriceMarked,prodCatID,prodVATRate,prodCountDate,prodStockLevel,prodStatus,
						pcatID,pgID,pcatTitle,pgTitle,pgTarget, 
						siID,siUnitSize,siUnitTrade,siOurPrice,siPackQty
					FROM tblProducts
					LEFT JOIN tblStockItem ON prodID = siProduct
					AND tblStockItem.siID = (
						SELECT MAX( siID )
						FROM tblStockItem
						WHERE prodID = siProduct )
					INNER JOIN tblProductCats ON prodCatID = pcatID
					INNER JOIN tblProductGroups ON pgID = pcatGroup
					WHERE prodID = #loc.productID#
				</cfquery>
				<cfif loc.result.QProdInfo.recordcount gt 0>
					<cfquery name="loc.result.StockItems" datasource="#args.datasource#">	<!--- stock records within given range --->
						SELECT tblStockItem.*, soRef,soDate,soStatus, accID,accName
						FROM tblStockItem
						LEFT JOIN tblStockOrder ON siOrder = soID
						INNER JOIN tblAccount on soAccountID = accID
						WHERE siProduct = #loc.productID#
						AND soDate BETWEEN '#loc.srchDateFrom#' AND '#loc.srchDateTo#'
						AND siStatus NOT IN ('promo')
						ORDER BY soDate DESC, siID DESC
					</cfquery>
				<cfelse>
					<cfset loc.result.msg = "Product not found">
					<cfset loc.result.action = "clear">
				</cfif>
			<cfelse>
				<cfset loc.result.msg = "No product ID supplied">
				<cfset loc.result.action = "clear">
			</cfif>
			<cfset loc.result.priceMarked = GetToken(" |PM",loc.result.QProdInfo.prodPriceMarked+1,"|")>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="StockItemList" access="public" returntype="struct" hint="stock items for a given product record">
		<cfargument name="args" type="struct" required="yes">
<cfdump var="#args#" label="StockItemList" expand="false">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.result.action = "">
		<cfset loc.barcode = Trim(args.form.bcode)>
<!---
		<cfif args.allStock>
			<cfset loc.lastYear = '2013-02-01'>
		<cfelse>
			<cfset loc.lastYear = DateAdd("d",Now(),-365)>
		</cfif>
		<cfset loc.startDate = CreateDate(Year(loc.lastYear),Month(loc.lastYear),1)>
--->
		<cfif len(args.form.srchDateFrom) IS 0>
			<cfset args.form.srchDateFrom = DateFormat(CreateDate(2013,1,1),'yyyy-mm-dd')>
		</cfif>
		<cfif len(args.form.srchDateTo) IS 0>
			<cfset args.form.srchDateTo = Now()>
		</cfif>
		<cfset loc.midnight = DateFormat(DateAdd("d",1,args.form.srchDateTo),'yyyy-mm-dd')>

		<cfset loc.args = args>
		<cftry>
			<cfif StructKeyExists(args.form,"productID") AND args.form.productID gt 0>
				<cfquery name="loc.QProduct" datasource="#args.datasource#">
					SELECT prodID,prodRef,prodTitle,prodPriceMarked,prodCatID,prodVATRate, pcatID,pgID,pcatTitle,pgTitle,pgTarget
					FROM tblProducts
					LEFT JOIN tblStockItem ON siProduct = prodID
					LEFT JOIN tblstockorder ON soID = siOrder
					INNER JOIN tblProductCats ON prodCatID = pcatID
					INNER JOIN tblProductGroups ON pgID = pcatGroup
					WHERE prodID = #val(args.form.productID)#
					LIMIT 1;	
				</cfquery>
			<cfelseif len(loc.barcode)>
				<cfquery name="loc.QProduct" datasource="#args.datasource#">
					SELECT prodID,prodRef,prodTitle,prodPriceMarked,prodCatID,prodVATRate, pcatID,pgID,pcatTitle,pgTitle,pgTarget
					FROM tblProducts
					INNER JOIN tblBarcodes on prodID = barProdID
					LEFT JOIN tblStockItem ON siProduct = prodID
					LEFT JOIN tblstockorder ON soID = siOrder
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
				<cfquery name="loc.result.StockItems" datasource="#args.datasource#" result="loc.result.StockItemsResult">
					SELECT tblStockItem.*, soRef,soDate,soStatus, accID,accName
					FROM tblStockItem
					LEFT JOIN tblStockOrder ON siOrder = soID
					INNER JOIN tblAccount on soAccountID = accID
					WHERE siProduct = #loc.QProduct.prodID#
					<!---AND soDate >= #loc.startDate#--->
					AND soDate BETWEEN '#DateFormat(args.form.srchDateFrom,'yyyy-mm-dd')#' AND '#loc.midnight#'
					AND siStatus NOT IN ('promo')
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
					pgTarget = #args.form.pgTarget#,
					pgShow = #args.form.pgShow#
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
				SELECT pgID,pgTitle,pgTarget,pgShow, Count(pcatID) AS Categories
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
				(pcatGroup,pcatTitle,pcatDescription) 
				VALUES (#args.form.pcatGroup#,'#args.form.pcatTitle#','#args.form.pcatDescription#')
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
					pcatGroup = #args.form.pcatGroup#,
					pcatShow = #val(args.form.pcatShow)#,
					pcatDescription = '#args.form.pcatDescription#'
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
				SELECT prodID,prodTitle,prodStatus,prodStaffDiscount,prodVATRate, siUnitSize,siOurPrice, pcatID,pcatTitle
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
					siStatus='outofstock',
					siReceived=0,
					soQtyItems=0
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
						siPOR=#DecimalFormat(QProduct.prodPOR)#		<!--- TODO should be siPOR --->
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





