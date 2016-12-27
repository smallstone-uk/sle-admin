<cfsetting showdebugoutput="no">
<cfobject component="code/core" name="core">
<cfobject component="code/accounts" name="acc">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.nomcode = nomcode>
<cfset parm.nomgroup = nomgroup>
<cfset nomrec = acc.LoadNominalRecordByCode(parm)>
<cfset groups = acc.LoadAllNominalGroups(parm)>

<cfoutput>
	<div class="nomEditBox">
		<script>
			$(document).ready(function(e) {
				$('input[name="remove"]').click(function(event) {
					var nomID = $(this).attr("data-nomID");
					var grpID = $(this).attr("data-grpID");
					$.ajax({
						type: "POST",
						url: "#parm.url#ajax/AJAX_removeNomFromGroup.cfm",
						data: {
							"nomID": nomID,
							"grpID": grpID
						},
						success: function(data) {
							$.messageBox("Nominal account removed from group successfully.", "success");
							loadAll();
							$('.nomEditBox').remove();
						}
					});
					event.preventDefault();
				});
				$('input[name="delete"]').click(function(event) {
					var nomID = $(this).attr("data-nomID");
					$.ajax({
						type: "POST",
						url: "#parm.url#ajax/AJAX_deleteNominalAccount.cfm",
						data: {"nomID": nomID},
						success: function(data) {
							if (data.trim() == "2") {
								$.messageBox("The nominal account cannot be deleted because there are items attached to it.", "error");
							} else {
								$.messageBox("Nominal account deleted successfully.", "success");
							}
							loadAll();
							$('.nomEditBox').remove();
						}
					});
					event.preventDefault();
				});
				$('##nomEditForm').submit(function(event) {
					$.ajax({
						type: "POST",
						url: "#parm.url#ajax/AJAX_saveNominalRecord.cfm",
						data: $(this).serialize(),
						success: function(data) {
							$('.nomEditBox').remove();
							loadAll();
							$.messageBox("Saved", "success");
						}
					});
					event.preventDefault();
				});
			});
		</script>
		<div style="padding:20px;">
			<form method="post" enctype="multipart/form-data" id="nomEditForm">
				<input type="hidden" name="id" value="#nomrec.nomid#">
				<table class="tableList" width="100%" border="0" style="border:none;">
					<tr>
						<td align="left">Title</td>
						<td align="left"><input type="text" name="title" value="#nomrec.nomtitle#"></td>
					</tr>
					<tr>
						<td align="left">Code</td>
						<td align="left"><input type="text" name="code" value="#nomrec.nomcode#"></td>
					</tr>
					<tr>
						<td align="left">Group</td>
						<td align="left">
							<select name="group">
								<cfloop array="#groups#" index="i">
									<option value="#i.ngName#" <cfif nomrec.nomgroup eq i.ngName>selected="selected"</cfif>>#i.ngName#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td align="left">Type</td>
						<td align="left">
							<select name="type">
								<option value="sales" <cfif nomrec.nomtype eq "sales">selected="selected"</cfif>>Sales</option>
								<option value="purch" <cfif nomrec.nomtype eq "purch">selected="selected"</cfif>>Purchases</option>
								<option value="nom" <cfif nomrec.nomtype eq "nom">selected="selected"</cfif>>Nominal</option>
							</select>
						</td>
					</tr>
					<tr>
						<td align="left">Class</td>
						<td align="left">
							<select name="class">
								<option value="shop" <cfif nomrec.nomclass eq "shop">selected="selected"</cfif>>Shop</option>
								<option value="news" <cfif nomrec.nomclass eq "news">selected="selected"</cfif>>News</option>
								<option value="ext" <cfif nomrec.nomclass eq "ext">selected="selected"</cfif>>Ext</option>
								<option value="other" <cfif nomrec.nomclass eq "other">selected="selected"</cfif>>Other</option>
							</select>
						</td>
					</tr>
					<tr>
						<td align="left">VAT</td>
						<td align="left">
							<select name="vat">
								<cfloop array="#core.GetVatTypes()#" index="item">
									<option value="#item.vatCode#" <cfif nomrec.nomvatcode eq item.vatCode>selected="selected"</cfif>>#item.vatTitle# - #DecimalFormat(item.vatRate)#%</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td align="left" colspan="2">
							<input type="submit" name="save" value="Save" style="margin-top:10px;float:right;">
							<input type="button" data-nomID="#nomrec.nomID#" name="delete" value="Delete" class="button_white" style="margin-top:10px;float:right;">
							<input type="button" data-nomID="#nomrec.nomID#" data-grpID="#parm.nomgroup#" name="remove" value="Remove From Group" class="button_white" style="margin-top:10px;float:left;">
						</td>
					</tr>
				</table>
			</form>
		</div>
	</div>
</cfoutput>