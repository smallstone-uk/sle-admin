
<cfset callback = true>
<cfsetting showdebugoutput="no">
<cfobject component="code/ProductStock6" name="pstock">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.form = form>
<cfset productData = pstock.AnalysisSalesItems(parm)>

<cfoutput>
	<cfloop query="productData.QProdInfo">
		<table class="tableList" border="1" width="100%">
			<tr>
				<th>ID</th>
				<th>Product Title</th>
				<th>Unit Size</th>
				<th>Case Qty</th>
				<th>Our Price</th>
				<th>VAT Rate</th>
				<th>Status</th>
				<th>Group</th>
				<th>Category</th>
			</tr>
			<tr>
				<td align="center">#prodID#</td>
				<td align="center">#prodTitle#</td>
				<td align="center">#siUnitSize#</td>
				<td align="center">#siPackQty#</td>
				<td align="center">&pound;#siOurPrice# #productData.priceMarked#</td>
				<td align="center">#prodVATRate#%</td>
				<td align="center">#prodStatus#</td>
				<td align="center">#pgTitle#</td>
				<td align="center">#pcatTitle#</td>
			</tr>
		</table>
	</cfloop>
	<table class="tableList" border="1" width="50%">
		<tr>
			<th align="right">Date</th>
			<th align="center">Sales</th>
			<th align="center">Waste</th>
			<td>&nbsp;</td>
			<th align="right">Net</th>
			<th align="right">VAT</th>
			<th align="right">Waste</th>
			<td>&nbsp;</td>
			<th align="right">Trade</th>
			<th align="right">Profit</th>
			<th align="right">POR%</th>
		</tr>
		<cfset dateKeys = ListSort(StructKeyList(productData.data,","),"numeric","desc")>
		<cfloop list="#dateKeys#" index="key">
			<cfset data = StructFind(productData.data,key)>
			<tr>
				<td align="right">#data.dateTitle#</td>
				<td align="center">#data.numSales#</td>
				<td align="center">#data.numWaste#</td>
				<td>&nbsp;</td>
				<td align="right">#pstock.formatNum(data.valueNet)#</td>
				<td align="right">#pstock.formatNum(data.valueVAT)#</td>
				<td align="right">#pstock.formatNum(data.valueWaste)#</td>
				<td>&nbsp;</td>
				<td align="right">#pstock.formatNum(data.valueTrade)#</td>
				<td align="right">#pstock.formatNum(data.valueProfit)#</td>
				<td align="right">#pstock.formatNum(data.POR)#%</td>
			</tr>
		</cfloop>
		<tr>
			<th align="left">Totals</th>
			<th align="center">#productData.totals.sold#</th>
			<th align="center">#productData.totals.waste#</th>
			<th></th>
			<th align="right">#pstock.formatNum(productData.totals.net)#</th>
			<th align="right">#pstock.formatNum(productData.totals.VAT)#</th>
			<th align="right">#pstock.formatNum(productData.totals.wasteValue)#</th>
			<th></th>
			<th align="right">#pstock.formatNum(productData.totals.trade)#</th>
			<th align="right">#pstock.formatNum(productData.totals.profit)#</th>
			<th align="right">#pstock.formatNum(productData.totals.POR)#%</th>
		</tr>
	</table>
</cfoutput>
