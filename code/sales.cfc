

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

	<cffunction name="relatedSales" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.args = args>
		<cfset loc.trans = {}>
		<cftry>
			<cfif StructKeyExists(args,"related") AND val(args.related) gt 0>
				<cfquery name="loc.group" datasource="#args.datasource#">
					SELECT pgTitle FROM tblproductgroups WHERE pgID=#val(args.related)#
				</cfquery>
				<cfset loc.GroupTitle = loc.group.pgTitle>
			</cfif>
			<cfquery name="loc.salesItems" datasource="#args.datasource#">
				SELECT prodID,prodTitle, SUM(eiQty) AS rQty, SUM(eiNet + eiVAT) AS rGross, ehID,ehTimeStamp
				FROM tblproducts
				INNER JOIN tblProductCats ON pcatID = prodCatID
				INNER JOIN tblepos_items AS st ON eiProdID = prodID
				INNER JOIN tblepos_header AS eh ON eiParent = ehID
				WHERE DATE(st.eiTimestamp) BETWEEN '#args.srchDateFrom#' AND '#args.srchDateTo#'
				<cfif StructKeyExists(args,"related") AND args.related gt 0>AND pcatGroup = #args.related#</cfif>
				GROUP BY ehID
			</cfquery>
			<cfif loc.salesItems.recordCount neq 0>
				<cfloop query="loc.salesItems">
					<cfset loc.tranID = ehID>
					<cfquery name="loc.salesTran" datasource="#args.datasource#">
						SELECT SUM(eiQty) AS Qty, SUM(eiNet + eiVAT) AS Gross, ehID,ehTimeStamp,ehMode
						FROM tblepos_items
						INNER JOIN tblepos_header AS eh ON eiParent = ehID
						WHERE ehID = #loc.tranID#
						AND eiClass != 'pay'
					</cfquery>
					<cfset loc.rec = QueryRowToStruct(loc.salesTran,1)>
					<cfset loc.rec.rQty = rQty>
					<cfset loc.rec.rGross = rGross>
					<cfset StructInsert(loc.trans,ehID,loc.rec)>
				</cfloop>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="relatedSales" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc>
	</cffunction>

	<cffunction name="selectProducts" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.args = args>
		<cfset loc.GroupTitle = "">
		<cftry>
			<cfif StructKeyExists(args,"grpID") AND val(args.grpID) gt 0>
				<cfquery name="loc.group" datasource="#args.datasource#">
					SELECT pgTitle FROM tblproductgroups WHERE pgID=#val(args.grpID)#
				</cfquery>
				<cfset loc.GroupTitle = loc.group.pgTitle>
			</cfif>
			<cfquery name="loc.productList" datasource="#args.datasource#">
				SELECT 
					pgID,pgTitle, pcatID,pcatTitle, 
					prodID,prodRef,prodTitle,prodCountDate,prodStockLevel,prodPriceMarked,prodStatus,prodVATRate, siUnitSize,siOurPrice, siUnitTrade
				FROM tblProducts
				LEFT JOIN tblStockItem ON prodID = siProduct
				AND tblStockItem.siID = (
					SELECT MAX(siID)
					FROM tblStockItem
					WHERE prodID = siProduct
					AND siStatus = "closed"
					AND siBookedIn IS NOT NULL)
				INNER JOIN tblProductCats ON pcatID = prodCatID
				INNER JOIN tblProductGroups ON pcatGroup = pgID
				WHERE pgType != 'epos'
				AND prodStatus != 'inactive'
				AND siID IS NOT NULL
				AND DATE(siBookedIn) > '2018-10-28'	<!--- start date of EPOS till --->
				<cfif StructKeyExists(args,"grpID") AND args.grpID gt 0>AND pcatGroup = #args.grpID#</cfif>
				<cfif StructKeyExists(args,"catID") AND args.catID gt 0>AND prodCatID = #args.catID#</cfif>
				<cfif StructKeyExists(args,"productID")>AND prodID = #args.productID#</cfif>
				GROUP BY pgTitle, pcatTitle, prodID
				ORDER BY pgTitle, pcatTitle, prodTitle, siUnitSize, prodID
			</cfquery>
			
			<cfset loc.purchData = {}>
			<cfset loc.salesData = {}>
			<cfloop query="loc.productList">
				<cfset loc.productID = prodID>
				<cfquery name="loc.purchItems" datasource="#args.datasource#">
					SELECT prodID,prodTitle,
					SUM(CASE WHEN MONTH(siBookedIn)=1 THEN siQtyItems ELSE 0 END) AS "jan",
					SUM(CASE WHEN MONTH(siBookedIn)=2 THEN siQtyItems ELSE 0 END) AS "feb",
					SUM(CASE WHEN MONTH(siBookedIn)=3 THEN siQtyItems ELSE 0 END) AS "mar",
					SUM(CASE WHEN MONTH(siBookedIn)=4 THEN siQtyItems ELSE 0 END) AS "apr",
					SUM(CASE WHEN MONTH(siBookedIn)=5 THEN siQtyItems ELSE 0 END) AS "may",
					SUM(CASE WHEN MONTH(siBookedIn)=6 THEN siQtyItems ELSE 0 END) AS "jun",
					SUM(CASE WHEN MONTH(siBookedIn)=7 THEN siQtyItems ELSE 0 END) AS "jul",
					SUM(CASE WHEN MONTH(siBookedIn)=8 THEN siQtyItems ELSE 0 END) AS "aug",
					SUM(CASE WHEN MONTH(siBookedIn)=9 THEN siQtyItems ELSE 0 END) AS "sep",
					SUM(CASE WHEN MONTH(siBookedIn)=10 THEN siQtyItems ELSE 0 END) AS "oct",
					SUM(CASE WHEN MONTH(siBookedIn)=11 THEN siQtyItems ELSE 0 END) AS "nov",
					SUM(CASE WHEN MONTH(siBookedIn)=12 THEN siQtyItems ELSE 0 END) AS "dec",
					SUM(siQtyItems) AS "total"
					FROM tblproducts
					INNER JOIN tblstockitem AS si ON siProduct = prodID
					WHERE prodID = #loc.productID#
					AND siBookedIn BETWEEN '#args.srchDateFrom#' AND '#args.srchDateTo#'
					AND siStatus IN ('closed','returned')
					GROUP BY prodID
				</cfquery>
				<cfif loc.purchItems.recordCount gt 0>
					<cfset StructInsert(loc.purchData,loc.productID,QueryRowToStruct(loc.purchItems,1))>
				<cfelse>
					<cfset StructInsert(loc.purchData,loc.productID,{
						"prodID" = loc.productID,
						"prodTitle" = loc.productList.prodTitle,
						"jan" = 0, "feb" = 0, "mar" = 0, "apr" = 0, "may" = 0, "jun" = 0,
						"jul" = 0, "aug" = 0, "sep" = 0, "oct" = 0, "nov" = 0, "dec" = 0,
						"total" = 0
					})>
				</cfif>			
				<cfquery name="loc.QPurchBFwd" datasource="#args.datasource#">
					SELECT siProduct, SUM(siQtyItems ) AS Qty, SUM(siWSP) AS WSP
					FROM tblstockitem
					WHERE siProduct = #loc.productID#
					AND DATE(siBookedIn) < '#args.srchDateFrom#'
					AND DATE(siBookedIn) > '2018-10-28'	<!--- start date of EPOS till --->
					AND siStatus = 'closed'
					GROUP BY siProduct
				</cfquery>
				<cfset loc.purchBFWD = val(loc.QPurchBFwd.Qty)>
				<cfset loc.purchy = StructFind(loc.purchData,loc.productID)>
				<cfset StructInsert(loc.purchy,"BFwd",loc.purchBFWD)>
				<cfset StructInsert(loc.purchy,"prodStockLevel",prodStockLevel)>
	
				<cfquery name="loc.salesItems" datasource="#args.datasource#">
					SELECT prodID,prodTitle,
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
					INNER JOIN tblepos_items AS st ON eiProdID=prodID
					WHERE prodID = #loc.productID#
					AND eiQty > 0	<!--- negatives cause problems --->
					AND DATE(st.eiTimestamp) BETWEEN '#args.srchDateFrom#' AND '#args.srchDateTo#'
					GROUP BY prodID
				</cfquery>
				<cfif loc.salesItems.recordCount gt 0>
					<cfset StructInsert(loc.salesData,loc.productID,QueryRowToStruct(loc.salesItems,1))>
				<cfelse>
					<cfset StructInsert(loc.salesData,loc.productID,{
						"prodID" = loc.productID,
						"prodTitle" = loc.productList.prodTitle,
						"jan" = 0, "feb" = 0, "mar" = 0, "apr" = 0, "may" = 0, "jun" = 0,
						"jul" = 0, "aug" = 0, "sep" = 0, "oct" = 0, "nov" = 0, "dec" = 0,
						"total" = 0
					})>
					<cfset loc.salesBFWD = 0>
				</cfif>
				<cfquery name="loc.QSalesBFwd" datasource="#args.datasource#">
					SELECT eiProdID, SUM(eiQty ) AS Qty, SUM(eiNet) AS Net
					FROM tblepos_items
					WHERE eiProdID=#val(loc.productID)#
					AND DATE(eiTimestamp) < '#args.srchDateFrom#'
					GROUP BY eiProdID
				</cfquery>
				<cfset loc.salesBFWD = val(loc.QSalesBFwd.Qty)>
				<cfset loc.salesy = StructFind(loc.salesData,loc.productID)>
				<cfset StructInsert(loc.salesy,"BFwd",loc.salesBFWD)>
			</cfloop>
			<cfreturn loc>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="selectProducts" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
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