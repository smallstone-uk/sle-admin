
<cfset callback = true>
<cfsetting showdebugoutput="no">
<cfobject component="code/ProductStock6" name="pstock">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.form = form>
<cfset productData = pstock.ListSalesItems(parm)>

<cfoutput>
	<cfloop query="productData.QProdInfo">
		<table class="tableList" border="1" width="100%">
			<tr>
				<th>Prod ID</th>
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
	<table class="tableList" border="1" width="100%">
		<tr>
			<th align="center">Tran ID</th>
			<th align="right">Date &amp; Time</th>
			<th align="center">Mode</th>
			<th align="center">Pay Acct</th>
			<th align="right">Class</th>
			<th align="right">Sold Qty</th>
			<th align="right">Waste Qty</th>
			<th align="right">Net</th>
			<th align="right">VAT</th>
			<th align="right">Waste</th>
			<th align="right">Trade</th>
			<th align="right">Profit</th>
			<th align="right">POR%</th>
		</tr>
		<cfset dataKeys = ListSort(StructKeyList(productData.data,","),"numeric","desc")>
		<cfloop list="#dataKeys#" index="key">
			<cfset data = StructFind(productData.data,key)>
			<tr class="">
				<td align="center">#data.ehID#</td>
				<td align="right">#DateFormat(data.eiTimestamp,"ddd dd-mmm-yy")# #TimeFormat(data.eiTimestamp,"HH:MM:SS")#</td>
				<td align="center">#data.ehMode#</td>
				<td align="center">#data.ehPayAcct#</td>
				<td align="center">#data.eiClass#</td>
				<td align="center">#data.sold#</td>
				<td align="center">#data.waste#</td>
				<td align="right">#pstock.formatNum(data.net)#</td>
				<td align="right">#pstock.formatNum(data.VAT)#</td>
				<td align="right">#pstock.formatNum(data.wasteValue)#</td>
				<td align="right">#pstock.formatNum(data.trade)#</td>
				<td align="right">#pstock.formatNum(data.profit)#</td>
				<td align="right">#data.POR#%</td>
			</tr>
		</cfloop>
		<tr>
			<th align="left">#productData.totals.count#</th>
			<th align="left" colspan="4">Totals</th>
			<th align="center">#productData.totals.sold#</th>
			<th align="center">#productData.totals.waste#</th>
			<th align="right">#DecimalFormat(productData.totals.net)#</th>
			<th align="right">#DecimalFormat(productData.totals.VAT)#</th>
			<th align="right">#DecimalFormat(productData.totals.wasteValue)#</th>
			<th align="right">#DecimalFormat(productData.totals.trade)#</th>
			<th align="right">#DecimalFormat(productData.totals.profit)#</th>
			<th align="right">#productData.totals.POR#%</th>
		</tr>
	</table>
</cfoutput>
