<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">

<cfobject component="code/accounts" name="accts">
<cfsetting showdebugoutput="no">
<cfset callback = 1>
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.form = form>
<cfset parm.rowLimit = 10>
<cfset parm.url = application.site.normal>
<cfset acctData = accts.LoadAccount(parm)>
<cfset parm.account = acctData.account>
<cfif StructKeyExists(acctData.account, "accID") gt 0>
	<cfset trans = accts.LoadTransactionList(parm)>
	<cfoutput>
		<script>
			$(document).ready(function(e) {
				$('.datepicker').datepicker({
					dateFormat: "dd/mm/yy",
					changeMonth: true,
					changeYear: true,
					showButtonPanel: true
				});
				$('##trnDate').blur(function(event) {
					var dateChecked = checkDate($(this).val(), false);
					if (!dateChecked) {
						alert('Date is out of range')
					} else {
						$(this).val(dateChecked)			
					}
				});
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
					$('##NetAmount').val(nf(amount1, "abs_str"));
					$('##trnDate').val(date);
					$('##VATAmount').val(nf(amount2, "abs_str"));
					$('##Ref').val(ref);
					$('##GrossTotal').val(nf(amount3, "abs_str"));
					$('##trnDesc').val(desc);
					$('##TrnTypeID').val(type);
					$('##HeaderType option[value="' + type + '"]').attr("selected", "selected");
					$.ajax({
						type: "POST",
						url: "#parm.url#ajax/AJAX_suppLoadItems.cfm",
						data: $('##RecordEditForm').serialize() + "&transID=" + id + "&type=" + type + "&isNew=false",
						beforeSend: function() {
							$('##callback').html("Loading...");
						},
						success: function(data) {
							$('##callback').html(data);
							$('.aifheaderForm').show();
							$('.aif-headline').show();
						}
					});
					event.preventDefault();
				});
				$('##btnDeleteAccTrans').click(function(event) {
					$.confirmation({
						accept: function() {
							var tranID = $('##EditID').val();
							$.ajax({
								type: "POST",
								url: "#parm.url#ajax/AJAX_deleteAccountTransRecord.cfm",
								data: {
									"tranID": tranID,
									"accID": "#parm.account.accNomAcct#"
								},
								success: function(data) {
									$.messageBox("Deleted Successfully", "success");
									$('##trnItem_' + tranID).remove();
									$('##btnNewAccTrans').click();
									
									$('##content').append(data);
								},
								error: function() {
									$.messageBox("An error occured", "error");
								}
							});
						},
						decline: function() {}
					});
					event.preventDefault();
				});
				$('##btnNewAccTrans').click(function(event) {
					$('##RecordEditForm')[0].reset();
					$('##RecordEditForm').find('input[name="accType"]').val("#parm.account.accType#");
					$('##RecordEditForm').find('input[name="accID"]').val("#parm.account.accID#");
					$('##callback').html("");
					$('.aifheaderForm').show();
					$('.aif-headline').hide();
					setTimeout(function() {
						$('##trnDate').focus();
					}, 250);
					$.ajax({
						type: "POST",
						url: "#parm.url#ajax/AJAX_suppLoadItems.cfm",
						data: {"isNew": true},
						beforeSend: function() {
							$('##callback').html("Loading...");
						},
						success: function(data) {
							$('##callback').html(data);
							$('.aifheaderForm').show();
							$('.aif-headline').show();
						}
					});
					event.preventDefault();
				});
				$('##NetAmount, ##VATAmount').keyup(function(event) {
					var net = parseFloat($('##NetAmount').val());
					var vat = parseFloat($('##VATAmount').val());
					$('##GrossTotal').val( nf(net + vat, "str") );
					event.preventDefault();
				});
				var cancelNew = false;
				$('##VATAmount').keydown(function(event) {
					var code = event.keyCode || event.which;
					var isNew = ( $('.aif-headline').html().match(/new/gi) != null ) ? true : false;
					if (code == '9') {
						if (isNew) {
							if (!cancelNew) {
								$('.aifnewRow').click();
								$('.aifHover:first')
									.click()
									.find('.nom').focus();
								cancelNew = true;
							} else {
								$('.aifHover:first')
									.click()
									.find('.nom').focus();
							}
						} else {
							$('.aifHover:first')
								.click()
								.find('.nom').focus();
						}
					}
					event.preventDefault();
				});
			});
		</script>
		<div class="aifControls">
			<button id="btnNewAccTrans" style="float:right;">New</button>
		</div>
		<div style="padding:20px 0;"></div>
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
		<div style="padding:5px 0;"></div>
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
			<cfset totAmnt1 = 0>
			<cfset totAmnt2 = 0>
			<cfloop array="#trans.tranList#" index="item">
				<cfset totAmnt1 += item.trnAmnt1>
				<cfset totAmnt2 += item.trnAmnt2>
				<tr id="trnItem_#item.trnID#">
					<td id="trnItem_ID"><a href="javascript:void(0)" class="trnIDLink" data-id="#item.trnID#" data-type="#item.trnType#">#item.trnID#</a></td>
					<td id="trnItem_Date" align="right">#LSDateFormat(item.trnDate,"dd/mm/yyyy")#</td>
					<td id="trnItem_Type" align="center">#item.trnType#</td>
					<td id="trnItem_Ref">#item.trnRef#</td>
					<td id="trnItem_Desc">#item.trnDesc#</td>
					<td id="trnItem_Amount1" class="amount">#DecimalFormat(item.trnAmnt1)#</td>
					<td id="trnItem_Amount2" class="amount">#DecimalFormat(item.trnAmnt2)#</td>
					<td id="trnItem_Amount3" class="amount">#DecimalFormat(item.trnAmnt1 + item.trnAmnt2)#</td>
					<td id="trnItem_Alloc" align="center">#item.trnAlloc#</td>
				</tr>
			</cfloop>
			<tr>
				<td colspan="5">#trans.rowCount# records.</td>
				<td class="amount">#DecimalFormat(totAmnt1)#</td>
				<td class="amount">#DecimalFormat(totAmnt2)#</td>
				<td class="amount">#DecimalFormat(totAmnt1 + totAmnt2)#</td>
				<td></td>
			</tr>
		</table>
		<div style="padding:5px 0;"></div>
		<div class="aif-headline" style="display:none;"></div>
		<div style="padding:5px 0;"></div>
		<div class="aifheaderForm" style="display:none;">
			<form method="post" enctype="multipart/form-data" id="RecordEditForm" name="RecordEditFormName">
				<input type="hidden" name="accType" value="#parm.account.accType#">
				<input type="hidden" name="accID" value="#parm.account.accID#">
				<input type="hidden" name="accNomAcct" value="#parm.account.accNomAcct#">
				<input type="hidden" name="trnType" value="" id="TrnTypeID">
				<input type="hidden" name="trnActive" value="1">
				<table border="1" class="tableList" width="100%">
					<tr>
						<th width="100" align="left">Trans ID</th>
						<td><input type="text" name="trnID" value="" id="EditID" disabled="disabled" tabindex="1"></td>
						<th width="100" align="left">Net Amount</th>
						<td><input type="text" name="trnAmnt1" value="" id="NetAmount" style="text-align:right;" tabindex="5"></td>
					</tr>
					<tr>
						<th width="100" align="left">Trans Date</th>
						<td><input type="text" name="trnDate" class="datepicker" value="" id="trnDate" tabindex="2"></td>
						<th width="100" align="left">VAT Amount</th>
						<td><input type="text" name="trnAmnt2" value="" id="VATAmount" style="text-align:right;" tabindex="6"></td>
					</tr>
					<tr>
						<th width="100" align="left">Trans Ref</th>
						<td><input type="text" name="trnRef" value="" id="Ref" tabindex="3"></td>
						<th width="100" align="left">Gross Total</th>
						<td><input type="text" name="trnTotal" value="" id="GrossTotal" style="text-align:right;" disabled="disabled" tabindex="7"></td>
					</tr>
					<tr>
						<th width="100" align="left">Description</th>
						<td><input type="text" name="trnDesc" value="" id="trnDesc" size="50" maxlength="255" tabindex="4"></td>
						<th width="100" align="left">Type</th>
						<td id="Active">
							<select name="Type" id="HeaderType" tabindex="-1">
								<option value="crn">Credit Note</option>
								<option value="inv" selected="selected">Invoice</option>
							</select>
						</td>
					</tr>
					<tr>
						<td colspan="4" id="btnCell">
							<input type="button" id="btnDeleteAccTrans" value="Delete" style="float:right;" tabindex="-1" />
						</td>
					</tr>
				</table>
			</form>
		</div>
		<div id="callback"></div>
	</cfoutput>
<cfelse>
	<table border="1" class="tableList" width="100%">
		<tr>
			<td>No account found. Please select an account from the pop-up menu or enter an existing transaction ID or reference.</td>
		</tr>
	</table>
</cfif>