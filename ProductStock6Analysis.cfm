
<cfset callback = true>
<cfsetting showdebugoutput="no">
<cfobject component="code/ProductStock6" name="pstock">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.form = form>
<cfset productData = pstock.AnalyseProduct(parm)>

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
	<table class="tableList" border="1" width="100%">
		<tr>
			<th></th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<th>#key#</th>
			</cfloop>
		</tr>
		<tr>
			<th>Stock Purchase Qty</th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<td align="center"><cfif blk.stockqty neq 0>#blk.stockqty#</cfif></td>
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
			<th>Waste Qty</th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<td align="center"><cfif blk.wasteqty neq 0>#blk.wasteqty#</cfif></td>
			</cfloop>
		</tr>
		<tr>
			<th>Remaining Stock Qty</th>
			<cfset remStock = 0>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<cfif key neq "Total">
					<cfset remStock += (blk.stockqty - blk.salesqty - blk.wasteqty)>
				</cfif>
				<th align="center">#remStock#</th>
			</cfloop>
		</tr>
		<tr>
			<th>Average Unit Price</th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<td align="center">#pstock.formatNum(blk.unitTrade)#</td>
			</cfloop>
		</tr>
		<tr>
			<th>Stock Purchase Value</th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<td align="center">#pstock.formatNum(blk.stockValue)#</td>
			</cfloop>
		</tr>
		<tr>
			<th>Remaining Stock Value</th>
			<cfset remStock = 0>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<cfif key neq "Total">
					<cfset remStock += (blk.stockqty - blk.salesqty - blk.wasteqty)>
				</cfif>
				<th align="center">#pstock.formatNum(remStock * blk.unitTrade)#</th>
			</cfloop>
		</tr>
		<tr>
			<th>Net Sales Value</th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<td align="center">#pstock.formatNum(blk.salesvalue)#</td>
			</cfloop>
		</tr>
		<tr>
			<th>Stock Sold Value</th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<td align="center">#pstock.formatNum(blk.tradeValue)#</td>
			</cfloop>
		</tr>
		<tr>
			<th>Waste Value</th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<td align="center">#pstock.formatNum(blk.wastevalue)#</td>
			</cfloop>
		</tr>
		<tr>
			<th>Gross Profit</th>
			<cfloop list="#productData.datalist#" index="key" delimiters=",">
				<cfset blk = StructFind(productData.data,key)>
				<th align="center">#pstock.formatNum(blk.profit)#</th>
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
	<br />
	<table class="tableList" border="1" width="100%">
		<tr>
			<td>Remaining Stock Qty</td>
			<td>
				If negative, means we sold more than we bought. This is possibly due to stock not being booked 
				in or booked into the wrong product.<br />
				If positive but higher than expected, could mean a booking in error or possibly theft.<br />
				If there is stock remaining for perishable stock, then it has probably been thrown but not wasted off.
			</td>
		</tr>
	</table>
</cfoutput>
<!---<cfdump var="#productData#" label="productData" expand="true">--->
