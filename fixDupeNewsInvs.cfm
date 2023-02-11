<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix Dupe News Invoices</title>
<style>
	.dupe {color:#FF00FF;}
	.normal {color:#000000;}
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
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

<cfflush interval="200">
<cfsetting requesttimeout="900">
<cfparam name="doUpdate" default="false">
<cfparam name="limit" default="1000">
<cfparam name="dupeDay" default="2022-06-25">
<body>
<h1>Delete Duplicate Invoices</h1>

<cftry>
	<cfquery name="QInvoices" datasource="#application.site.datasource1#">
		SELECT *  
		FROM `tbltrans` 
		WHERE `trnLedger` = 'sales' 
		AND `trnAccountID` = 4 
		AND `trnType` = 'inv' 
		AND `trnDate` = '#dupeDay#'
		LIMIT #limit#;
	</cfquery>
	<!---<cfdump var="#QInvoices#" label="QInvoices" expand="false">--->
	<cfset lastRef = 0>
	<cfset lastAmount = 0>
	<cfset lastTitle = "">
	<cfset lastUnitSize = "">
	<cfset dupCount = 0>
	<cfset class = "normal">
	<cfoutput>
		<h1>#QInvoices.recordcount# records found</h1>
		<table class="tableList" border="1">
			<tr>
				<th align="right">ID</th>
				<th align="right">Date</th>
				<th>Reference</th>
				<th>Description</th>
				<th align="right">Net</th>
				<th align="right">VAT</th>
			</tr>
			<cfloop query="QInvoices">
				<cfif lastRef neq 0>
					<cfif lastRef eq trnRef AND lastAmount eq trnAmnt1>
						<cfset dupCount++>
						<cfset class = "dupe">
					<cfelse>
						<cfset class = "normal">
					</cfif>
				</cfif>
				<tr class="#class#">
					<td align="right">#trnID#</td>
					<td align="right">#trnDate#</td>
					<td>#trnRef#</td>
					<td>#trnDesc#</td>
					<td align="right">#trnAmnt1#</td>
					<td align="right">#trnAmnt2#</td>
				</tr>
			</cfloop>
			<tr>
				<th colspan="6">#dupCount# duplicates found.</th>
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