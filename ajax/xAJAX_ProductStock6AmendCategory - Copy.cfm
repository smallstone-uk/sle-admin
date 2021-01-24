<cftry>
	<cfsetting showdebugoutput="no">
	<cfset callback = true>
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.url = application.site.normal>
	<cfset parm.pcatID = form.id>
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset record = pstock.LoadProductCategory(parm)>
	<cfset data = pstock.LoadProductGroups(parm)>
	<cfoutput>
			<span class="FCPDIHeader">
				<span class="FCPDITitle">Amend Category</span>
				<a href="javascript:void(0)" class="FCPDIClose" onclick="javascript:$.closeDialog();" title="Close popup"></a>
			</span>
			<div class="FCPopupDialogInner">
				<script>
					$(document).ready(function(e) {
						$('##AmendCategory').submit(function(event) {
							$.ajax({
								type: "POST",
								url: "#parm.url#ajax/AJAX_SaveCategory.cfm",
								data: $('##AmendCategory').serialize(),
								success: function(data) {
								$('#FCPopupDialog').remove();
								$('#FCPopupDim').remove();
									$.messageBox("Category Amended", "success");
								}
							});
							event.preventDefault();
						});
						$('##pcatDescription').keyup(function(event) {console.log(event)})
					});
				</script>
				<span class="FCPDIContent">
		<form method="post" enctype="multipart/form-data" id="AmendCategory">
			<input type="hidden" name="pcatID" id="pcatID" value="#form.id#" />
					<table width="100%" border="0" class="tableList" style="border:none;">
						<tr>
							<td align="right">Title</td>
							<td><input type="text" name="pcatTitle" size="25" value="#record.category.pcatTitle#" /></td>
						</tr>
						<tr>
							<td align="right">Group</td>
							<td>
								<select name="pcatGroup">
									<cfloop query="data.groups">
										<option value="#pgID#"<cfif record.category.pcatGroup eq pgID> selected="selected"</cfif>>#pgTitle#</option>
									</cfloop>
								</select>
							</td>
						</tr>
						<tr>
							<td align="right">Description</td>
							<td><textarea class="textBox" name="pcatDescription" id="pcatDescription"></textarea></td>
						</tr>
						<tr>
							<td align="right">Visible</td>
							<td>
								<input type="radio" name="pcatShow" value="1"<cfif record.category.pcatShow eq 1> checked="checked"</cfif> />Show on Live Site<br />
								<input type="radio" name="pcatShow" value="0"<cfif record.category.pcatShow eq 0> checked="checked"</cfif> />Hide on Live Site<br />								
							</td>
						</tr>
					</table>
				</span>
			<span class="FCPDIControls">
				<input type="submit" name="Submit" value="Save" class="NAFSubmit" style="float:right;margin-right:10px;" />
				<input type="button" name="cancel" value="Cancel" class="button_white" style="float:right;" onclick="javascript:$.closeDialog();" />
			</span>
		</form>
			</div>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
