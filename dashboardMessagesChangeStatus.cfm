<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/messages" name="msg">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.msgID=id>
<cfset parm.currState=state>
<cfset parm.urgent=urgent>
<cfset parm.days=days>

<script type="text/javascript">
	$(document).ready(function() {
		<cfoutput>var days="#parm.days#";</cfoutput>
		$('#btnChange').click(function(event) {
			var id=$('#msgID').val();
			$.ajax({
				type: 'POST',
				url: 'dashboardMessagesChangeStatusAction.cfm',
				data: $('#statusForm').serialize(),
				success:function(data){
					LoadMessages(days);
					$("#orderOverlay").fadeOut();
					$("#orderOverlay-ui").fadeOut();
				}
			});
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<h1>Update Status</h1>
	<form method="post" id="statusForm">
		<input type="hidden" name="msgID" id="msgID" value="#parm.msgID#">
		<select name="status">
			<option value="open"<cfif parm.currState is "open"> selected="selected"</cfif>>Open</option>
			<option value="closed"<cfif parm.currState is "closed"> selected="selected"</cfif>>Closed</option>
			<option value="complete"<cfif parm.currState is "complete"> selected="selected"</cfif>>Complete</option>
			<option value="archived"<cfif parm.currState is "archived"> selected="selected"</cfif>>Archived</option>
		</select><br>
		<label><input type="checkbox" name="urgent" value="1"<cfif parm.urgent is 1> checked="checked"</cfif> />&nbsp;Urgent</label><br>
		<input type="button" id="btnChange" value="Update" style="float:left;margin:10px 0 0 0;">
	</form>
</cfoutput>


