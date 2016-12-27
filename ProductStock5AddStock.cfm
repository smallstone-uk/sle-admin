
	<cffunction name="AddStockItem" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.args = args>
		<cftry>
			<!--- locate manual order for specified date --->
			<cfquery name="loc.QFindOrder" datasource="#application.site.datasource1#">
				SELECT * FROM tblStockOrder
				WHERE soDate = '#args.soDate#'
				AND soScanned IS NULL
			</cfquery>
			<cfif loc.QFindOrder.recordCount IS 0>
				<cfquery name="loc.QInsertOrder" datasource="#application.site.datasource1#" result="loc.QInsertOrderResult">
					INSERT INTO tblStockOrder (
						soAccountID,soRef,soDate,soStatus
					) VALUES (
						0,'#DateFormat(args.soDate,"yyyymmdd")#','#args.soDate#','closed'
					)
				</cfquery>
				<cfset loc.orderID = loc.QInsertOrderResult.generatedkey>
			<cfelse>
				<cfset loc.orderID = loc.QFindOrder.soID>
			</cfif>
				
			<cfset loc.vrate = StructFind(application.site.vat,prodVATCode)>
			<cfset loc.result.items = args.prodPackQty * siQtyPacks>
			<cfset loc.result.totalTrade = val(args.siQtyPacks) * val(args.prodPackPrice)>
			<cfset loc.result.unitNetTrade = val(args.prodPackPrice) / args.prodPackQty>
			<cfset loc.result.unitNetRetail = int(args.prodOurPrice * 100 / (1 + loc.vrate)) / 100>
			<cfset loc.result.wspGross = loc.result.totalTrade * (1 + loc.vrate)>
			<cfset loc.result.totalRetail = loc.result.items * args.prodOurPrice>
			<cfset loc.result.profit = loc.result.totalRetail - loc.result.wspGross>
			<cfset loc.result.POR = (loc.result.profit / loc.result.totalRetail) * 100>
			<cfif loc.result.items neq 0>
				<cfquery name="loc.QAddStockItem" datasource="#application.site.datasource1#">
					INSERT INTO tblStockItem (
						siOrder,siProduct,siQtyPacks,siQtyItems,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siReceived,siExpires,siStatus
					) VALUES (
						#loc.orderID#,
						#args.productID#,
						#val(args.siQtyPacks)#,
						#val(loc.result.items)#,
						#args.prodPackPrice#,
						#loc.result.unitNetTrade#,
						#args.prodRRP#,
						#args.prodOurPrice#,
						#loc.result.POR#,
						#val(loc.result.items)#,
						<cfif len(siExpires)>'#siExpires#',<cfelse>null,</cfif>
						'closed'
					)	
				</cfquery>
				<cfquery name="loc.QUpdateProduct" datasource="#application.site.datasource1#">
					UPDATE tblProducts
					SET prodLastBought = '#args.soDate#',
						prodRRP = #args.prodRRP#,
						prodOurPrice = #args.prodOurPrice#,
						prodPackQty = #args.prodPackQty#,
						prodPackPrice = #args.prodPackPrice#,
						prodUnitTrade = #loc.result.unitNetTrade#,
						prodUnitSize = '#args.prodUnitSize#',
						prodPOR = #loc.result.POR#,
						prodPriceMarked = #int(StructKeyExists(args,"prodPriceMarked"))#,
						prodCatID = #args.prodCatID#
					WHERE prodID = #args.productID#
				</cfquery>
			<cfelse>
				<cfset loc.result.msg = "Stock quantity received was zero.">
			</cfif>
			<cfset loc.result.msg = "Stock item added.">
		<cfcatch type="any">
			<cfset loc.result.msg = "An error occurred adding this stock item.">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
<cfset result = AddStockItem(form)>
<cfoutput>
	#result.msg#
</cfoutput>
