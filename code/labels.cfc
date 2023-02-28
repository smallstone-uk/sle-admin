<cfcomponent displayname="labels" extends="core">

	<cffunction name="LoadPriceLabels" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var result.list=[]>
		<cfset var QProduct="">
		<cfset var item={}>
		
		<cfquery name="QProduct" datasource="#args.datasource#">
			SELECT *
			FROM tblProducts
			<cfif StructKeyExists(args,"type")>WHERE prodCatID=#val(args.type)#</cfif>
		</cfquery>
		<cfloop query="QProduct">
			<cfset item={}>
			<cfset item.ID=prodID>
			<!---<cfset item.Barcode=prodBarcode>--->
			<cfset item.Barcode="">
			<cfset item.Title=prodTitle>
			<cfif DecimalFormat(prodOurPrice) lt 1.00>
				<cfset item.Price=NumberFormat(Right(DecimalFormat(prodOurPrice),2),"99")&"p">
			<cfelse>
				<cfset item.Price="&pound;"&DecimalFormat(REReplace(REReplace(prodOurPrice, "0+$", "", "ALL"), "\.+$", ""))>
			</cfif>
			<cfset item.UnitSize=prodUnitSize>
			<!---<cfset barcode=prodBarcode>--->
			<cfset barcode="">
			<cfif len(barcode) eq 8>
				<cfset item.BarcodeType="ean8">
			<cfelseif len(barcode) eq 12>
				<cfset item.BarcodeType="code11">
			<cfelse>
				<cfset item.BarcodeType="upc">
			</cfif>
			<cfset ArrayAppend(result.list,item)>
		</cfloop>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadPriceLabelsFromList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QProduct="">
		<cfset var QBarcode="">
		<cfset var QDeals="">
		<cfset var item={}>
		<cfset var intNum=false>
		<cfset var d={}>
		<cfset result.list=[]>
		<cfset result.deals={}>
		
		<cfif StructKeyExists(args.form,"selectitem")>
			<cfquery name="QProduct" datasource="#args.datasource#">
				SELECT *
				FROM tblProducts
				WHERE prodID IN (#args.form.selectitem#)
			</cfquery>
			<cfloop query="QProduct">
				<cfquery name="QBarcode" datasource="#args.datasource#">
					SELECT *
					FROM tblBarcodes
					WHERE barType='product'
					AND barProdID=#prodID#
				</cfquery>
				<cfset item={}>
				<cfset item.ID=prodID>
				<cfset item.Barcode=QBarcode.barCode>
				<cfset item.Title=prodTitle>
				<cfif prodOurPrice eq 0>
					<cfset item.Price="">
				<cfelseif prodOurPrice lt 1.00>
					<cfset item.Price=NumberFormat(Right(DecimalFormat(prodOurPrice),2),"99")&"p">
				<cfelse>
					<cfset intNum=IsValid("integer",prodOurPrice)>
					<cfif intNum>
						<cfset item.Price="&pound;"&Int(prodOurPrice)>
					<cfelse>
						<cfset item.Price="&pound;"&DecimalFormat(REReplace(REReplace(prodOurPrice, "0+$", "", "ALL"), "\.+$", ""))>
					</cfif>
				</cfif>
				<cfset item.UnitSize=prodUnitSize>
				<cfif len(item.Barcode) eq 8>
					<cfset item.BarcodeType="ean8">
				<cfelseif len(item.Barcode) eq 12>
					<cfset item.BarcodeType="code11">
				<cfelse>
					<cfset item.BarcodeType="upc">
				</cfif>
				<cfset ArrayAppend(result.list,item)>
				
				<cfquery name="QDeals" datasource="#args.datasource#">
					SELECT *
					FROM tblDealItems,tblDeals
					WHERE dimProdID=#item.ID#
					AND dimDealID=dealID
				</cfquery>
				<cfif QDeals.recordcount neq 0>
					<cfloop query="QDeals">
						<cfset d={}>
						<cfset d.ID=item.ID>
						<cfset d.Barcode=item.Barcode>
						<cfset d.Title=item.Title>
						<cfset d.DealID=QDeals.dealID>
						<cfset d.Deal=QDeals.dealTitle>
						<cfset d.Type=QDeals.dealType>
						<cfset d.Qty=QDeals.dealQty>
						<cfset d.Amount=QDeals.dealAmount>
						<cfset d.Price=item.Price>
						<cfset d.UnitSize=item.UnitSize>
						<cfset d.BarcodeType=item.BarcodeType>
						<cfif StructKeyExists(result.deals,d.DealID)>
							<cfset deal=StructFind(result.deals,d.DealID)>
							<cfset d.Title=deal.Title&", "&item.Title>
							<cfset StructUpdate(result.deals,d.DealID,d)>
						<cfelse>
							<cfset StructInsert(result.deals,d.DealID,d)>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadDealLabelsFromList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QDeals="">
		<cfset var QBarcode="">
		<cfset var item={}>
		<cfset var intNum=false>
		<cfset var d={}>
		<cfset result.list=[]>
		<cfset result.deals={}>
		
		<cfif StructKeyExists(args.form,"selectitem")>
			<cfquery name="QDeals" datasource="#args.datasource#">
				SELECT *
				FROM tblDealItems,tblDeals,tblProducts
				WHERE dimDealID IN (#args.form.selectitem#)
				AND dimDealID=dealID
				AND dimProdID=prodID
			</cfquery>
			<cfloop query="QDeals">
				<cfquery name="QBarcode" datasource="#args.datasource#">
					SELECT *
					FROM tblBarcodes
					WHERE barType='product'
					AND barProdID=#prodID#
				</cfquery>
				<cfset item={}>
				<cfset item.ID=prodID>
				<cfset item.Barcode=QBarcode.barCode>
				<cfset item.Title=prodTitle>
				<cfif DecimalFormat(prodOurPrice) lt 1.00>
					<cfset item.Price=NumberFormat(Right(DecimalFormat(prodOurPrice),2),"99")&"p">
				<cfelse>
					<cfset intNum=IsValid("integer",prodOurPrice)>
					<cfif intNum>
						<cfset item.Price="&pound;"&Int(prodOurPrice)>
					<cfelse>
						<cfset item.Price="&pound;"&DecimalFormat(REReplace(REReplace(prodOurPrice, "0+$", "", "ALL"), "\.+$", ""))>
					</cfif>
				</cfif>
				<cfset item.UnitSize=prodUnitSize>
				<cfif len(item.Barcode) eq 8>
					<cfset item.BarcodeType="ean8">
				<cfelseif len(item.Barcode) eq 12>
					<cfset item.BarcodeType="code11">
				<cfelse>
					<cfset item.BarcodeType="upc">
				</cfif>
				<cfset item.RecordTitle=dealRecordTitle>
				<cfset item.dealTitle=dealTitle>
				<cfset item.Datestamp=dealDatestamp>
				<cfset item.Starts=LSDateFormat(dealStarts,"dd/mm/yyyy")>
				<cfset item.Ends=LSDateFormat(dealEnds,"dd/mm/yyyy")>
				<cfset item.Type=dealType>
				<cfset item.Amount=dealAmount>
				<cfset item.Qty=dealQty>
				<cfset item.Status=dealStatus>
				<cfset ArrayAppend(result.list,item)>
			</cfloop>
		</cfif>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadPriceLabelsFromCache" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var result.list=[]>
		<cfset var QProduct="">
		<cfset var item={}>
		
		<cfquery name="QProduct" datasource="#args.datasource#">
			SELECT *
			FROM tblProductStock,tblProducts
			WHERE pskTimestamp='#LSDateFormat(Now(),"yyyy-mm-dd")#'
			AND pskProdID=prodID
		</cfquery>
		<cfloop query="QProduct">
			<cfset item={}>
			<cfset item.ID=prodID>
			<cfset item.Barcode=prodBarcode>
			<cfset item.Title=prodTitle>
			<cfif DecimalFormat(prodOurPrice) lt 1.00>
				<cfset item.Price=NumberFormat(Right(DecimalFormat(prodOurPrice),2),"99")&"p">
			<cfelse>
				<cfset item.Price="&pound;"&DecimalFormat(Replace(REReplace(prodOurPrice, "0+$", "", "ALL"), "\.+$", ""))>
			</cfif>
			<cfset item.UnitSize=prodUnitSize>
			<cfset barcode=prodBarcode>
			<cfif len(barcode) gt 8>
				<cfset item.BarcodeType="upc">
			<cfelse>
				<cfset item.BarcodeType="ean8">
			</cfif>
			<cfset ArrayAppend(result.list,item)>
		</cfloop>

		<cfreturn result>
	</cffunction>
	
</cfcomponent>