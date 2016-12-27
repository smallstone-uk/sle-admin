
<cfset callback=1>
<cfsetting showdebugoutput="no">

<cfobject component="code/accounts" name="accts">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset parm.rowLimit=10>
<cfset acctData=accts.LoadAccount(parm)>
<cfset parm.account=acctData.account>
<cfif StructKeyExists(acctData.account,"accID") gt 0>
	<cfset trans=accts.LoadTransactionList(parm)>
	<cfoutput>
		<script>
			$(document).ready(function(e) {
				$('.trnIDLink').click(function(event) {
					var row = $('##trnItem_' + $(this).attr("data-id"));
					var id = row.find('##trnItem_ID').find('a').html(),
						date = row.find('##trnItem_Date').html(),
						type = row.find('##trnItem_Type').html(),
						ref = row.find('##trnItem_Ref').html(),
						desc = row.find('##trnItem_Desc').html(),
						amount1 = row.find('##trnItem_Amount1').html(),
						amount2 = row.find('##trnItem_Amount2').html(),
						amount3 = row.find('##trnItem_Amount3').html(),
						alloc = row.find('##trnItem_Alloc').html();
					$('##EditID').val(id);
					$('##NetAmount').val(amount1);
					$('##trnDate').val(date);
					$('##VATAmount').val(amount2);
					$('##Ref').val(ref);
					$('##GrossTotal').val(amount3);
					$('##trnDesc').val(desc);
					
					$.ajax({
						type: "POST",
						url: "#application.site.normal#suppLoadItems.cfm",
						data: $('##RecordEditForm').serialize() + "&transID=" + id,
						beforeSend: function() {
							$('##callback').html("Loading...");
						},
						success: function(data) {
							$('##callback').html(data);
						},
						error: function(data) {
							$('##callback').html(data);
						}
					});
					event.preventDefault();
				});
				$('##btnSaveAccTrans').click(function(event) {
					$.ajax({
						type: "POST",
						url: "#application.site.normal#ajax/AJAX_saveAccountTransRecord.cfm",
						data: $('##RecordEditForm').serialize(),
						success: function(data) {
							// Debug Output
							$('##callback').html(data);
						}
					});
					event.preventDefault();
				});
			});
		</script>
		<table border="1" class="tableList" width="100%">
			<tr>
				<th width="100" align="left">Account Code</th>
				<td>#acctData.Account.accCode#</td>
				<th width="100" align="left">Account Name</th>
				<td>#acctData.Account.accName#</td>
				<th width="100" align="left">Account Type</th>
				<td>#acctData.Account.accType#</td>
				<th width="100" align="left">Account Group</th>
				<td>#acctData.Account.accGroup#</td>
			</tr>
		</table>
		<table border="1" class="tableList" width="100%">
			<tr>
				<th>ID</th>
				<th align="right">Date</th>
				<th>Type</th>
				<th align="left">Ref</th>
				<th align="left">Description</th>
				<th align="right">Net</th>
				<th align="right">VAT/Disc</th>
				<th align="right">Gross</th>
				<th>Allocated</th>
			</tr>
			<cfset totAmnt1=0>
			<cfset totAmnt2=0>
			<cfloop array="#trans.tranList#" index="item">
				<cfset totAmnt1=totAmnt1+item.trnAmnt1>
				<cfset totAmnt2=totAmnt2+item.trnAmnt2>
				<tr id="trnItem_#item.trnID#">
					<td id="trnItem_ID"><a href="##" class="trnIDLink" data-id="#item.trnID#">#item.trnID#</a></td>
					<td id="trnItem_Date" align="right">#LSDateFormat(item.trnDate,"ddd dd-mmm-yyyy")#</td>
					<td id="trnItem_Type" align="center">#item.trnType#</td>
					<td id="trnItem_Ref">#item.trnRef#</td>
					<td id="trnItem_Desc">#item.trnDesc#</td>
					<td id="trnItem_Amount1" class="amount">#DecimalFormat(item.trnAmnt1)#</td>
					<td id="trnItem_Amount2" class="amount">#DecimalFormat(item.trnAmnt2)#</td>
					<td id="trnItem_Amount3" class="amount">#DecimalFormat(item.trnAmnt1+item.trnAmnt2)#</td>
					<td id="trnItem_Alloc" align="center">#item.trnAlloc#</td>
				</tr>
			</cfloop>
			<tr>
				<td colspan="5">#trans.rowCount# records.</td>
				<td class="amount">#DecimalFormat(totAmnt1)#</td>
				<td class="amount">#DecimalFormat(totAmnt2)#</td>
				<td class="amount">#DecimalFormat(totAmnt1+totAmnt2)#</td>
				<td></td>
			</tr>
		</table>
		<div style="padding:10px 0;"></div>
		<form method="post" enctype="multipart/form-data" id="RecordEditForm">
			<input type="hidden" name="type" value="inv" id="Type">
			<input type="hidden" name="mode" value="1" id="Mode">
			<input type="hidden" name="accID" value="#parm.account.accID#">
			<input type="hidden" name="trnClientID" value="0">
			<table border="1" class="tableList" width="100%">
				<tr>
					<th width="100" align="left">Trans ID</th>
					<td><input type="text" name="trnID" value="" id="EditID" tabindex="2"></td>
					<th width="100" align="left">Net Amount</th>
					<td><input type="text" name="trnAmnt1" value="" id="NetAmount" tabindex="5"></td>
				</tr>
				<tr>
					<th width="100" align="left">Trans Date</th>
					<td><input type="text" name="trnDate" value="" id="trnDate" tabindex="3"></td>
					<th width="100" align="left">VAT Amount</th>
					<td><input type="text" name="trnAmnt2" value="" id="VATAmount" tabindex="6"></td>
				</tr>
				<tr>
					<th width="100" align="left">Trans Ref</th>
					<td><input type="text" name="trnRef" value="" tabindex="4" id="Ref"></td>
					<th width="100" align="left">Gross Total</th>
					<td><input type="text" name="trnTotal" value="" id="GrossTotal" tabindex="7"></td>
				</tr>
				<tr>
					<th width="100" align="left">Description</th>
					<td><input type="text" name="trnDesc" value="" id="trnDesc" size="50" maxlength="255" tabindex="8"></td>
					<th width="100" align="left">Active</th>
					<td id="Active"><input type="checkbox" name="trnActive" value="1" checked="checked" disabled="disabled" /></td>
				</tr>
				<tr>
					<td colspan="4" id="btnCell">
						<input type="button" id="btnSaveAccTrans" value="Save" tabindex="9" style="float:right;" />
					</td>
				</tr>
			</table>
		</form>
		<div id="callback"></div>
	</cfoutput>
<cfelse>
	<table border="1" class="tableList" width="100%">
		<tr>
			<td>No account found. Please select an account from the pop-up menu or enter an existing transaction ID or reference.</td>
		</tr>
	</table>
</cfif>