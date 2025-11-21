<cftry>
<cfobject component="code/accounts" name="acc">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.form = DeserializeJSON(formData)>
<cfset nominal_accounts = acc.LoadNominalAccounts2(parm)>

<cfoutput>
	<div class='module NT_Header'>
		<script>
			$(document).ready(function(e) {
				var shouldSuccess = false;
				$('.datepicker').blur(function(event) {
					var value = $(this).val();
					var isOk = checkDate(value, true);
					if (!isOk) {
						$.messageBox("Date out of range", "error");
						shouldSuccess = true;
					} else {
						if (value.length > 0) {
							$(this).val(isOk);
							if (shouldSuccess) $.messageBox("Date in range", "success");
						}
					}
				});
			});
		</script>
		<table class="tableList" border="1" width="100%">
			<tr>
				<th align="left">Trans ID</th>
				<td><input type="text" name="tranID" disabled="disabled" tabindex="1" /></td>
				
				<th align="left">Net Amount</th>
				<td><input type="text" name="tranNetAmnt" tabindex="5" /></td>
			</tr>
			<tr>
				<th align="left">Trans Date</th>
				<td><input type="text" name="tranDate" class="datepicker" tabindex="2" /></td>
				<th align="left">VAT Amount</th>
				<td><input type="text" name="tranVATAmnt" tabindex="6" /></td>
			</tr>
			<tr>
				<th align="left">Trans Ref</th>
				<td><input type="text" name="tranRef" tabindex="3" /></td>
				<th align="left">Gross Total</th>
				<td><input type="text" name="tranGrossTotal" tabindex="7" /></td>
			</tr>
			<tr>
				<th align="left">Description</th>
				<td colspan="3"><input type="text" name="tranDesc" style="width:100%;padding:4px 0;text-indent:4px;" tabindex="4" /></td>
			</tr>
		</table>
	</div>
	<div class="module NT_Items">
		<script>
			$(document).ready(function(e) {
				$(document).on("change", ".nomAmntCell", function(event) {
					var pos = $(this).data("pos");
					var value= $(this).val();
					if (value.length > 0) {
						if (pos == "left") {
							$(this).parents('tr').find('.nomAmntCell[data-pos="right"]').prop("disabled", true);
						} else {
							$(this).parents('tr').find('.nomAmntCell[data-pos="left"]').prop("disabled", true);
						}
					} else {
						$(this).parents('tr').find('.nomAmntCell').prop("disabled", false);
					}
				});
				
				$('.createItem').click(function(event) {
					var static = $('.staticItem').html();
					$(this).parent('tr').before("<tr class='dynamicItem'>" + static + "</tr>");
				});
				
				debitTotal = function() {
					var total = 0;
					$('.nomAmntCell[data-pos="left"]').each(function(i, e) {
						total += nf($(e).val(), "num");
					});
					return total;
				}
				
				creditTotal = function() {
					var total = 0;
					$('.nomAmntCell[data-pos="right"]').each(function(i, e) {
						total += nf($(e).val(), "num");
					});
					return total;
				}
				
				writeTotals = function() {
					$('.debitTotal').html(nf(debitTotal(), "str"));
					$('.creditTotal').html(nf(creditTotal(), "str"));
				}
				
				$(document).on("keyup", ".nomAmntCell", function(event) {
					writeTotals();
				});
				
				$('.nomSaveBtn').click(function(event) {
					var formData = {
						header: {
							tranID: $('input[name="tranID"]').val(),
							netAmount: nf($('input[name="tranNetAmnt"]').val(), "num"),
							tranDate: $('input[name="tranDate"]').val(),
							tranVAT: nf($('input[name="tranVATAmnt"]').val(), "num"),
							tranRef: $('input[name="tranRef"]').val(),
							tranGross:	nf($('input[name="tranGrossTotal"]').val(), "num"),
							tranDesc: $('input[name="tranDesc"]').val(),
							tranAccountID: parseInt("#parm.form.nominal_account#")
						},
						items: []
					};
					
					$('.dynamicItem').each(function(i, e) {
						formData.items.push({
							account: $(e).find('.nomAccountSel').val(),
							debit: nf($(e).find('.nomAmntCell[data-pos="left"]').val(), "num"),
							credit: nf($(e).find('.nomAmntCell[data-pos="right"]').val(), "num")
						});
					});
					
					$.ajax({
						type: "POST",
						url: "#parm.url#ajax/AJAX_saveNomTran.cfm",
						data: {"formData": JSON.stringify(formData)},
						success: function(data) {
							$.messageBox("Transaction Saved", "success");
						}
					});
					
					event.preventDefault();
				});
			});
		</script>

		<table class="tableList" border="1" width="100%">
			<tr>
				<th width="10"></th>
				<th align="left">Account</th>
				<th width="100" align="right">Debit</th>
				<th width="100" align="right">Credit</th>
			</tr>
			<tr class="staticItem" style="display:none;">
				<td>
					<a href="javascript:void(0)" onclick="javascript:$(this).parents('tr').remove();writeTotals();" 
						class="delRow" tabindex="-1" title="Delete Row"></a>
				</td>
				<td>
					<select name="nomAccount" class="nomAccountSel">
						<cfset groupTitle = "">
						<cfloop query="nominal_accounts.QNomList">
							<cfif groupTitle neq ngTitle>
								<option disabled="disabled" class="optiondisabled">#nomGroup# - #ngTitle#</option>
							</cfif>
							<option value="#nomID#">#nomTitle# - #nomCode#</option>
							<cfset groupTitle = ngTitle>
						</cfloop>
					</select>
					<!--- #n.nomGroup# - #n.nomCode# - #n.nomTitle# - #n.ngiOrder# #i.nomCode# - #i.nomTitle#--->
				</td>
				<td class="nomAmntCell_wrap">
					<input type="text" name="nomDebit" class="nomAmntCell" data-pos="left" style="text-align:right;" />
				</td>
				<td class="nomAmntCell_wrap">
					<input type="text" name="nomCredit" class="nomAmntCell" data-pos="right" style="text-align:right;" />
				</td>
			</tr>
			<tr style="height:25px;">
				<td class="createItem" colspan="4">Click to add row</td>
			</tr>
			<tr>
				<th colspan="2" align="right">Total</th>
				<td class="debitTotal" align="right" style="font-weight:bold;">0.00</td>
				<td class="creditTotal" align="right" style="font-weight:bold;">0.00</td>
			</tr>
		</table>
		<div style="padding:5px 0;"></div>
		<button class="nomSaveBtn">Save Transaction</button>
	</div>
</cfoutput>

	<cfcatch type="any">
		<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
	</cfcatch>
</cftry>