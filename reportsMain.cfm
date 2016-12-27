<!DOCTYPE html>
<html>
<head>
<title>Reports</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
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
		$('#Supplier').change(function(event) {
			$.ajax({
				type: 'POST',
				url: 'suppGetForm.cfm',
			//	data : $('#Supplier').serialize(),
				data : $('#Supplier').serialize()+'&accType='+$('#accType').val(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#supplier-form').html(data);
					$('#loading').fadeOut();
				},
				error:function(data){
					$('#supplier-form').html(data);
					$('#loading').fadeOut();
				}
			});
			event.preventDefault();
		});
		$('.orderOverlayClose').click(function(event) {   
			$("#orderOverlay").fadeOut();
			event.preventDefault();
		});
	});
</script>
</head>

<cfif StructKeyExists(form,"fieldnames")>
	<cfif form.reportID is 1>
		<cfinclude template="tranSummary.cfm">
	<cfelseif form.reportID is 2>
		<cfinclude template="suppTranList.cfm">
	</cfif>
</cfif>
<cfobject component="code/accounts" name="supp">
<cfset parm={}>
<cfset parm.nomType="purch">
<cfset parm.accountID=1>
<cfset parm.datasource=application.site.datasource1>
<cfset list=supp.LoadSuppliers(parm)>
<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post" enctype="multipart/form-data" id="account-form">
						<div id="orderOverlay">
							<div id="orderOverlayForm">
								<a href="##" class="orderOverlayClose">X</a>
								<div id="orderOverlayForm-inner"></div>
							</div>
						</div>
						<div class="form-header">
							Account Reports
							<span><div id="loading"></div></span>
						</div>
						<table border="0" cellpadding="2" cellspacing="0" width="100%">
							<tr>
								<td width="100">Date From</td>
								<td><input type="text" name="dateFrom" size="15" value="01/07/2013" /></td>
							</tr>
							<tr>
								<td width="100">Date To</td>
								<td><input type="text" name="dateTo" size="15" value="30/09/2013" /></td>
							</tr>
							<tr>
								<td width="100">Report</td>
								<td>
									<select name="reportID">
										<option value="">Select Report...</option>
										<option value="1">Transaction Summary</option>
										<option value="2">Supplier Transactions</option>
									</select>
								</td>
							</tr>
							<tr>
								<td width="100">Supplier</td>
								<td>
									<select name="accountID">
										<option value="">Select...</option>
										<cfloop array="#list.suppliers#" index="item">
											<option value="#item.accID#">#item.accName#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td width="100">&nbsp;</td>
								<td><input type="submit" name="btnSend" value="Send" /></td>
							</tr>
						</table>
						<div id="supplier-form"></div>
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
<!---<script type="text/javascript">
	$("#Supplier").chosen({width: "250px",disable_search_threshold: 10});
</script>
--->
</html>


