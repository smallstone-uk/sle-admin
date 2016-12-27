<cftry>
<cfobject component="epos2/code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.form = form>
<cfset searchResults = epos.SearchProductByName(parm)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('.searchItemBtn').click(function(event) {
				var row = $(this).parent("li");
				var price = Number(row.data("price")),
					id = row.data("id"),
					title = row.data("title"),
					type = row.data("type"),
					cashonly = row.data("cashonly");
					
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
	<ul class="searchList">
		<cfif !ArrayIsEmpty(searchResults)>
			<cfloop array="#searchResults#" index="item">
				<li class="searchItem" data-id="#item.prodID#" data-title="#item.prodTitle#" data-price="#item.prodOurPrice#" data-type="product" data-cashonly="#item.prodCashOnly#">
					<button class="searchItemBtn">Add</button>
					<span style="float:left;">#item.prodTitle# <cfif len(item.prodUnitSize)>#item.prodUnitSize#</cfif><cfif item.prodCashOnly eq 1> (Cash Only)</cfif></span>
					<span style="float:right;">
						<cfif item.prodOurPrice gt 0>
							&pound;#DecimalFormat(item.prodOurPrice)#
						<cfelse>
							Manual Price
						</cfif>
					</span>
				</li>
			</cfloop>
		</cfif>
	</ul>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>