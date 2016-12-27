<!DOCTYPE html>
<html>
<head>
<title>Accounts</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/accounts.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/tabs.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/checkDates.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
	//	$('#account').change(function(event) {
		$('#btnSearch').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'accountGetForm.cfm',
			//	data : $('#Supplier').serialize(),
				data : $('#account-form').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#tran-form').html(data);
					$('#loading').fadeOut();
				},
				error:function(data){
					$('#tran-form').html(data);
					$('#loading').fadeOut();
				}
			});
			event.preventDefault();
		});
		$('.overlayClose').click(function(event) {   
			$("#overlay").fadeOut();
			$("#overlay-ui").fadeOut();
			event.preventDefault();
		});
	});
</script>
</head>
<cfobject component="code/accounts" name="accts">
<cfset parm={}>
<cfset parm.nomType="">
<cfset parm.datasource=application.site.datasource1>
<cfset acctsList=accts.LoadAccounts(parm)>

<cfoutput>
<body>
<div id="wrapper">
	<cfinclude template="sleHeader.cfm">
	<div id="content">
		<div id="content-inner">
			<div class="form-wrap">
				<form method="post" enctype="multipart/form-data" id="account-form">
					<input type="hidden" name="accType" id="accType" value="#parm.nomType#">
					<div id="overlay-ui"></div>
					<div id="overlay">
						<div id="overlayForm"> <a href="##" class="overlayClose">X</a>
							<div id="overlayForm-inner"></div>
						</div>
					</div>
					<div class="form-header">Account Transactions 
						<span><div id="loading"></div></span>
					</div>
					<table border="0" cellpadding="2" cellspacing="0" width="100%">
						<tr>
							<td align="right">Account</td>
							<td>
								<select name="accountID" data-placeholder="Select..." id="account">
									<option value=""></option>
									<cfloop array="#acctsList.accounts#" index="item">
									<option value="#item.accID#">#item.accName#</option>
									</cfloop>
								</select>
							</td>
							<td align="right">Sort Order</td>
							<td>
								<select name="sortOrder" data-placeholder="Select..." id="sortOrder">
									<option value="date">Transaction Date</option>
									<option value="id">Transaction ID</option>
									<option value="ref">Transaction Ref</option>
								</select>
							</td>
							<td align="right">Records</td>
							<td>
								<select name="rowLimit" data-placeholder="Select..." id="rowLimit">
									<option value="5">5 records</option>
									<option value="10">10 records</option>
									<option value="25">25 records</option>
									<option value="0">All records</option>
								</select>
							</td>
							<td><input type="button" value="Search" id="btnSearch" /></td>
						</tr>
					</table>
					<div id="tran-form"></div>
					<div class="clear"></div>
				</form>
			</div>
			<div class="clear"></div>
		</div>
	</div>
	<cfinclude template="sleFooter.cfm">
</div>
<cfif application.site.showdumps>
	<cfdump var="#session#" label="session" expand="no">
	<cfdump var="#application#" label="application" expand="no">
	<cfdump var="#variables#" label="variables" expand="no">
</cfif>
</body>
</cfoutput>
<script type="text/javascript">
	$("#account").chosen({width: "220px",disable_search_threshold: 10});
</script>
</html>
