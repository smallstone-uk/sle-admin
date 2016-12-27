<cfsetting showdebugoutput="no">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.pgID = form.id>
<cfobject component="code/ProductStock6" name="pstock">
<cfset record = pstock.LoadProductGroup(parm)>
<cfoutput>
	<form method="post" enctype="multipart/form-data" id="AmendGroup">
		<input type="hidden" name="pgID" id="pgID" value="#form.id#" />
		<span class="FCPDIHeader">
			<span class="FCPDITitle">Amend Group</span>
			<a href="javascript:void(0)" class="FCPDIClose" onclick="javascript:$.closeDialog();" title="Close popup"></a>
		</span>
		<div class="FCPopupDialogInner">
			<script>
				$(document).ready(function(e) {
					$('##AmendGroup').submit(function(event) {
						$.ajax({
							type: "POST",
							url: "#parm.url#ajax/AJAX_SaveGroup.cfm",
							data: $('##AmendGroup').serialize(),
							success: function(data) {
								$.closeDialog();
								$.messageBox("Group Amended", "success");
							}
						});
						event.preventDefault();
					});
				});
			</script>
			<span class="FCPDIContent">
				<table width="100%" border="0" class="tableList" style="border:none;">
					<tr>
						<td align="right">Title</td>
						<td><input type="text" name="pgTitle" size="25" value="#record.group.pgTitle#" /></td>
					</tr>
					<tr>
						<td align="right">Target</td>
						<td><input type="text" name="pgTarget" size="5" value="#record.group.pgTarget#" />%</td>
					</tr>
					<tr>
						<td align="right">Type</td>
						<td>
							<select name="pgType">
								<option value="sale"<cfif record.group.pgType eq "sale"> selected="selected"</cfif>>Sale</option>
								<option value="shop"<cfif record.group.pgType eq "shop"> selected="selected"</cfif>>Shop</option>
							</select>
						</td>
					</tr>
				</table>
			</span>
		</div>
		<span class="FCPDIControls">
			<input type="submit" name="Submit" value="Save" class="NAFSubmit" style="float:right;margin-right:10px;" />
			<input type="button" name="cancel" value="Cancel" class="button_white" style="float:right;" onclick="javascript:$.closeDialog();" />
		</span>
	</form>
</cfoutput>
