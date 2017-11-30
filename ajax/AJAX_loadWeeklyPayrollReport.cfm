<cftry>
<cfobject component="code/payroll2" name="pr2">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.weekending = url.weekending>
<cfset records = pr2.LoadWeeklyPayrollRecords(parm)>

<cfoutput>
	<style type="text/css">
		body {margin:0;padding:0;font-family:Arial, Helvetica, sans-serif;}
		table[border="0"] {border: none !important;}
		.tableList {border-spacing: 0px;border-collapse: collapse;border: 1px solid ##BDC9DD;font-size: 11px;border-color:##BDC9DD;}
		.tableList th {padding:2px 3px;background: ##EFF3F7;border-color: ##BDC9DD;color: ##18315C;}
		.tableList td {padding:2px 5px;border-color: ##BDC9DD;}
		.tableList.trhover tr:hover {background: ##EFF3F7;}
		.tableList.trhover tr.active:hover {background:##0F5E8B;}
		.pr2-reportList {list-style-type: none;margin: 0;padding: 0;}
		.pr2-reportList li {padding: 10px 0;border-bottom: 1px dashed ##000;min-height: 240px;max-height: 300px;}
		@page  
		{   size:portrait;
			margin-top:20px;
			margin-left:20px;
			margin-right:20px;
			margin-bottom:20px;
		}
	</style>
	<ul class="pr2-reportList">
		<cfset rowCount=0>
		<cfloop array="#records#" index="record">
			<cfif !StructIsEmpty(record.header)>
				<cfset rowCount++>
				<li>
					<table class="tableList" border="1" width="100%">
						<tr>
							<th align="left" width="200">Employee #rowCount#</th>
							<td width="250">#record.employee.FirstName# #record.employee.LastName#</td>
							<th align="left" width="200">Week Ending</th>
							<td width="250">#DateFormat(parm.weekending,"dd-mmm-yyyy")#</td>
						</tr>
						<tr>
							<th align="left" width="200">Tax Code</th>
							<td width="250">#record.employee.TaxCode#</td>
							<th align="left" width="200">Week Number</th>
							<td width="250">#pr2.GetPayrollWeekNumber(parm.weekending)#</td>
						</tr>
					</table>
					<div style="padding:5px 0;"></div>
					<table class="tableList" border="1" width="100%">
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
							<tr class="pr2_depts">
								<th class="pr2_dept" data-dept="#dept.depID#" data-rate="#payRate#" align="left">#dept.depName#</th>
								<td width="75" align="center">&pound;#payRate#</td>
								<cfloop from="1" to="7" index="i">
									<cfif StructKeyExists(deptItems, "#DayOfWeekAsString(i)#")>
										<cfset dayItem = StructFind(deptItems, "#DayOfWeekAsString(i)#")>
										<td class="pr2_item" width="75" data-day="#DayOfWeekAsString(i)#">
											<cfif dayItem.piHours gt 0>
												#dayItem.piHours#
											</cfif>
										</td>
									<cfelse>
										<td class="pr2_item" width="75" data-day="#DayOfWeekAsString(i)#"></td>
									</cfif>
								</cfloop>
							</tr>
						</cfloop>
						<cfloop from="#deptCount+1#" to="5" index="deptRow">	<!--- pad area to same depth --->
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
					<table class="tableList" border="0" width="100%">
						<tr>
							<td style="vertical-align: top;padding: 0;">
								<table class="tableList pr2_hour_totals" border="1">
									<tr>
										<th width="150">(Week #record.totals.recs#)</th>
										<th width="80">This Period</th>
										<th width="80">YTD</th>
									</tr>
									<tr>
										<th align="left">Work Hours</th>
										<td data-role="holiday" align="right">#record.header.phWorkHours#</td>
										<td data-role="holiday" align="right">#record.totals.workSum#</td>
									</tr>
									<cfif record.employee.empPaySlip IS "detailed">	
									<tr>
										<th align="left">Holiday Entitlement</th>
										<td></td>
										<td data-role="holiday" align="right">#DecimalFormat(record.totals.annual)#</td>
									</tr>				
									<tr>
										<th align="left">Holiday Taken</th>
										<td align="right">#record.header.phHolHours#</td>
										<td data-role="holiday" align="right">#record.totals.holSum#</td>
									</tr>				
									<tr>
										<th align="left">Holiday Remaining</th>
										<td></td>
										<td data-role="holiday" align="right">#DecimalFormat(record.totals.remain)#</td>
									</tr>
									</cfif>		
								</table>
							</td>
							<td style="vertical-align: top;padding: 0;" align="right">
								<table class="tableList pr2_gross_totals" border="1">
									<tr>
										<th width="150"></th>
										<th width="80">YTD</th>
										<th width="80">This Period</th>
									</tr>
									<tr>
										<th align="left">PAYE</th>
										<td data-role="paye" align="right">
											&pound;#record.totals.PAYESum#
										</td>
										<td data-role="paye" align="right">
											<cfif StructIsEmpty(record.header)>
												&pound;0.00
											<cfelse>
												&pound;#record.header.phPAYE#
											</cfif>
										</td>
									</tr>
									<tr>
										<th align="left">National Insurance</th>
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
										<th align="left">Gross Total</th>
										<td data-role="gross" align="right">&pound;#DecimalFormat(record.totals.grossSum)#</td>
										<td data-role="gross" align="right">&pound;#record.header.phGross#</td>
									</tr>
									<tr>
										<th align="left">Net Pay</th>
										<td data-role="gross" align="right">&pound;#DecimalFormat(record.totals.npSum)#</td>
										<td data-role="netpay" align="right">&pound;#record.header.phNP#</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
				</li>
				<cfif (rowCount MOD 3) EQ 0>
					<div style="page-break-after:always;"></div>
				</cfif>
			</cfif>
		</cfloop>
	</ul>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>