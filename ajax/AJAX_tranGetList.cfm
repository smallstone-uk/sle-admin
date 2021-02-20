<!---WORKING VERSION AS OF 18/08/2014--->
<cftry>
	<cfobject component="code/accounts" name="accts">
	<cfsetting showdebugoutput="no">
	<cfset callback = 1>
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.form = form>
	<cfset parm.nomType = "">
	<cfset parm.rowLimit = 10>
	<cfset parm.url = application.site.normal>
	<cfset acctData = accts.LoadAccount(parm)>
	<cfset parm.account = acctData.account>
	<cfif StructKeyExists(acctData.account, "accID") gt 0>
		<cfset trans = accts.LoadTransactionList(parm)>
		<!---<cfdump var="#trans#" label="trans" expand="no">--->
		<cfoutput>
			<script>
				$(document).ready(function(e) {
					$('##account')
						.find('option[value="#parm.account.accID#"]').prop('selected', true)
						.end().trigger('chosen:updated');
					var #ToScript(parm.form, "jForm")#;
					$('.trnIDLink').click(function(event) {
						var row = $('##trnItem_' + $(this).attr("data-id"));
						var id = row.find('##trnItem_ID').find('a').html();
						$.ajax({
							type: "POST",
							url: "#parm.url#ajax/AJAX_loadTranHeaderForm.cfm",
							data: {
								"tranID": id,
								"accType": "#acctData.Account.accType#",
								"accID": "#parm.account.accID#",
								"accNomAcct": "#parm.account.accNomAcct#",
								"jForm": JSON.stringify(jForm)
							},
							beforeSend:function() {
								$('##loading').loading(true);
							},
							success: function(data) {
								$('##tran-form').html(data).show();
								$('.aif-headline').show();
								$('##loading').loading(false);
							}
						});
						event.preventDefault();
					});
					$('.delTranRow').click(function(event) {
						var tranID = $(this).attr("data-itemID");
						$.confirmation({
							accept: function() {
								$.ajax({
									type: "POST",
									url: "#parm.url#ajax/AJAX_deleteAccountTransRecord.cfm",
									data: {
										"tranID": tranID,
										"accNomAcct": "#parm.account.accNomAcct#"
									},
									beforeSend: function() {
										$('##loading').loading(true);
									},
									success: function(data) {
										$.messageBox("Transaction " + tranID + " Deleted", "success");
										$('##trnItem_' + tranID).remove();
										$('##loading').loading(false);
										$('##tran-form').html("").hide();
										$('##tran-items').html("").hide();
										$('##account-form').submit();
									}
								});
							},
							decline: function() {
								$.messageBox("Deletion Cancelled", "error");
							}
						});
						event.preventDefault();
					});
					$('.pencil_edit').click(function(event) {
						var accCode = $(this).attr("data-code");
						$.popupDialog({
							file: "AJAX_loadEditAccountForm",
							data: {"accCode": accCode},
							width: 350
						});
						event.preventDefault();
					});
					$('.selectitem').click(function(e) {
						var total = 0;
						var amount = 0;
						$('.selectitem').each(function() {
							if (this.checked) {
								var id = $(this).val();
								amount = Number($(this).attr("data-amount"));
								total = +(total + amount).toFixed(2);
							}
							console.log("value " + amount + " ntotal " + total);
						});
						
						// Display total
						$('.amountAllocatedTotal').html(nf(total, "str"));
						
						if (total.toFixed(2) == 0) {
							$('##btnAllocItems').show();
						} else {
							$('##btnAllocItems').hide();
						}
					});
					$('##btnAllocItems').click(function(event) {
						var array = [];
						
						$('.selectitem').each(function(i, e) {
							if ($(e).prop("checked")) {
								array.push({
									amount: $(e).data("amount"),
									id: $(e).val()
								});
							}
						});
						
						$.ajax({
							type: "POST",
							url: "#parm.url#ajax/AJAX_allocTranItems.cfm",
							data: {
								"data": JSON.stringify(array),
								"accID": "#parm.account.accID#"
							},
							beforeSend: function() {},
							success: function(data) {
								$.messageBox("Items Allocated", "success");
								$('##account-form').submit();
							}
						});
						event.preventDefault();
					});
				});
				$('.selectAllOnList').click(function(event) {
					if (this.checked) {
						$('.selectitem').prop({checked: true});
						$('.selectAllOnList').prop({checked: true});
	
						var total = 0;
						var amount = 0;
						$('.selectitem').each(function() {
							if (this.checked) {
								var id = $(this).val();
								amount = Number($(this).attr("data-amount"));
								total = +(total + amount).toFixed(2);
							}
							console.log("value " + amount + " ntotal " + total);
						});
						
						// Display total
						$('.amountAllocatedTotal').html(nf(total, "str"));
						
						if (total.toFixed(2) == 0) {
							$('##btnAllocItems').show();
						} else {
							$('##btnAllocItems').hide();
						}
	
					} else {
						$('.selectitem').prop({checked: false});
						$('.selectAllOnList').prop({checked: false});
					}
				});
				$('.selectitem').click(function(event) {
					$('.selectAllOnList').prop({checked: true});
					$('.selectitem').each(function(i, e) {
						if (!$(e).prop("checked")) {
							$('.selectAllOnList').prop({checked: false});
						}
					});
				});
			</script>
			<table border="1" class="tableList" width="100%">
				<tr>
					<td width="10"><a href="javascript:void(0)" class="pencil_edit" data-code="#acctData.Account.accCode#" tabindex="-1"></a></td>
					<th width="60" align="left">Acct Code</th>
					<td>#acctData.Account.accCode#</td>
					<th width="40" align="left">Name</th>
					<td>#acctData.Account.accName#</td>
					<th width="40" align="right">Type</th>
					<td>#acctData.Account.accType#</td>
					<th width="40" align="right">Group</th>
					<td>#acctData.Account.accGroup#</td>
					<td align="center">#acctData.Account.BalAccCode#</td>
					<td align="center">#acctData.Account.PayAccNomCode#</td>
				</tr>
			</table>
			<div style="padding:5px 0;"></div>
			<cfif ArrayLen(trans.tranList)>
				<table border="1" class="tableList" width="100%" id="tranListTable">
					<tr>
						<th width="10" class="noPrint"></th>
						<th align="left">ID</th>
						<th align="right" width="100">Date</th>
						<th>Type</th>
						<th align="left">Ref</th>
						<th align="left">Description</th>
						<th align="right">Net</th>
						<th align="right">VAT/<br />Disc</th>
						<th align="right">Gross</th>
						<th align="right">Balance</th>
						<th class="center">Allocated<br>
							<span class="noPrint"><input type="checkbox" name="selectAllOnList" class="selectAllOnList" style="width:20px; height:20px;"></span>
						</th>
					</tr>
					<cfset balance=trans.bfwd>
					<cfif balance NEQ 0>
						<tr><td width="10" class="noPrint"></td>
							<td colspan="8" align="right"><strong>Brought Forward</strong>&nbsp;</td>
							<td align="right"><strong>#DecimalFormat(balance)#</strong></td>
							<td align="center" class="noPrint"><input type="checkbox" name="selectitem" class="selectitem" data-amount="#val(balance)#" value="0" /></td>
						</tr>
					</cfif>
					<cfif StructKeyExists(trans,"allocError")>
						<tr><td colspan="9" align="right"><strong>Allocation Error</strong>&nbsp;</td>
							<td align="right"><strong>#DecimalFormat(trans.allocError)#</strong></td>
						</tr>
					</cfif>
					<cfset totAmnt1 = balance>
					<cfset totAmnt2 = 0>
					<cfloop array="#trans.tranList#" index="item">
						<cfset totAmnt1 += val(item.trnAmnt1)>
						<cfset totAmnt2 += val(item.trnAmnt2)>
						<cfset amountClass="amount">
						<cfif ListFind("crn,pay,jnl",item.trnType,",")><cfset amountClass="creditAmount"></cfif>
						<tr id="trnItem_#item.trnID#">
							<td class="noPrint"><a href="javascript:void(0)" class="delTranRow" data-itemID="#item.trnID#" data-accType="#acctData.Account.accType#" tabindex="-1"></a></td>
							<td id="trnItem_ID"><a href="javascript:void(0)" class="trnIDLink" data-id="#item.trnID#" data-type="#item.trnType#" tabindex="-1">#item.trnID#</a></td>
							<td id="trnItem_Date" align="right">#LSDateFormat(item.trnDate,"ddd dd/mm/yyyy")#</td>
							<td id="trnItem_Type" align="center">#item.trnType#</td>
							<td id="trnItem_Ref">#item.trnRef#</td>
							<td id="trnItem_Desc">#item.trnDesc#</td>
							<td id="trnItem_Amount1" class="#amountClass#">#DecimalFormat(val(item.trnAmnt1))#</td>
							<td id="trnItem_Amount2" class="#amountClass#">#DecimalFormat(val(item.trnAmnt2))#</td>
							<td id="trnItem_Amount3" class="#amountClass#">#DecimalFormat(val(item.trnAmnt1) + val(item.trnAmnt2))#</td>
							<td id="trnItem_Balance" class="#amountClass#">#DecimalFormat(totAmnt1 + totAmnt2)#</td>
							<td id="trnItem_Alloc" align="center">
								<span class="noPrint">
									<input type="checkbox" name="selectitem" class="selectitem" data-amount="#val(item.trnAmnt1) + val(item.trnAmnt2)#" 
										value="#item.trnID#"<cfif item.trnAlloc is 1> checked="checked" disabled="disabled"</cfif> />
								</span>
								<cfif item.trnAllocID gt 0>
									<a href="purchRemittancePDF.cfm?accountID=#acctData.Account.accID#&amp;allocationID=#item.trnAllocID#" target="_blank">#item.trnAllocID#</a>
								</cfif>
							</td>
						</tr>
					</cfloop>
					<tr>
						<td colspan="6">#trans.rowCount# records.</td>
						<td class="amountTotal">#DecimalFormat(totAmnt1)#</td>
						<td class="amountTotal">#DecimalFormat(totAmnt2)#</td>
						<td class="amountTotal">#DecimalFormat(totAmnt1 + totAmnt2)#</td>
						<td class="amountAllocatedTotal noPrint" style="font-weight:bold;" align="right"></td>
						<td class="noPrint"><a href="javascript:void(0)" id="btnAllocItems" class="button" style="display:none;">Allocate</a></td>
					</tr>
					<tr>
						<td colspan="5"></td>
						<td colspan="3" align="right">Page Total</td>
						<td>#DecimalFormat(totAmnt1+totAmnt2-balance)#</td>
						<td colspan="2" class="noPrint"></td>
				</table>
			<cfelse>
				No records.
			</cfif>
		</cfoutput>
	<cfelse>
		<table border="1" class="tableList" width="100%">
			<tr>
				<td>No account found. Please select an account from the pop-up menu or enter an existing transaction ID or reference.</td>
			</tr>
		</table>
	</cfif>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
