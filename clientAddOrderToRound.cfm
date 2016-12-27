<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/rounds" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset orders=rnd.LoadOrder(parm)>
<cfset rnds=rnd.LoadRoundList(parm)>

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
				},
				error:function(data){
					$('#roundTable').html(data);
					$('#loading').fadeOut();
				}
			});
		};
		$('#SaveDrops').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'AddOrderToRound.cfm',
				data : $('#RoundForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<div class='loading-box'><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Saving...</div>").fadeIn();
				},
				success:function(data){
					$('#loading').html(data);
					ReloadTable();
				},
				error:function(data){
					$('#loading').html(data);
				}
			});
			event.preventDefault();
		});
		function CheckAllDays() {
			if($('#AllDays').prop("checked")) {
				$('.daySelect').prop("disabled",true);
				$('.daySelect').trigger('chosen:updated');
			} else {
				$('.daySelect').prop("disabled",false);
				$('.daySelect').trigger('chosen:updated');
			};
		}
		$('#AllDays').click(function(){
			CheckAllDays();
		});
		$(function() {
			CheckAllDays();
		});
		ReloadTable();		
	});
</script>

<cfoutput>
	<form method="post" enctype="multipart/form-data" id="RoundForm">
		<input type="hidden" name="orderID" id="OrderID" value="#parm.form.orderID#" />
		<input type="hidden" name="cltID" value="#parm.form.cltID#" />
		<h1>Rounds</h1>
		<p><b>Please make sure All days are assigned to a round.</b></p>
		<div id="saveResults" style="display:none;"></div>
		<div class="loading-overlay" id="loading" style="display:none;"><div class="loading-box"></div></div>
		<div id="roundTable" class="order-attachments" style="margin:0 0 15px 0;"></div>
		<table border="1" width="500" class="tableList">
			<tr>
				<th colspan="2">Attach to Round</th>
			</tr>
			<tr>
				<th width="25%">Round</th>
				<td width="75%">
					<select name="roundID" class="roundSelect LoadItems" data-placeholder="Select...">
						<option value=""></option>
						<cfloop array="#rnds.rounds#" index="item">
							<option value="#item.ID#">#item.title#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<th width="25%">Day</th>
				<td width="75%">
					<select name="roundDay" class="daySelect LoadItems" data-placeholder="Select...">
						<option value="mon">Monday</option>
						<option value="tue">Tuesday</option>
						<option value="wed">Wednesday</option>
						<option value="thu">Thursday</option>
						<option value="fri">Friday</option>
						<option value="sat">Saturday</option>
						<option value="sun">Sunday</option>
					</select>
				</td>
			</tr>
			<tr>
				<th></th>
				<td width="50%">
					<label style="font-weight:bold;"><input type="checkbox" name="AllDays" id="AllDays" value="1" checked="checked"> Add to all days of the week</label>
				</td>
			</tr>
			<tr>
				<th colspan="2"><input type="button" id="SaveDrops" value="Add"></th>
			</tr>
		</table>
	</form>
	<div id="roundorder" style="margin:10px 0 0 0;"></div>
</cfoutput>
<script type="text/javascript">
	$(".daySelect").chosen({width: "120px"});
	$(".roundSelect").chosen({width: "120px"});
</script>
