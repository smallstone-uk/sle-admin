<cftry>
	<cfset callback = true>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.productID = productID>
	<cfset parm.form=form>
	<cfset lookup=pstock.LoadProductAndLatestStockItem(parm)>
	<cfset lastYear = DateAdd("d",Now(),-365)>
	<cfset startDate = CreateDate(Year(lastYear),Month(lastYear),1)>
	<!---<cfdump var="#lookup#" label="lookup" expand="false">--->
	<cfquery name="QSalesItems" datasource="#parm.datasource#">
		SELECT *
		FROM tblepos_items
		INNER JOIN tblEpos_Header ON ehID = eiParent
		WHERE eiProdID = #val(parm.productID)#
		AND eiTimeStamp >= #startDate# 
		ORDER BY YEAR(eiTimeStamp) DESC, MONTH(eiTimeStamp) DESC;
	</cfquery>
	<!---<cfdump var="#QSalesItems#" label="" expand="false">--->

	<cfset numSales = 0>
	<cfset numWaste = 0>
	<cfset numNet = 0>
	<cfset valueNet = 0>
	<cfset valueTrade = 0>
	<cfoutput>
		<table width="100%" class="showTable">
			<tr>
				<th align="left">#lookup.product.prodTitle#</th>
				<th><div id="productID2">#lookup.product.prodID#</div></th>
				<th>Sales from: #DateFormat(startDate,"dd-mmm-yyyy")#</th>
			</tr>
		</table>

		<table class="tableList">
			<tr>
				<th align="right">Date</th>
				<th align="right">Sales</th>
				<th align="right">Waste</th>
				<th align="right">Net</th>
				<td>&nbsp;</td>
				<th align="right">Value</th>
				<th align="right">Trade</th>
				<th align="right">Profit</th>
				<th align="right">POR%</th>
			</tr>
		<cfset dateKey = 0>
		<cfset totSales = 0>
		<cfset totWaste = 0>
		<cfset totNet = 0>
		<cfset totValue = 0>
		<cfset totTrade = 0>
		<cfset totProfit = 0>
		<cfloop query="QSalesItems">
			<cfset valueNet += eiNet>
			<cfset valueTrade += eiTrade>
			<cfif eiQty gt 0>
				<cfset numSales += eiQty>
				<cfset totSales += eiQty>
			<cfelse>
				<cfset numWaste -= eiQty>
				<cfset totWaste -= eiQty>
			</cfif>
			<cfif dateKey gt 0 AND dateKey neq LSDateFormat(eiTimeStamp,"yyyymm")>
				<cfset profit = valueNet + valueTrade>
				<cfset totNet += (numSales - numWaste)>
				<cfset totValue += valueNet>
				<cfset totTrade += valueTrade>
				<cfset totProfit += profit>
				<tr>
					<td align="right">#LSDateFormat(eiTimeStamp,"mmmm-yyyy")#</td>
					<td align="right">#numSales#</td>
					<td align="right">#numWaste#</td>
					<td align="right">#numSales - numWaste#</td>
					<td>&nbsp;</td>
					<td align="right">&pound;#DecimalFormat(-valueNet)#</td>
					<td align="right">&pound;#DecimalFormat(valueTrade)#</td>
					<td align="right">&pound;#DecimalFormat(-profit)#</td>
					<td align="right">#DecimalFormat((profit / valueNet) * 100)#%</td>
				</tr>
				<cfset numSales = 0>
				<cfset numWaste = 0>
				<cfset numNet = 0>
				<cfset valueNet = 0>
				<cfset valueTrade = 0>
			</cfif>
			<cfset dateKey = LSDateFormat(eiTimeStamp,"yyyymm")>
		</cfloop>
			<tr>
				<th></th>
				<th align="right">#totSales#</th>
				<th align="right">#totWaste#</th>
				<th align="right">#totNet#</th>
				<td>&nbsp;</td>
				<th align="right">&pound;#DecimalFormat(-totValue)#</th>
				<th align="right">&pound;#DecimalFormat(totTrade)#</th>
				<th align="right">&pound;#DecimalFormat(-totProfit)#</th>
				<th align="right">#DecimalFormat((totProfit / totValue) * 100)#%</th>
			</tr>
		</table>
	</cfoutput>
	
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

