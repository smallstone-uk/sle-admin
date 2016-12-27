<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="300">
<cfparam name="print" default="false">
<cfset days="mon,tue,wed,thu,fri,sat,sun">

<cfobject component="code/rounds5" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.roundID=form.roundID>
<cfset parm.roundDay=form.roundDay>
<cfset parm.orderID=form.orderID>
<cfset parm.cltID=form.cltID>

<script type="text/javascript">
	$(document).ready(function() {
		function ReloadRoundWindow() {
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: "clientAddOrderToRound.cfm",
				<cfoutput>data : {"orderID":"#parm.orderID#","cltID":"#parm.cltID#"},</cfoutput>
				beforeSend:function(){
					$('#orderOverlayForm-inner').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				}
			});
		}
		$('#btnRunCopy').click(function(event) {
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: 'RoundCopyOrderAction.cfm',
				data : $('#copyForm').serialize(),
				beforeSend:function(){
					$('#orderOverlayForm-inner').html("<div class='loading-box'><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Processing...</div>").fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					ReloadRoundWindow();
				}
			});
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<div style="width:300px;">
		<h1>Copy Round Order</h1>
		<p style="padding:0;"><strong>Only use this function if you know the days you are copying to have the same drops as the one you are copying from.</strong></p>
		<p style="font-size:18px;padding:0;">Copying from <strong>#UCase(parm.roundDay)#</strong> to:</p>
		<p style="padding:0;">Select the days you want to copy the round order too.</p>
		<form method="post" id="copyForm">
			<input type="hidden" name="roundID" value="#parm.roundID#" />
			<input type="hidden" name="roundDay" value="#parm.roundDay#" />
			<div>
				<cfloop list="#days#" delimiters="," index="i">
					<label style="float:left; text-align:center; width:40px;">
						<input type="checkbox" name="days" value="#i#"<cfif i is parm.roundDay> disabled="disabled"</cfif> /><br />
						<strong<cfif i is parm.roundDay> style="color:##666;"</cfif>>#UCase(i)#</strong>
					</label>
				</cfloop>
				<div style="clear:both;"></div>
			</div>
			<div style="clear:both;margin:10px 0 0 0;">
				<input type="button" id="btnRunCopy" value="Go" />
			</div>
		</form>
	</div>
</cfoutput>
