<!DOCTYPE html>
<html>
<head>
<title>Payroll</title>
<link href="css/payroll.css" rel="stylesheet" type="text/css">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="common/scripts/common.js"></script>
<script src="scripts/payroll.js"></script>
<script>
	$(document).ready(function(e) {
		var payDay = parseInt("<cfoutput>#application.controls.payDayNo#</cfoutput>");
		$.bindPayrollControls();
	});
</script>
</head>

<cftry>
	<cfobject component="code/payroll" name="pr">
	<cfset parm = {}>
	<cfset parm.database = application.site.datasource1>
	<cfset parm.active = true>
	<cfset LoadEmployees = pr.LoadEmployees(parm)>

	<cfoutput>
		<body>
			<div id="wrapper">
				<cfinclude template="sleHeader.cfm">
				<div id="content">
					<div id="content-inner">
						<div class="form-wrap">
							<div class="form-header">
								Payroll
								<span><div id="loading" class="loading"></div></span>
							</div>
							<table border="0">
								<tr>
									<td width="100">Employee</td>
									<td>
										<select class="PRHFormField" id="PRHFFName">
											<cfloop array="#LoadEmployees#" index="item">
												<option value="#item.ID#">#item.FirstName# #item.LastName#</option>
											</cfloop>
										</select>
									</td>
								</tr>
								<tr>
									<td>Week Ending</td>
									<td><input type="text" id="PRHFFWEDate" name="PRHWEDate" value="#LSDateFormat(Now(),'yyyy-mm-dd')#" class="datepicker" /></td>
								</tr>
							</table>
						</div>
						<div id="PRContent"></div>
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
		<cfdump var="#cfcatch#" label="cfcatch" expand="no">
	</cfcatch>
</cftry>
</html>

