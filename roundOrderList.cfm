<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cftry>
	<cfobject component="code/rounds" name="rnd">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.form=form>
	<cfset roundList=rnd.LoadRoundInOrder(parm)>
	
	<script type="text/javascript">
		$(document).ready(function() {
			$(".roundTable").tableDnD({
				onDrop: function() {
					$('.orderItem').each(function(index) {
						$(this).val(index+1);
					});
					$('#btnSaveOrder').fadeIn();
				},
				scrollAmount:25
			});
			var orderID=$('#OrderID').val();
			<cfif ArrayLen(roundList)>$('#btnCopyOrder').fadeIn();</cfif>
		});
	</script>
	
	<style type="text/css">
		.active {background: #2D97D3;}
	</style>
	<cfoutput>
		<table border="1" class="tableList trhover roundTable" width="100%">
			<tr class="nodrop nodrag">
				<th width="40">Ref</th>
				<th>Address</th>
				<th>Type</th>
			</tr>
			<cfif ArrayLen(roundList)>
				<cfloop array="#roundList#" index="i">
					<script type="text/javascript">
						var orderID=$('##OrderID').val();
						var thisorderID="#i.OrderID#";
						if (orderID == thisorderID) {
							$('.row'+thisorderID).addClass("active");
						} else {};
					</script>
					<tr class="row#i.OrderID#">
						<td><input type="hidden" name="item" value="#i.ID#"><input type="hidden" name="order#i.ID#" class="orderItem" value="#i.order#">#i.Ref#</td>
						<td>#i.name# #i.street# </td>
						<td align="center"><a href="#application.site.normal#clientDetails.cfm?row=0&ref=#i.ref#" target="_blank">#i.cltAccountType#</a></td>
					</tr>
				</cfloop>
			<cfelse>
				<tr><td colspan="3">Order to assign to this day.</td></tr>
			</cfif>
		</table>
	</cfoutput>

	<cfcatch type="any">
		<cfdump var="#cfcatch#" label="cfcatch" expand="no">
	</cfcatch>
</cftry>
