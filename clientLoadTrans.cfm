
<!--- 08/06/2025 Process news customer data --->

<cfobject component="code/accounts2" name="acc">
<cfset parm = {}>
<cfset parm.datasource1 = application.site.datasource1>
<cfset parm.form = form>
<cfset trans = acc.LoadTrans(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('#SaveAllocBtn').on('click', function(e) {
			e.preventDefault();
			var autoReload = true;
			var formData = $('#AllocForm').serialize();
			var result = $('#resultContainer');
			var maxCheck = $('#maxTrans').val();
			if (maxCheck > 200)	{
				$(result).html('Too many transactions to allocate. Use the dates to reduce the range.');
				return false;	
			}
			$.ajax({
				type: 'POST',
				url: 'SaveAllocIDs.cfm',
				data: formData,
				success: function(response) {
				//	console.log('Server response:', response);
					if (result) {
						$(result).html(response);
						if (autoReload) {
							$.ajax({
								type: 'POST',
								url: 'clientLoadTrans.cfm',
								data: $("#srchForm").serialize(),
								success: function(result){
									$('#tranResult').html(result);
									$('#loadingDiv').html("").fadeOut();
								}
							});
						}}
				},
				error: function(xhr, status, error) {
					console.error('Error:', error);
					if (result) {
						$(result).html('An error occurred while saving allocation. Check Console.');
					}
				}
			});
		})
		$('.allocs').on('click', function() {
			var index = 0;
			var tranID = $(this).data('id');
			var row = $(this).data('row');
			var assigned = $(this).data('assigned');

			if ($(this).is(':checked')) {
				$('#tick' + row).prop('checked', true);
				if (assigned > 0)	{
					$(this).val(tranID + ',' + assigned);
				} else {
					index = $('#clientIndex').val();
					$(this).val(tranID + ',' + index);
				}
			} else {
				$('#tick' + row).prop('checked', false);
				$(this).val(tranID + ',' + 0);
			}
		//	console.log('row ' + row + ' tranID ' + tranID + ',' + ' index ' + index + ' assigned ' + assigned);
			
			checkTotal();
		});
		$('#tickAll').click(function() {	// toggle all legacy tick boxes
			if ($('#tickAll').prop('checked')) {
				$('.trans').prop('checked', true);
			} else {
				$('.trans').prop('checked', false);
			}
		});
		$('#checkNotIDs').click(function() {	// toggle all new tick boxes
			if ($('#checkNotIDs').prop('checked')) {
				$('.allocs').each(function() {
					var savedAlloc = $(this).data('allocid');
					if (savedAlloc != 0) {
						$(this).prop('checked', true);						
					} else {
						$(this).prop('checked', false);						
					}
				});				
			} else {
				$('.allocs').each(function() {
					var savedAlloc = $(this).data('allocid');
					if (savedAlloc != 0) {
						$(this).prop('checked', true);						
					} else {
						$(this).prop('checked', false);						
					}
				});				
			}
		});
		$('#includeBfwd').click(function() {	// 
			checkTotal();
		});
		$('#checkAll').click(function() {	// toggle all new tick boxes
			if ($('#checkAll').prop('checked')) {
				$('.allocs').prop('checked', true);
			} else {
				$('.allocs').prop('checked', false);
			}
			checkTotal();
		});

		$('#searchNewsTran').on("keyup",function() {
			var srch=$(this).val();
			var hidetotals = false;
			$('.searchrow').each(function() {
				var id=$(this).attr("data-trnID");
				var str=$(this).attr("data-trnRef") + " " + $(this).attr("data-trnDesc");
				
				if (str.toLowerCase().indexOf(srch.toLowerCase()) == -1) {
					$(this).hide();
					hidetotals = true;
				} else {
					$(this).show();
				}
				
			});
			if (hidetotals) $('#pagetotals').hide()
				else $('#pagetotals').show();
		});
	});
</script>
<style type="text/css">
	#SaveAllocBtn {display:none;}
	#total {text-align:right; font-weight:bold; font-size:14px; margin:4px;}
	.tinynum {font-size:10px}
</style>

