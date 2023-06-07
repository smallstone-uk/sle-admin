<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Deal Checker</title>
	<link rel="stylesheet" type="text/css" href="css/main3.css"/>
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="scripts/jquery-1.11.1.min.js" type="text/javascript"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js" type="text/javascript"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js" type="text/javascript"></script>
	<script src="scripts/jquery.hoverIntent.minified.js" type="text/javascript"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, maxDate: new Date(2032, 12, 31), minDate: new Date(2012, 1 - 1, 1)});	
				
			$('.sod_status').click(function(event) {
				var value = $(this).html();
				var dealID = $(this).attr("data-id");
				var cell = $(this);
				$.ajax({
					type: "POST",
					url: "saveDealStatus.cfm",
					data: {"status": value, "dealID": dealID},
					success: function(data) {
						cell.html(data.trim());
						cell.css("color",'red');
						cell.css("font-weight",'bold');
					}
				});
			});
		});
	</script>
	<style type="text/css">
		.dealHeader {background-color:#dddddd;}
		.productHeader {background-color:#99CCFF;}
	</style>
</head>
<cfobject component="code/deals" name="deals">

	<cffunction name="LoadDealData" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfif args.range eq "current">
				<cfset loc.dateRange = " AND edStarts <= DATE(Now()) AND edEnds >= DATE(Now())">
			<cfelseif args.range eq "future">
				<cfset loc.dateRange = " AND edStarts >= DATE(Now())">
			<cfelseif args.range eq "past">
				<cfset loc.dateRange = " AND edEnds < DATE(Now())">
			<cfelseif args.range eq "all">
				<cfset loc.dateRange = "">
			</cfif>
			<cfquery name="loc.QDeals" datasource="#args.datasource#" result="loc.QDealResult">
				SELECT ercID,ercTitle, ediID, edID,edTitle,edDealType,edStarts,edEnds,edQty,edAmount,edStatus, prodID,prodRef,prodTitle,prodLastBought, barcode,
					siUnitSize,siOurPrice
				FROM tblEPOS_Deals
				INNER JOIN tblEPOS_RetailClubs ON ercID=edRetailClub
				INNER JOIN tblEPOS_DealItems ON ediParent=edID
				INNER JOIN tblProducts ON prodID=ediProduct
				INNER JOIN tblBarcodes ON barProdID = prodID
				INNER JOIN tblStockItem ON prodID = siProduct
				AND tblStockItem.siID = (
					SELECT MAX( siID )
					FROM tblStockItem
					WHERE prodID = siProduct )
				WHERE barType = 'product'
				#loc.dateRange#
				<cfif len(args.dealStatus)>AND edStatus = '#args.dealStatus#'</cfif>
				<cfif StructKeyExists(args,"boughtFrom") AND len(args.boughtFrom)>AND prodLastBought >= '#DateFormat(args.boughtFrom,"yyyy-mm-dd")#'</cfif>
				<cfif StructKeyExists(args,"boughtTo") AND len(args.boughtTo)>AND prodLastBought <= '#DateFormat(args.boughtTo,"yyyy-mm-dd")#'</cfif>
				<cfif StructKeyExists(args,"retailClub") AND retailClub gt 0>AND ercID = #args.retailClub#</cfif>
				ORDER BY ercID, edTitle, ediProduct
			</cfquery>
			<!---<cfdump var="#loc.QDealResult#" label="QDeals" expand="false">--->
			<cfset loc.today = CreateDate(year(now()),month(now()),day(now()))>
			<cfset loc.result.QDeals = loc.QDeals>
			<cfset loc.result.items = []>
			<cfset loc.lastProd = 0>
			<cfloop query="loc.QDeals">
				<cfset loc.rec = {}>
				<cfset loc.rec.ercID = ercID>
				<cfset loc.rec.ercTitle = ercTitle>
				<cfset loc.rec.ediID = ediID>
				<cfset loc.rec.edDealType = edDealType>
				<cfset loc.rec.edID = edID>
				<cfset loc.rec.edQty = edQty>
				<cfset loc.rec.edAmount = edAmount>
				<cfset loc.rec.edStatus = edStatus>
				<cfset loc.rec.edTitle = edTitle>
				<cfset loc.rec.edStarts = LSDateFormat(edStarts,"dd-mmm-yyyy")>
				<cfset loc.rec.edEnds = LSDateFormat(edEnds,"dd-mmm-yyyy")>
				<cfset loc.rec.prodID = prodID>
				<cfset loc.rec.prodRef = prodRef>
				<cfset loc.rec.prodTitle = prodTitle>
				<cfset loc.rec.siUnitSize = siUnitSize>
				<cfset loc.rec.siOurPrice = siOurPrice>
				<cfset loc.rec.prodLastBought = prodLastBought>
				<cfset loc.rec.barcode = barcode>
				<cfset loc.rec.style = "">
				<cfset loc.prev.style = "">
				<cfif loc.lastProd AND loc.lastProd eq prodID>
					<cfset loc.lastItem = ArrayLen(loc.result.items)>
					<cfset loc.prev = loc.result.items[loc.lastItem]>
					<cfif loc.prev.edStarts gte loc.rec.edStarts AND loc.prev.edEnds lte loc.rec.edEnds>
						<cfset loc.rec.style = "fuschia">
					<cfset ArrayAppend(loc.result.items,loc.rec)>
						<cfset loc.result.items[loc.lastItem].style = "blue">
					<cfelseif loc.rec.edStarts gte loc.today OR loc.rec.edEnds lte loc.today>
						<cfset loc.rec.style = "##eee">
						<cfset ArrayAppend(loc.result.items,loc.rec)>
					</cfif>
				<cfelseif edStarts gte loc.today OR edEnds lte loc.today>
					<cfset loc.rec.style = "##eee">
					<cfset ArrayAppend(loc.result.items,loc.rec)>
				<cfelse>
					<cfset loc.rec.style = "white">
					<cfset ArrayAppend(loc.result.items,loc.rec)>
				</cfif>
				<cfset loc.lastProd = prodID>			
			</cfloop>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="DealCrossRef" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfset loc.today = CreateDate(year(now()),month(now()),day(now()))>
			<cfif args.range eq "currentx">
				<cfset loc.dateRange = " AND edStarts <= DATE(Now()) AND edEnds >= DATE(Now())">
			<cfelseif args.range eq "futurex">
				<cfset loc.dateRange = " AND edStarts > DATE(Now())">
			<cfelseif args.range eq "pastx">
				<cfset loc.dateRange = " AND edEnds < DATE(Now())">
			<cfelseif args.range eq "allx">
				<cfset loc.dateRange = "">
			</cfif>
			<cfquery name="loc.QDeals" datasource="#args.datasource#" result="loc.QDealResult">
				SELECT ercTitle, ediID, edID,edTitle,edDealType,edStarts,edEnds,edQty, prodID,prodRef,prodTitle, barcode
				FROM tblEPOS_Deals
				INNER JOIN tblEPOS_DealItems ON ediParent=edID
				INNER JOIN tblProducts ON prodID=ediProduct
				INNER JOIN tblEPOS_RetailClubs ON ercID=edRetailClub
				INNER JOIN tblBarcodes ON barProdID = prodID
				WHERE edStatus='active'
				#loc.dateRange#
				ORDER BY ediProduct
			</cfquery>
			<cfset loc.result.QDeals = loc.QDeals>
			<cfset loc.result.items = []>
			<cfset loc.lastProd = 0>
			<cfloop query="loc.QDeals">
				<cfset loc.rec = {}>
				<cfset loc.rec.ediID = ediID>
				<cfset loc.rec.ercTitle = ercTitle>
				<cfset loc.rec.edDealType = edDealType>
				<cfset loc.rec.edID = edID>
				<cfset loc.rec.edQty = edQty>
				<cfset loc.rec.edTitle = edTitle>
				<cfset loc.rec.edStarts = LSDateFormat(edStarts,"dd-mmm-yyyy")>
				<cfset loc.rec.edEnds = LSDateFormat(edEnds,"dd-mmm-yyyy")>
				<cfset loc.rec.prodID = prodID>
				<cfset loc.rec.prodRef = prodRef>
				<cfset loc.rec.prodTitle = prodTitle>
				<cfset loc.rec.barcode = barcode>
				<cfset loc.rec.style = "">
				<cfset loc.prev.style = "">
				<cfif loc.lastProd AND loc.lastProd eq prodID>
					<cfset loc.lastItem = ArrayLen(loc.result.items)>
					<cfset loc.prev = loc.result.items[loc.lastItem]>
					<cfif loc.prev.edStarts gte loc.rec.edStarts AND loc.prev.edEnds lte loc.rec.edEnds>
						<cfset loc.rec.style = "red">
						<cfset loc.result.items[loc.lastItem].style = "red">
						<!---<cfdump var="#loc.prev#" label="#prodTitle#" expand="false">--->
					<cfelseif loc.rec.edStarts gte loc.today OR loc.rec.edEnds lte loc.today>
						<cfset loc.rec.style = "##eee">
						<cfset ArrayAppend(loc.result.items,loc.rec)>
					</cfif>
					<cfset ArrayAppend(loc.result.items,loc.rec)>
				<cfelseif edStarts gte loc.today OR edEnds lte loc.today>
					<cfset loc.rec.style = "##eee">
					<cfset ArrayAppend(loc.result.items,loc.rec)>
				<cfelse>
					<cfset loc.rec.style = "white">
					<cfset ArrayAppend(loc.result.items,loc.rec)>
				</cfif>
				<cfset loc.lastProd = prodID>			
			</cfloop>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

<body>
<cfparam name="retailClub" default="">
<cfparam name="dealview" default="">
<cfparam name="boughtFrom" default="">
<cfparam name="boughtTo" default="">
<cfparam name="dealStatus" default="">
<cftry>
	<cfoutput>
		<div>
			<form method="post" enctype="multipart/form-data">
				<table class="tableList" border="1">
					<tr>
						<td>Retail Clubs</td>
						<td>
							<select name="retailClub" id="retailClubSelect">
								<option value="-1">All Deals</option>
								<optgroup label="Retail Clubs">
									<cfloop array="#deals.LoadRetailClubs()#" index="item">
										<option value="#item.ercID#"<cfif retailClub eq item.ercID> selected="selected"</cfif>>#item.ercTitle#</option>
									</cfloop>
								</optgroup>
							</select>
						</td>
					</tr>
					<tr>
						<td>Deal Types</td>
						<td>
							<select name="dealview" id="view">
								<option value=""<cfif dealview eq ""> selected="selected"</cfif>>Select view...</option>
								<option value="current"<cfif dealview eq "current"> selected="selected"</cfif>>Current Deals</option>
								<option value="future"<cfif dealview eq "future"> selected="selected"</cfif>>Future Deals</option>
								<option value="past"<cfif dealview eq "past"> selected="selected"</cfif>>Past Deals</option>
								<option value="all"<cfif dealview eq "all"> selected="selected"</cfif>>All Deals</option>
								<option disabled="disabled">-</option>
								<option value="currentx"<cfif dealview eq "currentx"> selected="selected"</cfif>>Current Cross Check</option>
								<option value="futurex"<cfif dealview eq "futurex"> selected="selected"</cfif>>Future Deals Cross Check</option>
								<option value="pastx"<cfif dealview eq "pastx"> selected="selected"</cfif>>Past Deals Cross Check</option>
								<option value="allx"<cfif dealview eq "allx"> selected="selected"</cfif>>All Deals Cross Check</option>
							</select>
						</td>
					</tr>
					<tr>
						<td>Product Last Bought Between</td>
						<td><input type="text" name="boughtFrom" id="boughtFrom" size="10" class="datepicker" value="#boughtFrom#" tabindex="6" /></td>
					</tr>
					<tr>
						<td>And</td>
						<td><input type="text" name="boughtTo" id="boughtTo" size="10" class="datepicker" value="#boughtTo#" tabindex="6" /></td>
					</tr>
					<tr>
						<td>Deal Status</td>
						<td>
							<select name="dealStatus" class="dealStatus" data-placeholder="Select...(optional)">
								<option value=""<cfif dealStatus eq ""> selected="selected"</cfif>>either</option>
								<option value="active"<cfif dealStatus eq "active"> selected="selected"</cfif>>active</option>
								<option value="inactive"<cfif dealStatus eq "inactive"> selected="selected"</cfif>>inactive</option>
							</select>									
						</td>
					</tr>
					<tr>	
						<td colspan="2">
							<input type="submit" name="btnGo" value="Go">
						</td>
					</tr>
				</table>
			</form>
		</div>
		<cfif StructKeyExists(form,"dealview")>
			<cfset parm = {}>
			<cfset parm.datasource = application.site.datasource1>
			<cfset parm.retailClub = form.retailClub>
			<cfset parm.range = form.dealview>
			<cfset parm.boughtFrom = form.boughtFrom>
			<cfset parm.boughtTo = form.boughtTo>
			<cfset parm.dealStatus = form.dealStatus>
			<cfif ListFind("currentx,allx",parm.range,",")> 
				<cfset result = DealCrossRef(parm)>
				<h1>#parm.range# Deals</h1>
				<table class="tableList" border="1">
					<tr>
						<th>##</th>
						<th>ID</th>
						<th>prodID</th>
						<th>Ref</th>
						<th>Deal Type</th>
						<th>Deal Qty</th>
						<th>Product Title</th>
						<th>Retail Club</th>
						<th>Deal ID</th>
						<th>Deal Title</th>
						<th>Starts</th>
						<th>Ends</th>
						<th>Barcode</th>
					</tr>
					<tr>
						<td colspan="11">
							<span style="background:red">Product in multiple deals</span>
							<span style="background:##eee">Deal not active</span>
						</td>
					</tr>
					<cfset recCount = 0>
					<cfloop array="#result.items#" index="item">
						<cfset recCount++>
						<tr bgcolor="#item.style#">
							<td>#recCount#</td>
							<td>#item.ediID#</td>
							<td><a href="productStock6.cfm?product=#item.prodID#" target="checkDeal">#item.prodID#</a></td>
							<td>#item.prodRef#</td>
							<td>#item.edDealType#</td>
							<td>#item.edQty#</td>
							<td>#item.prodTitle#</td>
							<td>#item.ercTitle#</td>
							<td>#item.edID#</td>
							<td>#item.edTitle#</td>
							<td>#item.edStarts#</td>
							<td>#item.edEnds#</td>
							<td>#item.barcode#</td>
						</tr>
					</cfloop>
				</table>
			</cfif>
			<!---</cfloop>--->
			<cfif ListFind("current,future,past,all",parm.range,",")> 
				<cfset result = LoadDealData(parm)><!---<cfdump var="#result#" label="result" expand="false">--->
				<h1>#parm.range# Deals</h1>
				<table class="tableList" border="1">
					<tr>
						<th>RC ID</th>
						<th>Retail Club</th>
						<th>Deal ID</th>
						<th>Deal Type</th>
						<th>Deal Qty</th>
						<th>Deal Title</th>
						<th></th>
						<th></th>
						<th>Starts</th>
						<th>Ends</th>
						<th>Status</th>
					</tr>
					<tr class="productHeader">
						<td></td>
						<td></td>
						<td align="center">##</td>
						<td>Prod ID</td>
						<td>Ref</td>
						<td>Product Title</td>
						<td>Size</td>
						<td>Price</td>
						<td>Last Bought</td>
						<td>Barcode</td>
						<td></td>
					</tr>
					<cfset dealCount = 0>
					<cfset prodCount = 0>
					<cfset dealID = 0>
					<cfloop array="#result.items#" index="item">
						<cfset prodCount++>
						<cfif item.edID neq dealID>
							<cfset dealCount++>
							<tr><td>&nbsp;</td></tr>
							<tr class="dealHeader">
								<td>#item.ercID#</td>
								<td>#item.ercTitle#</td>
								<td>#item.edID#</td>
								<td>#item.edDealType#</td>
								<td>#item.edQty#</td>
								<td>#item.edTitle#</td>
								<td></td>
								<td>&pound;#item.edAmount#</td>
								<td>#item.edStarts#</td>
								<td>#item.edEnds#</td>
								<td class="sod_status disable-select" data-id="#item.edID#">#item.edStatus#</td>
							</tr>
						</cfif>
						<cfset dealID = item.edID>
						<tr class="productHeader" bgcolor="#item.style#">
							<td></td>
							<td></td>
							<td align="center">#prodCount#</td>
							<td><a href="productStock6.cfm?product=#item.prodID#" target="checkDeal">#item.prodID#</a></td>
							<td>#item.prodRef#</td>
							<td>#item.prodTitle#</td>
							<td>#item.siUnitSize#</td>
							<td>&pound;#item.siOurPrice#</td>
							<td>#DateFormat(item.prodLastBought,'dd-mmm-yy')#</td>
							<td>#item.barcode#</td>
							<td></td>
						</tr>
<!---
						<tr bgcolor="#item.style#">
							<td>#recCount#</td>
							<td>#item.ercID#</td>
							<td>#item.ercTitle#</td>
							<td>#item.edID#</td>
							<td><a href="productStock6.cfm?product=#item.prodID#" target="checkDeal">#item.prodID#</a></td>
							<td>#item.prodRef#</td>
							<td>#item.edDealType#</td>
							<td>#item.edQty#</td>
							<td>#item.prodTitle#</td>
							<td>#DateFormat(item.prodLastBought,'dd-mmm-yy')#</td>
							<td>#item.edID#</td>
							<td>#item.edTitle#</td>
							<td>#item.edStarts#</td>
							<td>#item.edEnds#</td>
							<td class="sod_status disable-select" data-id="#item.edID#">#item.edStatus#</td>
							<td>#item.barcode#</td>
						</tr>
--->
					</cfloop>
					<tr>
						<th></th>
						<th>#dealCount# deals.</th>
						<th>#prodCount# products.</th>
						<th colspan="10"></th>
					</tr>
				</table>
			</cfif>
		</cfif>
	</cfoutput>
		
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

</body>
</html>