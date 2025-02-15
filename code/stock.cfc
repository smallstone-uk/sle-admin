<cfcomponent displayname="stock" extends="code/core">
	<cffunction name="SaveProductDiscount" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.save" datasource="#args.datasource#">
			UPDATE tblProducts
			SET prodStaffDiscount = '#args.newDiscount#'
			WHERE prodID = #val(args.product)#
		</cfquery>
	</cffunction>
	<cffunction name="SaveProductStatus" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.save" datasource="#args.datasource#">
			UPDATE tblProducts
			SET prodStatus = '#args.newStatus#'
			WHERE prodID = #val(args.product)#
		</cfquery>
	</cffunction>
	<cffunction name="SaveProductLock" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfif args.newLock eq 'locked'>
			<cfset loc.lock = 1>
		<cfelse><cfset loc.lock = 0></cfif>
		<cfquery name="loc.save" datasource="#args.datasource#">
			UPDATE tblProducts
			SET prodLocked = #loc.lock#
			WHERE prodID = #val(args.product)#
		</cfquery>
	</cffunction>
	<cffunction name="SaveProductReorder" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.save" datasource="#args.datasource#">
			UPDATE tblProducts
			SET prodReorder = '#args.newReorder#'
			WHERE prodID = #val(args.product)#
		</cfquery>
	</cffunction>
	<cffunction name="SaveProductTitle" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.save" datasource="#args.datasource#">
			UPDATE tblProducts
			SET prodTitle = '#args.newTitle#'
			WHERE prodID = #val(args.product)#
		</cfquery>
	</cffunction>
	
	<cffunction name="SaveProductWSP" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
			<cfdump var="#args#" label="SaveProductWSP" expand="yes" format="html" 
				output="#application.site.dir_logs#args-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		<cftry>
			<cfset var loc = {}>
			<cfset loc.wsp = args.newWSP>
			<cfset loc.unitTrade = args.newWSP / args.packQty>
			<cfset loc.profit = args.ourPrice - (loc.unitTrade * (1 + (args.vatRate / 100)))>
			<cfset loc.POR = (loc.profit / args.ourPrice) * 100>
			<cfset loc.tradeTotal = args.newWSP * args.qtyPacks>
			<cfquery name="loc.save" datasource="#args.datasource#">
				UPDATE tblStockItem
				SET siWSP = '#loc.wsp#',
					siUnitTrade = #loc.unitTrade#,
					siPOR = #loc.POR#
				WHERE siID = #val(args.stockID)#
			</cfquery>
			<cfreturn loc>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="SaveProductWSP" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="SaveProductStock" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.save" datasource="#args.datasource#">
				UPDATE tblProducts
				SET prodStockLevel = #val(args.stockLevel)#,
					prodCountDate = '2018-10-28'	<!--- day before first date EPOS till was used --->
				WHERE prodID=#val(args.product)#
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
						<cfset loc.rec.siID=siID>
						<cfset loc.rec.siQtyPacks=siQtyPacks>
						<cfset loc.rec.siQtyItems=siQtyItems>
						<cfset loc.rec.siWSP=siWSP>
						<cfset loc.rec.siUnitTrade=siUnitTrade>
						<cfset loc.rec.siOurPrice=siOurPrice>
						<cfset loc.rec.siPOR=siPOR>
						<cfset loc.rec.siReceived=siReceived>
						<cfset loc.rec.siStatus=siStatus>
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
		output="#application.site.dir_logs#dump-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
--->
		<cfif loc.OrderContents.recordcount gt 0>
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
						<cfset ArrayAppend(loc.skips,loc.rec.prodRef)><em></em>
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
						<cfset loc.rec.siID=siID>
						<cfset loc.rec.siQtyPacks=siQtyPacks>
						<cfset loc.rec.siQtyItems=siQtyItems>
						<cfset loc.rec.siWSP=siWSP>
						<cfset loc.rec.siUnitTrade=siUnitTrade>
						<cfset loc.rec.siOurPrice=siOurPrice>
						<cfset loc.rec.siPOR=siPOR>
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
				(SELECT siOurPrice FROM tblStockItem WHERE siProduct=prodID ORDER BY siID DESC LIMIT 1) AS ourStockPrice
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

<!---
SELECT * FROM tblProducts 
JOIN tblProductCats ON prodCatID=pcatID 
LEFT JOIN tblStockItem ON prodID = siProduct 
JOIN tblstockorder ON siOrder=soID
JOIN tblaccount ON soAccountID=accID 
AND tblStockItem.siID = ( SELECT MAX( siID ) FROM tblStockItem WHERE prodID = siProduct ) 
WHERE prodCatID=pcatID 
AND accID IN (802) 
ORDER BY pcatTitle ASC,prodTitle ASC

