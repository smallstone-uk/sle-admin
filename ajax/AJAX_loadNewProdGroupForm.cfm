<cfsetting showdebugoutput="no">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>

<cfoutput>
	<form method="post" enctype="multipart/form-data" id="NewProdGroupForm">
		<span class="FCPDIHeader">
			<span class="FCPDITitle">New Product Group</span>
			<a href="javascript:void(0)" class="FCPDIClose" onclick="javascript:$.closeDialog();" title="Close popup"></a>
		</span>
		<div class="FCPopupDialogInner">
			<script>
				$(document).ready(function(e) {
					$('##NewProdGroupForm').submit(function(event) {
						$.ajax({
							type: "POST",
							url: "#parm.url#ajax/AJAX_addNewProdGroup.cfm",
							data: $('##NewProdGroupForm').serialize(),
							success: function(data) {
								$.closeDialog();
								$.messageBox("Group Created", "success");
								LoadGroups('##groupsdiv');
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
						<td><input type="text" name="pgTitle" size="25" /></td>
					</tr>
				</table>
			</span>
		</div>
		<span class="FCPDIControls">
			<input type="submit" name="Submit" value="Add" class="NAFSubmit" style="float:right;margin-right:10px;" />
			<input type="button" name="cancel" value="Cancel" class="button_white" style="float:right;" onclick="javascript:$.closeDialog();" />
		</span>
	</form>
</cfoutput>