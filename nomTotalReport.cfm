<!DOCTYPE html>
<html>
<head>
<title>Nominal Totals Report</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/main4.css" rel="stylesheet" type="text/css">
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
</head>

<cfobject component="code/accounts" name="acc">
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.url = application.site.normal>

<cfoutput>
	<script>
		$(document).ready(function() {
			$('##report-form').submit(function(event) {
				$.ajax({
					type: 'POST',
					url: '#parm.url#ajax/AJAX_loadNomTotalReport.cfm',
					data: $('##report-form').serialize(),
					success:function(data){
						$('##report-list').html(data);
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
					<form method="post" enctype="multipart/form-data" id="report-form">
						<div class="form-header">
							Nominal Totals Report
							<span><div id="loading"></div></span>
						</div>
						<div class="module">
							<table border="0" cellpadding="2" cellspacing="0" width="100%">
								<tr>
									<td align="left">Date Range</td>
									<td align="right">From</td>
									<td>
										<select name="Date_Start_Month">
											<cfloop from="1" to="12" index="i">
												<option value="#i#">#MonthAsString(i)#</option>
											</cfloop>
										</select>
										<select name="Date_Start_Year">
											<cfloop from="#Year(Now())#" to="2013" index="i" step="-1">
												<option value="#i#">#i#</option>
											</cfloop>
										</select>
									</td>
									<td align="right">To</td>
									<td>
										<select name="Date_End_Month">
											<cfloop from="1" to="12" index="i">
												<option value="#i#">#MonthAsString(i)#</option>
											</cfloop>
										</select>
										<select name="Date_End_Year">
											<cfloop from="#Year(Now())#" to="2013" index="i" step="-1">
												<option value="#i#">#i#</option>
											</cfloop>
										</select>
									</td>
									<td><input type="submit" value="Build Report" id="btnBuildReport" /></td>
								</tr>
							</table>
						</div>
					</form>
				</div>
				<div id="report-list" class="module"></div>
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
