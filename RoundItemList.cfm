<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/rounds" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset check=rnd.CheckRound(parm)>
<cfset rndOrder=rnd.LoadRoundInOrder(parm)>
<cfset drop=rnd.LoadDrop(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		function ReloadRoundItems() {
			$.ajax({
				type: 'POST',
				url: 'RoundItemList.cfm',
				data : $('#RoundForm').serialize(),
				beforeSend:function(){
					$('#loading .loading-box').html("<div class='loading-box'><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...</div>").fadeIn();
				},
				success:function(data){
					$('#roundlist').html(data);
					$('#loading').fadeOut();
					ReloadTable();
					$('#orderOverlayForm').center();
				},
				error:function(data){
					$('#roundlist').html(data);
					$('#loading').fadeOut();
				}
			});
		};
		function ReloadTable() {
			$.ajax({
				type: 'POST',
				url: 'clientAddOrderToRoundTable.cfm',
				data : $('#RoundForm').serialize(),
				success:function(data){
					$('#roundTable').html(data);
					$('#loading').fadeOut();
					$('#orderOverlayForm').center();
				},
				error:function(data){
					$('#roundTable').html(data);
					$('#loading').fadeOut();
				}
			});
		};
		$('.insertOrderLink').click(function(event) {
			var insert=$(this).parent("td");
			var span=$(this).siblings('span:first');
			var dropID=$('#NewDropID').val();
			var drop=$('#NewDropTitle').val();
			$('.insertOrderTD span').html("");
			$('.insertOrderTD span').removeClass('new');
			$(span).html('<input type="hidden" name="orderNew" class="order" value="0">'+drop);
			$(span).addClass('new');
			$('.order').each(function(index) {
				$(this).val(index+10);
			});
			event.preventDefault();
		});
		$('.removeOrderLink').click(function(event) {
			var id=$(this).attr("href");
			$('#RemoveItem').val(id);
			$.ajax({
				type: 'POST',
				url: 'RemoveOrderFromRound.cfm',
				data : $('#RoundForm').serialize(),
				success:function(data){
					$('#confirm').html(data).fadeIn();
				},
				error:function(data){
					$('#confirm').html(data).fadeIn();
				}
			});
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<div id="dump"></div>
	<div id="confirm"></div>
	<input type="hidden" name="all" id="all" value="false">
	<input type="hidden" name="NewDropID" id="NewDropID" value="#drop.ID#">
	<input type="hidden" name="NewDropTitle" id="NewDropTitle" value="#drop.Name# #drop.Street#">
	<input type="hidden" name="RemoveItem" id="RemoveItem" value="0">
	<table border="0" width="200">
		<cfif check.roundID eq 0>
			<tr class="insertOrderLine">
				<td class="insertOrderTD" colspan="2"><a href="##" class="insertOrderLink">Insert Here</a><span></span></td>
			</tr>
		</cfif>
		<cfloop array="#rndOrder#" index="i">
			<tr<cfif check.ID eq i.ID> style="background:##3399CC;"</cfif>>
				<td><cfif check.ID eq i.ID><a href="#i.ID#" class="removeOrderLink" style="color:##fff;">X</a><cfelse>#i.Order#</cfif></td>
				<td>
					<input type="hidden" name="itemID" value="#i.ID#">
					<input type="hidden" name="order#i.ID#" class="order" value="#i.Order#">
					#i.Name# #i.Street#
				</td>
			</tr>
			<cfif check.roundID eq 0>
				<tr class="insertOrderLine">
					<td class="insertOrderTD" colspan="2"><a href="##" class="insertOrderLink">Insert Here</a><span></span></td>
				</tr>
			<cfelse>
				<tr style="padding: 2px 0;"><td colspan="2" style="padding: 2px 5px;"></td></tr>
			</cfif>
		</cfloop>
	</table>
</cfoutput>