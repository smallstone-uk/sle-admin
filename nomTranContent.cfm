<cftry>
	<cfobject component="code/accounts" name="acc">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.url = application.site.normal>
	<cfset nomAccounts = acc.LoadNominalAccounts(parm)>
	
	<cfoutput>
		<script>
			$(document).ready(function(e) {
				$('.NTSF_Account').chosen({
					width: "270px",
					disable_search_threshold: 10
				});
				$('##NomTranSrchForm').submit(function(event) {
					$.ajax({
						type: "POST",
						url: "#parm.url#ajax/AJAX_loadNomTranList.cfm",
						data: $(this).serialize(),
						success: function(data) {
							$('.NT_TranList').html(data).show();
						}
					});
					event.preventDefault();
				});
				
			});
		</script>
		<div class="module noPrint">
			<h1>Nominal Transactions</h1>
			<form method="post" enctype="multipart/form-data" id="NomTranSrchForm">		
				Account
				<select name="nominal_account" class="NTSF_Account">
					<cfloop array="#nomAccounts#" index="item">
						<option value="#item.nomID#">#item.nomCode# - #item.nomGroup# - #item.nomTitle#</option>
					</cfloop>
				</select>			
				&nbsp;&nbsp;Reference			
				<input type="text" name="nominal_ref" class="NFSF_Ref" placeholder="Ref" style="width:50px;">			
				&nbsp;&nbsp;Sort By
				<select name="sortOrder" class="NTSF_Sort">
					<option value="1">Transaction Date</option>
					<option value="2">Transaction ID</option>
					<option value="3">Transaction Ref</option>
				</select>
				&nbsp;&nbsp;Records
				<select name="srchRange" data-placeholder="Select..." id="srchRange">
					#acc.DateRangeOptions()#
				</select>
				<label>
					<input type="checkbox" name="nominal_alloc" value="1" checked="checked" style="display:none;">
				</label>
				<input type="submit" name="nominal_submit" style="float:right;" value="Search" class="nomTranMainControl_search">
			</form>
		</div>
		<div class="module NT_TranList" style="display:none;"></div>
	</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>