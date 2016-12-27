<cfsetting showdebugoutput="no">
<cfobject component="code/accounts" name="acc">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset accounts = acc.LoadAccounts(parm)>

<cfoutput>
	<form method="post" enctype="multipart/form-data" id="ChoosePayAccounts">
		<span class="FCPDIHeader">
			<span class="FCPDITitle">Payment Accounts</span>
			<a href="javascript:void(0)" class="FCPDIClose" onclick="javascript:$.closeDialog();" title="Close popup"></a>
		</span>
		<div class="FCPopupDialogInner">
			<script>
				$(document).ready(function(e) {
					$('##ChoosePayAccounts').submit(function(event) {
						var values = "";
						$('.CPAOption').each(function(i, e) {
							if ($(e).prop('checked'))
								values += $(e).val() + ",";
						});
						$('##REFPayAccounts').val(values);
						$.closeDialog();
						$.messageBox("Accounts Attached", "success");
						event.preventDefault();
					});
				});
			</script>
			<span class="FCPDIContent">
				<table width="100%" border="1" class="tableList">
					<tr>
						<th width="10"></th>
						<th align="left">Account</th>
					</tr>
					<tr>
						<td><input type="checkbox" name="AccountID" value="201" class="CPAOption" /></td>
						<td>Shop</td>
					</tr>
					<tr>
						<td><input type="checkbox" name="AccountID" value="41" class="CPAOption" /></td>
						<td>Bank</td>
					</tr>
					<tr>
						<td><input type="checkbox" name="AccountID" value="1222" class="CPAOption" /></td>
						<td>LMC</td>
					</tr>
					<tr>
						<td><input type="checkbox" name="AccountID" value="1202" class="CPAOption" /></td>
						<td>James Bank (Dev)</td>
					</tr>
				</table>
			</span>
		</div>
		<span class="FCPDIControls">
			<input type="submit" name="Submit" value="Attach" class="NAFSubmit" style="float:right;margin-right:10px;" />
			<input type="button" name="cancel" value="Cancel" class="button_white" style="float:right;" onclick="javascript:$.closeDialog();" />
		</span>
	</form>
</cfoutput>