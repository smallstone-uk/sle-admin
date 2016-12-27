<!DOCTYPE html>
<html>
<head>
<title>Nominal Totals Dump (Dev)</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/main4.css" rel="stylesheet" type="text/css">
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
<script src="scripts/accounts.js" type="text/javascript"></script>
<script src="scripts/checkDates.js"></script>
<script src="scripts/main.js"></script>
</head>

<cfobject component="code/accounts" name="accts">
<cfset parm = {}>
<cfset parm.nomType = "">
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset nominals = accts.LoadNominalCodes(parm)>

<cfoutput>
	<script>
		$(document).ready(function() {
			$('##nomTotForm').submit(function(event) {
				$.ajax({
					type: "POST",
					url: "#parm.url#ajax/AJAX_loadNominalTotalsDump.cfm",
					data: $('##nomTotForm').serialize(),
					beforeSend: function() {
						$('##loading').loading(true);
					},
					success: function(data) {
						$('##loading').loading(false);
						$('##totals-list').html(data).show();
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
					<form method="post" enctype="multipart/form-data" id="nomTotForm">
						<div class="form-header" id="tranMainHeader">
							Nominal Totals Dump (Dev)
							<span><div id="loading"></div></span>
						</div>
						<div class="module" id="tranMainFilters">
							<table border="0" cellpadding="2" cellspacing="0" width="100%">
								<tr>
									<td align="right">Nominal</td>
									<td>
										<select name="nomID" class="nom">
											<cfset keys = ListSort(StructKeyList(nominals, ","), "text", "asc", ",")>
											<cfloop list="#keys#" index="key">
												<cfset nom = StructFind(nominals, key)>
												<option value="#nom.nomID#">#nom.nomCode# - #nom.nomTitle#</option>
											</cfloop>
										</select>
									</td>
									<td><input type="submit" value="Build" id="btnBuild" /></td>
								</tr>
							</table>
						</div>
					</form>
					<div id="totals-list" class="module" style="display:none;"></div>
					<div class="clear"></div>
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
</html>
