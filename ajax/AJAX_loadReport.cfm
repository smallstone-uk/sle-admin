<cftry>
<cfsetting showdebugoutput="no">
<cfflush interval="500">
<cfobject component="code/payroll3" name="pr">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.form = form>
<cfif StructKeyExists(form,"currentEmployees")>
	<cfset parm.currentEmployees = form.currentEmployees>
<cfelse>
	<cfset parm.currentEmployees = "0">
</cfif>
<cfif StructKeyExists(form,"importData")>
	<cfset parm.importData = form.importData>
<cfelse>
	<cfset parm.importData = "0">
</cfif>
<cfif parm.form.reportType eq "employee">
	<cfset Report = pr.LoadEmployeeReport(parm)>
<cfelseif parm.form.reportType eq "postTrans">
	<cfset Report = pr.ImportPayrollData(parm)>
<cfelseif parm.form.reportType eq "date_minimal">
	<cfset Report = pr.LoadMinimalPayrollReportByDate(parm)>
<cfelseif parm.form.reportType eq "holiday">
	<cfset Report = pr.LoadHolidayReportByDate(parm)>
<cfelse>
	<cfset Report = pr.LoadPayrollReportByDate(parm)>
</cfif>
<cfset heighttotal=0>
<cfset maxheight=900>
<cfset header=100>
<cfset row=20>

<cfif parm.form.reportType eq "employee">
	<cfoutput>
		<cfsavecontent variable="sReport">
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
							<th colspan="8"></th>
						</tr>
						<tr>
							<th align="left">Employer Ref:</th>
							<td>#rep.employee.employerRef#</td>
							<th>Start Date</th>
							<td>#DateFormat(rep.employee.start,"dd-mmm-yyyy")#</td>
							<th>Status</th>
							<td>#rep.employee.status#</td>
							<th colspan="8"></th>
						</tr>
						<tr>
							<th width="100">Date</th>
							<th width="">Week No</th>
							<th width="" align="right">Take Home</th>
							<th width="" align="right">Net Pay</th>
							<th width="" align="right">PAYE</th>
							<th width="" align="right">NI</th>
							<th width="" align="right">Employer Pension</th>
							<th width="" align="right">Member Pension</th>
							<th width="" align="right">Lotto</th>
							<th width="" align="right">Adjustment</th>
							<th width="" align="right">Gross Pay</th>
							<th width="" align="right">Hours</th>
							<th width="" align="right">Work Hours</th>
							<th width="" align="right">Hol Hours</th>
						</tr>
						<cfloop array="#rep.headers#" index="item">
<!---
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
										<th width="" align="right">Adjustment</th>
										<th width="" align="right">Gross Pay</th>
										<th width="" align="right">Hours</th>
										<th width="" align="right">Work Hours</th>
										<th width="" align="right">Hol Hours</th>
									</tr>
							</cfif>
							<cfset heighttotal=heighttotal+row>
--->
							<tr>
								<td align="center">#DateFormat(item.WeekEnding, "dd/mm/yyyy")#</td>
								<td align="center">#item.WeekNo#</td>
								<td align="right">#DecimalFormat(item.takeHome)#</td>
								<td align="right">#item.NP#</td>
								<td align="right">#item.PAYE#</td>
								<td align="right">#item.NI#</td>
								<td align="right">#item.EmployerPension#</td>
								<td align="right">#item.MemberPension#</td>
								<td align="right">#item.Lotto#</td>
								<td align="right">#item.Adjustment#</td>
								<td align="right">#item.Gross#</td>
								<td align="right">#item.Hours#</td>
								<td align="right">#item.WorkHours#</td>
								<td align="right">#item.HolHours#</td>
							</tr>
						</cfloop>
						<tr>
							<th colspan="2"></th>
							<th align="right">#DecimalFormat(rep.sums.takeHome)#</th>
							<th align="right">#rep.sums.np#</th>
							<th align="right">#rep.sums.paye#</th>
							<th align="right">#rep.sums.ni#</th>
							<th align="right">#rep.sums.EmployerPensionSum#</th>
							<th align="right">#rep.sums.MemberPensionSum#</th>
							<th align="right">#rep.sums.LottoSum#</th>
							<th align="right">#rep.sums.AdjustmentSum#</th>
							<th align="right">#rep.sums.gross#</th>
							<th align="right">#rep.sums.hours#</th>
							<th align="right">#rep.sums.workhours#</th>
							<th align="right">#rep.sums.holhours#</th>
						</tr>
						<tr>
							<td colspan="14">&nbsp;</td>
						</tr>
					</table>
				</div>
			</cfloop>
		</cfsavecontent>
	</cfoutput>
