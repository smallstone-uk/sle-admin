<cftry>
<cfsetting showdebugoutput="no">
<cfobject component="code/accounts" name="acc">
<cfset callback = 1>
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.form = {}>
<cfset parm.form.Date_Start_Month = url.Date_Start_Month>
<cfset parm.form.Date_Start_Year = url.Date_Start_Year>
<cfset parm.form.Date_End_Month = url.Date_End_Month>
<cfset parm.form.Date_End_Year = url.Date_End_Year>
<cfset totals = acc.LoadNominalTotalsBetweenDates(parm)>

<cfoutput>
	<style>
		.tableList {font-size:12px;}
	</style>
	<!DOCTYPE html>
	<html>
	<head>
	<title>Nominal Totals Report</title>
	<link href="#parm.url#css/main3.css" rel="stylesheet" type="text/css">
	<link href="#parm.url#css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="scripts/jquery-1.9.1.js"></script>
	<script src="#parm.url#scripts/jquery-ui-1.10.3.custom.min.js"></script>
	</head>
	<body>
		<script>
			$(document).ready(function(e) {
				window.print();
			});
		</script>
		<table width="100%" border="1" class="tableList">
			<tr>
				<th align="left" width="100">Code</th>
				<th align="left">Title</th>
				<th align="right" width="100">DR</th>
				<th align="right" width="100">CR</th>
			</tr>
			<cfset counter = 0>
			<cfset pageIndex = 0>
			<cfloop array="#totals.items#" index="item">
				<cfset counter++>
				<tr>
					<td align="left">#item.NomCode#</td>
					<td align="left">#item.NomTitle#</td>
					<cfif item.Bal lt 0>
						<td colspan="1" align="right"></td>
						<td align="right">#DecimalFormat(abs(item.Bal))#</td>
					<cfelse>
						<td align="right">#DecimalFormat(abs(item.Bal))#</td>
						<td colspan="1" align="right"></td>
					</cfif>
				</tr>
				<cfif counter is 48>
					<cfset pageIndex++>
					</table>
					<footer>
						<p style="text-align:center;">#pageIndex#</p>
					</footer>
					<div style="page-break-after:always;"></div>
					<table width="100%" border="1" class="tableList">
						<tr>
							<th align="left" width="100">Code</th>
							<th align="left">Title</th>
							<th align="right" width="100">DR</th>
							<th align="right" width="100">CR</th>
						</tr>
					<cfset counter = 0>
				</cfif>
			</cfloop>
			<tr>
				<th colspan="2" align="right">Total</th>
				<td align="right"><strong>#DecimalFormat(totals.header.drTotal)#</strong></td>
				<td align="right"><strong>#DecimalFormat(abs(totals.header.crTotal))#</strong></td>
			</tr>
		</table>
		<cfset pageIndex++>
		<footer>
			<p style="text-align:center;">#pageIndex#</p>
		</footer>
	</body>
	</html>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>