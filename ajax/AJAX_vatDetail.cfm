<!--- VAT detail --->

<cfobject component="code/vatReport" name="report">
<cfset parms = {}>
<cfset parms.datasource = application.site.datasource1>
<cfset parms.form = form>
<cfset data = report.VATDetail(parms)>

<cfoutput>
	<table class="tableList" border="1" width="100%">
		<tr>
			<th colspan="2">#data.group#</th>
			<th colspan="2" align="right">Date From</th>
			<th colspan="2">#DateFormat(form.srchDateFrom,'dd-mmm-yy')#</th>
			<th colspan="2" align="right">Date To</th>
			<th colspan="2">#DateFormat(form.srchDateto,'dd-mmm-yy')#</th>
			<th colspan="2"></th>
		</tr>
		<tr>
			<th>Mode</th>
			<th>Product ID</th>
			<th width="250">Category Title</th>
			<th width="250">Product Title</th>
			<th align="right">Size</th>
			<th align="right">Price</th>
			<th align="center">Qty</th>
			<th align="right">Net</th>
			<th align="right">VAT</th>
			<th align="right">Trade</th>
			<th align="right">Profit</th>
			<th align="right">POR</th>
		</tr>
		<cfloop collection="#data.products#" item="key">
			<cfset item = StructFind(data.products,key)>
			<tr class="#item.mode#">
				<td>#item.mode#</td>
				<td><a href="productStock6.cfm?product=#item.prodID#" target="product-#item.prodID#">#item.prodID#</td>
				<td>#item.pcatTitle#</td>
				<td>#item.prodTitle#</td>
				<td align="right">#item.siUnitSize#</td>
				<td align="right">#item.siOurPrice#</td>
				<td align="center">#item.qty#</td>
				<td align="right">#DecimalFormat(item.net)#</td>
				<td align="right">#DecimalFormat(item.vat)#</td>
				<td align="right">#DecimalFormat(item.trade)#</td>
				<td align="right">#DecimalFormat(item.profit)#</td>
				<td align="right">#DecimalFormat(item.POR)#%</td>
			</tr>
		</cfloop>
		<tr>
			<th></th>
			<th></th>
			<th></th>
			<th>Totals</th>
			<th></th>
			<th></th>
			<th align="center">#data.totals.Qty#</th>
			<th align="right">#DecimalFormat(data.totals.Net)#</th>
			<th align="right">#DecimalFormat(data.totals.VAT)#</th>
			<th align="right">#DecimalFormat(data.totals.Trade)#</th>
			<th align="right">#DecimalFormat(data.totals.Profit)#</th>
			<th align="right">#DecimalFormat(data.totals.POR)#%</th>
		</tr>
	</table>
</cfoutput>