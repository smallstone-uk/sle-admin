<!---WORKING VERSION AS OF 18/08/2014--->
<cftry>
<cfobject component="code/accounts" name="acc">
<cfsetting showdebugoutput="no">
<cfset callback = 1>
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.accID = accID>
<cfset parm.form = {}>
<cfset parm.form.accountID = accID>
<cfset parm.form.tranRef = "">
<cfset acctData = acc.LoadAccount(parm)>
<cfset parm.account = acctData.account>
<cfset parm.accType = parm.account.accType>
<cfset acctsList = acc.LoadAccounts(parm)>
<cfset fundList = acc.LoadFundList(parm)>

<cfoutput>
	<cfif StructKeyExists(acctData.account, "accID") gt 0>
		<script>
			$(document).ready(function(e) {
				$(document).on("keyup", "input", function(event) {
					allowNewTran = false;
				});
				switchHeaderType("inv", true);
				$('.aif-headline').show();
				$('##NetAmount, ##VATAmount').keyup(function(event) {
					var netVal = $('##NetAmount').val();
					var vatVal = $('##VATAmount').val();
				
					var net = nf(netVal, "num");
					var vat = nf(vatVal, "num");
					
					$('##GrossTotal').val( nf(net + vat, "str") );
					
					if (isNaN(netVal) || isNaN(vatVal)) {
						disableSave(true);
					} else {
						disableSave(false);
					}
				});
				var cancelNew = false;
				$('##VATAmount').keydown(function(event) {
					var code = event.keyCode || event.which;
					var isNew = ( $('.aif-headline').html().match(/new/gi) != null ) ? true : false;
					if (code == '9') {
						if (isNew) {
							if (!cancelNew) {
								$('.aifnewRow').click();
								cancelNew = true;
							} else {
								//$('.aifHover:first').find('.nom').focus();
							}
						} else {
							//$('.aifHover:first').click().find('.nom').focus();
						}
					}
				});
				$.ajax({
					type: "POST",
					url: "#parm.url#ajax/AJAX_suppLoadItems.cfm",
					data: {
						"isNew": true,
						"type": "inv",
						"accType": "#parm.accType#"
					},
					success: function(data) {
						$('##tran-items').html(data).show();
					}
				});
				$('##HeaderType').change(function(event) {
					var option = $(this).val();
					if (option == "inv" || option == "crn") {
						$('##hfVATAmntLbl').html("VAT Amount");
						$.ajax({
							type: "POST",
							url: "#parm.url#ajax/AJAX_suppLoadItems.cfm",
							data: {
								"isNew": true,
								"type": "inv",
								"accType": "#parm.accType#"
							},
							success: function(data) {
								$('##tran-items').html(data).show();
							}
						});
					} else {
						$('##tran-items').html("").hide();
						$('##hfVATAmntLbl').html("Discount Amount");
						if (option == "pay" || option == "rfd") {
							$('##selPayAccField option').removeAttr("selected");
							$('##selPayAccField option[value="#parm.account.accPayAcc#"]').attr("selected", "selected");
						} else {
							$('##selPayAccField option').removeAttr("selected");
							$('##selPayAccField option[value="null"]').attr("selected", "selected");
						}
					}
					
					if (option == "pay" || option == "rfd") $('##selPayAcc').show(); else $('##selPayAcc').hide();
					
					switchHeaderType(option, true);
				});
				var shouldSuccess = false;
				$('.datepicker').blur(function(event) {
					var value = $(this).val();
					var isOk = checkDate(value, true);
					if (!isOk) {
						$.messageBox("Date out of range", "error");
						disableSave(true);
						shouldSuccess = true;
					} else {
						if (value.length > 0) {
							$(this).val(isOk);
							if (shouldSuccess) {$.messageBox("Date in range", "success");}
							disableSave(false);
						}
					}
				});
				$('##selPayAccField').change(function(event) {
					var value = $(this).val();
					if (value == "null") {
						disableSave(true);
					} else {
						disableSave(false);
					}
				});
				$('##RecordEditForm input').change(function(event) {
					validateTran();
				});
			});
		</script>
		<div class="aif-headline"></div>
		<div class="aifheaderForm">
			<form method="post" enctype="multipart/form-data" id="RecordEditForm" name="RecordEditFormName">
				<input type="hidden" name="PaymentAccounts" value="" id="REFPayAccounts" />
				<input type="hidden" name="accType" value="#parm.account.accType#">
				<input type="hidden" name="accID" value="#parm.account.accID#">
				<input type="hidden" name="accNomAcct" value="#parm.account.accNomAcct#">
				<input type="hidden" name="trnType" value="" id="TrnTypeID">
				<input type="hidden" name="trnMethod" value="" />
				<input type="hidden" name="trnClientID" value="0" />
				<input type="hidden" name="trnClientRef" value="" />
				<input type="hidden" name="trnActive" value="1">
				<table border="1" class="tableList" width="100%">
					<tr>
						<th width="100" align="left">Trans ID</th>
						<td><input type="text" name="trnID" value="" id="EditID" disabled="disabled" tabindex="-1">
						<label>
						<input type="checkbox" name="paidCOD" id="paidCOD" value="1" tabindex="-1" 
							<cfif acctData.account.PAYACCNOMCODE IS "CASH"> checked="checked"</cfif>
							title="tick this box to create a payment entry for the same amount." /> Paid from account on: </label>
							<input type="text" name="paidDate" class="datepicker" value="" id="paidDate" tabindex="6"></td>
						<th width="100" align="left">Net Amount</th>
						<td><input type="text" name="trnAmnt1" value="" id="NetAmount" style="text-align:right;" tabindex="9"></td>
					</tr>
					<tr>
						<th width="100" align="left">Trans Date</th>
						<td><input type="text" name="trnDate" class="datepicker" value="" id="trnDate" tabindex="6"></td>
						<th width="100" align="left" id="hfVATAmntLbl">VAT Amount</th>
						<td><input type="text" name="trnAmnt2" value="" id="VATAmount" style="text-align:right;" tabindex="10"></td>
					</tr>
					<tr>
						<th width="100" align="left">Trans Ref</th>
						<td><input type="text" name="trnRef" value="" id="Ref" tabindex="7"></td>
						<th width="100" align="left">Gross Total</th>
						<td><input type="text" name="trnTotal" value="" id="GrossTotal" style="text-align:right;" disabled="disabled" tabindex="-1"></td>
					</tr>
					<tr>
						<th width="100" align="left">Description</th>
						<td>
							<input type="text" name="trnDesc" value="" id="trnDesc" size="50" maxlength="255" tabindex="8" style="float:left;">
						</td>
						<th width="100" align="left">Type</th>
						<td id="Active">
							<select name="tranType" id="HeaderType" tabindex="11">
								<option value="inv">Invoice</option>
								<option value="crn">Credit Note</option>
								<option value="pay">Payment</option>
								<option value="rfd">Refund</option>
								<option value="jnl">Credit Journal</option>
								<option value="dbt">Debit Journal</option>
							</select>
						</td>
					</tr>
					<tr id="selPayAcc" style="display:none;">
						<th colspan="2"></th>
						<th align="left">Fund Source</th>
						<td>
							<select name="paymentAccounts" tabindex="13" id="selPayAccField">
								<option value="null">Select payment...</option>
								<cfloop query="fundList.FundAccts">
									<option value="#nomID#">#nomTitle#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<!--- HIDE ON NEW
					<tr>
						<th align="left">Move Transaction</th>
						<td align="left" colspan="3">
							<script>
								$(document).ready(function(e) {
									$('.changeAccountChk').click(function(event) {
										var isChecked = $(this).prop("checked");
										if (isChecked && $('##EditID').val().length > 0) {
											$('.changeAccountSel, .changeAccountBtn').prop("disabled", false);
										} else {
											$('.changeAccountSel, .changeAccountBtn').prop("disabled", true);
										}
									});
									$('.changeAccountBtn').click(function(event) {
										$.ajax({
											type: "POST",
											url: "#parm.url#ajax/AJAX_moveTranAccount.cfm",
											data: {
												"newAccount": $('.changeAccountSel').val(),
												"tranID": $('##EditID').val()
											},
											success: function(data) {
												$.messageBox("Transaction Moved - You MUST reload the transaction", "success");
											}
										});
										event.preventDefault();
									});
								});
							</script>
							<select class="changeAccountSel" disabled="disabled">
								<cfloop array="#acctsList.accounts#" index="i">
									<option value="#i.accID#">#i.accName#</option>
								</cfloop>
							</select>
							<label>
								<input type="checkbox" class="changeAccountChk" />
								Yes I am sure I want to move this transaction to the selected account.
							</label>
							<button class="changeAccountBtn" disabled="disabled">Move Transaction</button>
						</td>
					</tr>
					--->
				</table>
			</form>
		</div>
	<cfelse>
	</cfif>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="false">
</cfcatch>
</cftry>