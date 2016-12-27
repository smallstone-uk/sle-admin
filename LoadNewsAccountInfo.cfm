<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/till" name="till">
<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.rec.cltRef=accountRef>
<cfset tranTotal=func.LoadClientTrans(parm)>
<cfset orderTotal=func.LoadClientOrder(parm)>
<cfset weekly=0.00>
<cfset monthly=0.00>

<script type="text/javascript">
	$(document).ready(function() { 
		$('#AddNewsPayment').click(function(event) {   
			$.ajax({
				type: 'POST',
				url: 'TillAddNewsAccount.cfm',
				data : $('.NewsAccountItem').serialize(),
				success:function(data){
					//$('#orderOverlayForm-inner').html(data);
					UpdateBasket();
					$("#orderOverlay").fadeOut();
$("#orderOverlay-ui").fadeOut();
					$('#orderOverlayForm-inner').html("");
				}
			});
			event.preventDefault();
		});
		$('a.pay-button').click(function(event) {
			var option=$(this).attr("href");
			var amount=$('#'+option+'Total').val();
			$('#NewsPayment').val(amount);
			$('a.pay-button').removeClass("active");
			$(this).toggleClass("active");
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<cfif StructKeyExists(orderTotal,"order")>
		<cfif StructKeyExists(orderTotal.order,"list")>
			<cfif ArrayLen(orderTotal.order.list)>
				<cfloop array="#orderTotal.order.list#" index="item">
					<cfset weekly=DecimalFormat(item.orderPerWeek)>
					<cfset monthly=DecimalFormat(item.orderPerMonth)>
					<input type="hidden" name="weeklyTotal" id="weeklyTotal" value="#weekly#" />
					<input type="hidden" name="monthlyTotal" id="monthlyTotal" value="#monthly#" />
				</cfloop>
			</cfif>
		</cfif>
	</cfif>
	<div id="account-detail">
		#orderTotal.cltName#<br />
		#orderTotal.cltDelHouse#&nbsp;#orderTotal.cltDelAddr#
		
	</div>
	<div id="account-balance" class="pay-button"><h3>Account Balance Outstanding</h3><h2>&pound;#DecimalFormat(tranTotal.balance)#</h2></div>
	<div class="clear"></div>
	<a href="weekly" id="weekly-payment" class="pay-button"><h3>Weekly Payment</h3><h2>&pound;#weekly#</h2></a>
	<a href="monthly" id="monthly-payment" class="pay-button"><h3>Monthly Payment</h3><h2>&pound;#monthly#</h2></a>
	<div id="other-payment" class="pay-button"><h3>Other Amount</h3><h2><input type="text" name="OtherPayment" id="OtherPayment" class="NewsAccountItem" value="" /></h2></div>
	<div class="clear"></div>
	<input type="hidden" name="NewsPayment" id="NewsPayment"  class="NewsAccountItem" value="" />
	<input type="button" id="AddNewsPayment" value="Add to Basket" />
</cfoutput>

