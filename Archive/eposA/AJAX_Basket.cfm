<cftry>

<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset load=epos.LoadBasket(parm)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('.basket_item').touchHold([
				{
					text: "quantity",
					action: function(i, e) {
						$.virtualNumpad(function(value) {
							if (Number(value) > 99) {
								$.messageBox("You have exceeded the maximum quantity", "error");
							} else if (Number(value) <= 0) {
								$.messageBox("You must enter a quantity greater than zero", "error");
							} else {
								$.ajax({
									type: "POST",
									url: "AJAX_BasketUpdateQty.cfm",
									data: {
										"index": i.index,
										"newQty": value
									},
									success: function(data) {
										$.messageBox(i.title + " quantity updated", "success");
										$('##basket').LoadBasket();
									}
								});
							}
						}, true);
					}
				},
				{
					text: "remove",
					action: function(i, e) {
						$.ajax({
							type: "POST",
							url: "AJAX_removeFromBasket.cfm",
							data: {"index": i.index},
							success: function(data) {
								$.messageBox(i.title + " removed from basket", "success");
								$('##basket').LoadBasket();
							}
						});
					}
				}
			]);
		});
	</script>
	<div class="header">
		<span class="title">Product Title</span>
		<span class="qty">Qty</span>
		<span class="price">Price</span>
		<span class="linetotal">Line Total</span>
	</div>
	<ul class="custom-scrollbar">
		<cfif ArrayLen(load.basket)>
			<cfloop array="#load.basket#" index="i">
				<li class="basket_item" data-index="#i.index#" data-title="#i.prodTitle#">
					<span class="title">#i.prodTitle# <cfif i.cashonly is 1>(Cash Only)</cfif></span>
					<span class="qty">#i.qty#</span>
					<span class="price">&pound;#DecimalFormat(i.price)#</span>
					<span class="linetotal">&pound;#DecimalFormat(i.linetotal)#</span>
				</li>
			</cfloop>
		<cfelse>
			<li>Basket Empty</li>
		</cfif>
		<cfif ArrayLen(load.deals)>
			<cfloop array="#load.deals#" index="d">
				<cfif d.DealQty neq 0>
					<li class="basket_deal" data-index="#d.index#" data-title="#d.Title#">
						<span class="title">#d.Title#</span>
						<span class="qty">#d.DealQty#</span>
						<span class="price">&nbsp;</span>
						<span class="linetotal">&pound;#DecimalFormat(d.linetotal)#</span>
					</li>
				</cfif>
			</cfloop>
		</cfif>
		<cfif ArrayLen(load.payments)>
			<cfloop array="#load.payments#" index="p">
				<li class="basket_payment">
					<span class="title">#UCase(p.Type)#</span>
					<span class="qty">&nbsp;</span>
					<span class="price">&nbsp;</span>
					<span class="linetotal">&pound;#DecimalFormat(p.amount)#</span>
				</li>
			</cfloop>
		</cfif>
		<cfdump var="#session#" label="session" expand="no">
	</ul>
	<div class="footer">
		<span class="total">
			<cfif DecimalFormat(val(parm.form.changedue)) is 0>
				<cfif load.total lt 0>
					<span class="totaltext">Change Due</span>
					<span class="totalamount">&pound;#DecimalFormat(load.total*-1)#</span>
				<cfelse>
					<span class="totaltext">Sub Total</span>
					<span class="totalamount">&pound;#DecimalFormat(load.total)#</span>
				</cfif>
			<cfelse>
				<span class="totaltext">Change Due</span>
				<span class="totalamount">&pound;#DecimalFormat(parm.form.changedue)#</span>
			</cfif>
		</span>
	</div>
</cfoutput>

	<cfcatch type="any">
		<div class="dumpstop">
			<cfdump var="#load#" label="load" expand="no">
			<cfdump var="#session#" label="session" expand="no">
			<cfdump var="#cfcatch#" label="cfcatch" expand="no">
		</div>
	</cfcatch>
</cftry>