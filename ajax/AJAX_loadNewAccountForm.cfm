<cfsetting showdebugoutput="no">
<cfobject component="code/accounts" name="acc">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset groups = acc.LoadAccountGroups(parm)>
<cfset fund_sources = acc.LoadFundSources(parm)>

<cfoutput>
	<form method="post" enctype="multipart/form-data" id="NewAccountForm">
		<span class="FCPDIHeader">
			<span class="FCPDITitle">New Account</span>
			<a href="javascript:void(0)" class="FCPDIClose" onclick="javascript:$.closeDialog();" title="Close popup"></a>
		</span>
		<div class="FCPopupDialogInner">
			<script>
				$(document).ready(function(e) {
					$('##NewAccountForm').submit(function(event) {
						$.ajax({
							type: "POST",
							url: "#parm.url#ajax/AJAX_addNewAccount.cfm",
							data: $('##NewAccountForm').serialize(),
							success: function(data) {
								$.closeDialog();
								$.messageBox("Account Created", "success");
							}
						});
						event.preventDefault();
					});
					$('.NAFType').change(function(event) {
						var value = $(this).val();
						switch (value)
						{
							case "sales":
								$('.NAFNomAcc')
									.html("<option value='1'>Debt</option><option value='201'>Shop</option>")
									.removeAttr("disabled");
								break;
							case "purch":
								$('.NAFNomAcc')
									.html("<option value='11'>Cred</option><option value='201'>Shop</option>")
									.removeAttr("disabled");
								break;
							case "null":
								$('.NAFNomAcc')
									.html("")
									.attr("disabled", "disabled");
								break;
						}
					});
					$('.NAFCode').blur(function(event) {
						$.ajax({
							type: "POST",
							url: "#parm.url#ajax/AJAX_checkAccountCodeExists.cfm",
							data: {"code": $('.NAFCode').val()},
							success: function(data) {
								var tData = data.trim();
								if (tData == "true") {
									$('.NAFCode').css("border", "1px solid ##C00");
									$('.NAFSubmit').attr("disabled", "disabled");
								} else {
									$('.NAFCode').css("border", "1px solid ##B6B6B6");
									$('.NAFSubmit').removeAttr("disabled");
								}
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
						<td><input type="text" name="Code" class="NAFCode" style="text-transform:uppercase;" /></td>
					</tr>
					<tr>
						<td align="right">Group</td>
						<td>
							<select name="Group">
								<cfloop array="#groups#" index="i">
									<option value="#i.ttlValue#">#i.ttlTitle#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right">Name</td>
						<td><input type="text" name="Name" /></td>
					</tr>
					<tr>
						<td align="right">Type</td>
						<td>
							<select name="Type" class="NAFType">
								<option value="null" selected="selected">Select type...</option>
								<option value="sales">Sales</option>
								<option value="purch">Purchases</option>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right">Balancing Account</td>
						<td>
							<select name="NominalAccount" class="NAFNomAcc" disabled="disabled"></select>
						</td>
					</tr>
					<tr>
						<td align="right">Fund Source</td>
						<td>
							<select name="FundSource">
								<cfloop array="#fund_sources#" index="i">
									<option value="#i.nomID#">#i.nomCode# - #i.nomTitle#</option>
								</cfloop>
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