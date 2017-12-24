<cfcomponent displayname="stock" extends="code/core">
	<cffunction name="SaveProductTitle" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.save" datasource="#args.datasource#">
			UPDATE tblProducts
			SET prodTitle = '#args.newTitle#'
			WHERE prodID = #val(args.product)#
		</cfquery>
	</cffunction>
	<cffunction name="LoadStockListFromArray" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cfquery name="loc.stockItems" datasource="#args.datasource#">
			SELECT *
			FROM tblStockItem, tblProducts, tblStockOrder
			WHERE siProduct = prodID
			AND siOrder = soID
			AND prodID IN (#args.stocklist#)
			GROUP BY prodID
			ORDER BY prodTitle, prodUnitSize
<!---
			ORDER BY soDate DESC
--->		</cfquery>
		
		<cfset loc.result.recordcount = loc.stockItems.recordcount>
		<cfset loc.result.stockItems = loc.stockItems>
		
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="GetSubstProduct" access="private" returntype="struct">
		<cfargument name="ID" type="numeric" required="yes">
		<cfargument name="datasource" type="string" required="yes">
		<cfset var loc={}>
		<cfset loc.rec={}>
		<cfquery name="loc.SubstituteProduct" datasource="#datasource#">
			SELECT *
			FROM tblProducts,tblStockItem,tblStockOrder,tblProductCats
			WHERE siProduct=prodID
			AND siOrder=soID
			AND pcatID=prodCatID
			AND siID=#ID#
			LIMIT 1;
		</cfquery>
		<cfif loc.SubstituteProduct.recordcount eq 1>
			<cfloop query="loc.SubstituteProduct">
				<cfquery name="loc.Qbarcode" datasource="#datasource#">
					SELECT *
					FROM tblBarcodes
					WHERE barProdID=#prodID#
					AND barType='product'
					ORDER BY barID desc
					LIMIT 1;
				</cfquery>
				<cfset loc.rec.msg="">
				<cfset loc.rec.QBarcode = loc.Qbarcode>
				<cfset loc.rec.barCode=loc.Qbarcode.barCode>
				<cfset loc.rec.prodID=prodID>
				<cfset loc.rec.prodRef=prodRef>
				<cfset loc.rec.prodTitle=prodTitle>
				<cfset loc.rec.prodPackQty=prodPackQty>
				<cfset loc.rec.prodPackPrice=prodPackPrice>
				<cfset loc.rec.prodUnitSize=prodUnitSize>
				<cfset loc.rec.prodOurPrice=prodOurPrice>
				<cfset loc.rec.prodValidTo=prodValidTo>
				<cfset loc.rec.prodUnitTrade=prodUnitTrade>
				<cfset loc.rec.prodRRP=prodRRP>
				<cfset loc.rec.prodVATRate=prodVATRate>
				<cfset loc.rec.prodPOR=prodPOR>
				<cfset loc.rec.prodPriceMarked=prodPriceMarked>
				<cfset loc.rec.siQtyPacks=siQtyPacks>
				<cfset loc.rec.siReceived=siReceived>
				<cfset loc.rec.siStatus=siStatus>
				<cfset loc.rec.siSubs=siSubs>
				<cfset loc.rec.category=pcatTitle>
			</cfloop>
		<cfelse>
			<cfset loc.rec.prodRef="not found">
		</cfif>
		<cfreturn loc.rec>
	</cffunction>

	<cffunction name="OrderDetails" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.result.count=0>
		<cfquery name="loc.OrderContents" datasource="#args.datasource#">
			SELECT *
			FROM tblProducts,tblStockItem,tblStockOrder,tblProductCats
			WHERE siProduct=prodID
			AND siOrder=soID
			AND pcatID=prodCatID
			AND soRef='#args.ref#'
		</cfquery>
<!---<cfdump var="#loc.OrderContents#" label="OrderContents" expand="yes" format="html" 
	output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
--->		<cfif loc.OrderContents.recordcount gt 0>
			<cfset loc.result.count=loc.OrderContents.recordcount>
			<cfset loc.result.OrderID=loc.OrderContents.soID>
			<cfset loc.result.OrderRef=args.ref>
			<cfset loc.result.OrderDate=LSDateFormat(loc.OrderContents.soDate,"ddd dd-mmm-yyyy")>
			<cfset loc.result.items=[]>
			<cfset loc.skips=[]>
			<cfloop query="loc.OrderContents">
				<cfif NOT ArrayFind(loc.skips,prodRef)>
					<cfquery name="loc.Qbarcode" datasource="#args.datasource#">
						SELECT *
						FROM tblBarcodes
						WHERE barProdID=#val(loc.OrderContents.prodID)#
						AND barType='product'
						ORDER BY barID desc
						LIMIT 1;
					</cfquery>
					<cfquery name="loc.checkBefore" datasource="#args.datasource#">
						SELECT *
						FROM tblStockItem
						WHERE siProduct = #val(loc.OrderContents.prodID)#
						AND siID != #val(loc.OrderContents.siID)#
						ORDER BY siID DESC
						LIMIT 1;
					</cfquery>
					
					<cfset loc.rec={}>
					<cfset loc.rec.msg="">
					<cfif siSubs gt 0>
						<cfset loc.msg="Substitute for: #prodRef#">
						<cfset loc.rec=GetSubstProduct(siSubs,args.datasource)>
						<cfset loc.rec.msg=loc.msg>
                        <cfset loc.rec.newFlag = true>
                        <cfset loc.rec.changedFlag = false>
						<cfset ArrayAppend(loc.result.items,loc.rec)>
						<cfset ArrayAppend(loc.skips,loc.rec.prodRef)>
					<cfelse>
						<cfset loc.rec.QbarCode=loc.Qbarcode>
						<cfset loc.rec.barCode=loc.Qbarcode.barCode>
						<cfset loc.rec.prodID=prodID>
						<cfset loc.rec.prodRef=prodRef>
						<cfset loc.rec.prodTitle=prodTitle>
						<cfset loc.rec.prodPackQty=prodPackQty>
						<cfset loc.rec.prodPackPrice=prodPackPrice>
						<cfset loc.rec.prodUnitSize=prodUnitSize>
						<cfset loc.rec.prodOurPrice=prodOurPrice>
						<cfset loc.rec.prodValidTo=prodValidTo>
						<cfset loc.rec.prodLastBought=prodLastBought>
						<cfset loc.rec.prodUnitTrade=prodUnitTrade>
						<cfset loc.rec.prodRRP=prodRRP>
						<cfset loc.rec.prodVATRate=prodVATRate>
						<cfset loc.rec.prodPOR=prodPOR>
						<cfset loc.rec.prodPriceMarked=prodPriceMarked>
						<cfset loc.rec.siQtyPacks=siQtyPacks>
						<cfset loc.rec.siReceived=siReceived>
						<cfset loc.rec.siStatus=siStatus>
						<cfset loc.rec.siSubs=siSubs>
						<cfset loc.rec.category=pcatTitle>
						
						<cfset loc.rec.newFlag = (loc.checkBefore.recordcount is 0) ? true : false>
						<cfif !loc.rec.newFlag>
							<cfset loc.rec.changedFlag = (val(loc.OrderContents.siOurPrice) neq val(loc.checkBefore.siOurPrice)) ? true : false>
						<cfelse>
							<cfset loc.rec.changedFlag = false>
						</cfif>
						
						<cfset ArrayAppend(loc.result.items,loc.rec)>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="StockItemList" access="public" returntype="struct" hint="stock items for a given product record">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfquery name="loc.StockItems" datasource="#args.datasource#">
			SELECT tblStockItem.*, prodID,prodRef,prodTitle,prodLastBought,prodPriceMarked,prodOurPrice,prodPackQty,prodStockLevel, soRef,soDate,soStatus
			FROM tblStockItem,tblProducts,tblStockOrder
			WHERE siProduct=prodID
			AND siOrder=soID
			AND prodID='#args.ref#'
			ORDER BY soDate DESC, siID DESC
		</cfquery>
		<cfset loc.result.recordcount=loc.StockItems.recordcount>
		<cfset loc.result.StockItems=loc.StockItems>
		<cfset loc.result.prodID=loc.StockItems.prodID>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ProductBarcodes" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cftry>
			<cfset loc.result.barcodes = []>
			<cfquery name="loc.QBarcodes" datasource="#args.datasource#" result="loc.qresult">
				SELECT *
				FROM tblbarcodes
				WHERE barProdID	= #val(args.ref)#
				AND barType = 'product'
			</cfquery>
			<cfloop query="loc.QBarcodes">
				<cfset ArrayAppend(loc.result.barcodes,{"ID"=barID,"code"=barcode})>
			</cfloop>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="StockPriceList" access="public" returntype="struct" hint="product records for recent orders">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfquery name="loc.result.StockItems" datasource="#args.datasource#">
			SELECT pcatGroup,pcatTitle,prodID,prodCatID,prodRef,prodTitle,prodLastBought,prodValidTo,prodUnitSize,prodPriceMarked,prodOurPrice,prodPOR,
				(SELECT siOurPrice FROM tblStockItem WHERE siProduct=prodID ORDER BY siID DESC LIMIT 1) AS ourPrice
			FROM tblProducts,tblProductCats
			WHERE prodCatID=pcatID
			<cfif StructKeyExists(args.form,"srchCategory") AND len(args.form.srchCategory) GT 0>AND prodCatID IN (#args.form.srchCategory#)</cfif>
			<cfif len(args.form.srchCatStr) GT 0>AND pcatTitle LIKE '%#args.form.srchCatStr#%'</cfif>
			<cfif len(args.form.srchProdStr) GT 0>AND prodTitle LIKE '%#args.form.srchProdStr#%'</cfif>
			<cfif len(args.form.srchDateFrom) GT 0>AND prodLastBought >= '#args.form.srchDateFrom#'</cfif>
			<cfif len(args.form.srchDateTo) GT 0>AND (prodLastBought IS null OR prodLastBought <= '#args.form.srchDateTo#')</cfif>
			ORDER BY pcatTitle ASC,prodTitle ASC
		</cfquery>
		<cfset loc.result.recCount=loc.result.StockItems.recordcount>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadCategories" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		
		<cfquery name="loc.result.QCategories" datasource="#args.datasource#">
			SELECT * FROM tblProductCats ORDER BY pCatTitle
		</cfquery>
		<cfset loc.result.recordcount=loc.result.QCategories.recordcount>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="StockSearch" access="public" returntype="struct" hint="search for product records">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.status = "">
		<cfif StructKeyExists(args.form,"srchStatus")>
			<cfloop list="#args.form.srchStatus#" index="loc.item" delimiters=",">
				<cfset loc.status = "#loc.status#,'#loc.item#'">
			</cfloop>
			<cfset loc.status = Removechars(loc.status,1,1)>
		</cfif>
		<cfquery name="loc.result.StockItems" datasource="#args.datasource#" result="loc.result.StockItemsResult">
			SELECT *
			FROM tblProducts
			JOIN tblProductCats ON prodCatID=pcatID
			<cfif StructKeyExists(args.form,"srchSupplier")>JOIN tblAccount ON prodSuppID=accID</cfif>
			LEFT JOIN tblStockItem ON prodID = siProduct
			AND tblStockItem.siID = (
				SELECT MAX( siID )
				FROM tblStockItem
				WHERE prodID = siProduct
				<cfif StructKeyExists(args.form,"srchStatus")>AND siStatus IN (#PreserveSingleQuotes(loc.status)#)</cfif> )
			WHERE prodCatID=pcatID
			<cfif StructKeyExists(args.form,"srchSupplier") AND len(args.form.srchSupplier) GT 0>AND prodSuppID IN (#args.form.srchSupplier#) AND prodSuppID=accID</cfif>
			<cfif StructKeyExists(args.form,"srchCategory") AND len(args.form.srchCategory) GT 0>AND prodCatID IN (#args.form.srchCategory#)</cfif>
			<cfif len(args.form.srchCatStr) GT 0>AND pcatTitle LIKE '%#args.form.srchCatStr#%'</cfif>
			<cfif len(args.form.srchProdStr) GT 0>AND prodTitle LIKE '%#args.form.srchProdStr#%'</cfif>
			<cfif len(args.form.srchDateFrom) GT 0>AND prodLastBought >= '#args.form.srchDateFrom#'</cfif>
			<cfif len(args.form.srchDateTo) GT 0>AND (prodLastBought IS null OR prodLastBought <= '#args.form.srchDateTo#')</cfif>
			<cfif len(args.form.srchStockDate) GT 0>AND prodCountDate >= '#args.form.srchStockDate#'</cfif>
			ORDER BY pcatTitle ASC,prodTitle ASC
		</cfquery>
		<cfset loc.result.recCount=loc.result.StockItems.recordcount>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="AddProductBarcode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		
		<cftry>
			<cfset loc.result.msg="">
			<cfquery name="loc.QCheckExists" datasource="#args.datasource#">
				SELECT * FROM tblBarcodes WHERE barCode='#args.form.newCode#'
			</cfquery>
			<cfif loc.QCheckExists.recordcount EQ 0>
				<cfquery name="loc.QAddBarcode" datasource="#args.datasource#" result="loc.QAddBarcodeResult">
					INSERT INTO tblBarcodes
					(barProdID,barcode) 
					VALUES (#args.form.prodID#,'#args.form.newCode#')
				</cfquery>
				<cfset loc.result.msg="Barcode added: #args.form.newCode#">
			<cfelse>
				<cfset loc.result.msg="that barcode already exists: #args.form.newCode#">
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="DeleteProductBarcode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		
		<cftry>
			<cfset loc.result.msg="">
			<cfquery name="loc.QCheckExists" datasource="#args.datasource#">
				SELECT * FROM tblBarcodes WHERE barID='#args.ID#'
			</cfquery>
			<cfif loc.QCheckExists.recordcount IS 1>
				<cfquery name="loc.QDeleteBarcode" datasource="#args.datasource#" result="loc.QDeleteBarcodeResult">
					DELETE FROM tblBarcodes
					WHERE barID=#val(args.ID)#
					LIMIT 1;
				</cfquery>
				<cfset loc.result.msg="barcode record deleted.">
			<cfelse>
				<cfset loc.result.msg="barcode record not found.">
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

<!--- New 2016 --->

	<cffunction name="UpdateStockLevel" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QProduct" datasource="#args.datasource#">
				UPDATE tblProducts
				SET prodStockLevel = #val(args.form.stockLevel)#,
					prodCountDate = #Now()#
				WHERE prodID=#val(args.form.prodID)#
			</cfquery>
			<cfif len(args.form.expiryDate)>
				<cfquery name="loc.QStock" datasource="#args.datasource#">
					UPDATE tblStockItem
					SET siExpires = '#LSDateFormat(args.form.expiryDate,"yyyy-mm-dd")#'
					WHERE siID=#val(args.form.siID)#
				</cfquery>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="StockTakeList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QStock" datasource="#args.datasource#" result="loc.result.QStockResult">
				SELECT prodID,prodCatID,prodRef,prodTitle,prodUnitSize,prodCountDate,prodStockLevel,prodUnitTrade,prodPriceMarked,prodLastBought,
					(SELECT siOurPrice FROM tblStockItem WHERE siProduct=prodID ORDER BY siID DESC LIMIT 1) AS ourPrice,
					(SELECT siUnitTrade FROM tblStockItem WHERE siProduct=prodID ORDER BY siID DESC LIMIT 1) AS unitTrade,
					pcatTitle
				FROM tblProducts
				INNER JOIN tblProductCats ON prodCatID=pcatID
				WHERE prodCountDate IS NOT NULL
				<cfif len(args.form.srchStockDate) GT 0>AND prodCountDate >= '#args.form.srchStockDate#'</cfif>
				ORDER BY pCatID,prodTitle
			</cfquery>
			<cfset loc.result.QStock = loc.QStock>
			<cfset loc.result.recCount = loc.QStock.recordcount>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>