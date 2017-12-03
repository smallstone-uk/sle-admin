<!---WORKING VERSION AS OF 18/08/2014--->
<cftry>
<cfobject component="code/accounts" name="acc">
<cfsetting showdebugoutput="no">
<cfset callback = 1>
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.form = DeserializeJSON(jForm)>
<cfset parm.tranID = tranID>
<cfset parm.accType = accType>
<cfset parm.accID = accID>
<cfset parm.accNomAcct = accNomAcct>
<cfset acctData = acc.LoadAccount(parm)>
<cfset parm.account = acctData.account>
<cfset trans = acc.LoadTransactionHeader(parm)>
<cfset acctsList = acc.LoadAccounts(parm)>
<cfset fundList = acc.LoadFundList(parm)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$(document).on("keyup", "input", function(event) {
				allowNewTran = false;
			});
			disableSave(false);
			var tranType = "#trans.trnType#";
			if (tranType != "pay" && tranType != "jnl" && tranType != "dbt" && tranType != "rfd") {
				$('##hfVATAmntLbl').html("VAT Amount");
				$('##selPayAccField option').removeAttr("selected");
				$('##selPayAccField option[value="null"]').attr("selected", "selected");
				$.ajax({
					type: "POST",
					url: "#parm.url#ajax/AJAX_suppLoadItems.cfm",
					data: $('##RecordEditForm').serialize() + "&transID=#trans.trnID#&type=#trans.trnType#&isNew=false",
					beforeSend:function() {
						$('##loading').loading(true);
					},
					success: function(data) {
						$('##tran-items').html(data).show();
						$('##loading').loading(false);
					}
				});
			} else {
				if (tranType == "pay" || tranType == "rfd") {
					$('##selPayAccField option').removeAttr("selected");
					$('##selPayAccField option[value="#trans.trnPayAcc#"]').attr("selected", "selected");
				} else {
					$('##selPayAccField option').removeAttr("selected");
					$('##selPayAccField option[value="null"]').attr("selected", "selected");
				}
				$('##tran-items').html("").hide();
				$('##hfVATAmntLbl').html("Discount Amount");
			}
			switchHeaderType(tranType, false);
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
			var shouldSuccess = false;
			$('.datepicker').blur(function(event) {
				var value = $(this).val();
				var isOk = checkDate(value, true);
				if (!isOk) {
					$.messageBox("Date out of range", "error");
					disableSave(true);
					shouldSuccess = true;
				} else {
					$(this).val(isOk);
					if (shouldSuccess) {$.messageBox("Date in range", "success");}
					disableSave(false);
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
			
			$('##VATAmount').tab(function() {
				$('.aifHover:first').click();
			});
			
			$('##Ref').focus();
		});
	</script>
	<div class="aif-headline"></div>
	<div class="aifheaderForm">
		<form method="post" enctype="multipart/form-data" id="RecordEditForm" name="RecordEditFormName">
			<input type="hidden" name="PaymentAccounts" value="" id="REFPayAccounts" />
			<input type="hidden" name="accType" value="#parm.accType#" />
			<input type="hidden" name="accID" value="#parm.accID#" />
			<input type="hidden" name="accNomAcct" value="#parm.accNomAcct#" />
			<input type="hidden" name="trnType" value="" id="TrnTypeID" />
			<input type="hidden" name="trnMethod" value="" />
			<input type="hidden" name="trnClientID" value="0" />
			<input type="hidden" name="trnClientRef" value="" />
			<input type="hidden" name="trnActive" value="1" />
			<table border="1" class="tableList" width="100%">
				<tr>
					<th width="100" align="left">Trans ID</th>
					<td><input type="text" name="trnID" value="#trans.trnID#" id="EditID" disabled="disabled" tabindex="-1">
						<label>
						<input type="checkbox" name="paidCOD" id="paidCOD" value="1" tabindex="-1" 
							title="tick this box to create a payment entry for the same amount." /> Paid cash from till</label>
					</td>
					<th width="100" align="left">Net Amount</th>
					<td><input type="text" name="trnAmnt1" value="#abs(trans.trnAmnt1)#" id="NetAmount" style="text-align:right;" tabindex="11"></td>
				</tr>
				<tr>
					<th width="100" align="left">Trans Date</th>
					<td><input type="text" name="trnDate" class="datepicker" value="#LSDateFormat(trans.trnDate, 'dd/mm/yyyy')#" id="trnDate" tabindex="8"></td>
					<th width="100" align="left" id="hfVATAmntLbl">VAT Amount</th>
					<td><input type="text" name="trnAmnt2" value="#abs(trans.trnAmnt2)#" id="VATAmount" style="text-align:right;" tabindex="12"></td>
				</tr>
				<tr>
					<th width="100" align="left">Trans Ref</th>
					<td><input type="text" name="trnRef" value="#trans.trnRef#" id="Ref" tabindex="9"></td>
					<th width="100" align="left">Gross Total</th>
					<td><input type="text" name="trnTotal" value="#abs(trans.trnAmnt1 + trans.trnAmnt2)#" id="GrossTotal" style="text-align:right;" disabled="disabled" tabindex="13"></td>
				</tr>
				<tr>
					<th width="100" align="left">Description</th>
					<td>
						<input type="text" name="trnDesc" value="#trans.trnDesc#" id="trnDesc" size="50" maxlength="255" tabindex="10" style="float:left;">
					</td>
					<th width="100" align="left">Type</th>
					<td id="Active">
						<select name="tranType" id="HeaderType" tabindex="14" disabled="disabled">
							<option value="inv" <cfif trans.trnType eq "inv">selected="selected"</cfif>>Invoice</option>
							<option value="crn" <cfif trans.trnType eq "crn">selected="selected"</cfif>>Credit Note</option>
							<option value="pay" <cfif trans.trnType eq "pay">selected="selected"</cfif>>Payment</option>
							<option value="rfd" <cfif trans.trnType eq "rfd">selected="selected"</cfif>>Refund</option>
							<option value="jnl" <cfif trans.trnType eq "jnl">selected="selected"</cfif>>Credit Journal</option>
							<option value="dbt" <cfif trans.trnType eq "dbt">selected="selected"</cfif>>Debit Journal</option>
						</select>
						&nbsp; <input type="checkbox" name="trnAlloc" <cfif trans.trnAlloc> checked="checked"</cfif> /> Allocated
					</td>
				</tr>
				<tr id="selPayAcc" <cfif trans.trnType neq "pay" AND trans.trnType neq "rfd">style="display:none;"</cfif>>
					<th colspan="2"></th>
					<th align="left">Fund Source</th>
					<td>
						<select name="paymentAccounts" tabindex="15" id="selPayAccField">
							<option value="null">Select payment...</option>
							<cfloop query="fundList.FundAccts">
								<option value="#nomID#">#nomTitle#</option>
							</cfloop>
						</select>
					</td>
				</tr>
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
							<option value="">Select account to move to...</option>
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
			</table>
		</form>
	</div>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="false">
</cfcatch>
</cftry>