<cftry>
<cfobject component="epos2/code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset payments = epos.LoadPayments(parm)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('.payment_item').click(function(event) {
				var type = $(this).data("method");
				$.virtualNumpad({
					callback: function(value) {
						$.addPayment({
							type: type,
							value: value
						});
					}
				});
				event.preventDefault();
			});
			$('.payment_item_special').click(function(event) {
				var type = $(this).data("method");
				switch (type)
				{
					case "staffdiscount":
						$.addDiscount({
							type: type,
							title: "Staff Discount",
							value: 10
						});
						break;
					case "paypointcharge":
						$.addCharge({
							type: type,
							title: "PayPoint Charge",
							value: 0.5
						});
						break;
				}
				event.preventDefault();
			});
		});
	</script>
	<ul class="payment_list">
		<cfset counter = 0>
		<cfloop array="#payments#" index="item">
			<cfset counter++>
			<li class="payment_item" data-method="#LCase(item.eaTitle)#" <cfif counter is 1>style="width: 100%;height: 200px;line-height: 175px;"</cfif>>#item.eaTitle#</li>
		</cfloop>
		<!---<li class="payment_item" data-method="cash" style="width: 94.5%;height: 150px;line-height: 150px;">Cash</li>
		<li class="payment_item" data-method="card">Card</li>
		<li class="payment_item" data-method="cheque">Cheque</li>
		<li class="payment_item" data-method="voucher">Voucher</li>
		<li class="payment_item" data-method="coupon">Coupon</li>
		<li class="payment_item" data-method="owners">Owners Account</li>
		<li class="payment_item" data-method="timmy">Timmy</li>--->
		
		<li class="payment_item_special" data-method="staffdiscount">Staff Discount</li>
		<li class="payment_item_special" data-method="paypointcharge">PayPoint Charge</li>
	</ul>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>