<!DOCTYPE html>
<html>
<head>
<title>Sales</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/accounts.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/tabs.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.11.1.min.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/checkDates.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
		getForm = function() {
			$.ajax({
				type: 'POST',
				url: 'salesGetForm3.cfm',
				data: $('#account-form').serialize(),
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
		}
		$('#Supplier').change(function(event) {
			getForm();
			event.preventDefault();
		});
		$('.orderOverlayClose').click(function(event) {   
			$("#orderOverlay").fadeOut();
			$("#orderOverlay-ui").fadeOut();
			event.preventDefault();
		});
	});
</script>
</head>

<cftry>
<cfobject component="code/accounts3" name="sales">
<cfset parm={}>
<cfset parm.nomType="sales">
<cfset parm.accID=1>
<cfset parm.datasource=application.site.datasource1>
<cfset acctsList=sales.LoadAccounts(parm)>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post" enctype="multipart/form-data" id="account-form">
						
						<cfif StructKeyExists(url, "acc") AND StructKeyExists(url, "tran")>
							<input type="hidden" name="preTranID" value="#url.tran#">
						<cfelse>
							<input type="hidden" name="preTranID" value="0">
						</cfif>
						
						<input type="hidden" name="ForceInt" id="ForceInt" value="0">
						<input type="hidden" name="accType" id="accType" value="#parm.nomType#">
						<div id="orderOverlay-ui"></div>
<div id="orderOverlay">
							<div id="orderOverlayForm">
								<a href="##" class="orderOverlayClose">X</a>
								<div id="orderOverlayForm-inner"></div>
							</div>
						</div>
						<div class="form-header">
							Sales Accounts
							<span><div id="loading"></div></span>
						</div>
						<table border="0" cellpadding="2" cellspacing="0" width="100%">
							<!---<tr>
								<th width="100" align="left">Trans Date</th>
								<td><input type="text" name="trnDate" value="" id="trnDate" tabindex="3"></td>
							</tr>--->
							<tr>
								<td width="100">Sales Account</td>
								<td>
									<select name="accID" data-placeholder="Select..." id="Supplier">
										<option value=""></option>
										<cfloop array="#acctsList.accounts#" index="item">
											<option value="#item.accID#" <cfif StructKeyExists(url, "acc") AND StructKeyExists(url, "tran") AND val(item.accID) is val(url.acc)>selected="true"</cfif>>#item.accName#</option>
										</cfloop>
									</select>
									<cfif StructKeyExists(url, "acc") AND StructKeyExists(url, "tran")>
										<script>
											$(document).ready(function(e) {
												getForm();
											});
										</script>
									</cfif>
								</td>
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
<script type="text/javascript">
	$("#Supplier").chosen({width: "250px",disable_search_threshold: 10});
</script>
</html>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
