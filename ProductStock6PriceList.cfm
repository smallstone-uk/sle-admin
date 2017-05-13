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
		#priceList {
			border:none;
			margin:2px;
		}
		.display {
			font:"Comic Sans MS", cursive; 
			font-size:16px;
			border-spacing: 0px;
			border-collapse: collapse;
			border-color: #ccc;
			line-height:24px;
		}
		.display th {padding:4px 5px; background:#eee; border-left:solid 1px #ccc; border-color: #ccc;}
		.display td {padding:2px 5px; background:#fff; border-left:solid 1px #ccc;}
		.blankcell {padding: 2px 5px; background:#fff; border-color: #fff;}
		.printdate {font-size:10px;}
	</style>
</head>
	<cfparam name="group" default="17">
	<cfparam name="categories" default="">
	<cfparam name="period" default="12">
	<cfparam name="pricelist" default="cust">
	<cfparam name="showSize" default="0">
	<cfparam name="ignorePM" default="0">
	<cfparam name="twoColumn" default="0">
	
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
			<cfquery name="loc.QProducts" datasource="#args.datasource#" result="loc.QProductsResult">
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
				<cfif args.ignorePM>AND NOT prodPriceMarked</cfif>
				AND siStatus <> 'inactive'
				ORDER BY prodTitle
			</cfquery>
			<cfset loc.result.products = loc.QProducts>
<!---			<cfdump var="#loc.QProductsResult#" label="GetProducts" expand="yes" format="html" 
				output="#application.site.dir_logs#dump-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
--->		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="GetProducts" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="FixProduct" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cftry>
			<cfquery name="loc.QProduct" datasource="#args.datasource#">
				SELECT prodID,prodRef,prodTitle,prodPriceMarked, siID,siRef,siUnitSize,siOurPrice,soDate
				FROM tblProducts
				LEFT JOIN tblStockItem ON prodID = siProduct
				INNER JOIN tblStockOrder ON soID = siOrder
				AND tblStockItem.siID = (
					SELECT MAX( siID )
					FROM tblStockItem
					WHERE prodID = siProduct 
				)
				WHERE prodID=#args.prodID#
			</cfquery>
			<cfset loc.lastDigit = Right(loc.QProduct.siOurPrice,1)>
			<cfoutput>lastDigit = #loc.lastDigit#</cfoutput>
			<cfif loc.lastDigit gt 0>
				<cfif loc.lastDigit lt 5>
					<cfset loc.newPrice = (int(val(loc.QProduct.siOurPrice) * 10) / 10) + 0.05>
				<cfelseif loc.lastDigit gt 5>
					<cfset loc.newPrice = (int(val(loc.QProduct.siOurPrice) * 10) / 10) + 0.10>
				</cfif>
				<cfquery name="loc.QFixProduct" datasource="#args.datasource#" result="loc.QFixResult">
					UPDATE tblProducts
					INNER JOIN tblStockItem ON prodID = siProduct
					INNER JOIN tblStockOrder ON soID = siOrder
					SET siOurPrice = #loc.newPrice#,
						prodMinPrice = #loc.newPrice#
					WHERE prodID=#args.prodID#
					AND tblStockItem.siID = #loc.QProduct.siID#
				</cfquery>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="FixProduct" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
<body>
<cftry>
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfif StructKeyExists(url,"fixPrice")>
		<cfset parm.prodID = url.fixPrice>
		<cfset FixProduct(parm)>
	</cfif>
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
					<td colspan="2"><input type="checkbox" value="1" name="ignorePM"<cfif ignorePM> checked="checked"</cfif>>Ignore Pricemarked?</td>
				</tr>
				<tr>
					<td colspan="2"><input type="checkbox" value="1" name="twoColumn"<cfif twoColumn> checked="checked"</cfif>>Display in 2 columns?</td>
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
					<cfset parm.ignorePM = StructKeyExists(form,"ignorePM")>
					<cfset items = GetProducts(parm)>
					<cfif items.products.recordcount gt 0>
						<cfset recCount += items.products.recordcount>
						<tr>
							<th colspan="8" align="left">#pcatTitle#</th>
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
								<td><cfif !prodPriceMarked>
									<a href="?fixPrice=#prodID#&amp;group=#group#&amp;period=#period#&amp;showSize=#showSize#&amp;ignorePM=#ignorePM#&amp;pricelist=#pricelist#">Fix</a></cfif></td>
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
			<cfset recCount = 0>
			<cfset catTitle = "">
			<cfset lastItem = "">
			<cfset productArray = []>
			<cfif twoColumn>
				<cfloop query="data.categories">
					<cfset parm.cat = pcatID>
					<cfset parm.period = period>
					<cfset parm.ignorePM = StructKeyExists(form,"ignorePM")>
					<cfset items = GetProducts(parm)>
					<cfif items.products.recordcount gt 0>
						<cfset recCount += items.products.recordcount>
						<cfloop query="items.products">
							<cfif data.categories.pcatTitle neq catTitle>
								<cfset ArrayAppend(productArray,{
									pcatTitle = '#data.categories.pcatTitle#',
									header = true
								})>
								<cfset catTitle = data.categories.pcatTitle>
							</cfif>
							<cfif items.products.siOurPrice lt 1>
								<cfset price = '#items.products.siOurPrice * 100#p'>
							<cfelse>
								<cfset price = '&pound;#items.products.siOurPrice#'>
							</cfif>
							<cfif lastItem neq "#items.products.prodTitle#-#items.products.siUnitSize#-price">
								<cfset ArrayAppend(productArray,{
									prodTitle = '#items.products.prodTitle#',
									siUnitSize = '#items.products.siUnitSize#',
									siOurPrice = price,
									header = false
								})>
							</cfif>
							<cfset lastItem = "#items.products.prodTitle#-#items.products.siUnitSize#-price">
						</cfloop>
					</cfif>
				</cfloop>
				<cfset halfway = int(ArrayLen(productArray) / 2)>
				<table id="priceList" class="display" border="1">
					<tr>
						<th>Description</th>
						<cfif showSize><th>Size</th></cfif>
						<th align="right">Price</th>
						<td width="20" class="blankcell"></td>
						<th>Description</th>
						<cfif showSize><th>Size</th></cfif>
						<th align="right">Price</th>
					</tr>
					<cfloop from="1" to="#halfway#" index="i">
						<cfset leftItem = productArray[i]>
						<cfset rightItem = productArray[halfway+i]>
						<tr>
							<cfif leftItem.header>
								<th colspan="3">#leftItem.pcatTitle#</th>
							<cfelse>
								<td>#leftItem.prodTitle#</td>
								<td>#leftItem.siUnitSize#</td>
								<td align="right">#leftItem.siOurPrice#</td>
							</cfif>
							<td class="blankcell"></td>
							<cfif rightItem.header>
								<th colspan="3">#rightItem.pcatTitle#</th>
							<cfelse>
								<td>#rightItem.prodTitle#</td>
								<td>#rightItem.siUnitSize#</td>
								<td align="right">#rightItem.siOurPrice#</td>
							</cfif>
						</tr>
					</cfloop>
					<cfif ArrayLen(productArray) - (halfway * 2) neq 0>
						<cfset rightItem = productArray[ArrayLen(productArray)]>
						<tr>
							<td colspan="4"></td>
							<td>#rightItem.prodTitle#</td>
							<td>#rightItem.siUnitSize#</td>
							<td align="right">#rightItem.siOurPrice#</td>
						</tr>
					</cfif>
					<tr>
						<td colspan="3" class="printdate">Printed: #LSDateFormat(Now(),"dd-mmm-yyyy")#</td>
					</tr>
				</table>
				
			<cfelse>
				<table class="display" border="1" width="500">
					<tr>
						<th>Description</th>
						<cfif showSize><th>Size</th></cfif>
						<th align="right">Price</th>
					</tr>
					<cfloop query="data.categories">
						<cfset parm.cat = pcatID>
						<cfset parm.period = period>
						<cfset parm.ignorePM = StructKeyExists(form,"ignorePM")>
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
						<td colspan="3" align="right" class="printdate">#LSDateFormat(Now(),"dd-mmm-yyyy")#</td>
					</tr>
				</table>		
			</cfif>
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
