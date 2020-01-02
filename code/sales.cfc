

<cfcomponent displayname="SalesReports" extends="code/core">

	<cffunction name="QueryRowToStruct" access="public" returntype="struct" output="false" hint="returns a struct for a specified record from query.">
		<cfargument name="queryname" type="query" required="true">
		<cfargument name="rowNo" type="numeric" required="true">
		<cfset var qStruct={}>
		<cfset var columns=queryname.columnlist>
		<cfset var colName="">
		<cfset var fldValue="">
		<cfset qStruct={}>
		<cfloop list="#columns#" index="colName">
			<cfset fldValue=queryname[colName][rowNo]>
			<cfset StructInsert(qStruct,colName,fldValue)>
		</cfloop>
		<cfreturn StructCopy(qStruct)>
	</cffunction>

	<cffunction name="stockNonMovers" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.args = args>
		<cfif NOT StructKeyExists(args,"rptYear")><cfset loc.rptYear = Year(Now())>
			<cfelse><cfset loc.rptYear = args.rptYear></cfif>
		<cfquery name="loc.productList" datasource="#args.datasource#">
			SELECT pgID,pgTitle, pcatID,pcatTitle, prodID,prodTitle,prodCountDate,prodStockLevel,prodPriceMarked, soDate, SUM(siQtyItems) AS Items, siUnitSize,siOurPrice
			FROM tblProducts
			INNER JOIN tblStockItem ON siProduct=prodID
			INNER JOIN tblStockOrder ON siOrder=soID
			INNER JOIN tblProductCats ON pcatID=prodCatID
			INNER JOIN tblProductGroups ON pcatGroup=pgID
			LEFT JOIN tblepos_items ON eiProdID=prodID
			WHERE eiID IS NULL
			AND soDate >= DATE_ADD(NOW(), INTERVAL '-365' DAY)
			AND siStatus='closed'
			AND pgType != 'epos'
			AND siStatus = 'closed'
			AND prodStatus = 'active'
			<cfif StructKeyExists(args,"grpID") AND args.grpID gt 0>AND pcatGroup = #args.grpID#</cfif>
			<cfif StructKeyExists(args,"catID") AND args.catID gt 0>AND prodCatID = #args.catID#</cfif>
			<cfif StructKeyExists(args,"productID")>AND prodID = #args.productID#</cfif>
			GROUP BY pgTitle, pcatTitle, prodID
		</cfquery>
		<cfreturn loc>
	</cffunction>

	<cffunction name="stockSalesByMonth" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.args = args>
		
		<cfif NOT StructKeyExists(args,"rptYear")><cfset loc.rptYear = Year(Now())>
			<cfelse><cfset loc.rptYear = args.rptYear></cfif>
		
		<cfif StructKeyExists(args,"grpID") AND val(args.grpID) gt 0>
			<cfquery name="loc.group" datasource="#args.datasource#">
				SELECT pgTitle FROM tblproductgroups WHERE pgID=#val(args.grpID)#
			</cfquery>
			<cfset loc.GroupTitle = loc.group.pgTitle>
		<cfelse>
			<cfset loc.GroupTitle = "">
		</cfif>
		
		<cfquery name="loc.salesItems" datasource="#args.datasource#">
			SELECT pgID,pgTitle, pcatID,pcatTitle, prodID,prodTitle,prodCountDate,prodStockLevel,prodPriceMarked,prodStatus,
			SUM(CASE WHEN MONTH(st.eiTimestamp)=1 THEN eiQty ELSE 0 END) AS "jan",
			SUM(CASE WHEN MONTH(st.eiTimestamp)=2 THEN eiQty ELSE 0 END) AS "feb",
			SUM(CASE WHEN MONTH(st.eiTimestamp)=3 THEN eiQty ELSE 0 END) AS "mar",
			SUM(CASE WHEN MONTH(st.eiTimestamp)=4 THEN eiQty ELSE 0 END) AS "apr",
			SUM(CASE WHEN MONTH(st.eiTimestamp)=5 THEN eiQty ELSE 0 END) AS "may",
			SUM(CASE WHEN MONTH(st.eiTimestamp)=6 THEN eiQty ELSE 0 END) AS "jun",
			SUM(CASE WHEN MONTH(st.eiTimestamp)=7 THEN eiQty ELSE 0 END) AS "jul",
			SUM(CASE WHEN MONTH(st.eiTimestamp)=8 THEN eiQty ELSE 0 END) AS "aug",
			SUM(CASE WHEN MONTH(st.eiTimestamp)=9 THEN eiQty ELSE 0 END) AS "sep",
			SUM(CASE WHEN MONTH(st.eiTimestamp)=10 THEN eiQty ELSE 0 END) AS "oct",
			SUM(CASE WHEN MONTH(st.eiTimestamp)=11 THEN eiQty ELSE 0 END) AS "nov",
			SUM(CASE WHEN MONTH(st.eiTimestamp)=12 THEN eiQty ELSE 0 END) AS "dec",
			SUM(eiQty) AS "total"
			FROM tblproducts
			INNER JOIN tblProductCats ON pcatID=prodCatID
			INNER JOIN tblProductGroups ON pcatGroup=pgID
			LEFT JOIN tblepos_items AS st ON eiProdID=prodID
			WHERE st.eiTimestamp >= DATE_ADD(NOW(), INTERVAL '-365' DAY)

			AND pgType != 'epos'
			AND prodStatus != 'inactive'
			<cfif StructKeyExists(args,"grpID") AND args.grpID gt 0>AND pcatGroup = #args.grpID#</cfif>
			<cfif StructKeyExists(args,"catID") AND args.catID gt 0>AND prodCatID = #args.catID#</cfif>
			<cfif StructKeyExists(args,"productID")>AND prodID = #args.productID#</cfif>
			GROUP BY pgTitle, pcatTitle, prodID
			ORDER BY pgTitle, pcatTitle, prodTitle
		</cfquery>
		<cfset QueryAddColumn(loc.salesItems,"siUnitSize",[])>
		<cfset QueryAddColumn(loc.salesItems,"siOurPrice",[])>
		<cfloop query="loc.salesItems">
			<cfset loc.prodID = prodID>
			<cfquery name="loc.stockItem" datasource="#args.datasource#">
				SELECT siID,siUnitSize,siOurPrice
				FROM tblProducts
				LEFT JOIN tblStockItem ON prodID = siProduct
				AND tblStockItem.siID = (
					SELECT MAX( siID )
					FROM tblStockItem
					WHERE prodID = siProduct
					AND siStatus = "closed" )
				WHERE prodID=#val(loc.prodID)#
			</cfquery>
			<cfset QuerySetCell(loc.salesItems,"siUnitSize",loc.stockItem.siUnitSize,currentrow)>
			<cfset QuerySetCell(loc.salesItems,"siOurPrice",loc.stockItem.siOurPrice,currentrow)>
		</cfloop>
		<cfreturn loc>
	</cffunction>

	<cffunction name="stockPurchByMonth" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.args = args>
		
		<cfif NOT StructKeyExists(args,"rptYear")><cfset loc.rptYear = Year(Now())>
			<cfelse><cfset loc.rptYear = args.rptYear></cfif>
		
		<cfif StructKeyExists(args,"grpID") AND val(args.grpID) gt 0>
			<cfquery name="loc.group" datasource="#args.datasource#">
				SELECT pgTitle FROM tblproductgroups WHERE pgID=#val(args.grpID)#
			</cfquery>
			<cfset loc.GroupTitle = loc.group.pgTitle>
		<cfelse>
			<cfset loc.GroupTitle = "">
		</cfif>
		
		<cfquery name="loc.purchItems" datasource="#args.datasource#" result="loc.purchItemsResult">
			SELECT pgID,pgTitle, pcatID,pcatTitle, prodID,prodRef,prodTitle,prodPriceMarked,prodCountDate,prodStockLevel,
			SUM(CASE WHEN MONTH(so.soDate)=1 THEN siQtyItems ELSE 0 END) AS "jan",
			SUM(CASE WHEN MONTH(so.soDate)=2 THEN siQtyItems ELSE 0 END) AS "feb",
			SUM(CASE WHEN MONTH(so.soDate)=3 THEN siQtyItems ELSE 0 END) AS "mar",
			SUM(CASE WHEN MONTH(so.soDate)=4 THEN siQtyItems ELSE 0 END) AS "apr",
			SUM(CASE WHEN MONTH(so.soDate)=5 THEN siQtyItems ELSE 0 END) AS "may",
			SUM(CASE WHEN MONTH(so.soDate)=6 THEN siQtyItems ELSE 0 END) AS "jun",
			SUM(CASE WHEN MONTH(so.soDate)=7 THEN siQtyItems ELSE 0 END) AS "jul",
			SUM(CASE WHEN MONTH(so.soDate)=8 THEN siQtyItems ELSE 0 END) AS "aug",
			SUM(CASE WHEN MONTH(so.soDate)=9 THEN siQtyItems ELSE 0 END) AS "sep",
			SUM(CASE WHEN MONTH(so.soDate)=10 THEN siQtyItems ELSE 0 END) AS "oct",
			SUM(CASE WHEN MONTH(so.soDate)=11 THEN siQtyItems ELSE 0 END) AS "nov",
			SUM(CASE WHEN MONTH(so.soDate)=12 THEN siQtyItems ELSE 0 END) AS "dec",
			SUM(siQtyItems) AS "total"
			FROM tblproducts
			INNER JOIN tblstockitem AS si ON siProduct=prodID
			INNER JOIN tblStockOrder AS so ON siOrder=soID
			INNER JOIN tblProductCats ON pcatID=prodCatID
			INNER JOIN tblProductGroups ON pcatGroup=pgID
			WHERE so.soDate >= DATE_ADD(NOW(), INTERVAL '-365' DAY)
			AND pgType != 'epos'
			AND siStatus = 'closed'
			AND prodStatus != 'inactive'
			<cfif StructKeyExists(args,"grpID") AND args.grpID gt 0>AND pcatGroup = #args.grpID#</cfif>
			<cfif StructKeyExists(args,"catID") AND args.catID gt 0>AND prodCatID = #args.catID#</cfif>
			<cfif StructKeyExists(args,"productID")>AND prodID = #args.productID#</cfif>
			GROUP BY pgTitle, pcatTitle, prodID
		</cfquery>
		<cfset loc.stock = {}>
		<cfloop query="loc.purchItems">
			<cfset StructInsert(loc.stock,prodID,QueryRowToStruct(loc.purchItems,currentrow))>
		</cfloop>
		<cfreturn loc>
	</cffunction>
	
	<cffunction name="LoadGroups" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.result.ProductGroups" datasource="#args.datasource#" result="loc.QQueryResult">
				SELECT *
				FROM tblproductgroups
				WHERE pgType='sale'
				ORDER BY pgTitle
			</cfquery>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
</cfcomponent>