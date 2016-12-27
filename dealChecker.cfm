<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Deal Checker</title>
	<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>

	<cffunction name="LoadDealData" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfif args.range eq "current">
				<cfset loc.dateRange = " AND edStarts <= Now() AND edEnds > Now()">
			<cfelseif args.range eq "future">
				<cfset loc.dateRange = " AND edStarts > Now()">
			<cfelseif args.range eq "past">
				<cfset loc.dateRange = " AND edEnds < Now()">
			<cfelseif args.range eq "all">
				<cfset loc.dateRange = "">
			</cfif>
			<cfquery name="loc.QDeals" datasource="#args.datasource#" result="loc.QDealResult">
				SELECT ercID,ercTitle, ediID, edID,edTitle,edDealType,edStarts,edEnds,edQty, prodID,prodRef,prodTitle
				FROM tblEPOS_Deals
				INNER JOIN tblEPOS_DealItems ON ediParent=edID
				INNER JOIN tblProducts ON prodID=ediProduct
				INNER JOIN tblEPOS_RetailClubs ON ercID=edRetailClub
				WHERE edStatus='active'
				#loc.dateRange#
				ORDER BY ercID, edID, ediProduct
			</cfquery>
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
				<cfset loc.rec.edTitle = edTitle>
				<cfset loc.rec.edStarts = LSDateFormat(edStarts,"dd-mmm-yyyy")>
				<cfset loc.rec.edEnds = LSDateFormat(edEnds,"dd-mmm-yyyy")>
				<cfset loc.rec.prodID = prodID>
				<cfset loc.rec.prodRef = prodRef>
				<cfset loc.rec.prodTitle = prodTitle>
				<cfset loc.rec.style = "">
				<cfset loc.prev.style = "">
				<cfif loc.lastProd AND loc.lastProd eq prodID>
					<cfset loc.prev = loc.result.items[ArrayLen(loc.result.items)]>
					<cfif loc.prev.edStarts gte loc.rec.edStarts AND loc.prev.edEnds lte loc.rec.edEnds>
						<cfset loc.rec.style = "red">
						<cfset loc.prev.style = "red">
					<cfelseif loc.rec.edStarts gt Now() OR loc.rec.edEnds lt Now()>
						<cfset loc.rec.style = "##eee">
						<cfset ArrayAppend(loc.result.items,loc.rec)>
					</cfif>
					<cfset ArrayAppend(loc.result.items,loc.rec)>
				<cfelseif edStarts gt Now() OR edEnds lt Now()>
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
			<cfif args.range eq "currentx">
				<cfset loc.dateRange = " AND edStarts <= Now() AND edEnds > Now()">
			<cfelseif args.range eq "futurex">
				<cfset loc.dateRange = " AND edStarts > Now()">
			<cfelseif args.range eq "pastx">
				<cfset loc.dateRange = " AND edEnds < Now()">
			<cfelseif args.range eq "allx">
				<cfset loc.dateRange = "">
			</cfif>
			<cfquery name="loc.QDeals" datasource="#args.datasource#" result="loc.QDealResult">
				SELECT ercTitle, ediID, edID,edTitle,edDealType,edStarts,edEnds,edQty, prodID,prodRef,prodTitle
				FROM tblEPOS_Deals
				INNER JOIN tblEPOS_DealItems ON ediParent=edID
				INNER JOIN tblProducts ON prodID=ediProduct
				INNER JOIN tblEPOS_RetailClubs ON ercID=edRetailClub
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
				<cfset loc.rec.style = "">
				<cfset loc.prev.style = "">
				<cfif loc.lastProd AND loc.lastProd eq prodID>
					<cfset loc.prev = loc.result.items[ArrayLen(loc.result.items)]>
					<cfif loc.prev.edStarts gte loc.rec.edStarts AND loc.prev.edEnds lte loc.rec.edEnds>
						<cfset loc.rec.style = "red">
						<cfset loc.prev.style = "red">
					<cfelseif loc.rec.edStarts gt Now() OR loc.rec.edEnds lt Now()>
						<cfset loc.rec.style = "##eee">
						<cfset ArrayAppend(loc.result.items,loc.rec)>
					</cfif>
					<cfset ArrayAppend(loc.result.items,loc.rec)>
				<cfelseif edStarts gt Now() OR edEnds lt Now()>
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
<cftry>
	<cfoutput>
		<div>
			<form method="post" enctype="multipart/form-data">
				Report Date: 
				<select name="view" id="view">
					<option value="">Select view...</option>
					<option value="current">Current Deals</option>
					<option value="future">Future Deals</option>
					<option value="past">Past Deals</option>
					<option value="all">All Deals</option>
					<option disabled="disabled">-</option>
					<option value="currentx">Current Cross Check</option>
					<option value="futurex">Future Deals Cross Check</option>
					<option value="pastx">Past Deals Cross Check</option>
					<option value="allx">All Deals Cross Check</option>
				</select>
				<input type="submit" name="btnGo" value="Go">
			</form>
		</div>
		<cfif StructKeyExists(form,"view")>
			<cfset parm = {}>
			<cfset parm.datasource = application.site.datasource1>
			<!---<cfloop list="current,future,past,all" delimiters="," index="range">--->
			<cfset parm.range = form.view>
			<cfif ListFind("currentx,allx",parm.range,",")> 
				<cfset result = DealCrossRef(parm)>
				<h1>#parm.range#</h1>
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
							<td>#item.prodID#</td>
							<td>#item.prodRef#</td>
							<td>#item.edDealType#</td>
							<td>#item.edQty#</td>
							<td>#item.prodTitle#</td>
							<td>#item.ercTitle#</td>
							<td>#item.edID#</td>
							<td>#item.edTitle#</td>
							<td>#item.edStarts#</td>
							<td>#item.edEnds#</td>
						</tr>
					</cfloop>
				</table>
			</cfif>
			<!---</cfloop>--->
			<cfif ListFind("current,future,past,all",parm.range,",")> 
				<cfset result = LoadDealData(parm)>
				<h1>#parm.range#</h1>
				<table class="tableList" border="1">
					<tr>
						<th>##</th>
						<th>RC ID</th>
						<th>Retail Club</th>
						<th>ID</th>
						<th>prodID</th>
						<th>Ref</th>
						<th>Deal Type</th>
						<th>Deal Qty</th>
						<th>Product Title</th>
						<th>Deal ID</th>
						<th>Deal Title</th>
						<th>Starts</th>
						<th>Ends</th>
					</tr>
					<cfset recCount = 0>
					<cfset dealID = 0>
					<cfloop array="#result.items#" index="item">
						<cfset recCount++>
						<cfif item.edID neq dealID>
							<tr><td>&nbsp;</td></tr>
						</cfif>
						<cfset dealID = item.edID>
						<tr bgcolor="#item.style#">
							<td>#recCount#</td>
							<td>#item.ercID#</td>
							<td>#item.ercTitle#</td>
							<td>#item.ediID#</td>
							<td>#item.prodID#</td>
							<td>#item.prodRef#</td>
							<td>#item.edDealType#</td>
							<td>#item.edQty#</td>
							<td>#item.prodTitle#</td>
							<td>#item.edID#</td>
							<td>#item.edTitle#</td>
							<td>#item.edStarts#</td>
							<td>#item.edEnds#</td>
						</tr>
					</cfloop>
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