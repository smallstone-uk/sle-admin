<cftry>
	<cfobject component="code/deals" name="deals">
	<cfset parm = {}>
	<cfset parm.form = form>
	<cfset parm.form.query = parm.form.ps_search_fld>
	<cfset data = deals.SearchProductsByName(parm.form.query)>

	<cfoutput>
		<script>
			$(document).ready(function(e) {
				$('.psr_item').click(function(event) {
					event.preventDefault();
					window.productSelectComplete([{
						id: $(this).data("id"),
						title: $(this).data("title")
					}]);
				});
			});
		</script>
		<cfloop array="#data#" index="item">
			<cfif Len(item.prodTitle)>
				<div class="psr_item" data-id="#item.prodID#" data-title="#item.prodTitle#">
					<span class="psri_title">#item.prodTitle#</span>
					<span class="psri_price">
						<cfif Len(item.siOurPrice)>
							&pound;#item.siOurPrice#
						<cfelse>
							?
						</cfif>
					</span>
					<span class="psri_size">
						<cfif Len(item.siUnitSize)>
							#item.siUnitSize#
						<cfelse>
							?
						</cfif>
					</span>
				</div>
			</cfif>
		</cfloop>
	</cfoutput>

	<cfcatch type="any">
		<cf_dumptofile var="#cfcatch#">
	</cfcatch>
</cftry>
