
<cfset callback = true>
<cfsetting showdebugoutput="no">
<cfobject component="code/ProductStock6" name="pstock">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.form = form>
<cfset productData = pstock.AnalysisStockItems(parm)>

<cfoutput>
	<cfloop query="productData.QProdInfo">
		<table class="tableList" border="1" width="100%">
			<tr>
				<th>ID</th>
				<th>Product Title</th>
				<th>Unit Size</th>
				<th>Our Price</th>
				<th>VAT Rate</th>
				<th>Price Marked</th>
				<th>Status</th>
				<th>Group</th>
				<th>Category</th>
			</tr>
			<tr>
				<td align="center">#prodID#</td>
				<td align="center">#prodTitle#</td>
				<td align="center">#siUnitSize#</td>
				<td align="center">&pound;#siOurPrice#</td>
				<td align="center">#prodVATRate#%</td>
				<td align="center">#prodPriceMarked#</td>
				<td align="center">#prodStatus#</td>
				<td align="center">#pgTitle#</td>
				<td align="center">#pcatTitle#</td>
			</tr>
		</table>
	</cfloop>
	<table class="tableList" border="1" width="100%">
		<tr>
			<th></th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<th>#key#</th>
			</cfloop>
		</tr>
		<tr>
			<th>Sales Qty</th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<td align="center"><cfif blk.salesqty neq 0>#blk.salesqty#</cfif></td>
			</cfloop>
		</tr>
		<tr>
			<th>Stock Purchased</th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<td align="center"><cfif blk.stockqty neq 0>#blk.stockqty#</cfif></td>
			</cfloop>
		</tr>
		<tr>
			<th>Remaining Stock Qty</th>
			<cfset remStock = 0>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<cfif key neq "Total">
					<cfset remStock += (blk.stockqty - blk.salesqty)>
				</cfif>
				<th align="center">#remStock#</th>
			</cfloop>
		</tr>
		<tr>
			<th>Average Unit Price</th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<td align="center"><cfif blk.unitTrade>#DecimalFormat(blk.unitTrade)#</cfif></td>
			</cfloop>
		</tr>
		<tr>
			<th>Remaining Stock Value</th>
			<cfset remStock = 0>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<cfif key neq "Total">
					<cfset remStock += (blk.stockqty - blk.salesqty)>
				</cfif>
				<td align="center"><cfif blk.unitTrade>#DecimalFormat(remStock * blk.unitTrade)#</cfif></td>
			</cfloop>
		</tr>
		<tr>
			<th>Net Sales Value</th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<td align="center"><cfif blk.salesvalue neq 0>#DecimalFormat(blk.salesvalue)#</cfif></td>
			</cfloop>
		</tr>
		<tr>
			<th>Stock Sold</th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<td align="center"><cfif blk.tradeValue neq 0>#DecimalFormat(blk.tradeValue)#</cfif></td>
			</cfloop>
		</tr>
		<tr>
			<th>Gross Profit</th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<th align="center">#DecimalFormat(blk.salesvalue - blk.tradeValue)#</th>
			</cfloop>
		</tr>
		<tr>
			<th>POR%</th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<td align="center">#blk.POR#</td>
			</cfloop>
		</tr>
	</table>
</cfoutput>
<!---<cfdump var="#productData#" label="productData" expand="true">--->
