<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix Dupe Products</title>
<style>
	.red {color:#FF0000;}
</style>
	<link href="css/main3.css" rel="stylesheet" type="text/css">
</head>
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
	
	<cffunction name="UpdateProduct" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QQuery" datasource="#args.datasource#" result="loc.QQueryResult">
				UPDATE tblProducts
				SET prodStatus = 'inactive'
				WHERE prodID = #val(args.productID)#
			</cfquery>
			<cfset loc.result.QQuery = loc.QQuery>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

<cfsetting requesttimeout="900">
<cfparam name="doUpdate" default="false">
<cfparam name="limit" default="1000">
<body>
<h1>Product Duplicates Cleanup</h1>
<p>Inactivates duplicate products.</p>
<cftry>
	<cfquery name="QProducts" datasource="#application.site.datasource1#">
		SELECT prodID,prodRef,prodRecordTitle,prodTitle,prodStatus, siID,siRef,siUnitSize,siPackQty,siBookedIn,siStatus
		FROM tblProducts
		LEFT JOIN tblStockItem ON prodID = siProduct
		AND tblStockItem.siID = (
			SELECT MAX( siID )
			FROM tblStockItem
			WHERE prodID = siProduct )
		WHERE prodRecordTitle IS NOT NULL
		AND prodStatus = 'active'
		ORDER BY prodRecordTitle, siUnitSize, prodID
		LIMIT #limit#;
	</cfquery>
	<!---<cfdump var="#QProducts#" label="QProducts" expand="false">--->
	<cfset lastRec = {}>
	<cfset lastTitle = "">
	<cfset lastUnitSize = "">
	<cfset dupCount = 0>
	<cfoutput>
		<h1>#QProducts.recordcount# records found</h1>
		<table class="tableList" border="1">
			<tr>
				<th>##</th>
				<th>prodID</th>
				<th>prodRef</th>
				<th>prodRecordTitle</th>
				<th>siUnitSize</th>
				<th>prodTitle</th>
				<th>prodStatus</th>
				<th>siID</th>
				<th>siRef</th>
				<th>siPackQty</th>
				<th>siBookedIn</th>
				<th>siStatus</th>
			</tr>
			<cfloop query="QProducts">
				<cfset topClass = "">
				<cfset btmClass = "">
				<cfif (len(lastTitle) AND prodRecordTitle eq lastTitle) AND (len(lastUnitSize) AND siUnitSize eq lastUnitSize)>
					<cfset dupCount++>
					<cfif siPackQty gt lastRec.siPackQty>
						<cfset topClass = "red">
						<cfset parms = {
							datasource = application.site.datasource1,
							productID = prodID
						}>
						<cfif doUpdate><cfset UpdateProduct(parms)></cfif>
					<cfelse>
						<cfset btmClass = "red">
						<cfset parms = {
							datasource = application.site.datasource1,
							productID = lastRec.prodID
						}>
						<cfif doUpdate><cfset UpdateProduct(parms)></cfif>
					</cfif>
					<tr>
						<td class="#topClass#">#currentRow#</td>
						<td class="#topClass#">#prodID#</td>
						<td class="#topClass#">#prodRef#</td>
						<td class="#topClass#">#prodRecordTitle#</td>
						<td class="#topClass#">#siUnitSize#</td>
						<td class="#topClass#">#prodTitle#</td>
						<td class="#topClass#">#prodStatus#</td>
						<td class="#topClass#">#siID#</td>
						<td class="#topClass#">#siRef#</td>
						<td class="#topClass#">#siPackQty#</td>
						<td class="#topClass#">#siBookedIn#</td>
						<td class="#topClass#">#siStatus#</td>
					</tr>
					<tr>
						<td></td>
						<td class="#btmClass#">#lastRec.prodID#</td>
						<td class="#btmClass#">#lastRec.prodRef#</td>
						<td class="#btmClass#">#lastRec.prodRecordTitle#</td>
						<td class="#btmClass#">#lastRec.siUnitSize#</td>
						<td class="#btmClass#">#lastRec.prodTitle#</td>
						<td class="#btmClass#">#lastRec.prodStatus#</td>
						<td class="#btmClass#">#lastRec.siID#</td>
						<td class="#btmClass#">#lastRec.siRef#</td>
						<td class="#btmClass#">#lastRec.siPackQty#</td>
						<td class="#btmClass#">#lastRec.siBookedIn#</td>
						<td class="#btmClass#">#lastRec.siStatus#</td>
					</tr>
					<tr>
						<td colspan="12">&nbsp;</td>
					</tr>
				</cfif>
				<cfset lastRec = QueryRowToStruct(QProducts,currentRow)>
				<cfset lastTitle = prodRecordTitle>
				<cfset lastUnitSize = siUnitSize>
				<cfflush interval="200">
			</cfloop>
			<tr>
				<td colspan="6">#dupCount# duplicates found.</td>
				<td colspan="6"></td>
			</tr>
		</table>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

</body>
</html>