<cfsetting showdebugoutput="no">
<cfobject component="code/accounts" name="acc">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.url = application.site.normal>

<cfoutput>
	<form method="post" enctype="multipart/form-data" id="NewNominalForm">
		<span class="FCPDIHeader">
			<span class="FCPDITitle">New Nominal</span>
			<a href="javascript:void(0)" class="FCPDIClose" onclick="javascript:$.closeDialog();" title="Close popup"></a>
		</span>
		<div class="FCPopupDialogInner">
			<script>
				$(document).ready(function(e) {
					$('##NewNominalForm').submit(function(event) {
						$.ajax({
							type: "POST",
							url: "#parm.url#ajax/AJAX_addNewNominal.cfm",
							data: $('##NewNominalForm').serialize(),
							success: function(data) {
								$.closeDialog();
								$.messageBox("Nominal Created", "success");
							}
						});
						event.preventDefault();
					});
				});
			</script>
			<span class="FCPDIContent">
				<table width="100%" border="0" class="tableList" style="border:none;">
					<tr>
						<td align="right">Code</td>
						<td><input type="text" name="Code" class="NAFCode" /></td>
					</tr>
					<tr>
						<td align="right">Title</td>
						<td><input type="text" name="Title" /></td>
					</tr>
					<tr>
						<td align="right">Type</td>
						<td>
							<select name="Type" class="NAFType">
								<option value="null" selected="selected">Select type...</option>
								<option value="sales">Sales</option>
								<option value="purch">Purchases</option>
								<option value="nom">Nominal</option>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right">VAT Code</td>
						<td>
							<select name="vatCode">
								<option value="1" selected="selected">Non-Vatable</option>
								<option value="2">Vatable</option>
							</select>
						</td>
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