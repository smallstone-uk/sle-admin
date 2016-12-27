<cfobject component="code/payroll" name="pr">
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.weekEnding = weekEnding>
<cfset Report = pr.LoadReport(parm)>
<cfset Types = pr.LoadTypes(parm)>
<cfoutput>
	<link href="#application.site.normal#css/main3.css" rel="stylesheet" type="text/css">
	<link href="#application.site.normal#css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="scripts/jquery-1.9.1.js"></script>
	<script src="#application.site.normal#scripts/jquery-ui-1.10.3.custom.min.js"></script>
</cfoutput>

<style>
	.tableList {font-size:16px;}
</style>

<script>
	$(document).ready(function(e) {
		//window.print();
	});
</script>

<cfoutput>
	<!DOCTYPE html>
	<html>
	<head>
	<title>Payroll Report - #parm.weekEnding#</title>
	<link href="../css/payroll.css" rel="stylesheet" type="text/css">
	</head>
	
	<body>
	<ul style="margin:0; padding:0; list-style-type:none;">
		<cfset counter = 0>
		<cfloop array="#Report#" index="rItem">
			<cfif counter is 0>
				<div class="page">
			</cfif>
			<cfset counter++>
			<li class="RItem">
				<div style="padding:10px 0px;">
					<table class="tableList" width="100%" border="0" cellpadding="0" cellspacing="0" style="border:none; border-color:0;">
						<tr>
							<td>
								<table class="tableList" width="100%" border="1" cellpadding="0" cellspacing="0">
									<tr>
										<th align="left">Name:</th>
										<td>#rItem.employee.FirstName# #rItem.employee.LastName#</td>
									<tr>
										<th align="left">Employer:</th>
										<td>#rItem.employee.Employer#</td>
									</tr>
									<tr>
										<th align="left">Employer Ref:</th>
										<td>#rItem.employee.EmployerRef#</td>
									</tr>
								</table>
							</td>
							<td>
								<table class="tableList" width="100%" border="1" cellpadding="0" cellspacing="0">
									<tr>
										<th align="left">Week Ending:</th>
										<td>#DateFormat(parm.weekEnding, "dd/mm/yyyy")#</td>
									</tr>
									<tr>
										<th align="left">Week No:</th>
										<td>#rItem.header.WeekEnding#</td>
									</tr>
									<tr>
										<th align="left">Tax Code:</th>
										<td>#rItem.employee.TaxCode#</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
				</div>
				<table class="tableList" width="100%" border="0" cellpadding="0" cellspacing="0" style="border:none; border-color:0;">
					<tr>
						<td>
							<table class="tableList" width="100%" border="1" cellpadding="0" cellspacing="0">
								<tr>
									<th align="left">Department</th>
									<th>Rate</th>
									<th>Sun</th>
									<th>Mon</th>
									<th>Tue</th>
									<th>Wed</th>
									<th>Thu</th>
									<th>Fri</th>
									<th>Sat</th>
								</tr>
								<cfloop array="#Types#" index="prefix">
									<cfif StructKeyExists(rItem.weekDays, "#prefix.string#")>
										<cfset ItemStruct = StructFind(rItem.weekDays, "#prefix.string#")>
										<tr id="#prefix.string#Row">
											<td align="left">#prefix.title#</td>
											<cfif prefix.string eq "po">
												<td align="center">#rItem.Employee.Rate3#</td>
											<cfelse>
												<td align="center">#rItem.Employee.Rate#</td>
											</cfif>
											<td align="center">#ItemStruct.Sun#</td>
											<td align="center">#ItemStruct.Mon#</td>
											<td align="center">#ItemStruct.Tue#</td>
											<td align="center">#ItemStruct.Wed#</td>
											<td align="center">#ItemStruct.Thu#</td>
											<td align="center">#ItemStruct.Fri#</td>
											<td align="center">#ItemStruct.Sat#</td>
										</tr>
									</cfif>
								</cfloop>
							</table>
						</td>
					</tr>
				</table>
				<div style="padding:10px 0px;">
					<table class="tableList" width="100%" border="0" cellpadding="0" cellspacing="0" style="border:none; border-color:0;">
						<tr>
							<td valign="top">
								<table class="tableList" width="100%" border="1" cellpadding="0" cellspacing="0">
									<tr>
										<th colspan="2">Wages Due</th>
									</tr>
									<tr>
										<td align="right"><strong>Total Hours</strong></td>
										<td align="right">#rItem.header.THours#</td>
									</tr>
									<tr>
										<td align="right"><strong>Gross Pay</strong></td>
										<td align="right">#rItem.header.gross#</td>
									</tr>
									<!---<tr>
										<td align="right"><strong>Mon-Fri Rate</strong></td>
										<td align="right">#rItem.Employee.Rate#</td>
									</tr>
									<tr>
										<td align="right"><strong>Sat-Sun Rate</strong></td>
										<td align="right">#rItem.Employee.Rate2#</td>
									</tr>--->
								</table>
							</td>
							<td valign="top">
								<table class="tableList" width="100%" border="1" cellpadding="0" cellspacing="0">
									<tr>
										<th colspan="2">Deductions</th>
									</tr>
									<tr>
										<td align="right"><strong>Income Tax</strong></td>
										<td align="right">#rItem.header.paye#</td>
									</tr>
									<tr>
										<td align="right"><strong>National Insurance</strong></td>
										<td align="right">#rItem.header.ni#</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
				</div>
				<table class="tableList" width="100%" border="0" cellpadding="0" cellspacing="0" style="border:none; border-color:0;">
					<tr>
						<td>
							<table class="tableList" width="50%" border="1" cellpadding="0" cellspacing="0" align="right">
								<tr>
									<th align="right" style="font-size:20px;">Net Pay</th>
									<td align="right" style="font-size:20px;">#rItem.header.np#</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</li>
			<cfif counter is 3>
				<cfset counter = 0>
				</div>
			</cfif>
		</cfloop>
	</ul>
	</body>
	</html>
</cfoutput>