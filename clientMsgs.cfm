<script type="text/javascript">
	$(document).ready(function() {
		function LoadMsgs() {
			$.ajax({
				type: 'POST',
				url: 'clientMsgsList.cfm',
				data : $('#notClientID').serialize(),
				success:function(data){
					$('#list').html(data).fadeIn();
				}
			});
		};
		$("#MsgTab").click(function(event) {LoadMsgs();});
		$("#btnAdd").click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'clientMsgsAction.cfm',
				data : $('#MsgForm').serialize(),
				success:function(data){
					$('#saveResults').html(data).fadeIn();
					LoadMsgs();
					setTimeout(function(){$("#saveResults").fadeOut("slow");}, 5000);
				}
			});
			event.preventDefault();
		});
		LoadMsgs();
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
	});
</script>

<cfset tomorrow = DateAdd("d",1,Now())>
<cfoutput>
	<div id="saveResults" style="display:none;"></div>
	<form method="post" enctype="multipart/form-data" id="MsgForm">
		<input type="hidden" name="notClientID" id="notClientID" value="#customer.rec.cltID#" />
		<input type="hidden" name="notEntered" value="#LSDateFormat(now(),'yyyy-mm-dd')#" />
		<table border="1" class="tableList">
			<tr>
				<th colspan="5">New Message</th>
			</tr>
			<tr>
				<td><textarea name="notText" cols="50" rows="5"></textarea></td>
				<td align="center">
					<strong>Type</strong><br />
					<select name="notType">
						<option value="note" selected="selected">Note</option>
						<option value="call">Call</option>
						<option value="email">Email</option>
						<option value="letter">Letter</option>
						<option value="msg">Round Message</option>
					</select>
				</td>
				<td align="center">
					<strong>Status</strong><br />
					<select name="notStatus">
						<option value="open" selected="selected">Open</option>
						<option value="closed">Closed</option>
						<option value="complete">Complete</option>
						<option value="archived">Archived</option>
					</select>
				</td>
				<td align="center">
					<strong>Urgent</strong><br />
					<input type="checkbox" name="notUrgent" value="1" />
				</td>
				<td>
					<table width="100%">
						<tr>
							<td align="center">
								<strong>Start</strong>
							</td>
							<td>
								<input type="text" size="10" name="notStart" class="datepicker" value="#DateFormat(tomorrow,'yyyy-mm-dd')#" />
							</td>
							<td>
								<strong>Stop</strong>
							</td>
							<td>
								<input type="text" size="10" name="notEnd" class="datepicker" value="#DateFormat(tomorrow,'yyyy-mm-dd')#" />
							</td>
						</tr>
						<tr>
							<td colspan="4" align="center">
								<table>
									<tr>
										<cfloop list="Sun,Mon,Tue,Wed,Thu,Fri,Sat" index="day">
											<td>#day#<br /><input type="checkbox" name="not#day#" value="1" /></td>
										</cfloop>
									</tr>
								</table>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<th colspan="5"><input type="button" id="btnAdd" value="Add" style="float:right;" /></th>
			</tr>
		</table>
	</form>
	<div id="list" style="margin:10px 0 0 0;"></div>
	<div class="clear"></div>
</cfoutput>