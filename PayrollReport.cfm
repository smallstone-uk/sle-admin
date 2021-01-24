<!DOCTYPE html>
<html>
<head>
<title>Payroll Report</title>
<!---<link href="css/payroll.css" rel="stylesheet" type="text/css">--->
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/main4.css" rel="stylesheet" type="text/css">
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
<script src="scripts/main.js"></script>
<script src="scripts/payrollReport.js"></script>
<script>
	$(document).ready(function(e) {
		$('#ReportForm').bind("submit", function(event) {
			$.ajax({
				type: "POST",
				url: "ajax/AJAX_loadReport.cfm",
				data: $(this).serialize(),
				beforeSend: function() {},
				success: function(data) {
					$('#PRContent').html(data);
				}
			});
			event.preventDefault();
		});
		
		$('.datepicker').datepicker({
			dateFormat: "yy-mm-dd",
			changeMonth: true,
			changeYear: true,
			showButtonPanel: true,
			minDate: new Date(2013, 1 - 1, 1),
			onClose: function() {}
		});
		
		$('.chosen-select').chosen({
			width: "350px",
			enable_split_word_search: false,
			allow_single_deselect: true
		});
	});
</script>
</head>

<cftry>
	<cfobject component="code/payroll" name="pr">
	<cfset parm = {}>
	<cfset parm.database = application.site.datasource1>
	<cfset parm.active = false>
	<cfset LoadEmployees = pr.LoadEmployees(parm)>
	<cfset startMonth=CreateDate(year(now()),month(now()),1)>
	<cfset endMonth=DateAdd("m",1,startMonth)>
	<cfset endMonth=DateAdd("d",-1,endMonth)>
	<cfoutput>
		<body>
			<div id="wrapper">
				<cfinclude template="sleHeader.cfm">
				<div id="content">
					<div id="content-inner">
						<div class="form-wrap">
							<div class="form-header">
								Payroll Report
								<span><div id="loading" class="loading"></div></span>
							</div>
							<div class="module">
								<form method="post" id="ReportForm">
									<table border="0">
										<tr>
											<td width="100">Employee</td>
											<td>
												<select class="chosen-select" name="Employee" multiple="multiple" data-placeholder="Select employees">
													<cfloop array="#LoadEmployees#" index="item">
														<option value="#item.ID#">#item.FirstName# #item.LastName#</option>
													</cfloop>
												</select>
											</td>
										</tr>
										<tr>
											<td>From</td>
											<td><input type="text" name="From" value="#LSDateFormat(startMonth,'yyyy-mm-dd')#" class="datepicker" /></td>
										</tr>
										<tr>
											<td>To</td>
											<td><input type="text" name="To" value="#LSDateFormat(endMonth,'yyyy-mm-dd')#" class="datepicker" /></td>
										</tr>
										<tr>
											<td>Report type</td>
											<td>
												<select name="Sort">
													<option value="date">Weekly Summary per Employee</option>
													<option value="employee">Employee Summary per Week</option>
													<option value="date_minimal">Payment Summary Totals</option>
													<option value="postTrans">Post Payroll Data</option>
												</select>
											</td>
										</tr>
										<input type="submit" name="btnSubmit" value="Go" class="button" />
									</table>
								</form>
							</div>
						</div>
						<div id="PRContent" class="module"></div>
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

