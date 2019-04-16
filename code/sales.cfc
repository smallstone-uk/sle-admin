

<cfcomponent displayname="SalesReports" extends="code/core">

	<cffunction name="pivotTable" access="public" returntype="struct">
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
			SELECT pgID,pgTitle, pcatTitle, prodTitle, 
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
			INNER JOIN tblProductCats ON pcatID=prodCatID
			INNER JOIN tblProductGroups ON pcatGroup=pgID
			WHERE YEAR(st.eiTimestamp) = #val(loc.rptYear)#
			<cfif StructKeyExists(args,"grpID") AND args.grpID gt 0>AND pcatGroup = #args.grpID#</cfif>
			<cfif StructKeyExists(args,"catID") AND args.catID gt 0>AND prodCatID = #args.catID#</cfif>
			<cfif StructKeyExists(args,"productID")>AND prodID = #args.productID#</cfif>
			GROUP BY pgTitle, pcatTitle, prodTitle
			ORDER BY pgTitle, pcatTitle, prodTitle
		</cfquery>	
		<cfreturn loc>
	</cffunction>
	
</cfcomponent>