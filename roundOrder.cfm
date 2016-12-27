<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no" requesttimeout="300">
<cfparam name="print" default="false">

<cfobject component="code/rounds" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset roundList=rnd.LoadRoundList(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		function LoadRoundList() {
			$.ajax({
				type: 'POST',
				url: 'RoundOrderList.cfm',
				data : $('#roundOrderForm').serialize(),
				beforeSend:function(){
					$('#roundList').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#roundList').html(data);
				},
				error:function(data){
					$('#roundList').html(data);
				}
			});
		};
		$('#btnSaveOrder').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'RoundOrderSave.cfm',
				data : $('#roundOrderForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<div class='loading-box'><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Saving...</div>").fadeIn();
				},
				success:function(data){
					$('#loading').fadeOut();
					LoadRoundList();
				},
				error:function(data){
					$('#loading').html(data);
				}
			});
			event.preventDefault();
		});
		$('#btnCopyOrder').click(function(event) {
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: 'RoundCopyOrder.cfm',
				data : $('#roundOrderForm').serialize(),
				beforeSend:function(){
					$('#orderOverlayForm-inner').html("<div class='loading-box'><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...</div>").fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
		$('.roundOrder').change(function() {
			LoadRoundList();
		});
		//LoadRoundList();
	});
</script>

<cfoutput>
	<h2 style="margin:10px 0 0 0;font-size:18px;">Round Ordering</h2>
	<form method="post" id="roundOrderForm">
		<input type="hidden" name="orderID" value="#parm.form.orderID#" />
		<input type="hidden" name="cltID" value="#parm.form.cltID#" />
		<table border="1" class="tableList" width="100%">
			<tr>
				<th width="60">Round</th>
				<td>
					<select name="roundID" class="roundOrder">
						<cfloop array="#roundList.rounds#" index="item">
							<script type="text/javascript">
								$(document).ready(function() {
									function LoadRoundList() {
										$.ajax({
											type: 'POST',
											url: 'RoundOrderList.cfm',
											data : $('##roundOrderForm').serialize(),
											beforeSend:function(){
												$('##roundList').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
											},
											success:function(data){
												$('##roundList').html(data);
											},
											error:function(data){
												$('##roundList').html(data);
											}
										});
									};
									var roundID=$('##firstRound').val();
									var thisroundID="#item.ID#";
									if (roundID == thisroundID) {
										$('.roundRow'+thisroundID).prop("selected",true);
										LoadRoundList();
									} else {};
								});
							</script>
							<option value="#item.ID#" class="roundRow#item.ID#">#item.Title#</option>
						</cfloop>
					</select>
				</td>
				<th width="60">Day</th>
				<td>
					<select name="roundDay" class="roundOrder">
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
				<th colspan="4"><input type="button" id="btnCopyOrder" value="Copy" style="display:none;float:left;"><input type="button" id="btnSaveOrder" value="Save" style="display:none;float:right;"></th>
			</tr>
		</table>
		<div id="roundList" style="margin:10px 0 0 0;"></div>
	</form>
</cfoutput>
<script type="text/javascript">
	$(".roundOrder").chosen({width: "120px"});
</script>
