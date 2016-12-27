<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/accounts" name="supp">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset parm.tranID=transID>
<cfset load=supp.LoadTransaction(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		function GetFormItems() {
			$.ajax({
				type: 'POST',
				url: 'salesGetFormItems.cfm',
				data : $('#account-form').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#transItems').html(data);
					$('#loading').fadeOut();
				},
				error:function(data){
					$('#transItems').html(data);
					$('#loading').fadeOut();
				}
			});
			event.preventDefault();
		}
		$('#Compile').click(function() {
			$.ajax({
				type: 'POST',
				url: 'salesCompile.cfm',
				data : $('#account-form').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#loading').html(data);
				},
				error:function(data){
					$('#loading').fadeOut();
				}
			});
			event.preventDefault();
		});
		$('.DeleteItem').click(function(event) {
			var id=$(this).attr("href");
			$.ajax({
				type: 'POST',
				url: 'salesDeleteItem.cfm',
				data : $('#niID'+id).serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#loading').fadeOut();
					GetFormItems();
				},
				error:function(data){
					$('#loading').fadeOut();
				}
			});
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<cfif StructKeyExists(load,"items")>
		<cfif ArrayLen(load.items)>
			<div class="clear" style="padding:5px 0;"></div>
			<table border="1" class="tableList" width="100%">
				<tr>
					<th></th>
					<th>Category</th>
					<th width="60" align="right">VAT Rate</th>
					<th width="60" align="right">Net Amount</th>
					<th width="60" align="right">VAT Amount</th>
				</tr>
				<cfloop array="#load.items#" index="item">
					<tr>
						<td width="10"><a href="#item.niID#" class="DeleteItem">X</a><input type="hidden" name="itemID" id="niID#item.niID#" value="#item.niID#"></td>
						<td>#item.nomTitle#</td>
						<td align="right">#item.nomVATRate#%</td>
						<td align="right">&pound;#DecimalFormat(item.niAmount)#</td>
						<td align="right">&pound;#DecimalFormat(item.vat)#</td>
					</tr>
				</cfloop>
				<tr>
					<th colspan="3" align="right">Total</th>
					<td align="right"><input type="hidden" name="total" id="check-total" value="#load.GrandTotal#">
							<strong>&pound;#DecimalFormat(load.GrandTotal)#</strong></td>
					<td align="right"><input type="hidden" name="VatTotal" id="check-VatTotal" value="#load.GrandVatTotal#">
						<strong>&pound;#DecimalFormat(load.GrandVatTotal)#</strong></td>
				</tr>
				<tr>
					<th colspan="3" align="right">Difference</th>
					<td id="Check" align="right"></td>
					<td id="CheckVat" align="right"></td>
				</tr>
			</table>
			<div class="clear" style="padding:5px 0;"></div>
			<input type="button" id="Compile" value="Done">
		</cfif>
	</cfif>
</cfoutput>
