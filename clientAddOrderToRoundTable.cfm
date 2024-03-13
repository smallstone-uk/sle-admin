<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/rounds" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset orders=rnd.LoadOrder(parm)>
<!---<cfdump var="#orders#" label="orders">--->

<script type="text/javascript">
	$(document).ready(function() {
		function ReloadTable() {
			$.ajax({
				type: 'POST',
				url: 'clientAddOrderToRoundTable.cfm',
				data : $('#RoundForm').serialize(),
				success:function(data){
					$('#roundTable').html(data);
					$('#loading').fadeOut();
					$('#orderOverlayForm').center();
				}
			});
		};
		function LoadRoundOrdering() {
			$.ajax({
				type: 'POST',
				url: 'roundOrder.cfm',
				<cfoutput>data: {"orderID":"#parm.form.orderID#","cltID":"#parm.form.cltID#"},</cfoutput>
				beforeSend:function() {
					$('#roundorder').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...");
				},
				success:function(data){
					$('#roundorder').html("");
					$('#roundorder').html(data);
					$('#orderOverlayForm').center();
				}
			});
		};
		$('.removeItem').click(function(event) {
			var id=$(this).attr("href");
			$.ajax({
				type: 'POST',
				url: 'clientAddOrderToRoundDelete.cfm',
				data : {"id":id},
				success:function(data){
					ReloadTable();
				}
			});
			event.preventDefault();
		});
		<cfif ArrayLen(orders.list)>LoadRoundOrdering();</cfif>
	});
</script>

<cfoutput>
	<div style="width:500px;">
		<cfif ArrayLen(orders.list)>
			<input type="hidden" id="firstRound" value="#orders.list[1].roundID#" />
			<p>This order is already attached to:</p>
		<cfelse>
			<input type="hidden" id="firstRound" value="0" />
			<p>The customer now needs to be <strong>added to the rounds</strong>. Based on the customers address assign the drop to the most relevent round by selecting the round from the '<strong>Attach to Round</strong>' section.</p>
			<p>Make sure the customer is assigned to a round for <strong>everyday of the week</strong>, even if they don't have publications on a particular day.</p>
			<p>Once attached, you need to <strong>order the drop</strong> on the round. You do this by selecting the <strong>round and a day</strong>. Then you will be able to see the drop highlighted in blue. <strong>Drag & Drop</strong> the item in the position you want it and <strong>click Save</strong>. Do this for everyday of the week.</p>
			<p><i>If you are unsure where to put the drop, leave the ordering alone and ask the driver where they want it placed.</i></p>
		</cfif>
		<table border="1" class="tableList" width="100%">
			<tr>
				<th>Monday</th>
				<th>Tuesday</th>
				<th>Wednesday</th>
				<th>Thursday</th>
				<th>Friday</th>
				<th>Saturday</th>
				<th>Sunday</th>
			</tr>
			<tr>
				<td><cfif StructKeyExists(orders.days.mon,"ID")><a href="#orders.days.mon.ID#" class="removeItem" title="Click to delete">#orders.days.mon.RoundTitle#</a><cfelse>None</cfif></td>
				<td><cfif StructKeyExists(orders.days.tue,"ID")><a href="#orders.days.tue.ID#" class="removeItem" title="Click to delete">#orders.days.tue.RoundTitle#</a><cfelse>None</cfif></td>
				<td><cfif StructKeyExists(orders.days.wed,"ID")><a href="#orders.days.wed.ID#" class="removeItem" title="Click to delete">#orders.days.wed.RoundTitle#</a><cfelse>None</cfif></td>
				<td><cfif StructKeyExists(orders.days.thu,"ID")><a href="#orders.days.thu.ID#" class="removeItem" title="Click to delete">#orders.days.thu.RoundTitle#</a><cfelse>None</cfif></td>
				<td><cfif StructKeyExists(orders.days.fri,"ID")><a href="#orders.days.fri.ID#" class="removeItem" title="Click to delete">#orders.days.fri.RoundTitle#</a><cfelse>None</cfif></td>
				<td><cfif StructKeyExists(orders.days.sat,"ID")><a href="#orders.days.sat.ID#" class="removeItem" title="Click to delete">#orders.days.sat.RoundTitle#</a><cfelse>None</cfif></td>
				<td><cfif StructKeyExists(orders.days.sun,"ID")><a href="#orders.days.sun.ID#" class="removeItem" title="Click to delete">#orders.days.sun.RoundTitle#</a><cfelse>None</cfif></td>
			</tr>
            <tr>
            	<td></td>
            </tr>
		</table>
	</div>
</cfoutput>