<cfelseif parm.form.reportType eq "date">
	<cfsavecontent variable="sReport">
		<cfoutput>
			<table class="tableList" border="1">
				<cfloop array="#Report#" index="item">
					<cfset sums = {}>
					<tr>
						<th align="left">Week Ending</th>
						<td>#DateFormat(item.weekEnding, "dd mmmm yyyy")#</td>
						<th align="left">Week No</th>
						<td colspan="11">#item.weekNo#</td>
					</tr>
					<tr>
						<th align="left">Employee</th>
						<th>Tax Code</th>
						<th>Method</th>
						<th width="" align="right">Take Home</th>
						<th align="right">Net Pay</th>
						<th align="right">PAYE</th>
						<th align="right">NI</th>
						<th align="right">E. Pension</th>
						<th align="right">M. Pension</th>
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
							<td align="center">#i.phMethod#</td>
							<td align="right"><strong>#DecimalFormat(i.phNP -i.phLotterySubs)#</strong></td>
							<td align="right">#DecimalFormat(i.phNP)#</td>
							<td align="right">#DecimalFormat(i.phPAYE)#</td>
							<td align="right">#DecimalFormat(i.phNI)#</td>
							<td align="right">#DecimalFormat(i.phEmployerContribution)#</td>
							<td align="right">#DecimalFormat(i.phMemberContribution)#</td>
							<td align="right">#DecimalFormat(i.phLotterySubs)#</td>
							<td align="right">#DecimalFormat(i.phGross)#</td>
							<td align="right">#DecimalFormat(i.phTotalHours)#</td>
						</tr>
						<cfif i.phMethod eq 'cash'>
							<cfset cashTotal += (i.phNP - i.phLotterySubs)>
						<cfelse>
							<cfset bacsTotal += (i.phNP - i.phLotterySubs)>
						</cfif>
					</cfloop>
					<tr>
						<th align="right">Totals</th>
						<th align="center">Cash: #DecimalFormat(cashTotal)#</th>
						<th align="center">BACS: #DecimalFormat(bacsTotal)#</th>
						<th align="right">#DecimalFormat(sums.npSum - sums.LottoSum)#</th>
						<th align="right">#DecimalFormat(sums.npSum)#</th>
						<th align="right">#DecimalFormat(sums.payeSum)#</th>
						<th align="right">#DecimalFormat(sums.niSum)#</th>
						<th align="right">#DecimalFormat(sums.EmployerPensionSum)#</th>
						<th align="right">#DecimalFormat(sums.MemberPensionSum)#</th>
						<th align="right">#DecimalFormat(sums.LottoSum)#</th>
						<th align="right">#DecimalFormat(sums.grossSum)#</th>
						<th align="right">#DecimalFormat(sums.hoursSum)#</th>
					</tr>
					<tr>
						<td colspan="12">&nbsp;</td>
					</tr>
				</cfloop>
			</table>
		</cfoutput>
	</cfsavecontent>
<cfelseif parm.form.reportType eq "date_minimal">
	<cfsavecontent variable="sReport">
		<cfset totalTakeHome = 0>
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
					<th align="right">Take Home</th>
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
						<td align="right"><strong>#DecimalFormat(item.TotalNP - item.TotalLotto)#</strong></td>
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
					<th align="right">#DecimalFormat(totalNet - totalLotto)#</th>
					<th align="right">#DecimalFormat(totalNet)#</th>
					<th align="right">#DecimalFormat(totalPAYE)#</th>
					<th align="right">#DecimalFormat(totalNI)#</th>
					<th align="right">#DecimalFormat(totalEmployerPension)#</th>
					<th align="right">#DecimalFormat(totalMemberPension)#</th>
					<th align="right">#DecimalFormat(totalLotto)#</th>
					<th align="right">#DecimalFormat(totalAdjustment)#</th>
					<th align="right">#DecimalFormat(totalGross)#</th>
					<th align="right">#DecimalFormat(totalHours)#</th>
				</tr>				
			</table>
		</cfoutput>
	</cfsavecontent>
	
