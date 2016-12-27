<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset load=epos.LoadCatsProducts(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('.prodtile').click(function(e) {
			var id=$(this).data("id");
			$(this).removeClass("active");
			$.LoadProduct(0,id,0,"product",1);
			/*$.addToBasket({
				id: id,
				type: "product",
				qty: 1
			});*/
			e.preventDefault();
		});
		$('.backtobasket').click(function(e) {
			$.CloseOverlay();
			e.preventDefault();
		});
	});
</script>

<cfoutput>
	<div class="list">
		<cfif ArrayLen(load)>
			<cfloop array="#load#" index="i">
				<a href="javascript:void(0)" class="tile prodtile<cfif ArrayLen(load) gt 12> small</cfif>" data-id="#i.ID#" data-title="#i.title#">
					<div class="inner">
						<div class="title">#i.title#</div>
						<cfif i.price neq 0><div class="price">&pound;#DecimalFormat(i.price)#</div></cfif>
						<cfif i.cashonly is 1><div class="cashonly">(Cash Only)</div></cfif>
					</div>
				</a>
			</cfloop>
		<cfelse>
			<p>No products found in this category (#parm.form.id#)</p>
		</cfif>
		<div style="clear:both;"></div>
	</div>
</cfoutput>

