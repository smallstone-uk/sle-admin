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
					var total = 0;
					var amount = 0;
					if (this.checked) {
						$('.selectitem').prop({checked: true});
						$('.selectAllOnList').prop({checked: true});
	
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
						$('.amountAllocatedTotal').html(nf(total, "str"));
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
				if (document.title != "#acctData.Account.accName#") {
					document.title = "#acctData.Account.accName#";
				};
				$('##tranSearch').on("keyup",function() {
					var srch=$(this).val();
					$('.searchrow').each(function() {
						var id=$(this).attr("data-tranID");
						var str=$(this).attr("data-title");
						if (str.toLowerCase().indexOf(srch.toLowerCase()) == -1) {
							$(this).hide();
						} else {
							$(this).show();
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
						<th align="right">Date</th>
						<th>Type</th>
						<th align="left">Ref</th>
						<th align="left">Description</th>
						<th align="right" width="70">Net</th>
						<th align="right" width="70">VAT/<br />Disc</th>
						<th align="right" width="70">Gross</th>
						<th align="right" width="70">Balance</th>
						<th class="center">Allocated<br>
							<span class="noPrint"><input type="checkbox" name="selectAllOnList" class="selectAllOnList" tabindex="-1" style="width:20px; height:20px;"></span>
						</th>
					</tr>
					<tr class="noPrint">
						<th></th>
						<th colspan="3" align="right">Search</th>
						<th colspan="2" align="left"><input type="text" id="tranSearch" value="" placeholder="Search..." tabindex="-1" style="width:80%;"></th>
						<th colspan="5"></th>
					</tr>
					<cfset balance=trans.bfwd>
					<cfif balance NEQ 0>
						<tr><td width="10" class="noPrint"></td>
							<td colspan="8" align="right"><strong>Brought Forward</strong>&nbsp;</td>
							<td align="right"><strong>#DecimalFormat(balance)#</strong></td>
							<td align="center" class="noPrint"><input type="checkbox" name="selectitem" class="selectitem" data-amount="#val(balance)#" tabindex="-1" value="0" /></td>
						</tr>
					</cfif>
					<cfif StructKeyExists(trans,"allocError")>
						<tr><td colspan="9" align="right"><strong>Allocation Error</strong>&nbsp;</td>
							<td align="right"><strong>#DecimalFormat(trans.allocError)#</strong></td>
						</tr>
					</cfif>
					<cfset totAmnt1 = balance>
					<cfset totAmnt2 = 0>
					<cfset weekTotals = {}>
					<cfloop array="#trans.tranList#" index="item">
						<cfset totAmnt1 += val(item.trnAmnt1)>
						<cfset totAmnt2 += val(item.trnAmnt2)>
						<cfset invGross = val(item.trnAmnt1) + val(item.trnAmnt2)>
						<cfset amountClass="amount">
						<cfset weekNo = Year(item.trnDate) * 100 + Week(item.trnDate)>
						<cfif ListFind('inv,crn',item.trnType,',')>
							<cfif StructKeyExists(weekTotals,weekNo)>
								<cfset thisWeek = StructFind(weekTotals,weekNo)>
								<cfset thisWeek.total += invGross>
							<cfelse>
								<cfset StructInsert(weekTotals,weekNo,{"Date" = item.trnDate, "total" = invGross})>
							</cfif>
						</cfif>
						<cfif ListFind("crn,pay,jnl",item.trnType,",")><cfset amountClass="creditAmount"></cfif>
						<tr class="searchrow" data-title="#item.trnRef# #item.trnDesc# #item.trnAmnt1#" data-tranID="#item.trnID#" id="trnItem_#item.trnID#">
						<!---<tr id="trnItem_#item.trnID#">--->
							<td class="noPrint"><a href="javascript:void(0)" class="delTranRow" data-itemID="#item.trnID#" data-accType="#acctData.Account.accType#" tabindex="-1"></a></td>
							<td id="trnItem_ID"><a href="javascript:void(0)" class="trnIDLink" data-id="#item.trnID#" data-type="#item.trnType#" tabindex="-1">#item.trnID#</a></td>
							<td id="trnItem_Date" align="right">#LSDateFormat(item.trnDate,"ddd dd/mm/yy")#</td>
							<td id="trnItem_Type" align="center">#item.trnType#</td>
							<td id="trnItem_Ref">#item.trnRef#</td>
							<td id="trnItem_Desc">#item.trnDesc#</td>
							<td id="trnItem_Amount1" class="#amountClass#">#DecimalFormat(val(item.trnAmnt1))#</td>
							<td id="trnItem_Amount2" class="#amountClass#">#DecimalFormat(val(item.trnAmnt2))#</td>
							<td id="trnItem_Amount3" class="#amountClass#">#DecimalFormat(val(item.trnAmnt1) + val(item.trnAmnt2))#</td>
							<td id="trnItem_Balance" class="#amountClass#">#DecimalFormat(totAmnt1 + totAmnt2)#</td>
							<td id="trnItem_Alloc" align="center">
								<span class="noPrint">
									<input type="checkbox" name="selectitem" class="selectitem" tabindex="-1" data-amount="#val(item.trnAmnt1) + val(item.trnAmnt2)#" 
										value="#item.trnID#"<cfif item.trnAlloc is 1> checked="checked" disabled="disabled"</cfif> />
								</span>
								<cfif item.trnAllocID gt 0>
									<a href="purchRemittancePDF.cfm?accountID=#acctData.Account.accID#&amp;allocationID=#item.trnAllocID#" tabindex="-1" target="_blank">#item.trnAllocID#</a>
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
				<!---<cfdump var="#weekTotals#" label="weekTotals" expand="false">--->
				<table width="300">
					<tr>
						<td colspan="2"><h2>Summary</h2></td>
					</tr>
					<cfset grossTotal = 0>
					<cfset keys = ListSort(StructKeyList(weekTotals,","),"numeric")>
					<cfset keyCount = ListLen(keys)>
					<cfif keyCount gt 0>
						<cfloop list="#keys#" delimiters="," index="item">
							<cfset thisWeek = StructFind(weekTotals,item)>
							<cfset grossTotal += thisWeek.total>
							<tr>
								<td align="right">#DateFormat(thisWeek.date,'ddd dd-mmm-yy')#</td>
								<td align="right">#DecimalFormat(thisWeek.total)#</td>
							</tr>
						</cfloop>
						<tr>
							<td align="right">Total</td>
							<td align="right">#DecimalFormat(grossTotal)#</td>
						</tr>
						<tr>
							<td align="right">Average (#keyCount#)</td>
							<td align="right">#DecimalFormat(grossTotal / keyCount)#</td>
						</tr>
					</cfif>
				</table>
				<!--- <button type="button" onclick="tableToCSV()">download CSV</button>--->
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
