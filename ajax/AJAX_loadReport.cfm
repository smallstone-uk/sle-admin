<cftry>
<cfsetting showdebugoutput="no">
<cfobject component="code/payroll3" name="pr">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.form = form>
<cfset parm.allEmployees = true>
<cfif parm.form.sort eq "employee">
	<cfset Report = pr.LoadEmployeeReport(parm)>
<cfelseif parm.form.sort eq "postTrans">
	<cfset parm.allEmployees = false>
	<cfset Report = pr.LoadEmployeeReport(parm)>
<cfelseif parm.form.sort eq "date_minimal">
	<cfset Report = pr.LoadMinimalPayrollReportByDate(parm)>
<cfelse>
	<cfset Report = pr.LoadPayrollReportByDate(parm)>
</cfif>
<cfset heighttotal=0>
<cfset maxheight=900>
<cfset header=100>
<cfset row=20>

<cfif parm.form.sort eq "employee">
	<cfoutput>
		<cfsavecontent variable="sReport">
			<!---<style type="text/css">
				body {font-family:Arial, Helvetica, sans-serif;}
				.RepTable {padding: 20px 0px;}
				.tableList {font-size:11px;border-left: solid 1px ##ccc;border-top: solid 1px ##ccc;}
				.tableList th {padding:2px 4px;border-bottom: solid 1px ##ccc;border-right: solid 1px ##ccc;background:##eee;}
				.tableList th.subtitle {padding:2px 4px;border-bottom: solid 1px ##ccc;border-right: solid 1px ##ccc;background:##fff;}
				.tableList td {padding:2px 4px;border-bottom: solid 1px ##ccc;border-right: solid 1px ##ccc;background:##fff;}
				.tableList.morespace {font-size: 12px;}
				.tableList.morespace th {padding:4px 5px;}
				.tableList.morespace td {padding:4px 5px;}
				.tableList.trhover tr:hover {background:##EEE;}
				.tableList.trhover tr.active:hover {background:##0F5E8B;}
			</style>--->
			
			<cfloop array="#Report#" index="rep">
				<cfset heighttotal += header>
				<cfif heighttotal gte maxheight>
					<div style="page-break-before:always;"></div>
					<cfset heighttotal = 0>
				</cfif>
				<div class="RepTable">
					<table class="tableList" width="100%" border="1" cellpadding="0" cellspacing="0">
						<tr>
							<th align="left">Name:</th>
							<td>#rep.employee.firstname# #rep.employee.lastname#</td>
							<th>N.I.</th>
							<td>#rep.employee.NI#</td>
							<th>Tax Code</th>
							<td>#rep.employee.taxCode#</td>
							<th colspan="3"></th>
						</tr>
						<tr>
							<th align="left">Employer Ref:</th>
							<td>#rep.employee.employerRef#</td>
							<th>Start Date</th>
							<td>#DateFormat(rep.employee.start,"dd-mmm-yyyy")#</td>
							<th>Status</th>
							<td>#rep.employee.status#</td>
							<th colspan="3"></th>
						</tr>
						<tr>
							<th width="100">Date</th>
							<th width="">Week No</th>
							<th width="" align="right">Net Pay</th>
							<th width="" align="right">PAYE</th>
							<th width="" align="right">NI</th>
							<th width="" align="right">Employer Pension</th>
							<th width="" align="right">Member Pension</th>
							<th width="" align="right">Lotto</th>
							<th width="" align="right">Gross Pay</th>
							<th width="" align="right">Hours</th>
							<th width="" align="right">Work Hours</th>
							<th width="" align="right">Hol Hours</th>
						</tr>
						<cfloop array="#rep.headers#" index="item">
							<cfif heighttotal gte maxheight>
								<cfset heighttotal=0>
								</table>
								<div style="page-break-before:always;"></div>
								<table class="tableList" width="100%" border="0" cellpadding="0" cellspacing="0">
									<tr>
										<th align="left">Name:</th>
										<td colspan="8">#rep.employee.firstname# #rep.employee.lastname#</td>
									</tr>
									<tr>
										<th align="left">Employer Ref:</th>
										<td colspan="8">#rep.employee.employerRef#</td>
									</tr>
									<tr>
										<th width="100">Date</th>
										<th width="">Week No</th>
										<th width="" align="right">Net Pay</th>
										<th width="" align="right">PAYE</th>
										<th width="" align="right">NI</th>
										<th width="" align="right">Employer Pension</th>
										<th width="" align="right">Member Pension</th>
										<th width="" align="right">Lotto</th>
										<th width="" align="right">Gross Pay</th>
										<th width="" align="right">Hours</th>
										<th width="" align="right">Work Hours</th>
										<th width="" align="right">Hol Hours</th>
									</tr>
							</cfif>
							<cfset heighttotal=heighttotal+row>
							<tr>
								<td align="center">#DateFormat(item.WeekEnding, "dd/mm/yyyy")#</td>
								<td align="center">#item.WeekNo#</td>
								<td align="right">#item.NP#</td>
								<td align="right">#item.PAYE#</td>
								<td align="right">#item.NI#</td>
								<td align="right">#item.EmployerPension#</td>
								<td align="right">#item.MemberPension#</td>
								<td align="right">#item.Lotto#</td>
								<td align="right">#item.Gross#</td>
								<td align="right">#item.Hours#</td>
								<td align="right">#item.WorkHours#</td>
								<td align="right">#item.HolHours#</td>
							</tr>
						</cfloop>
						<tr>
							<th colspan="2"></th>
							<th align="right">#rep.sums.np#</th>
							<th align="right">#rep.sums.paye#</th>
							<th align="right">#rep.sums.ni#</th>
							<th align="right">#rep.sums.EmployerPensionSum#</th>
							<th align="right">#rep.sums.MemberPensionSum#</th>
							<th align="right">#rep.sums.LottoSum#</th>
							<th align="right">#rep.sums.gross#</th>
							<th align="right">#rep.sums.hours#</th>
							<th align="right">#rep.sums.workhours#</th>
							<th align="right">#rep.sums.holhours#</th>
						</tr>
					</table>
				</div>
			</cfloop>
		</cfsavecontent>
	</cfoutput>
<cfelseif parm.form.sort eq "date">
	<cfsavecontent variable="sReport">
		<cfoutput>
			<table class="tableList" width="100%" border="1">
				<cfloop array="#Report#" index="item">
					<cfset sums = {}>
					<tr>
						<th align="left">Week Ending</th>
						<td colspan="7">#DateFormat(item.weekEnding, "dd mmmm yyyy")#</td>
					</tr>
					<tr>
						<th align="left">Week No</th>
						<td colspan="7">#item.weekNo#</td>
					</tr>
					<tr>
						<th align="left">Employee</th>
						<th>Tax Code</th>
						<th>Method</th>
						<th align="right">Net Pay</th>
						<th align="right">PAYE</th>
						<th align="right">NI</th>
						<th align="right">Employer Pension</th>
						<th align="right">Member Pension</th>
						<th align="right">Lotto</th>
						<th align="right">Gross Pay</th>
						<th align="right">Hours</th>
					</tr>
					<cfset cashTotal = 0>
					<cfset bacsTotal = 0>
					<cfloop array="#item.items#" index="i">
						<cfset sums.grossSum = i.grossSum>
						<cfset sums.hoursSum = i.hoursSum>
						<cfset sums.niSum = i.niSum>
						<cfset sums.EmployerPensionSum = i.EmployerPensionSum>
						<cfset sums.MemberPensionSum = i.MemberPensionSum>
						<cfset sums.LottoSum = i.LottoSum>
						<cfset sums.npSum = i.npSum>
						<cfset sums.payeSum = i.payeSum>
						<tr>
							<td>#i.empFirstName# #i.empLastName#</td>
							<td align="center">#i.empTaxCode#</td>
							<td align="center">#i.empMethod#</td>
							<td align="right">#DecimalFormat(i.phNP)#</td>
							<td align="right">#DecimalFormat(i.phPAYE)#</td>
							<td align="right">#DecimalFormat(i.phNI)#</td>
							<td align="right">#DecimalFormat(i.phEmployerContribution)#</td>
							<td align="right">#DecimalFormat(i.phMemberContribution)#</td>
							<td align="right">#DecimalFormat(i.phLotterySubs)#</td>
							<td align="right">#DecimalFormat(i.phGross)#</td>
							<td align="right">#DecimalFormat(i.phTotalHours)#</td>
						</tr>
						<cfif i.empMethod eq 'cash'>
							<cfset cashTotal += i.phNP>
						<cfelse>
							<cfset bacsTotal += i.phNP>
						</cfif>
					</cfloop>
					<tr>
						<th align="right">Totals</th>
						<td align="center">Cash: #DecimalFormat(cashTotal)#</td>
						<td align="center">BACS: #DecimalFormat(bacsTotal)#</td>
						<td align="right"><strong>#DecimalFormat(sums.npSum)#</strong></td>
						<td align="right"><strong>#DecimalFormat(sums.payeSum)#</strong></td>
						<td align="right"><strong>#DecimalFormat(sums.niSum)#</strong></td>
						<td align="right"><strong>#DecimalFormat(sums.EmployerPensionSum)#</strong></td>
						<td align="right"><strong>#DecimalFormat(sums.MemberPensionSum)#</strong></td>
						<td align="right"><strong>#DecimalFormat(sums.LottoSum)#</strong></td>
						<td align="right"><strong>#DecimalFormat(sums.grossSum)#</strong></td>
						<td align="right"><strong>#DecimalFormat(sums.hoursSum)#</strong></td>
					</tr>
				</cfloop>
			</table>
		</cfoutput>
	</cfsavecontent>
<cfelseif parm.form.sort eq "date_minimal">
	<cfsavecontent variable="sReport">
		<cfset totalNet = 0>
		<cfset totalPAYE = 0>
		<cfset totalNI = 0>
		<cfset totalGross = 0>
		<cfset totalHours = 0>
		<cfset totalEmployerPension = 0>
		<cfset totalMemberPension = 0>
		<cfset totalLotto = 0>
		<cfset totalAdjustment = 0>
		<cfoutput>
			<table class="tableList" width="100%" border="1">
				<tr>
					<th>Date</th>
					<th>Week No</th>
					<th align="right">Net Pay</th>
					<th align="right">PAYE</th>
					<th align="right">NI</th>
					<th align="right">Employer Pension</th>
					<th align="right">Member Pension</th>
					<th align="right">Lotto</th>
					<th align="right">Adjustment</th>
					<th align="right">Gross</th>
					<th align="right">Hours</th>
				</tr>
				<cfloop array="#Report#" index="item">
					<cfset totalNet += item.TotalNP>
					<cfset totalPAYE += item.TotalPAYE>
					<cfset totalNI += item.TotalNI>
					<cfset totalEmployerPension += val(item.TotalEmployerPension)>
					<cfset totalMemberPension += item.TotalMemberPension>
					<cfset totalLotto += item.TotalLotto>
					<cfset totalAdjustment += item.TotalAdjustment>
					<cfset totalGross += item.TotalGross>
					<cfset totalHours += item.TotalHours>
					<tr>
						<td align="center">#DateFormat(item.phDate, "dd/mm/yyyy")#</td>
						<td align="center">#item.phWeekNo#</td>
						<td align="right">#item.TotalNP#</td>
						<td align="right">#item.TotalPAYE#</td>
						<td align="right">#item.TotalNI#</td>
						<td align="right">#item.TotalEmployerPension#</td>
						<td align="right">#item.TotalMemberPension#</td>
						<td align="right">#item.TotalLotto#</td>
						<td align="right">#item.TotalAdjustment#</td>
						<td align="right">#item.TotalGross#</td>
						<td align="right">#item.TotalHours#</td>
					</tr>
				</cfloop>
				<tr>
					<th></th>
					<th>Totals</th>
					<th align="right">#totalNet#</th>
					<th align="right">#totalPAYE#</th>
					<th align="right">#totalNI#</th>
					<th align="right">#totalEmployerPension#</th>
					<th align="right">#totalMemberPension#</th>
					<th align="right">#totalLotto#</th>
					<th align="right">#totalAdjustment#</th>
					<th align="right">#totalGross#</th>
					<th align="right">#totalHours#</th>
				</tr>				
			</table>
		</cfoutput>
	</cfsavecontent>
<cfelseif parm.form.sort eq "postTrans">
	<cfdump var="#Report#" label="Report" expand="false">
	<cfoutput>
	<table class="tableList" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<th width="">Name</th>
			<th width="100">Date</th>
			<th width="">Week No</th>
			<th width="" align="right">Net Pay</th>
			<th width="" align="right">PAYE</th>
			<th width="" align="right">NI</th>
			<th width="" align="right">Employer Pension</th>
			<th width="" align="right">Member Pension</th>
			<th width="" align="right">Lotto</th>
			<th width="" align="right">Gross Pay</th>
		</tr>
		<cfloop array="#Report#" index="rep">
			<cfloop array="#rep.headers#" index="item">
				<tr>
					<td>#rep.employee.firstname# #rep.employee.lastname#</td>
					<td align="center">#DateFormat(item.WeekEnding, "dd/mm/yyyy")#</td>
					<td align="center">#item.WeekNo#</td>
					<td align="right">#item.NP#</td>
					<td align="right">#item.PAYE#</td>
					<td align="right">#item.NI#</td>
					<td align="right">#item.EmployerPension#</td>
					<td align="right">#item.MemberPension#</td>
					<td align="right">#item.Lotto#</td>
					<td align="right">#item.Gross#</td>
				</tr>
			</cfloop>
		</cfloop>
	</table>
	</cfoutput>
</cfif>

<cfif parm.form.sort neq "postTrans">
	<script>
		$(document).ready(function(e) {
			<cfoutput>
				var #ToScript(sReport, "content")#;
			</cfoutput>
			$('#ToPDFBtn').click(function(event) {
				toPDF(content);
				event.preventDefault();
			});
		});
	</script>
	<cfoutput>
		<!---<a href="javascript:void(0)" class="button" id="ToPDFBtn">Export PDF</a>--->
		#sReport#
	</cfoutput>
</cfif>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>
