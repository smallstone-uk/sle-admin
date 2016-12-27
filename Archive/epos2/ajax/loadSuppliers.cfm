<cftry>
<cfobject component="epos2/code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.form = form>
<cfset suppliers = epos.LoadSuppliers(parm)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('.products_item').click(function(event) {
				var id = $(this).data("id"),
					title = $(this).data("title"),
					cashonly = $(this).data("cashonly"),
					type = $(this).data("type");
					
				$.virtualNumpad({
					callback: function(value) {
						$.addToBasket({
							id: id,
							title: title,
							type: type,
							price: value,
							cashonly: cashonly
						});
					}
				});
				event.preventDefault();
			});
		});
	</script>
	<div class="products">
		<ul class="products_list">
			<cfloop array="#suppliers#" index="item">
				<li class="products_item" data-id="#item.accID#" data-title="#item.accName#" data-type="supplier" data-cashonly="0">
					<span><strong>#item.accName#</strong></span>
				</li>
			</cfloop>
		</ul>
	</div>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>