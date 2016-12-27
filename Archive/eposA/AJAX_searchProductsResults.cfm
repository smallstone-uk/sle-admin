<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.title = title>
<cfset results = epos.SearchProducts(parm)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('.products_list li').click(function(event) {
				var id = $(this).data("id");
				if (!window.touchhold) {
					$.LoadProduct(0, id, 0, "product",1);
				}
			});
		});
	</script>
	<ul class="products_list">
		<cfif !ArrayIsEmpty(results)>
			<cfloop array="#results#" index="item">
				<li data-id="#item.id#">
					<span class="title">
						<cfif Len(item.ref)>(#item.ref#)</cfif>
						#item.title# #item.size#
					</span>
					<span class="price">&pound;#item.price#</span>
				</li>
			</cfloop>
		<cfelse>
			<center style="padding:20px 0;">No products found!</center>
		</cfif>
	</ul>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>