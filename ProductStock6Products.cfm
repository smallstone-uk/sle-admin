<cftry>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset callback = true>
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.url = application.site.normal>
	<cfset parm.form = form>
	<cfset data = pstock.LoadProducts(parm)>

	<script type="text/javascript">
		$(document).ready(function() {
		});
	</script>
	<cfoutput>
		<cfif data.products.recordcount gt 0>
			<table class="tableList" width="100%" border="1">
				<tr>
					<th></th>
					<th>#data.products.pcatTitle#</th>
					<th align="right">Size</th>
					<th align="right">Price</th>
				</tr>
				<cfloop query="data.products">
					<tr>
						<td align="center">#currentrow#</td>
						<td><a href="ProductStock6.cfm?product=#prodID#" target="product">#prodTitle#</a></td>
						<td>#siUnitSize#</td>
						<td align="right">#siOurPrice#</td>
					</tr>
				</cfloop>
			</table>
		<cfelse>
			<span class="title2">This category has no products.</span>
		</cfif>
<!---		<form method="post">
			<input type="hidden" name="categoryID" id="categoryID" value="#data.pcatID#" />
		</form>
--->	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
