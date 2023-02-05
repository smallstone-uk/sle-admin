<cftry>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset callback = true>
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.url = application.site.normal>
	<cfset parm.form = form>
	<cfset data = pstock.LoadProducts(parm)>

	<script src="scripts/jquery-1.11.1.min.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script src="scripts/main.js"></script>
	<script src="scripts/popup.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.sod_status').click(function(event) {
				var value = $(this).html();
				var prodID = $(this).attr("data-id");
				var cell = $(this);
				$.ajax({
					type: "POST",
					url: "saveProductStatus.cfm",
					data: {"status": value, "prodID": prodID},
					success: function(data) {
						cell.html(data.trim());
						cell.css("color",'red');
						cell.css("font-weight",'bold');
					}
				});
			});
			$('.sod_discount').click(function(event) {
				var value = $(this).html();
				var prodID = $(this).attr("data-id");
				var cell = $(this);
				$.ajax({
					type: "POST",
					url: "saveProductDiscount.cfm",
					data: {"discount": value, "prodID": prodID},
					success: function(data) {
						cell.html(data.trim());
						cell.css("color",'red');
						cell.css("font-weight",'bold');
					}
				});
			});
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
					<th align="right">VAT</th>
					<th>Status</th>
					<th>Discount</th>
				</tr>
				<cfloop query="data.products">
					<tr>
						<td align="center">#currentrow#</td>
						<td><a href="ProductStock6.cfm?product=#prodID#" target="product">#prodTitle#</a></td>
						<td>#siUnitSize#</td>
						<td align="right">#siOurPrice#</td>
						<td align="right">#prodVATRate#</td>
						<td class="sod_status disable-select" data-id="#prodID#">#prodStatus#</td>
						<td class="sod_discount disable-select" data-id="#prodID#">#prodStaffDiscount#</td>
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
