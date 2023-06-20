<cftry>
<cfsetting showdebugoutput="no">
<cfobject component="code/accounts" name="acc">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.code = accCode>
<cfset account = acc.LoadAccountByCode(parm)>
<cfset groups = acc.LoadAccountGroups(parm)>
<cfset pay_types = acc.LoadPaymentTypes(parm)>
<cfset fund_sources = acc.LoadFundSources(parm)>

<cfoutput>
	<form method="post" enctype="multipart/form-data" id="EditAccountForm">
		<input type="hidden" name="accountID" value="#account.accID#">
		<span class="FCPDIHeader">
			<span class="FCPDITitle">Edit Account</span>
			<a href="javascript:void(0)" class="FCPDIClose" onclick="javascript:$.closeDialog();" title="Close popup"></a>
		</span>
		<div class="FCPopupDialogInner">
			<script>
				$(document).ready(function(e) {
					$('##EditAccountForm').submit(function(event) {
						$.ajax({
							type: "POST",
							url: "#parm.url#ajax/AJAX_editAccount.cfm",
							data: $(this).serialize(),
							success: function(data) {
								$.closeDialog();
								$.messageBox("Account Edited - <strong style='color:##C00;'>Please click 'Search' for the update to take effect</strong>", "success");
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
				});
			</script>
			<span class="FCPDIContent">
				<table width="100%" border="0" class="tableList" style="border:none;">
					<tr>
						<td align="right">Code</td>
						<td><input type="text" name="Code" class="NAFCode" style="text-transform:uppercase;" value="#account.accCode#" disabled="disabled" /></td>
					</tr>
					<tr>
						<td align="right">Name</td>
						<td><input type="text" name="Name" value="#account.accName#" /></td>
					</tr>
					<tr>
						<td align="right">Bank Ref</td>
						<td><input type="text" name="accIndex" value="#account.accIndex#" /></td>
					</tr>
					<tr>
						<td align="right">Type</td>
						<td>
							<select name="Type" class="NAFType">
								<option value="null" selected="selected">Select type...</option>
								<option value="sales" <cfif account.accType eq "sales">selected="selected"</cfif>>Sales</option>
								<option value="purch" <cfif account.accType eq "purch">selected="selected"</cfif>>Purchases</option>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right">Payment Method</td>
						<td>
							<select name="PayType" class="NAFPayType">
								<option value="null" selected="selected">Select type...</option>
								<cfloop array="#pay_types#" index="i">
									<option value="#i.ttlValue#" <cfif account.accPayType is i.ttlValue>selected="selected"</cfif>>#i.ttlValue# - #i.ttlTitle#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right">Group</td>
						<td>
							<select name="Group">
								<cfloop array="#groups#" index="i">
									<option value="#i.ttlValue#" <cfif i.ttlValue is account.accGroup>selected="selected"</cfif>>#i.ttlTitle#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right">Balancing Account</td>
						<td>
							<select name="NominalAccount" class="NAFNomAcc">
								<cfif account.accType eq "sales">
									<option value="1" <cfif account.accNomAcct is 1>selected="selected"</cfif>>Debt</option>
									<option value="201" <cfif account.accNomAcct is 201>selected="selected"</cfif>>Shop</option>
								<cfelseif account.accType eq "purch">
									<option value="11" <cfif account.accNomAcct is 11>selected="selected"</cfif>>Cred</option>
									<option value="201" <cfif account.accNomAcct is 201>selected="selected"</cfif>>Shop</option>
								</cfif>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right">Fund Source</td>
						<td>
							<select name="FundSource">
								<cfloop array="#fund_sources#" index="i">
									<option value="#i.nomID#" <cfif account.accPayAcc is i.nomID>selected="selected"</cfif>>#i.nomCode# - #i.nomTitle#</option>
								</cfloop>
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

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>