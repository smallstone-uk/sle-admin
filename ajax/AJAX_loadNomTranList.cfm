<cftry>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/accounts" name="acc">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.url = application.site.normal>
	<cfset parm.form = form>
	<cfset transactions = acc.LoadNominalTransactions(parm)>
	<style type="text/css">
		.shaded { background-color:#ddd; border:#ff0000;}
		.normal { background-color:#fff; border:#ccc;}
		@media print {
			.noPrint {display:none;}
			.tableList {font-size:14px; white-space: nowrap;}
			.description {width:300px;}
			body {
				font-family: serif;
				color: black;
				background-color: white;
			}
		}
	</style>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			var #toScript(parm.form, "formData")#;
			$('.NT_New').click(function(event) {
				$.ajax({
					type: "POST",
					url: "#parm.url#ajax/AJAX_loadNewNominalTransaction.cfm",
					data: {"formData": JSON.stringify(formData)},
					success: function(data) {
						$('.NT_Header, .NT_Items').remove();
						$('.NT_TranList').after(data);
					}
				});
				event.preventDefault();
			});
			$('.nomTranList_editLink').click(function(event) {
				$.ajax({
					type: "POST",
					url: "#parm.url#ajax/AJAX_loadEditNominalTransaction.cfm",
					data: {
						"formData": JSON.stringify(formData),
						"tranID": $(this).html().trim()
					},
					success: function(data) {
						$('.NT_Header, .NT_Items').remove();
						$('.NT_TranList').after(data);
						$('html, body').animate({
							scrollTop: $('.NT_Header').offset().top
						}, 1);
					}
				});
				event.preventDefault();
			});
			$('.delTranRow').click(function(event) {
				var itemID = $(this).attr("data-itemID");
				$.ajax({
					type: "POST",
					url: "#parm.url#ajax/AJAX_deleteNominalTran.cfm",
					data: {"tranID": itemID},
					success: function(data) {
						$('.nomTranMainControl_search').click();
					}
				});
				event.preventDefault();
			});
			if (document.title != "#transactions.nomAccount.nomTitle#") {
				document.title = "#transactions.nomAccount.nomTitle#";
			}
		});
	</script>
	<cfif !ArrayIsEmpty(transactions.tranList)>
		<input value="Export" type="button" class="noPrint" onclick="$('##tranTable').table2CSV({header:['icon','ID','Date','Type','PaidIn','Ref','Description','DR','CR','Balance']})">
		<table id="tranTable" class="tableList" border="1">
			<tr>
				<th class="noPrint"></th>
				<th class="noPrint"></th>
				<th>#transactions.nomAccount.nomCode#</th>
				<th class="noPrint"></th>
				<th colspan="5">#transactions.nomAccount.nomTitle#</th>
			</tr>
			<tr>
				<th width="10" class="noPrint"></th>
				<th width="90" class="noPrint">ID</th>
				<th width="90">Date</th>
				<th width="60" class="noPrint">Type</th>
				<th width="100">Ref</th>
				<th width="400" class="description">Description</th>
				<th width="80" align="right">DR</th>
				<th width="80" align="right">CR</th>
				<th width="80" align="right">Balance</th>
			</tr>
			<cfset balance=transactions.bfwd>
			<cfif balance NEQ 0>
				<tr>
					<td class="noPrint"></td>
					<td class="noPrint"></td>
					<td></td>
					<td class="noPrint"></td>
					<td colspan="4" align="right"><strong>Brought Forward</strong>&nbsp;</td>
					<td align="right"><strong>#DecimalFormat(balance)#</strong></td>
				</tr>
			</cfif>
			<cfset tranCount = 0>
			<cfset drTotal = 0>
			<cfset crTotal = 0>
			<cfset lastDate = -1>
			<cfset changeCounter = 0>
			<cfloop array="#transactions.tranList#" index="item">
				<cfset tranCount++>
				<cfset accID = val(item.trnAccountID)>
				<cfif lastDate neq item.trnDate>
					<cfset changeCounter++>
				</cfif>
				<cfset dayMod = changeCounter MOD 2>
				<cfif dayMod eq 1>
					<cfset rowStyle = "shaded">
				<cfelse>
					<cfset rowStyle = "normal">
				</cfif>
				<cfset lastDate = item.trnDate>

				<tr class="#rowStyle#">
					<td width="10" align="center" class="noPrint">
						<cfif item.trnClientRef GT 0>
							<a href="javascript:void(0)" class="delTranRow" data-itemID="#item.trnID#" tabindex="-1"></a>
						<cfelseif accID IS 0>
							<a href="javascript:void(0)" class="delTranRow" data-itemID="#item.trnID#" tabindex="-1"></a>
						<cfelseif accID IS 3>
							<a href="javascript:void(0)" class="delTranRow" data-itemID="#item.trnID#" tabindex="-1"></a>
						</cfif>
					</td>
					<td align="center" class="noPrint">
						<cfif item.trnClientRef GT 0>
							<a href="javascript:void(0)" class="nomTranList_editLink">#item.trnID#</a>
						<cfelseif accID IS 0>
							<a href="javascript:void(0)" class="nomTranList_editLink">#item.trnID#</a>
						<cfelseif accID IS 3>
							<a href="javascript:void(0)" class="nomTranList_editLink">#item.trnID#</a>
						<cfelseif accID IS 1>
							<a href="#parm.url#salesMain3.cfm?acc=#item.trnAccountID#&tran=#item.trnID#" 
								title="Go to account transaction" target="_newtab">#item.trnID#</a>
						<cfelseif accID GT 1>
							<a href="#parm.url#tranMain2.cfm?acc=#item.trnAccountID#&tran=#item.trnID#" 
								title="Go to account transaction" target="_newtab">#item.trnID#</a>
						</cfif>
					</td>
					<td align="center">#LSDateFormat(item.trnDate, "dd/mm/yyyy")#</td>
					<td align="center" class="noPrint">#item.trnType# &nbsp; #item.trnMethod#</td>
					<td>#item.trnRef# <cfif item.trnClientRef GT 0>#item.trnClientRef#</cfif></td>
					<td>#ReReplace(item.trnDesc,"\d+","")#</td>
					<cfif item.niAmount GT 0>
						<cfset drTotal += item.niAmount>
						<td align="right">#item.niAmount#</td>
						<td></td>
					<cfelse>
						<cfset crTotal += item.niAmount>
						<td></td>
						<td align="right">#item.niAmount#</td>
					</cfif>
					<cfset balance=balance+item.niAmount>
					<td align="right">#DecimalFormat(balance)#</td>
				</tr>
			</cfloop>
			<tr>
				<td class="noPrint"></td>
				<td class="noPrint"></td>
				<td></td>
				<td class="noPrint"></td>
				<td colspan="2">#tranCount# transactions</td>
				<td align="right">#DecimalFormat(drTotal)#</td>
				<td align="right">#DecimalFormat(crTotal)#</td>
				<td></td>
			</tr>
		</table>
	<cfelse>
		<table class="tableList" border="1" width="100%">
			<tr>
				<td>
					No records found.
				</td>
			</tr>
		</table>
	</cfif>
	<div style="padding:5px 0;"></div>
	<button class="NT_New noPrint">New Transaction</button>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>