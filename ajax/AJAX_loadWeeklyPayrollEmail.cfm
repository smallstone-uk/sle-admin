<cftry>
	<cfparam name="checkList" default="">
	<cfobject component="code/payroll2" name="pr2">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.url = application.site.normal>
	<cfset parm.emailPDF = StructKeyExists(form,"emailPDF")>
	<cfif StructKeyExists(form,"weekending")>
		<cfset parm.weekending = form.weekending>
	<cfelseif StructKeyExists(url,"weekending")>
		<cfset parm.weekending = url.weekending>
	<cfelse>
		<cfset parm.weekending = "">
	</cfif>
	<cfif IsDate(parm.weekending)>
		<cfset records = pr2.LoadWeeklyPayrollRecords(parm)>
	<cfelse>
		<p>Please provide a week ending date.</p>
		<cfexit>
	</cfif>
	<cfoutput>
		<p>Pay Records for week Ending #DateFormat(parm.weekending,"ddd dd-mmm-yyyy")#</p>
		<table width="600">
			<form method="post">
				<input type="hidden" name="weekending" value="#parm.weekending#" />
			<cfset iCount = 0>
			<cfloop array="#records#" index="record">
				<cfset iCount++>
				<tr>
					<td><input type="checkbox" name="checkList" value="#iCount#"<cfif ListFind(checkList,iCount)> checked="checked"</cfif> /></td>
					<td>#iCount#</td>
					<td>#record.employee.ID#</td>
					<td>#record.employee.FirstName# #record.employee.LastName#</td>
				</tr>
			</cfloop>
				<tr>
					<td colspan="4"><input type="checkbox" name="emailPDF" />Email the payslips?</td>
				</tr>
				<tr>
					<td colspan="4"><input type="submit" name="btnGo" value="Send" /></td>
				</tr>
			</form>
		</table>

		<cfif len(checkList)>
				<cfset rowCount=0>
				<cfloop list="#checkList#" index="slip">
					<cfset record = records[slip]>
					<cfif StructIsEmpty(record.header)>
						No pay data found for #record.employee.FirstName# #record.employee.LastName#.<br />
					<cfelse>
						<cfset filename = "pay-#record.employee.LastName#-#DateFormat(parm.weekending,"yymmdd")#.pdf">
						#record.employee.FirstName# #record.employee.LastName# - #filename# - #record.employee.empEMail#<br />
						<cfdocument
							permissions="allowcopy,AllowPrinting" 
							orientation="portrait" 
							mimetype="text/html"
							saveAsName="#record.employee.LastName#" 
							filename="#application.site.dir_data#payslips\#filename#"
							overwrite="yes"
							localUrl="yes" 
							format="PDF" 
							fontEmbed="yes" 
							userpassword=""
							encryption="128-bit">
							
								<cfset rowCount++>
							<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
							<html xmlns="http://www.w3.org/1999/xhtml">
								<head>
									<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
									<meta name="viewport" content="width=device-width,initial-scale=1.0">
									<title>Payslip <cfoutput>#filename#</cfoutput></title>
									<style type="text/css">
										body {margin:0; padding:0; font-family:Arial, Helvetica, sans-serif;}
										.tableList {border:1px solid ##BDC9DD; font-size:9px; border-color:##BDC9DD;}
										.tableList th {padding:2px 3px; background:##EFF3F7; border-color:##BDC9DD; color: ##18315C;}
										.tableList td {padding:2px 5px; border-color:##BDC9DD;}
										.pr2-reportList {list-style-type:none; margin:0; padding:0;}
										.pr2-reportList li {padding:10px 0; border-bottom: 1px dashed ##000; min-height:240px; max-height: 300px;}
										@page  
										{   size:portrait;
											margin-top:20px;
											margin-left:20px;
											margin-right:20px;
											margin-bottom:20px;
										}
									</style>
								</head>
								<body>
										<table class="tableList" width="100%">
											<tr>
												<th width="200" align="left">Employer</th>
												<td width="250">#record.employee.employer#</td>
												<th width="200" align="left">Reference</th>
												<td width="250">#record.employee.employerRef#</td>
											</tr>
											<tr>
												<th align="left">Employee Name</th>
												<td>#record.employee.FirstName# #record.employee.LastName#</td>
												<th align="left">Week Ending</th>
												<td>#DateFormat(parm.weekending,"dd-mmm-yyyy")#</td>
											</tr>
											<tr>
												<th align="left">Tax Code</th>
												<td>#record.employee.TaxCode#</td>
												<th align="left">Tax Week Number</th>
												<td>#pr2.GetPayrollWeekNumber(parm.weekending)#</td>
											</tr>
										</table>
										<div style="padding:5px 0;"></div>
										<table class="tableList" width="100%">
											<tr>
												<th width="300"></th>
												<th width="75">Rate</th>
												<cfloop from="1" to="7" index="i">
													<th width="75">#DayOfWeekAsString(i)#</th>
												</cfloop>
											</tr>
											<cfset deptCount = 0>
											<cfloop array="#record.employee.depts#" index="dept">
												<cfset deptCount++>
												<cfif StructKeyExists(record.items, dept.depName)>
													<cfset deptItems = StructFind(record.items, dept.depName)>
													<cfif StructCount(deptItems) gt 0>
														<cfloop collection="#deptItems#" item="key">
															<cfset dayPay = StructFind(deptItems,key)>
															<cfset payRate = dayPay.piRate>
															<cfbreak>
														</cfloop>
													</cfif>
												<cfelse>
													<cfset deptItems = {}>
													<cfset payRate = dept.rtRate>
												</cfif>
												<cfif val(payRate) neq 0>
												<tr class="pr2_depts">
													<th class="pr2_dept" data-dept="#dept.depID#" data-rate="#payRate#" align="left">#dept.depName#</th>
													<td width="75" align="center">&pound;#payRate#</td>
													<cfloop from="1" to="7" index="i">
														<cfif StructKeyExists(deptItems, "#DayOfWeekAsString(i)#")>
															<cfset dayItem = StructFind(deptItems, "#DayOfWeekAsString(i)#")>
															<td class="pr2_item" align="center" width="75" data-day="#DayOfWeekAsString(i)#">
																<cfif dayItem.piHours neq 0>
																	#dayItem.piHours#
																<cfelseif dayItem.piHolHours neq 0>
																	#dayItem.piHolHours#
																</cfif>
															</td>
														<cfelse>
															<td class="pr2_item" width="75" data-day="#DayOfWeekAsString(i)#"></td>
														</cfif>
													</cfloop>
												</tr>
												</cfif>
											</cfloop>
											<cfloop from="#deptCount+1#" to="7" index="deptRow">	<!--- pad area to same depth --->
												<tr class="pr2_depts">
													<th class="pr2_dept" align="left">&nbsp;</th>
													<td width="75" align="center"></td>
													<td class="pr2_item" width="75"></td>
													<td class="pr2_item" width="75"></td>
													<td class="pr2_item" width="75"></td>
													<td class="pr2_item" width="75"></td>
													<td class="pr2_item" width="75"></td>
													<td class="pr2_item" width="75"></td>
													<td class="pr2_item" width="75"></td>
												</tr>
											</cfloop>
										</table>
										<div style="padding:5px 0;"></div>
										<table class="tableList" width="100%">
											<tr>
												<td style="vertical-align: top;padding: 0;">
													<table class="tableList">
														<tr>
															<th width="150">(Calandar Week #record.totals.recs#)</th>
															<th width="80" align="right">This<br />Year</th>
															<th width="80" align="right">This<br />Week</th>
														</tr>
														<tr>
															<th align="left">Work Hours</th>
															<td data-role="holiday" align="right">#record.totals.workSum#</td>
															<td data-role="holiday" align="right">#record.header.phWorkHours#</td>
														</tr>
														<cfif record.employee.empPaySlip IS "detailed">	
														<tr>
															<th align="left">Holiday Entitlement</th>
															<td data-role="holiday" align="right">#DecimalFormat(record.totals.annual)#</td>
															<td></td>
														</tr>				
														<tr>
															<th align="left">Holiday Taken</th>
															<td data-role="holiday" align="right">#record.totals.holSum#</td>
															<td align="right">#record.header.phHolHours#</td>
														</tr>				
														<tr>
															<th align="left">Holiday Remaining</th>
															<td data-role="holiday" align="right">#DecimalFormat(record.totals.remain)#</td>
															<td></td>
														</tr>
														</cfif>		
													</table>
												</td>
												<td style="vertical-align: top;padding: 0;" align="right">
													<table class="tableList">
														<tr>
															<th width="150"></th>
															<th width="80" align="right">This<br />Year</th>
															<th width="80" align="right">This<br />Week</th>
														</tr>
														<tr>
															<th align="left">Pension Contribution</th>
															<td data-role="paye" align="right">
																<cfif val(record.totals.PensionSum)>
																	&pound;#DecimalFormat(record.totals.PensionSum)#
																</cfif>
															</td>
															<td data-role="paye" align="right">
																<cfif val(record.header.phMemberContribution)>
																	&pound;#record.header.phMemberContribution#
																</cfif>
															</td>
														</tr>
														<tr>
															<th align="left">Lottery</th>
															<td data-role="ni" align="right">
																<cfif val(record.totals.LotterySum)>
																	&pound;#DecimalFormat(record.totals.LotterySum)#
																</cfif>
															</td>
															<td data-role="ni" align="right">
																<cfif val(record.header.phLotterySubs)>
																	&pound;#record.header.phLotterySubs#
																</cfif>
															</td>
														</tr>
														<tr>
															<th align="left">Adjustments</th>
															<td data-role="gross" align="right">
																<cfif val(record.header.phAdjustment)>
																	&pound;#DecimalFormat(record.totals.AdjustmentSum)#
																</cfif>
															</td>
															<td data-role="gross" align="right">
																<cfif val(record.header.phAdjustment)>
																	&pound;#record.header.phAdjustment#
																</cfif>
															</td>
														</tr>
													</table>
												</td>
												<td style="vertical-align: top;padding: 0;" align="right">
													<table class="tableList">
														<tr>
															<th width="100"></th>
															<th width="80" align="right">This<br />Year</th>
															<th width="80" align="right">This<br />Week</th>
														</tr>
														<tr>
															<th align="left">Gross Pay</th>
															<td data-role="gross" align="right">&pound;#DecimalFormat(record.totals.grossSum)#</td>
															<td data-role="gross" align="right">&pound;#DecimalFormat(record.header.phGross)#</td>
														</tr>
														<tr>
															<th align="left">PAYE Tax</th>
															<td data-role="paye" align="right">&pound;#record.totals.PAYESum#</td>
															<td data-role="paye" align="right">
																<cfif StructIsEmpty(record.header)>
																	&pound;0.00
																<cfelse>
																	&pound;#record.header.phPAYE#
																</cfif>
															</td>
														</tr>
														<tr>
															<th align="left">N.I. Contribution</th>
															<td data-role="ni" align="right">
																&pound;#record.totals.NISum#
															</td>
															<td data-role="ni" align="right">
																<cfif StructIsEmpty(record.header)>
																	&pound;0.00
																<cfelse>
																	&pound;#record.header.phNI#
																</cfif>
															</td>
														</tr>
														<tr>
															<th align="left">Net Pay</th>
															<td data-role="gross" align="right">&pound;#DecimalFormat(record.totals.npSum)#</td>
															<td data-role="netpay" align="right">&pound;#DecimalFormat(record.header.phNP)#</td>
														</tr>
														<tr>
															<th align="left">Take Home</th>
															<td data-role="gross" align="right">
																<strong>&pound;#DecimalFormat(val(record.totals.npSum) - val(record.totals.LotterySum))#</strong></td>
															<td data-role="netpay" align="right">
																<strong>&pound;#DecimalFormat(val(record.header.phNP) - val(record.header.phLotterySubs))#</strong></td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
									<cfif (rowCount MOD 3) EQ 0>
										<div style="page-break-after:always;"></div>
									</cfif>
								</body>
							</html>
						</cfdocument>
						<cfif parm.emailPDF>
							<cfset attachment = filename>
							<cfset sendTo = "#record.employee.empEMail#">
							<cfinclude template="AJAX_sendWeeklyPayrollEmail.cfm">
						</cfif>
					</cfif>
				</cfloop>
		</cfif>
	</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>
