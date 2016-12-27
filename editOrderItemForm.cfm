<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.form=form>
<cfset parm.datasource=application.site.datasource1>

<cfoutput>
<script type="text/javascript">
	$(document).ready(function() {
		$('.orderOverlayClose').click(function(event) {   
			$("##orderOverlay").hide();
			event.preventDefault();
		});
		function GetOrders() {
			var id=$('##OrderID').val();
			$.ajax({
				type: 'POST',
				url: 'LoadClientOrder.cfm',
				data : $('##editform').serialize(),
				beforeSend:function(){},
				success:function(data){$('##OrderList'+id).html(data);},
				error:function(data){}
			});
		};
		$('##UpdateItems').click(function(event) { 
			$.ajax({
				type: 'POST',
				url: 'editOrderItemAction.cfm',
				data : $('##editform').serialize(),
				beforeSend:function(){},
				success:function(data){
					$('##saveResults').html(data);
					$('##saveResults').show();
					GetOrders();
					setTimeout(function(){$("##saveResults").fadeOut("slow");}, 5000 );
				},
				error:function(data){}
			});
			event.preventDefault();
		});
	});
</script>
<cfif StructKeyExists(parm.form,"SelectPub")>
	<form method="post" enctype="multipart/form-data" id="editform">
		<input type="hidden" name="oiOrderID" id="OrderID" value="#parm.form.orderID#" />
		<input type="hidden" name="cltID" value="#parm.form.cltID#" />
		<input type="hidden" name="cltRef" value="#parm.form.cltRef#" />
		<h1>
			Edit
			<button name="btnUpdateOrderItems" type="submit" class="overlayNav" id="UpdateItems">
				<img src="images/icons/save.png">&nbsp;Save
			</button>
		</h1>
		<div id="saveResults" style="display:none;"></div>
		<table border="1" width="100%" class="tableList">
			<tr>
				<th width="200">Publication</th>
				<th>Mon</th>
				<th>Tue</th>
				<th>Wed</th>
				<th>Thu</th>
				<th>Fri</th>
				<th>Sat</th>
				<th>Sun</th>
			</tr>
			<cfloop list="#parm.form.SelectPub#" delimiters="," index="i">
				<cfset itemParm={}>
				<cfset itemParm.datasource=application.site.datasource1>
				<cfset itemParm.oiID=i>
				<cfset item=cust.LoadOrderItem(itemParm)>
				<cfset itemParm.form.oiPubID=item.PubID>
				<cfset check=cust.CheckPublication(itemParm)>

				<input type="hidden" name="oiID" value="#i#" />
				<tr>
					<td>#item.Title#</td>
					<td align="center"><input type="text" size="2" style="text-align:center;" name="qtymon#i#"<cfif check.Mon is 0> value="0" disabled="disabled"<cfelse> value="#item.qtymon#"</cfif> /><br><cfif check.Mon neq 0>#item.price#<cfelse>&nbsp;</cfif></td>
					<td align="center"><input type="text" size="2" style="text-align:center;" name="qtytue#i#"<cfif check.Tue is 0> value="0" disabled="disabled"<cfelse> value="#item.qtytue#"</cfif> /><br><cfif check.Tue neq 0>#item.price#<cfelse>&nbsp;</cfif></td>
					<td align="center"><input type="text" size="2" style="text-align:center;" name="qtywed#i#"<cfif check.Wed is 0> value="0" disabled="disabled"<cfelse> value="#item.qtywed#"</cfif> /><br><cfif check.Wed neq 0>#item.price#<cfelse>&nbsp;</cfif></td>
					<td align="center"><input type="text" size="2" style="text-align:center;" name="qtythu#i#"<cfif check.Thu is 0> value="0" disabled="disabled"<cfelse> value="#item.qtythu#"</cfif> /><br><cfif check.Thu neq 0>#item.price#<cfelse>&nbsp;</cfif></td>
					<td align="center"><input type="text" size="2" style="text-align:center;" name="qtyfri#i#"<cfif check.Fri is 0> value="0" disabled="disabled"<cfelse> value="#item.qtyfri#"</cfif> /><br><cfif check.Fri neq 0>#item.price#<cfelse>&nbsp;</cfif></td>
					<td align="center"><input type="text" size="2" style="text-align:center;" name="qtysat#i#"<cfif check.Sat is 0> value="0" disabled="disabled"<cfelse> value="#item.qtysat#"</cfif> /><br><cfif check.Sat neq 0>#item.price#<cfelse>&nbsp;</cfif></td>
					<td align="center"><input type="text" size="2" style="text-align:center;" name="qtysun#i#"<cfif check.Sun is 0> value="0" disabled="disabled"<cfelse> value="#item.qtysun#"</cfif> /><br><cfif check.Sun neq 0>#item.price#<cfelse>&nbsp;</cfif></td>
				</tr>
			</cfloop>
		</table>
	</form>
<cfelse>
	<h1>Error</h1>
	<p>Please select at least one publication to edit.</p>
</cfif>
</cfoutput>