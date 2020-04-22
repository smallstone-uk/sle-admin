<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Stock Items</title>
	<!---<link rel="stylesheet" type="text/css" href="css/main.css"/>--->
	<style type="text/css">
		.priceDiff {background-color:#FADCD8;}
		.priceMatch {background-color:#fff;}
		.header {font-size:14px; font-weight:bold;}
		.headleft {text-align:left; font-size:12px;}
		.headright {text-align:right; font-size:12px;}
		#barcodeDiv {margin-top:30px;}
		.tableList {
			font-family:Arial, Helvetica, sans-serif;
			font-size:14px;
			border-collapse:collapse;
			
		}
		.tableList th, .tableList td {
			padding:2px 4px; 
			border: solid 1px #ccc;
		}
		.red {background-color:#FF0000;}
		.badPrice {background-color:#c000ff}
		.badDate {background-color:#3FF}
	</style>
</head>

<cfsetting requesttimeout="900">
<cfparam name="doUpdate" default="false">
<cfparam name="limit" default="1000">

<cftry>

	<cfquery name="QProducts" datasource="#application.site.datasource1#">
		SELECT pgTitle, pcatTitle, prodID,prodRef,prodTitle,prodUnitSize,prodOurPrice,prodLastBought
		FROM `tblproductgroups` 
		INNER JOIN tblProductCats ON pcatGroup=pgID
		LEFT JOIN tblProducts ON prodCatID=pcatID
		WHERE `pgShow` = 1 
		AND pcatShow=1
		AND prodStatus='active'
		ORDER BY `pgTitle` ASC, pcatTitle ASC
		LIMIT #limit#;
	</cfquery>
	
	<cfoutput>
		<table class="tableList" border="1">
			<tr>
				<th>##</th>
				<th>pgTitle</th>
				<th>pcatTitle</th>
				<th>prodID</th>
				<th>prodRef</th>
				<th>prodTitle</th>
				<th>prodUnitSize</th>
				<th>prodOurPrice</th>
				<th>prodLastBought</th>
			</tr>
			<cfset errorCount = 0>
			<cfloop query="QProducts">
				<cfset topClass = "">
				<cfset refClass = "">
				<cfset unitClass = "">
				<cfset priceClass="">
				<cfset dateClass="">
				<cfif len(prodRef) lt 6>
					<cfset refClass = "red">
				</cfif>
				<cfif len(prodUnitSize) eq 0>
					<cfset unitClass = "priceDiff">
				</cfif>
				<cfif val(prodOurPrice) lte 0>
					<cfset priceClass="badPrice">
				</cfif>
				<cfif len(prodLastBought) lte 0>
					<cfset dateClass="badDate">
				</cfif>
				<cfif len(refClass) + len(unitClass) + len(priceClass) + len(dateClass)>
					<cfset errorCount++>
					<tr>
						<td class="#topClass#">#currentRow#</td>
						<td class="#topClass#">#pgTitle#</td>
						<td class="#topClass#">#pcatTitle#</td>
						<td class="#topClass#">#prodID#</td>
						<td class="#refClass#">#prodRef#</td>
						<td class="#topClass#">#prodTitle#</td>
						<td class="#unitClass#">#prodUnitSize#</td>
						<td class="#priceClass#">#prodOurPrice#</td>
						<td class="#dateClass#">#prodLastBought#</td>
					</tr>
				</cfif>
			</cfloop>
			<tr>
				<td colspan="3">#QProducts.recordcount# records.</td>
				<td colspan="6">#errorCount# with errors.</td>
		</table>
	</cfoutput>
	
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

