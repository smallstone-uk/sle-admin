
<cfobject component="code/stock" name="stock">
<cfset parm = {}>
<cfset parm.form = form>
<cfset parm.datasource = application.site.datasource1>
<cfset result = stock.UpdateStockLevel(parm)>
<cfoutput>
	<h1>Stock Level Updated</h1>
	<table class="tableList2">
		<tr><td>Barcode</td><td>#form.barcode#</td></tr>
		<tr><td>Product ID</td><td>#form.prodID#</td></tr>
		<tr><td>Reference</td><td>#form.prodRef#</td></tr>
		<tr><td>Title</td><td>#form.prodTitle#</td></tr>
		<tr><td>Stock Level</td><td>#form.stockLevel#</td></tr>
	</table>
	<h1>Please scan the next barcode</h1>
</cfoutput>