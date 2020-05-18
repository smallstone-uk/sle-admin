<cfsetting showdebugoutput="no">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>

<cfoutput>
	<form method="post" enctype="multipart/form-data" id="NewProdCategoryForm">
		<input type="hidden" name="pcatGroup" id="pcatGroup" value="#form.group#" />
		<span class="FCPDIHeader">
			<span class="FCPDITitle">New Product Category</span>
			<a href="javascript:void(0)" class="FCPDIClose" onclick="javascript:$.closeDialog();" title="Close popup"></a>
		</span>
		<div class="FCPopupDialogInner">
			<script>
				$(document).ready(function(e) {
					$('##NewProdCategoryForm').submit(function(event) {
						$.ajax({
							type: "POST",
							url: "#parm.url#ajax/AJAX_addNewProdCategory.cfm",
							data: $('##NewProdCategoryForm').serialize(),
							success: function(data) {
								$.closeDialog();
								$.messageBox("Category Created", "success");
								var group = $('##groupID').val();
								LoadCategories(group,'##catList');
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
						<td><input type="text" name="pcatTitle" size="25" /></td>
					</tr>
					<tr>
						<td align="right">Description</td>
						<td><textarea class="textBox" name="pcatDescription" cols="40" rows="6" id="pcatDescription"></textarea></td>
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
