<!DOCTYPE html>
<html>
<head>
<title>Wipe Nominal Totals</title>
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
		$(".srchNom").chosen({width: "300px"});
	});
</script>
</head>
<cftry>

<cfparam name="srchNom" default="">

<cfobject component="code/accounts" name="acc">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>

<cfobject component="code/purchase" name="pur">
<cfset parms={}>
<cfset parms.datasource=application.site.datasource1>
<cfset nominals=pur.LoadNominalCodes(parms)>

<cfoutput>
	<script>
		$(document).ready(function() {
			$('##wipeTotalsForm').submit(function(event) {
				$.ajax({
					type: "POST",
					url: "#parm.url#ajax/AJAX_wipeNominalTotals.cfm",
					data: $('##wipeTotalsForm').serialize(),
					beforeSend: function() {
						$('.wipe-totals-callback').html("Please wait...");
					},
					success: function(data) {
						$('.wipe-totals-callback').html(data);
					},
					error: function(e) {
						$('.wipe-totals-callback').html(e);
					}
				});
				event.preventDefault();
			});
		});
	</script>
	<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post" enctype="multipart/form-data" id="wipeTotalsForm">
						<div class="form-header">
							Wipe Nominal Totals
							<span><div id="loading"></div></span>
						</div>
						<table border="0" cellpadding="2" cellspacing="0" width="100%">
							<tr>
								<td><b>Nominal Account</b></td>
								<td>
									<select name="srchNom" class="srchNom" multiple="multiple" data-placeholder="Select...">
										<option value="">Select...</option>
										<cfset keys=ListSort(StructKeyList(nominals.codes,","),"text","asc",",")>
										<cfloop list="#keys#" index="key">
											<cfset nom=StructFind(nominals.codes,key)>
											<option value="#nom.nomID#"<cfif nom.nomID is srchNom> selected="selected"</cfif>>#nom.nomCode# - #nom.nomTitle#</option>
										</cfloop>
									</select>							
								</td>
							</tr>
							<tr>
								<td align="right">Trigger Keyword</td>
								<td>
									<input type="text" name="TriggerKeyword" placeholder="Hint: How do you turn a car's engine on?" style="width:250px;" />
								</td>
								<td><input type="submit" value="Fire" /></td>
							</tr>
						</table>
						<div class="wipe-totals-callback"></div>
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

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
</html>