new version 28/03/2019
SELECT * 
FROM tblproducts a
INNER JOIN (
    SELECT tblstockitem.*,tblstockorder.*, MAX(siID)
    FROM tblstockitem
    INNER JOIN tblstockorder ON soID=siOrder
    GROUP BY siProduct
) b ON (a.prodID=b.siProduct)
WHERE soDate > '2019-01-01' 
ORDER BY prodCatID,prodTitle  ASC


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
		<cfquery name="loc.result.StockItems" datasource="#args.datasource#" result="loc.result.StockItemsresult">
			SELECT *
			FROM tblProducts
			JOIN tblProductCats ON prodCatID=pcatID
			LEFT JOIN tblStockItem ON prodID = siProduct
			LEFT JOIN tblstockorder ON siOrder=soID
			<cfif StructKeyExists(args.form,"srchSupplier")>JOIN tblAccount ON soAccountID=accID</cfif>
			AND tblStockItem.siID = (
				SELECT MAX( siID )
				FROM tblStockItem
				WHERE prodID = siProduct
				<cfif StructKeyExists(args.form,"srchStatus")>AND siStatus IN (#PreserveSingleQuotes(loc.status)#)</cfif> )
			WHERE prodCatID=pcatID
			<cfif StructKeyExists(args.form,"srchSupplier") AND len(args.form.srchSupplier) GT 0>AND accID IN (#args.form.srchSupplier#)</cfif>
			<cfif StructKeyExists(args.form,"srchCategory") AND len(args.form.srchCategory) GT 0>AND prodCatID IN (#args.form.srchCategory#)</cfif>
			<cfif len(args.form.srchCatStr) GT 0>AND pcatTitle LIKE '%#args.form.srchCatStr#%'</cfif>
			<cfif len(args.form.srchProdStr) GT 0>AND prodTitle LIKE '%#args.form.srchProdStr#%'</cfif>
			<cfif len(args.form.srchDateFrom) GT 0>AND prodLastBought >= '#args.form.srchDateFrom#'</cfif>
			<cfif len(args.form.srchDateTo) GT 0>AND (prodLastBought IS null OR prodLastBought <= '#args.form.srchDateTo#')</cfif>
			<cfif len(args.form.srchStockDate) GT 0>AND prodCountDate >= '#args.form.srchStockDate#'</cfif>
			ORDER BY pcatTitle ASC,prodTitle ASC
		</cfquery>
<cfdump var="#loc.result.StockItems#" label="StockSearch" expand="yes" format="html" 
	output="#application.site.dir_logs#epos/err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">

		<cfset loc.result.recCount=loc.result.StockItems.recordcount>
		<cfreturn loc.result>
	</cffunction>
--->

	<cffunction name="StockSearch" access="public" returntype="struct" hint="search for product records">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.status = "">
		<cfset loc.ProdStatus = "">
		<cfset loc.Reorder = "">
		<cfif StructKeyExists(args.form,"srchStatus")>
			<cfloop list="#args.form.srchStatus#" index="loc.item" delimiters=",">
				<cfset loc.status = "#loc.status#,'#loc.item#'">
			</cfloop>
			<cfset loc.status = Removechars(loc.status,1,1)>
		</cfif>
		<cfif StructKeyExists(args.form,"srchProdStatus")>
			<cfloop list="#args.form.srchProdStatus#" index="loc.item" delimiters=",">
				<cfset loc.ProdStatus = "#loc.ProdStatus#,'#loc.item#'">
			</cfloop>
			<cfset loc.ProdStatus = Removechars(loc.ProdStatus,1,1)>
		</cfif>
		<cfif StructKeyExists(args.form,"srchReorder")>
			<cfloop list="#args.form.srchReorder#" index="loc.item" delimiters=",">
				<cfset loc.Reorder = "#loc.Reorder#,'#loc.item#'">
			</cfloop>
			<cfset loc.Reorder = Removechars(loc.Reorder,1,1)>
		</cfif>
		<cfquery name="loc.result.StockItems" datasource="#args.datasource#" result="loc.result.StockItemsresult">
			SELECT *
			FROM tblProducts
			INNER JOIN tblProductCats ON prodCatID = pcatID
			LEFT JOIN tblStockItem ON prodID = siProduct
			AND tblStockItem.siID = (
				SELECT MAX( siID )
				FROM tblStockItem
				WHERE prodID = siProduct
				<cfif StructKeyExists(args.form,"srchStatus")>AND siStatus IN (#PreserveSingleQuotes(loc.status)#)</cfif>
			)
			
			<cfif len(args.form.srchDateFrom) GT 0 || len(args.form.srchDateTo) GT 0 || (StructKeyExists(args.form,"srchSupplier") AND len(args.form.srchSupplier) GT 0)>
				LEFT JOIN tblstockorder ON siOrder = soID
				LEFT JOIN tblAccount ON soAccountID = accID
			</cfif>
			WHERE 1
			<cfif len(args.form.srchProdStr) GT 0>AND prodTitle LIKE '%#args.form.srchProdStr#%'</cfif>
			<cfif len(args.form.srchDateFrom) GT 0>AND soDate >= '#args.form.srchDateFrom#'</cfif>
			<cfif len(args.form.srchDateTo) GT 0>AND (soDate IS null OR soDate <= '#args.form.srchDateTo#')</cfif>
			<cfif len(args.form.srchCatStr) GT 0>AND pcatTitle LIKE '%#args.form.srchCatStr#%'</cfif>
			<cfif StructKeyExists(args.form,"srchProdStatus")>AND prodStatus IN (#PreserveSingleQuotes(loc.ProdStatus)#)</cfif>
			<cfif StructKeyExists(args.form,"srchReorder")>AND prodReorder IN (#PreserveSingleQuotes(loc.Reorder)#)</cfif>
			<cfif StructKeyExists(args.form,"srchSupplier") AND len(args.form.srchSupplier) GT 0>AND accID IN (#args.form.srchSupplier#)</cfif>
			<cfif StructKeyExists(args.form,"srchCategory") AND len(args.form.srchCategory) GT 0>AND prodCatID IN (#args.form.srchCategory#)</cfif>
			ORDER BY pcatTitle, prodTitle
		</cfquery>
		<cfset loc.result.recCount=loc.result.StockItems.recordcount>
		<cfreturn loc.result>
	</cffunction>

<!---	<cffunction name="StockSearch" access="public" returntype="struct" hint="search for product records">
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
		<cfquery name="loc.result.StockItems" datasource="#args.datasource#" result="loc.result.StockItemsresult">
			SELECT * 
			FROM tblproducts a
			INNER JOIN tblProductCats ON prodCatID=pcatID
			INNER JOIN (
				SELECT b.*,c.soID,c.soDate, MAX(siID)
				<cfif StructKeyExists(args.form,"srchSupplier")>,d.accName</cfif>
				FROM tblstockitem b
				INNER JOIN tblstockorder c ON soID=siOrder
				<cfif StructKeyExists(args.form,"srchSupplier")>JOIN tblAccount d ON soAccountID=accID</cfif>
				WHERE 1
				<cfif StructKeyExists(args.form,"srchStatus")>AND siStatus IN (#PreserveSingleQuotes(loc.status)#)</cfif>
				<cfif StructKeyExists(args.form,"srchSupplier") AND len(args.form.srchSupplier) GT 0>AND accID IN (#args.form.srchSupplier#)</cfif>				
				<cfif len(args.form.srchDateFrom) GT 0>AND soDate >= '#args.form.srchDateFrom#'</cfif>
				<cfif len(args.form.srchDateTo) GT 0>AND (soDate IS null OR soDate <= '#args.form.srchDateTo#')</cfif>
				GROUP BY siProduct
			) b ON (a.prodID=b.siProduct)
			WHERE 1
			<cfif len(args.form.srchProdStr) GT 0>AND prodTitle LIKE '%#args.form.srchProdStr#%'</cfif>
			<cfif len(args.form.srchCatStr) GT 0>AND pcatTitle LIKE '%#args.form.srchCatStr#%'</cfif>
			<cfif len(args.form.srchStockDate) GT 0>AND prodCountDate >= '#args.form.srchStockDate#'</cfif>
			<cfif StructKeyExists(args.form,"srchCategory") AND len(args.form.srchCategory) GT 0>AND prodCatID IN (#args.form.srchCategory#)</cfif>
			ORDER BY pcatTitle,prodTitle  ASC
		</cfquery>
		<cfset loc.result.recCount=loc.result.StockItems.recordcount>
		<cfdump var="#loc.result.StockItems#" label="StockItems" expand="false">
		<cfreturn loc.result>
	</cffunction>
--->	
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
<!---
			<cfquery name="loc.QStock" datasource="#args.datasource#" result="loc.result.QStockResult">
				SELECT prodID,prodCatID,prodRef,prodTitle,prodUnitSize,prodCountDate,prodStockLevel,prodUnitTrade,prodPriceMarked,prodLastBought,prodVATRate,
					(SELECT siOurPrice FROM tblStockItem WHERE siProduct=prodID ORDER BY siID DESC LIMIT 1) AS ourPrice,
					(SELECT siUnitTrade FROM tblStockItem WHERE siProduct=prodID ORDER BY siID DESC LIMIT 1) AS unitTrade,
					pcatTitle,pgTitle,pgTarget
				FROM tblProducts
				INNER JOIN tblProductCats ON prodCatID=pcatID
				INNER JOIN tblproductgroups ON pcatGroup=pgID
				WHERE prodCountDate IS NOT NULL
				<cfif len(args.form.srchStockDate) GT 0>AND prodCountDate >= '#args.form.srchStockDate#'</cfif>
				ORDER BY pgTitle,pcatTitle,prodTitle
			</cfquery>
--->
			<cfquery name="loc.result.QStock" datasource="#args.datasource#" result="loc.result.QStockResult">
				SELECT prodID,prodCatID,prodRef,prodTitle,prodUnitSize,prodCountDate,prodStockLevel,prodUnitTrade,prodPriceMarked,prodLastBought,prodVATRate,
					(SELECT siOurPrice FROM tblStockItem WHERE siProduct=prodID ORDER BY siID DESC LIMIT 1) AS ourPrice,
					(SELECT siUnitTrade FROM tblStockItem WHERE siProduct=prodID ORDER BY siID DESC LIMIT 1) AS unitTrade,
					(SELECT SUM(siQtyItems) FROM tblStockItem INNER JOIN tblStockOrder ON soID=siOrder WHERE siProduct=prodID AND soDate >= '2023-01-01') AS itemsBought,
					(SELECT SUM(eiQty) FROM tblepos_items WHERE eiProdID=prodID AND eiTimeStamp >= '2023-01-01') AS itemsSold,
				pcatTitle,pgTitle,pgTarget
				FROM tblProducts
				INNER JOIN tblProductCats ON prodCatID=pcatID
				INNER JOIN tblproductgroups ON pcatGroup=pgID
				WHERE prodCountDate IS NOT NULL
				<cfif len(args.form.srchStockDate) GT 0>AND prodCountDate >= '#args.form.srchStockDate#'</cfif>
				ORDER BY pgTitle,pcatTitle,prodTitle
				LIMIT 0,50
			</cfquery>	
			<cfset loc.result.recCount = loc.result.QStock.recordcount>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	
	<cffunction name="SalesPerformance" access="public" returntype="struct" hint="stock sales performance">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cftry>
			<cfquery name="loc.QStock" datasource="#args.datasource#" result="loc.result.QStockResult">
				select prodID,prodRef,prodTitle,prodCatID,pgTitle,pcatTitle,
					sum(tblepos_items.eiQty) as productsSold,
					min(DATE(tblepos_header.ehTimeStamp)) as firstSale,
					max(DATE(tblepos_header.ehTimeStamp)) as lastSale,
					DATEDIFF(max(tblepos_header.ehTimeStamp),min(tblepos_header.ehTimeStamp)) as days,
					sum(tblepos_items.eiQty) / DATEDIFF(max(tblepos_header.ehTimeStamp),min(tblepos_header.ehTimeStamp)) as averageSold,
					DATEDIFF(NOW(),max(tblepos_header.ehTimeStamp)) AS lastSold
				from tblproducts
				inner join tblepos_items on tblproducts.prodID = tblepos_items.eiProdID
				inner join tblepos_header on tblepos_items.eiParent = tblepos_header.ehID
				inner join tblproductcats ON prodCatID = pcatID
				inner join tblproductgroups ON pgID = pcatGroup
				WHERE tblepos_header.ehTimeStamp > '#args.form.srchDateFrom#'
				AND eiClass = 'sale'
				<cfif StructKeyExists(args.form,"srchCategory") AND len(args.form.srchCategory)>AND prodCatID IN (#args.form.srchCategory#)</cfif>
				<cfif StructKeyExists(args.form,"srchGroup") AND len(args.form.srchGroup)>AND pgID IN (#args.form.srchGroup#)</cfif>
				<!---<cfif StructKeyExists(args.form,"srchSupplier") AND len(args.form.srchSupplier)>AND prodSuppID IN (#args.form.srchSupplier#)</cfif>--->
				<cfif StructKeyExists(args.form,"srchProdStatus")>AND prodStatus = '#args.form.srchProdStatus#'</cfif>
				<cfif len(args.form.srchProdStr)>AND prodTitle LIKE '%#args.form.srchProdStr#%'</cfif>
				group by tblproducts.prodID
				ORDER BY pcatTitle, prodTitle
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