<cftry>
<cfobject component="code/forecasting" name="cast">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.pubID = val(id)>
<cfset result = cast.CustomersPerPublication(parm)>

<cfoutput>
	<style>
		.tableList {border-spacing: 0px;border-collapse: collapse;border: 1px solid ##BDC9DD;font-size: 12px;border-color:##BDC9DD;}
		.tableList th {padding:4px 5px;background: ##EFF3F7;border-color: ##BDC9DD;color: ##18315C;}
		.tableList td {padding:2px 5px;border-color: ##BDC9DD;}
		.tableList.morespace {font-size: 12px;}
		.tableList.morespace th {padding:4px 5px;}
		.tableList.morespace td {padding:4px 5px;}
		.tableList.trhover tr:hover {background: ##EFF3F7;}
		.tableList.trhover tr.active:hover {background:##0F5E8B;}
	</style>
	<table class="tableList" border="1">
		<tr>
			<td colspan="3"><h1>#result.pubTitle#</h1></td> 
			<td colspan="5"><h1>#result.pubGroup#</h1></td>
		</tr>
		<tr>
			<th align="left">Client Ref</th>
			<th align="left">Client Name</th>
			<th align="left">Client Company Name</th>
			<th align="left">Address</th>
			<th align="left">Type</th>
			<th align="left">Status</th>
			<th align="center">Weekly<br />Qty</th>
			<th align="right">Value</th>
		</tr>
		<cfset totalQty=0>
		<cfset totalValue=0>
		<cfloop query="result.QCustomers">
			<cfset rowQty=oiSun+oiMon+oiTue+oiWed+oiThu+oiFri+oiSat>
			<cfif ListFind("H,N",cltaccounttype) OR oistatus eq 'inactive'>
				<cfset rowQty = 0>
			</cfif>
			<cfset rowValue=rowQty*pubPrice>
			<cfset totalQty += rowQty>
			<cfset totalValue += rowValue>
			<tr>
				<td><a href="#parm.url#clientDetails.cfm?ref=#cltref#" target="_newtab">#cltref#</a></td>
				<td>#clttitle# #cltinitial# #cltname#</td>
				<td>#cltcompanyname#</td>
				<td>#cltDelHouseName# #cltDelHouseNumber# #stName#</td>
				<td>#cltaccounttype#</td>
				<td>#oistatus#</td>
				<td align="center">#rowQty#</td>
				<td align="right"><cfif rowValue neq 0>#DecimalFormat(rowValue)#</cfif></td>
			</tr>
		</cfloop>
		<tr>
			<td colspan="6"></td>
			<td align="center">#totalQty#</td>
			<td align="right">#DecimalFormat(totalValue)#</td>
		</tr>
	</table>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>