<cfoutput>
	<cfif StructKeyExists(trans,"msg")>
		#trans.msg#
	<cfelse>
		<cfset allocID = 0>
		<cfset allocCount = trans.cltAllocID>
		<cfset balance = trans.bfwd>
		<cfset totalDebit = 0>
		<cfset totalCredit = 0>
		<cfset rowCount = 0>
		
		<form id="AllocForm">
			<input type="hidden" name="clientID" id="clientID" value="#trans.cltID#" />
			<input type="hidden" name="clientRef" id="clientRef" value="#trans.cltRef#" />
			<input type="hidden" name="cltAllocID" id="cltAllocID" value="#trans.cltAllocID#" />
			<table id="tranTable" class="tableList" border="1">
				<tr class="noPrint">
					<th align="left" colspan="13"><input type="text" id="searchNewsTran" value="" placeholder="Search list" /></th>
				</tr>
				<tr>
					<th width="40">ID</th>
					<th width="40">Reference</th>
					<th width="150">Description</th>
					<th width="120">Date</th>
					<th width="60">Type</th>
					<th width="60">Method</th>
					<th width="50">Paid In</th>
					<th width="80" align="right">Debits<br />(invoices)</th>
					<th width="80" align="right">Credits<br />(payments)</th>
					<th width="80" align="right">Balance</th>
					<th width="50"><input type="checkbox" name="tickAll" id="tickAll" tabindex="-1" title="Toggle checkboxes for the original allocation method." /><br>Alloc</th>
					<th width="70">
						<input type="checkbox" name="checkAll" id="checkAll" tabindex="-1" title="Toggle checkboxes for the new allocation method." />
						<input type="checkbox" name="checkNotIDs" id="checkNotIDs" tabindex="-1" title="De-select only those trans that have not already been assigned an allocation ID." />
						<br>Alloc ID
					</th>
					<th><span title="This is the currently stored Allocation ID.">Saved<br />Alloc</span></th>
				</tr>
				<cfif trans.bfwd neq 0>
					<tr>
						<td colspan="3" height="30"></td>
						<td colspan="6" align="right"><strong>Brought Forward from #DateFormat(trans.args.form.srchDateFrom,'dd-mmm-yyyy')#</strong></td>
						<td align="right"><strong>#DecimalFormat(trans.bfwd)#</strong></td>
						<td>&nbsp;</td>
						<td align="center"><input type="checkbox" name="includeBfwd" id="includeBfwd" tabindex="-1" title="Include this balance when allocating." /></td>
					</tr>
				</cfif>
				<cfloop query="trans.QTrans">
					<cfset rowCount++>
					<tr class="searchrow" data-trnDesc="#trnDesc#" data-trnID="#trnID#" data-trnRef="#trnRef#">
						<td>#trnID#</td>
						<td>#trnRef#</td>
						<td><span class="tinynum">#rowCount# - </span>#trnDesc#</td>
						<td>#DateFormat(trnDate,"dd-mmm-yyyy")#</td>
						<td>#acc.trantype(trnType)#</td>
						<td class="centre"><cfif trnMethod eq "sv">VOUCHERS<cfelse>#trnMethod#</cfif></td>
						<td class="centre">#trnPaidin#</td>
						<cfset gross = trnAmnt1 + trnAmnt2>
						<cfset balance += gross>
						<cfif gross gt 0>
							<cfset totalDebit += gross>
							<td align="right">#DecimalFormat(gross)#</td>
							<td></td>
						<cfelse>
							<cfset totalCredit += gross>
							<td></td>
							<td align="right" style="color:##FF0000">#DecimalFormat(gross)#</td>
						</cfif>
						<td align="right">#DecimalFormat(balance)#</td>
						<cfif trnAllocID eq 0 AND trnAlloc>
							<cfif DecimalFormat(balance) eq 0>
								<cfset allocID = allocCount>
								<cfset allocCount++>
							<cfelse>
								<cfset allocID = allocCount>
							</cfif>
						<cfelse>
							<cfset allocID = trnAllocID>
						</cfif>
						<cfset rowNo = NumberFormat(currentrow,'00')>
						<td class="centre">
							#trnAlloc#
							<input type="checkbox" name="tick#rowNo#" id="tick#rowNo#" class="trans" tabindex="-1" value="#trnID#"<cfif trnAlloc> checked="checked"</cfif> />
						</td>
						<td class="centre">
							<input type="hidden" name="trnID#rowNo#" class="IDs" value="#trnID#" />
							<input type="hidden" name="amnt#rowNo#" id="amnt#rowNo#" class="amounts" value="#trnAmnt1#" />
							<input type="checkbox" name="alloc#rowNo#" id="alloc#rowNo#" class="allocs" tabindex="-1" value="#trnID#,#allocID#"
								data-allocid="#trnAllocID#" data-id="#trnID#" data-row="#rowNo#" data-amount="#trnAmnt1#" data-assigned="#allocID#"<cfif allocID> checked="checked"</cfif> />
							#allocID#
						</td>
						<td class="centre">#trnAllocID#</td>
					</tr>
				</cfloop>
			<tr>
				<td colspan="9">#trans.tranCount# Transactions.</td>
				<td><input name="total" id="total" type="text" size="6" value="0.00" tabindex="-1" disabled="disabled" /></td>
				<td colspan="2"></td>
				<td><button id="SaveAllocBtn">Save Allocation</button></td>
			</tr>
			</table>	
			<input type="hidden" size="4" name="clientIndex" id="clientIndex" value="#allocCount#" />
			<input type="hidden" size="4" name="maxTrans" id="maxTrans" value="#trans.tranCount#" />
			<input type="hidden" size="4" name="bfwd" id="bfwd" value="#trans.bfwd#" />
		</form>
	</cfif>
	<div id="resultContainer"></div>
</cfoutput>
