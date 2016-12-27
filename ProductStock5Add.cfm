	
	<cffunction name="AddRecords" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.barcode = Trim(args.barcode)>
		<cftry>
			<cfset args.prodPackPrice = val(args.prodPackPrice)>
			<cfset args.prodRRP = val(args.prodRRP)>
			<cfset args.prodOurPrice = val(args.prodOurPrice)>
			<cfquery name="loc.QBarcode" datasource="#application.site.datasource1#" result="loc.result.QBarcodeResult">
				SELECT *
				FROM tblBarcodes
				WHERE barCode LIKE '%#loc.barcode#%'
				AND barType = 'product'
				LIMIT 1;
			</cfquery>
			<!--- locate manual order for specified date --->
			<cfquery name="loc.QFindOrder" datasource="#application.site.datasource1#">
				SELECT * FROM tblStockOrder
				WHERE soDate = '#args.soDate#'
				AND soAccountID = #val(args.accID)#
				AND soScanned IS NULL
			</cfquery>
			<cfif loc.QFindOrder.recordCount IS 0>
				<cfquery name="loc.QInsertOrder" datasource="#application.site.datasource1#" result="loc.QInsertOrderResult">
					INSERT INTO tblStockOrder (
						soAccountID,soRef,soDate,soStatus
					) VALUES (
						#val(args.accID)#,'#DateFormat(args.soDate,"yyyymmdd")#','#args.soDate#','closed'
					)
				</cfquery>
				<cfset loc.orderID = loc.QInsertOrderResult.generatedkey>
			<cfelse>
				<cfset loc.orderID = loc.QFindOrder.soID>
			</cfif>
			<cfset loc.vrate = StructFind(application.site.vat,prodVATCode)>
			<cfquery name="loc.QAddProduct" datasource="#application.site.datasource1#" result="loc.QAddProductResult">
				INSERT INTO tblProducts (
					prodSuppID,
					prodRef,
					prodRecordTitle,
					prodTitle,
					prodUnitSize,
					prodPackQty,
					prodPackPrice,
					prodRRP,
					prodOurPrice,
					<cfif StructKeyExists(args,"prodPriceMarked")>prodPriceMarked,</cfif>
					prodVatRate,
					prodLastBought,
					prodCatID
					
				) VALUES (
					#args.accID#,
					'#args.prodRef#',
					'#args.prodRecordTitle#',
					'#args.prodRecordTitle#',
					'#args.prodUnitSize#',
					'#args.prodPackQty#',
					#val(args.prodPackPrice)#,
					#val(args.prodRRP)#,
					#val(args.prodOurPrice)#,
					<cfif StructKeyExists(args,"prodPriceMarked")>1,</cfif>					
					#loc.vrate * 100#,
					'#args.soDate#',
					#args.prodCatID#
				)
			</cfquery>
			<cfset loc.result.productID = loc.QAddProductResult.generatedkey>
			
			<cfif loc.QBarcode.recordcount eq 1>
				<cfquery name="loc.QUpdateBarcode" datasource="#application.site.datasource1#" result="loc.result.QBarcodeResult">
					UPDATE tblBarcodes
					SET barProdID = #loc.result.productID#
					WHERE barID = #loc.QBarcode.barID#
				</cfquery>
			<cfelse>
				<cfquery name="loc.QAddBarCode" datasource="#application.site.datasource1#" result="loc.QAddBarcodeResult">
					INSERT INTO tblBarcodes (
						barCode,
						barType,
						barProdID
					) VALUES (
						'#args.barcode#',
						'product',
						#loc.result.productID#
					)
				</cfquery>
				<cfset loc.result.BarcodeID = loc.QAddBarcodeResult.generatedkey>
			</cfif>
			<cfset loc.result.retailNet = int(args.prodOurPrice * 100 / (1 + loc.vrate)) / 100>	<!--- net unit price per item --->
			<cfset loc.result.totalValue = val(args.prodPackQty) * loc.result.retailNet>	<!--- net retail value of pack --->
			<cfset loc.result.profit = loc.result.totalValue - args.prodPackPrice>
			<cfset loc.result.POR = (loc.result.profit / loc.result.totalValue) * 100>
			<cfset loc.result.items = val(args.prodPackQty) * val(args.siQtyPacks)>
			<cfquery name="loc.QAddStockItem" datasource="#application.site.datasource1#" result="loc.QAddStockResult">
				INSERT INTO tblStockItem (
					siOrder,siProduct,siQtyPacks,siQtyItems,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siReceived,siExpires,siStatus
				) VALUES (
					#loc.orderID#,
					#loc.result.productID#,
					#val(args.siQtyPacks)#,
					#loc.result.items#,
					#args.prodPackPrice#,
					<cfif loc.result.items gt 0>#args.prodPackPrice / args.prodPackQty#,</cfif>
					#args.prodRRP#,
					#args.prodOurPrice#,
					#loc.result.POR#,
					#loc.result.items#,
					<cfif len(siExpires)>'#siExpires#',<cfelse>null,</cfif>
					'closed'
				)	
			</cfquery>
			<cfset loc.result.StockItemID = loc.QAddStockResult.generatedkey>
			<cfset loc.result.msg = "Product added.">

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

<cfset result = AddRecords(form)>
<cfoutput>
	#result.msg#
</cfoutput>
