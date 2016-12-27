<cftry>
<cfsetting showdebugoutput="no">
<cfobject component="epos2/code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset basket = session.epos_frame.basket>
<cfset sign = (2 * int(session.epos_frame.mode eq "reg")) - 1>
<cfset session.epos_frame.result.balanceDue = 0>
<cfset session.epos_frame.result.totalGiven = 0>
<cfset session.epos_frame.result.changeDue = 0>
<cfif NOT StructKeyExists(session.epos_frame.result, "discount")>
	<cfset session.epos_frame.result.discount = 0>
</cfif>
<cfset epos.ProcessDeals()>
<cfset discountMessage = epos.ProcessDiscounts()>
<cfset basketIsEmpty = (epos.BasketItemCount() is 0) ? true : false>

<cfset colour = {
	red = "background-color:rgba(207, 0, 0, 0.25);",
	orange = "background-color:rgba(207, 126, 0, 0.25);",
	green = "background-color:rgba(52, 207, 0, 0.25);"
}>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			var #ToScript(discountMessage, "discountMessage")#;
			if (discountMessage.length > 0) {
				$.msgBox(discountMessage);
			}
			$('.basket_payment, .basket_discount').touchHold([
				{
					text: "remove",
					action: function(a, e) {
						$.ajax({
							type: "POST",
							url: "ajax/removeFromBasket.cfm",
							data: {
								"type": a.type,
								"index": a.index
							},
							success: function(data) {
								$.loadBasket();
							}
						});
					}
				}
			]);
			$('.basket_item').touchHold([
				{
					text: "remove",
					action: function(a, e) {
						$.ajax({
							type: "POST",
							url: "ajax/removeFromBasket.cfm",
							data: {
								"type": a.type,
								"index": a.index
							},
							success: function(data) {
								$.loadBasket();
							}
						});
					}
				},
				{
					text: "quantity",
					action: function(a, e) {
						$.virtualNumpad({
							wholenumber: true,
							callback: function(value) {
								if (value > 0) {
									$.ajax({
										type: "POST",
										url: "ajax/editBasketQuantity.cfm",
										data: {
											"type": a.type,
											"index": a.index,
											"newQty": value
										},
										success: function(data) {
											$.loadBasket();
										}
									});
								} else {
									$.ajax({
										type: "POST",
										url: "ajax/removeFromBasket.cfm",
										data: {
											"type": a.type,
											"index": a.index
										},
										success: function(data) {
											$.loadBasket();
										}
									});
								}
							}
						});
					}
				},
				{
					text: "discount",
					action: function(a, e) {
						$.virtualNumpad({
							wholenumber: true,
							minimum: 0,
							maximum: 10,
							callback: function(value) {
								if (value > 0 && value <= 10) {
									$.ajax({
										type: "POST",
										url: "ajax/discountProductInBasket.cfm",
										data: {
											"type": a.type,
											"index": a.index,
											"discount": value
										},
										success: function(data) {
											$.loadBasket();
										}
									});
								}
							}
						});
					}
				}
			]);
			$('.basket_clear').click(function(event) {
				$.confirmation("Are you sure you want to clear the basket?", function() {
					$.ajax({
						type: "GET",
						url: "ajax/emptyBasket.cfm",
						success: function(data) {
							$.loadBasket();
						}
					});
				});
				event.preventDefault();
			});
			$('.basket_checkout').click(function(event) {
				$('.categories_viewer').loadPayments();
				event.preventDefault();
			});
			
			$('.basketProductItems tbody').css("max-height", 800 - $('.basket_footer').height());
		});
	</script>
	<cfif basketIsEmpty>
		<div class="basket_empty_img"></div>
	<cfelse>
		<table width="100%" border="0" class="basketProductItems">
			<tbody>
				<tr>
					<th align="left" width="100%">Product</th>
					<th align="right" width="20">Qty</th>
					<th align="right" width="40">Price</th>
					<th align="right" width="40">Total</th>
				</tr>
				<cfloop collection="#basket.product#" item="key">
					<cfset item = StructFind(basket.product, key)>
					<cfset item.lineTotal = val(item.qty) * val(item.price)>
					<cfset session.epos_frame.result.balanceDue += item.lineTotal>
					<tr class="basket_item" data-index="#item.index#" data-type="product">
						<td align="left">#item.title#<cfif item.cashonly is 1> <strong>(Cash Only)</strong></cfif></td>
						<td align="right">#item.qty#</td>
						<td align="right">&pound;#DecimalFormat(-item.price)#</td>
						<td align="right">&pound;#DecimalFormat(-item.lineTotal)#</td>
					</tr>
				</cfloop>
				<cfloop collection="#basket.supplier#" item="key">
					<cfset item = StructFind(basket.supplier, key)>
					<cfset item.lineTotal = val(item.qty) * val(item.price)>
					<cfset session.epos_frame.result.balanceDue += item.lineTotal>
					<tr class="basket_item" data-index="#item.index#" data-type="product">
						<td align="left">#item.title#<cfif item.cashonly is 1> <strong>(Cash Only)</strong></cfif></td>
						<td align="right">#item.qty#</td>
						<td align="right">&pound;#DecimalFormat(-item.price)#</td>
						<td align="right">&pound;#DecimalFormat(-item.lineTotal)#</td>
					</tr>
				</cfloop>
				<cfloop collection="#basket.publication#" item="key">
					<cfset item = StructFind(basket.publication, key)>
					<cfset item.lineTotal = val(item.qty) * val(item.price)>
					<cfset session.epos_frame.result.balanceDue += item.lineTotal>
					<tr class="basket_item" data-index="#item.index#" data-type="publication">
						<td align="left">#item.title#</td>
						<td align="right">#item.qty#</td>
						<td align="right">&pound;#DecimalFormat(-item.price)#</td>
						<td align="right">&pound;#DecimalFormat(-item.lineTotal)#</td>
					</tr>
				</cfloop>
				<cfloop collection="#basket.paypoint#" item="key">
					<cfset item = StructFind(basket.paypoint, key)>
					<cfset item.lineTotal = val(item.qty) * val(item.price)>
					<cfset session.epos_frame.result.balanceDue += item.lineTotal>
					<tr class="basket_item" data-index="#item.index#" data-type="paypoint">
						<td align="left">#item.title#</td>
						<td align="right">#item.qty#</td>
						<td align="right">&pound;#DecimalFormat(-item.price)#</td>
						<td align="right">&pound;#DecimalFormat(-item.lineTotal)#</td>
					</tr>
				</cfloop>
				<cfloop collection="#basket.deal#" item="key">
					<cfset item = StructFind(basket.deal, key)>
					<cfset item.lineTotal = val(item.qty) * val(item.price)>
					<cfset session.epos_frame.result.balanceDue += item.lineTotal>
					<tr class="basket_item" data-index="#item.index#" data-type="deal" style="#colour.green#">
						<td align="left">#item.title#</td>
						<td align="right">#item.qty#</td>
						<td align="right">&pound;#DecimalFormat(-item.price)#</td>
						<td align="right">&pound;#DecimalFormat(-item.lineTotal)#</td>
					</tr>
				</cfloop>
			</tbody>
		</table>
		
		<cfset session.epos_frame.result.balanceDue -= session.epos_frame.result.discount>
		
		<div class="basket_footer">
			<table width="100%" border="0">
				<cfloop collection="#basket.discount#" item="key">
					<cfset item = StructFind(basket.discount, key)>
					<cfset session.epos_frame.result.totalGiven += item.amount>
					<tr class="basket_discount" data-index="#key#" data-type="discount" style="font-size: 18px;">
						<th align="left" colspan="3">#item.title#</td>
						<td align="right" style="font-weight:bold;">&pound;#DecimalFormat(item.amount)#</td>
					</tr>
				</cfloop>
				<cfif session.epos_frame.mode eq "reg">
					<cfloop collection="#basket.payment#" item="key">
						<cfset item = StructFind(basket.payment, key)>
						<cfset session.epos_frame.result.totalGiven += item.value>
						<tr class="basket_payment" data-index="#LCase(item.title)#" data-type="payment" style="font-size: 18px;">
							<th align="left" colspan="3">#item.title#</td>
							<td align="right" style="font-weight:bold;">&pound;#DecimalFormat(item.value)#</td>
						</tr>
					</cfloop>
					<tr style="font-size: 28px;">
						<th align="left" colspan="3">Balance Due</th>
						<td align="right" style="font-weight:bold;">&pound;#DecimalFormat(-session.epos_frame.result.balanceDue)#</td>
					</tr>
					<cfset session.epos_frame.result.changeDue = (session.epos_frame.result.balanceDue + session.epos_frame.result.totalGiven) * sign>
					<cfset session.epos_frame.result.changeDue -= session.epos_frame.result.discount>
					<cfif StructKeyExists(session.epos_frame.basket, "payment")>
						<cfif StructCount(session.epos_frame.basket.payment) gt 0>
							<tr style="font-size: 28px;">
								<cfif session.epos_frame.result.changeDue lt 0>
									<th align="left" colspan="3">Balance Now Due</th>
									<td align="right" style="font-weight:bold;">&pound;#DecimalFormat(-session.epos_frame.result.changeDue)#</td>
								<cfelse>
									<th align="left" colspan="3">Change Due</th>
									<td align="right" style="font-weight:bold;">&pound;#DecimalFormat(session.epos_frame.result.changeDue)#</td>
								</cfif>
							</tr>
						</cfif>
					</cfif>
				<cfelse>
					<tr style="font-size: 28px;">
						<th align="left" colspan="3">Refund Due</th>
						<td align="right" style="font-weight:bold;">&pound;#DecimalFormat(session.epos_frame.result.balanceDue)#</td>
					</tr>
				</cfif>
			</table>
		</cfif>
		<div class="basket_controls">
			<button class="basket_checkout" style="width: 75%;margin: 0;border: 5px solid white;height: 70px;" <cfif basketIsEmpty>disabled="disabled"</cfif>>Checkout</button>
			<button class="basket_clear" style="width: 25%;margin: 0;border: 5px solid white;border-width: 5px 0 5px 5px;height: 70px;" <cfif basketIsEmpty>disabled="disabled"</cfif>>Clear</button>
		</div>
		
		<!---CLOSE TRANSACTION--->
		<cfset session.epos_frame.result.absBalanceDue = abs(session.epos_frame.result.balanceDue)>
		<cfset session.epos_frame.result.absTotalGiven = abs(session.epos_frame.result.totalGiven)>
		
		<cfif val(session.epos_frame.result.absBalanceDue) gt 0 AND val(session.epos_frame.result.absTotalGiven) gte val(session.epos_frame.result.absBalanceDue)>
			<cfset closeTran = epos.CloseTransaction()>
			<script>
				$(document).ready(function(e) {
					$.printReceipt("#closeTran#");
				});
			</script>
		</cfif>
	</div>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>