<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/messages" name="msg">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.msgID=id>
<cfset parm.days=days>

<script type="text/javascript">
	$(document).ready(function() {
		<cfoutput>var days="#parm.days#";</cfoutput>
		$('#btnAdd').click(function(event) {
			var id=$('#msgID').val();
			$.ajax({
				type: 'POST',
				url: 'dashboardMessagesAddCommentAction.cfm',
				data: $('#commentForm').serialize(),
				success:function(data){
					LoadMessages(days);
					$("#orderOverlay").fadeOut(function() {
						LoadComments(id);
					});
					$("#orderOverlay-ui").fadeOut();
				}
			});
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<h1>Add Comment</h1>
	<form method="post" id="commentForm">
		<input type="hidden" name="msgID" id="msgID" value="#parm.msgID#">
		<input type="text" name="comment" value="" placeholder="Comment goes here" size="80">
		<input type="button" id="btnAdd" value="Add" style="float:left;margin:10px 0 0 0;">
	</form>
</cfoutput>


