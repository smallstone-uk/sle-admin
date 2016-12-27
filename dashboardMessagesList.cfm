<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/messages" name="msg">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.days=days>
<cfset messages=msg.LoadMessages(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		<cfoutput>var days="#parm.days#";</cfoutput>
		$('.showComments').click(function(event) {
			var id=$(this).attr("href");
			LoadComments(id);
			event.preventDefault();
		});
		$('.addComment').click(function(event) {
			var id=$(this).attr("href");
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: 'dashboardMessagesAddComment.cfm',
				data: {"id":id,"days":days},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
		$('.changeStatus').click(function(event) {
			var id=$(this).attr("href");
			var state=$(this).attr("rel");
			var urgent=$(this).attr("rev");
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: 'dashboardMessagesChangeStatus.cfm',
				data: {"id":id,"state":state,"urgent":urgent,"days":days},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<cfloop array="#messages#" index="msg">
		<div class="msg-space<cfif msg.Urgent is 1 OR msg.Important is 1> urgent</cfif>">
			<div class="msg-wrap<cfif msg.Urgent is 1 OR msg.Important is 1> urgent</cfif>">
				<div class="msg-title">
					<a href="clientDetails.cfm?row=0&ref=#msg.ClientRef#" target="_blank">(#msg.ClientRef#) #msg.ClientName#</a>
					<span class="status"><a href="#msg.ID#" rel="#msg.Status#" rev="#msg.Urgent#" class="changeStatus">#msg.Status#</a></span>
					<span class="add"><a href="#msg.ID#" class="addComment" title="Add comment">+</a></span>
					<cfif msg.Urgent is 1><b style="float: right;margin: 0 10px 0 0;color: ##F00;font-size: 14px;text-transform: uppercase;">Urgent</b></cfif>
					<cfif msg.Important is 1><b style="float: right;margin: 0 10px 0 0;color: ##F00;font-size: 14px;text-transform: uppercase;">Important</b></cfif>
				</div>
				<div class="msg-info">
					<span class="type">#msg.Type#</span>
					<span class="timestamp">#DateFormat(msg.Timestamp,"dd-mmm-yy")# #TimeFormat(msg.Timestamp,"HH:MM")#</span>
					<span class="tel">#msg.ClientTel#</span>
				</div>
				<div class="msg-text">#msg.Text#</div>
				<cfif msg.Comments neq 0>
					<div class="msg-commentTitle"><a href="#msg.ID#" class="showComments">Comments</a> <span class="comment-count">#msg.Comments#</span></div>
					<div class="msg-comments" id="comments#msg.ID#" style="display:none;"></div>
				</cfif>
			</div>
		</div>
	</cfloop>
</cfoutput>