<cfelseif parm.form.reportType eq "holiday">
	<cfoutput>
	<table class="tableList" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<th width="200">Name</th>
			<th width="100" align="right">Year</th>
			<th width="100" align="right">Age</th>
			<th width="100" align="right">Work<br />Hours</th>
			<th width="100" align="right">Holiday<br />Entitlement</th>
			<th width="100" align="right">Holiday<br />Taken</th>
			<th width="100" align="right">Remaining</th>
			<th width="100" align="right">Avg Rate</th>
			<th width="100" align="right">Debit</th>
			<th width="100" align="right">Credit</th>
			<th width="100" align="right">Balance</th>
		</tr>
		<cfset employeeID = 0>
		<cfset dob = "">
		<cfset t.work = 0>
		<cfset t.Entitlement = 0>
		<cfset t.Holiday = 0>
		<cfset t.Difference = 0>
		<cfset t.Value = 0>
		<cfset t.credit = 0>
		<cfset t.debit = 0>
		<cfset t.totcredit = 0>
		<cfset t.totdebit = 0>
		<cfloop query="Report.QHoliday">
			<cfset diff = (Round(Entitlement * 100) / 100) - Holiday>
			<cfset value = diff * Rate>
			<cfset age = 0>
			<cfif employeeID gt 0 AND empID neq employeeID>
				<tr>
					<th align="left">(#LSDateFormat(dob)#)</th>
					<th colspan="2">Totals</th>
					<th align="right">#DecimalFormat(t.work)#</th>
					<th align="right">#DecimalFormat(t.Entitlement)#</th>
					<th align="right">#DecimalFormat(t.Holiday)#</th>
					<th align="right">#DecimalFormat(t.Difference)#</th>
					<th></th>
					<th align="right">#DecimalFormat(t.debit)#</th>
					<th align="right">#DecimalFormat(t.credit)#</th>
					<th align="right">#DecimalFormat(t.debit + t.credit)#</th>
				</tr>
				<cfset t.work = 0>
				<cfset t.Entitlement = 0>
				<cfset t.Holiday = 0>
				<cfset t.Difference = 0>
				<cfset t.Value = 0>
				<cfset t.credit = 0>
				<cfset t.debit = 0>
			</cfif>
			<tr>
				<td>#empfirstname# #emplastname#</td>
				<td align="right">#YYYY#</td>
				<td align="right">#DecimalFormat(age)#</td>
				<td align="right">#DecimalFormat(Work)#</td>
				<td align="right">#DecimalFormat(Entitlement)#</td>
				<td align="right">#DecimalFormat(Holiday)#</td>
				<td align="right">#DecimalFormat(diff)#</td>
				<td align="right">#DecimalFormat(Rate)#</td>
				<td align="right"><cfif value gt 0>#DecimalFormat(value)#</cfif></td>
				<td align="right"><cfif value lt 0>#DecimalFormat(value)#</cfif></td>
			</tr>
			<cfset employeeID = empID>
			<cfset dob = empDOB>
			<cfset t.work += work>
			<cfset t.Entitlement += Entitlement>
			<cfset t.Holiday += Holiday>
			<cfset t.Difference += diff>
			<cfset t.Value += value>
			<cfif value gt 0>
				<cfset t.debit += value>
				<cfset t.totdebit += value>
			<cfelse>
				<cfset t.credit += value>
				<cfset t.totcredit += value>
			</cfif>
		</cfloop>
		<tr>
			<th align="left">(#LSDateFormat(dob)#)</th>
			<th colspan="2">Totals</th>
			<th align="right">#DecimalFormat(t.work)#</th>
			<th align="right">#DecimalFormat(t.Entitlement)#</th>
			<th align="right">#DecimalFormat(t.Holiday)#</th>
			<th align="right">#DecimalFormat(t.Difference)#</th>
			<th></th>
			<th align="right"><cfif t.value gte 0>#DecimalFormat(t.debit)#</cfif></th>
			<th align="right"><cfif t.value lt 0>#DecimalFormat(t.credit)#</cfif></th>
			<th align="right">#DecimalFormat(t.debit + t.credit)#</th>
		</tr>
		<tr>
			<th colspan="3">Grand Total</th>
			<th align="right"></th>
			<th align="right"></th>
			<th align="right"></th>
			<th align="right"></th>
			<th></th>
			<th align="right">#DecimalFormat(t.totdebit)#</th>
			<th align="right">#DecimalFormat(t.totcredit)#</th>
			<th align="right">#DecimalFormat(t.totdebit + t.totcredit)#</th>
		</tr>
	</table>
	</cfoutput>

<cfelseif parm.form.reportType eq "postTrans">
	<cfdump var="#report#" label="report" expand="false">
	<cfoutput>
<!---
		<table border="1" class="tableList">
		<cfloop collection="#report.nomTitles#" item="key">
			<cfset nomTitle = StructFind(report.nomTitles,key)>
			<tr>
				<td>#key#</td><td>#nomTitle#</td>
			</tr>
		</cfloop>
		</table>
--->
		<table border="1" class="tableList">
			<tr>
				<th>Tran ID</th>
				<th>Date</th>
				<th>Reference</th>
				<th>Description</th>
				<th>Pay Method</th>
				<th>Items Posted</th>
			</tr>
		<cfloop array="#report.trans#" index="tran">
			<tr>
				<td>#tran.trnID#</td>
				<td>#DateFormat(tran.trnDate, "dd/mm/yyyy")#</td>
				<td>#tran.trnRef#</td>
				<td>#tran.trnDesc#</td>
				<td>#tran.trnMethod#</td>
				<td>
					<table border="0" class="tableList">
						<cfloop array="#tran.nomItems#" index="item">
							<cfif item.status neq 'ignored'>
							<tr>
								<td width="50">#item.nomID#</td>
								<td width="200">#StructFind(report.nomTitles,item.nomID)#</td>
								<td width="50" align="right">#DecimalFormat(item.value)#</td>
								<td width="200">#item.status#</td>
							</tr>
							</cfif>
						</cfloop>
					</table>
				</td>
			</tr>
		</cfloop>
		</table>
	</cfoutput>
</cfif>

<cfif parm.form.reportType neq "postTrans" AND StructKeyExists(variables,"sReport")>
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
