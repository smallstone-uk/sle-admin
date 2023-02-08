<cftry>
	<cfset callback = true>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.productID = productID>
	<cfset parm.allStock = allStock>
	<cfset parm.form=form>
	<cfset lookup=pstock.LoadProductAndLatestStockItem(parm)>
	<cfif allStock>
		<cfset lastYear = '2013-02-01'>
	<cfelse>
		<cfset lastYear = DateAdd("d",Now(),-365)>
	</cfif>
	<cfset startDate = CreateDate(Year(lastYear),Month(lastYear),1)>
	<cfquery name="QSalesItems" datasource="#parm.datasource#">
		SELECT *
		FROM tblepos_items
		INNER JOIN tblEpos_Header ON ehID = eiParent
		WHERE eiProdID = #val(parm.productID)#
		AND eiTimeStamp >= #startDate# 
		ORDER BY eiTimeStamp DESC;		<!---YEAR(eiTimeStamp) DESC, MONTH(eiTimeStamp) DESC, --->
	</cfquery>

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
				<th align="center">ID</th>
				<th align="right">Date</th>
				<th align="center">Mode</th>
				<th align="center">Pay Acct</th>
				<th align="right">Class</th>
				<th align="right">Qty</th>
				<th align="right">Net</th>
				<th align="right">VAT</th>
				<th align="right">Trade</th>
				<th align="right">Profit</th>
				<th align="right">POR%</th>
			</tr>
			<cfloop query="QSalesItems">
				<cfset profit = -(eiNet + eiTrade)>
				<tr>
					<td align="center">#ehID#</td>
					<td align="right">#DateFormat(ehTimestamp,"ddd dd-mmm-yy")#</td>
					<td align="center">#ehMode#</td>
					<td align="center">#ehPayAcct#</td>
					<td align="center">#eiClass#</td>
					<td align="center">#eiQty#</td>
					<td align="right">#DecimalFormat(-eiNet)#</td>
					<td align="right">#DecimalFormat(-eiVAT)#</td>
					<td align="right">#DecimalFormat(eiTrade)#</td>
					<td>#DecimalFormat(profit)#</td>
					<td>#DecimalFormat((profit / -eiNet) * 100)#%</td>
				</tr>
			</cfloop>
<!---
			<tr>
				<th></th>
				<th align="center">#totNumSales#</th>
				<th align="center">#totNumWaste#</th>
				<th align="center">#totNumNet#</th>
				<td>&nbsp;</td>
				<th align="right">&pound;#DecimalFormat(totValueSales)#</th>
				<th align="right">&pound;#DecimalFormat(totValueWaste)#</th>
				<th align="right">&pound;#DecimalFormat(totValueNet)#</th>
				<td>&nbsp;</td>
				<th align="right">&pound;#DecimalFormat(totTrade)#</th>
				<th align="right">&pound;#DecimalFormat(totProfit)#</th>
				<th align="right">#DecimalFormat((totProfit / totValueNet) * 100)#%</th>
			</tr>
--->
		</table>
	</cfoutput>
	
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

