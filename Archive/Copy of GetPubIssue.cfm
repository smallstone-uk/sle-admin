<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.pub=val(form.psPubID)>
<cfset parm.type=form.GetType>
<cfset parm.currenttype=form.psType>
<cfset parm.date=form.psDate>
<cfset parm.limit=5>
<cfset issues=func.GetPubStockIssues(parm)>
<cfdump var="#parm#" label="parm" expand="no">
<cfif parm.currenttype eq "returned">
	<script type="text/javascript">
		$(document).ready(function() {
			$('#issueList').change(function() {SendIssue();});
			function SendIssue() {
				$.ajax({
					type: 'POST',
					url: 'GetPubIssueQty.cfm',
					data : $('#returnPubForm').serialize(),
					beforeSend:function(){
						$('#loading2').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					},
					success:function(data){
						$('#loading2').fadeOut();
						$('#received').html(data);
						$('#returnedQty').show();
						$('#returned-btn').show();
					},
					error:function(data){
						$('#loading2').html(data);
						$('#returnedQty').hide();
						$('#returned-btn').hide();
					}
				});
			}
			<cfif ArrayLen(issues.list)>SendIssue();</cfif>
		});
	</script>
<cfelseif parm.currenttype eq "credited">
	<script type="text/javascript">
		$(document).ready(function() {
			$('#issueList').change(function() {SendIssue();});
			function SendIssue() {
				$.ajax({
					type: 'POST',
					url: 'GetPubIssueQty.cfm',
					data : $('#creditForm').serialize(),
					beforeSend:function(){
						$('#loading3').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					},
					success:function(data){
						$('#loading3').fadeOut();
						$('#returnedqtys').html(data);
						$('#creditedQty').show();
						$('#credited-btn').show();
					},
					error:function(data){
						$('#loading3').html(data);
						$('#creditedQty').hide();
						$('#credited-btn').hide();
					}
				});
			}
			$('#override').click(function() {
				if (this.checked) {
					$('#issueList').prop("disabled",true);
					$("#issueList").trigger("chosen:updated");
					$('#issueListWrap').fadeOut(function() {
						$('#returnedqtys').html("");
						$('#creditedQty').val("");
						$('#overrideIssue').fadeIn();
						$('#overrideIssue').prop("disabled",false);
						$('#mode').prop("disabled",false);
						$('#overrideIssue').focus();
						$('#creditedQty').fadeIn();
						$('#credited-btn').fadeIn();
					});
				} else {
					$('#issueList').prop("disabled",false);
					$("#issueList").trigger("chosen:updated");
					$('#overrideIssue').fadeOut(function() {
						$('#issueListWrap').fadeIn();
						$('#overrideIssue').prop("disabled",true);
						$('#mode').prop("disabled",true);
						$("#issueList").trigger("chosen:activate");
						<cfif ArrayLen(issues.list)>SendIssue();</cfif>
					});
				}
			});
			<cfif ArrayLen(issues.list)>SendIssue();</cfif>
		});
	</script>
<cfelseif parm.currenttype eq "claim">
	<script type="text/javascript">
		$(document).ready(function() {
			$('#issueList').change(function() {SendIssue();});
			function SendIssue() {
				$.ajax({
					type: 'POST',
					url: 'GetPubIssueQty.cfm',
					data : $('#claimForm').serialize(),
					beforeSend:function(){
						$('#loading4').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					},
					success:function(data){
						$('#loading4').fadeOut();
						$('#receivedqtys').html(data);
						$('#claimQty').show();
						$('#claim-btn').show();
					},
					error:function(data){
						$('#loading3').html(data);
						$('#claimQty').hide();
						$('#claim-btn').hide();
					}
				});
			}
			<cfif ArrayLen(issues.list)>SendIssue();</cfif>
		});
	</script>
</cfif>

<cfoutput>
	<cfif parm.currenttype is "credited">
		<label style="display:block;"><input type="checkbox" name="override" id="override" value="1">&nbsp;Override returned issues.</label>
	</cfif>
	<input type="hidden" name="mode" id="mode" value="1" disabled="disabled">
	<input type="text" name="psIssue" id="overrideIssue" value="" placeholder="Enter issue" style="display:none;margin: 5px 0;width: 210px; text-transform: uppercase;" disabled="disabled">
	<cfif ArrayLen(issues.list)>
		<div id="issueListWrap" style="margin: 5px 0;">
			<select name="psIssue" id="issueList" class="issueSelect">
				<cfloop array="#issues.list#" index="item">
					<option value="#item.ID#_#item.issue#">#item.issue#<cfif len(item.Client)> <i style="font-size:10px !important;">(#item.Client#)</i></cfif></option>
				</cfloop>
			</select>
		</div>
	<cfelse>
		<input type="hidden" name="psIssue" id="issueList" value="0">
		<div id="issueListWrap" style="margin: 11px 0 10px 0;">No previous returned issues found</div>
	</cfif>
</cfoutput>
<script type="text/javascript">
	$(".issueSelect").chosen({width: "100%",disable_search_threshold: 10});
</script>
