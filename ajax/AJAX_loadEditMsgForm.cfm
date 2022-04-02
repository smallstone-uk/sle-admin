<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfset count=0>

<cfoutput>
	<cfobject component="code/functions" name="cust">
	<cfset parm = {}>
	<cfset parm.form = form>
	<cfset parm.url = application.site.normal>
	<cfset parm.datasource = application.site.datasource1>
	<cfset result = cust.LoadMsg(parm)>
	<script type="text/javascript">
		$(document).ready(function() {
			function LoadMsgs() {
				$.ajax({
					type: 'POST',
					url: 'clientMsgsList.cfm',
					data : $('##notClientID').serialize(),
					success:function(data){
						$('##list').html(data).fadeIn();
					}
				});
			};
			$('##EditMsgForm').submit(function(event) {
				$.ajax({
					type: "POST",
					url: "#parm.url#ajax/AJAX_saveMsg.cfm",
					data: $(this).serialize(),
					success: function(data) {
						$.closeDialog();
						$.messageBox("Message Saved", "success");
						LoadMsgs();
					}
					
				});
				
				event.preventDefault();
			});
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
		});
	</script>

	<cfloop query="result.QMsg">
	<form method="post" enctype="multipart/form-data" id="EditMsgForm">
		<input type="hidden" name="notID" id="notID" value="#noteID#" />
			<span class="FCPDIHeader">
				<span class="FCPDITitle">Edit Message</span>
				<a href="javascript:void(0)" class="FCPDIClose" onclick="javascript:$.closeDialog();" title="Close popup"></a>
			</span>
			<div class="FCPopupDialogInner">
				<span class="FCPDIContent">
				<table>
					<tr>
						<td><textarea name="notText" cols="50" rows="5">#notText#</textarea></td>
						<td>
							<table>
								<tr>
									<td>Type</td>
									<td>
										<select name="notType">
											<option value="note"<cfif  notType eq "note">selected="selected"</cfif>>Note</option>
											<option value="call"<cfif  notType eq "call">selected="selected"</cfif>>Call</option>
											<option value="email"<cfif  notType eq "email">selected="selected"</cfif>>Email</option>
											<option value="letter"<cfif  notType eq "letter">selected="selected"</cfif>>Letter</option>
											<option value="msg"<cfif  notType eq "msg">selected="selected"</cfif>>Round Message</option>
										</select>
									</td>
								</tr>
								<tr>
									<td>Status</td>
									<td>
										<select name="notStatus">
											<option value="open"<cfif  notStatus eq "open">selected="selected"</cfif>>Open</option>
											<option value="closed"<cfif  notStatus eq "closed">selected="selected"</cfif>>Closed</option>
											<option value="complete"<cfif  notStatus eq "complete">selected="selected"</cfif>>Complete</option>
											<option value="archived"<cfif  notStatus eq "archived">selected="selected"</cfif>>Archived</option>
										</select>
									</td>
								</tr>
								<tr>
									<td>Urgent</td>
									<td>
										<input type="checkbox" name="notUrgent" value="1"<cfif notUrgent> checked="checked"</cfif> />
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<tr>
						<td>
							<table width="100%">
								<tr>
									<td>Start</td>
									<td><input type="text" size="10" name="notStart" class="datepicker" value="#DateFormat(notStart,'yyyy-mm-dd')#" /></td>
									<td>Stop</td>
									<td><input type="text" size="10" name="notEnd" class="datepicker" value="#DateFormat(notEnd,'yyyy-mm-dd')#" /></td>
								</tr>
								<tr>
									<td colspan="4" align="center">
										<table>
											<tr>
												<cfloop list="Sun,Mon,Tue,Wed,Thu,Fri,Sat" index="day">
													<cfset checkDay = Evaluate("not#day#")>
													<td>
														#day#<br />
														<input type="checkbox" name="not#day#"<cfif checkDay eq 1> checked="checked"</cfif> value="1" />
													</td>
												</cfloop>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
				
				</span>
				<span class="FCPDIControls">
					<input type="submit" name="Submit" value="Save" class="NAFSubmit" style="float:right;margin-right:10px;" />
					<input type="button" name="cancel" value="Cancel" class="button_white" style="float:right;" onclick="javascript:$.closeDialog();" />
				</span>
			</div>
		</form>
		</cfloop>
</cfoutput>
<script type="text/javascript">
	$(".nosearch100").chosen({width: "100%",disable_search_threshold: 10});
</script>
