<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>PriceList</title>
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/main4.css" rel="stylesheet" type="text/css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<script src="scripts/jquery-1.9.1.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<style type="text/css">
		#dashboard {width:400px; margin:10px; padding:10px;}
		@media print {
			.noPrint {display:none;}
		}
		.display {
			font:"Comic Sans MS", cursive; 
			font-size:18px;
			border-spacing: 0px;border-collapse: collapse;
			border-color: #CCC;
			line-height:30px;
		}
		.display th {padding:4px 5px; background:#eee; border-color: #ccc;}
		.display td {padding: 2px 5px; background:#fff; border-color: #ccc;}
	</style>
</head>
	<cfparam name="group" default="17">
	<cfparam name="categories" default="">
	<cfparam name="period" default="12">
	<cfparam name="pricelist" default="cust">
	<cfparam name="showSize" default="0">
	
	<cffunction name="GetData" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QGroupsAndCats" datasource="#args.datasource#">
				SELECT *
				FROM tblProductGroups
				INNER JOIN tblProductCats ON pcatGroup = pgID
				WHERE pgID IN (#group#)
				<cfif NOT args.menu AND len(categories)>AND pcatID IN (#categories#)</cfif>
				ORDER BY pcatTitle
			</cfquery>
			<cfset loc.result.categories = loc.QGroupsAndCats>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="GetData" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="GetGroups" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QGroups" datasource="#args.datasource#">
				SELECT *
				FROM tblProductGroups
				WHERE 1
				ORDER BY pgTitle
			</cfquery>
			<cfset loc.result.titles = loc.QGroups>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="GetGroups" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="GetProducts" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QProducts" datasource="#args.datasource#">
				SELECT prodID,prodRef,prodTitle,prodPriceMarked, siID,siRef,siUnitSize,siOurPrice,soDate
				FROM tblProducts
				LEFT JOIN tblStockItem ON prodID = siProduct
				INNER JOIN tblStockOrder ON soID = siOrder
				AND tblStockItem.siID = (
					SELECT MAX( siID )
					FROM tblStockItem
					WHERE prodID = siProduct 
				)
				WHERE prodCatID=#val(args.cat)#
				<cfif args.period neq 99>AND soDate > DATE_ADD(CURDATE(), INTERVAL -#args.period# MONTH)</cfif>
				AND siStatus <> 'inactive'
				ORDER BY prodTitle
			</cfquery>
			<cfset loc.result.products = loc.QProducts>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="GetProducts" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

<body>
<cftry>
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset groups = GetGroups(parm)>
	<cfset parm.menu = true>
	<cfset catmenu = GetData(parm)>
	<cfset parm.menu = false>
	<cfset data = GetData(parm)>
	<cfoutput>
		<div id="dashboard" class="noPrint">
			<table>
			<form method="post">
				<tr>
					<td>Group</td>
					<td>
						<select name="group" data-placeholder="Show all..." id="groupList" multiple="multiple">
							<cfloop query="groups.titles">
								<option value="#pgID#"<cfif ListFind(group,pgID,",")> selected="selected"</cfif>>#pgTitle#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>Categories</td>
					<td>
						<select name="categories" data-placeholder="Show all..." id="catList" multiple="multiple">
							<cfloop query="catmenu.categories">
								<option value="#pcatID#"<cfif ListFind(categories,pcatID,",")> selected="selected"</cfif>>#pcatTitle#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>Period</td>
					<td>
						<select name="period">
							<cfloop from="1" to="24" index="i">
								<cfif i gt 6>
									<cfif i MOD 3 eq 0>
										<option value="#i#"<cfif period eq i> selected="selected"</cfif>>#i# months</option>
									</cfif>
								<cfelse>
									<option value="#i#"<cfif period eq i> selected="selected"</cfif>>#i# months</option>
								</cfif>
							</cfloop>
							<option value="99"<cfif period eq 99> selected="selected"</cfif>>all</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>Price List Style</td>
					<td>
						<select name="pricelist">
							<option value="staff"<cfif pricelist eq "staff"> selected="selected"</cfif>>Staff Price List</option>
							<option value="cust"<cfif pricelist eq "cust"> selected="selected"</cfif>>Customer Price List</option>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2"><input type="checkbox" value="1" name="showSize"<cfif showSize> checked="checked"</cfif>>Show Size?</td>
				</tr>
				<tr>
					<td colspan="2"><input type="submit" name="btnRun" value="Go" /></td>
				</tr>
			</form>
			</table>
		</div>
		<cfif pricelist eq "staff">
			<table class="tableList" border="1">
				<cfset recCount = 0>
				<cfloop query="data.categories">
					<cfset parm.cat = pcatID>
					<cfset parm.period = period>
					<cfset items = GetProducts(parm)>
					<cfif items.products.recordcount gt 0>
						<cfset recCount += items.products.recordcount>
						<tr>
							<th colspan="7" align="left">#pcatTitle#</th>
						</tr>
						<cfloop query="items.products">
							<tr>
								<td><a href="ProductStock6.cfm?product=#prodID#" target="product">#prodID#</a></td>
								<td><cfif len(siRef)>#siRef#<cfelse>#prodRef#</cfif></td>
								<td>#prodTitle#</td>
								<cfif showSize><td>#siUnitSize#</td></cfif>
								<td align="right">&pound;#siOurPrice#</td>
								<td>#GetToken(" |PM",prodPriceMarked+1,"|")#</td>
								<td align="right">#LSDateFormat(soDate)#</td>
							</tr>
						</cfloop>
					</cfif>
				</cfloop>
				<tr>
					<td colspan="3" height="30">#recCount# products listed</td>
					<td colspan="4" align="right">#LSDateFormat(Now(),"dd-mmm-yyyy")#</td>
				</tr>
			</table>
		<cfelse>
			<table class="display" border="1" width="500">
				<tr>
					<th>Description</th>
					<cfif showSize><th>Size</th></cfif>
					<th align="right">Price</th>
				</tr>
				<cfset recCount = 0>
				<cfloop query="data.categories">
					<cfset parm.cat = pcatID>
					<cfset items = GetProducts(parm)>
					<cfif items.products.recordcount gt 0>
						<cfset recCount += items.products.recordcount>
						<tr>
							<th colspan="3" align="left">#pcatTitle#</th>
						</tr>
						<cfloop query="items.products">
							<tr>
								<td>#prodTitle#</td>
								<cfif showSize><td align="center">#siUnitSize#</td></cfif>
								<td align="right">&pound;#siOurPrice#</td>
							</tr>
						</cfloop>
					</cfif>
				</cfloop>
				<tr>
					<td colspan="3" align="right">#LSDateFormat(Now(),"dd-mmm-yyyy")#</td>
				</tr>
			</table>		
		</cfif>
	</cfoutput>
	<script type="text/javascript">
		$(document).ready(function() {
			$("#groupList").chosen({width: "350px",enable_split_word_search:false,allow_single_deselect: true});
			$("#catList").chosen({width: "350px",enable_split_word_search:false,allow_single_deselect: true});
		});
	</script>
</body>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
</html>
