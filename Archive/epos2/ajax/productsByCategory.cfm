<cftry>
<cfobject component="epos2/code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.form = form>
<cfset products = epos.LoadProductsByCategory(parm.form.catID)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('.products_item').click(function(event) {
				var price = Number($(this).data("price")),
					id = $(this).data("id"),
					title = $(this).data("title"),
					type = $(this).data("type"),
					cashonly = $(this).data("cashonly");
					
				if (price > 0) {
					$.addToBasket({
						id: id,
						title: title,
						type: type,
						price: price,
						cashonly: cashonly
					});
				} else {
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
				}
				event.preventDefault();
			});
		});
	</script>
	<div class="products">
		<ul class="products_list">
			<cfloop array="#products#" index="item">
				<li class="products_item" data-id="#item.prodID#" data-title="#item.prodTitle#" data-price="#item.prodOurPrice#" data-type="product" data-cashonly="#item.prodCashOnly#">
					<span><strong>#item.prodTitle#</strong><cfif item.prodCashOnly eq 1> (Cash Only)</cfif></span>
					<span>
						<cfif item.prodOurPrice gt 0>
							&pound;#DecimalFormat(item.prodOurPrice)#
						<cfelse>
							Manual Price
						</cfif>
					</span>
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