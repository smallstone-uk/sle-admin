<cfobject component="code/payroll" name="pr">
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.employee = employee>
<cfset parm.prWeek = prWeek>
<cfset PayrollRecords = pr.LoadPayrollRecord(parm)>
<cfset Employee = pr.LoadEmployee(parm)>
<cfset Types = pr.LoadTypes(parm)>
<cfset prefix = []>
<cfloop array="#Types#" index="t">
	<cfset ArrayAppend(prefix, t.string)>
</cfloop>

<script>
	$(document).ready(function(e) {
		var employee = "<cfoutput>#parm.employee#</cfoutput>",
			prWeek = "<cfoutput>#parm.prWeek#</cfoutput>";
		var recordID, grossTotal, paye, ni, np;
		
		<cfoutput>
			var #ToScript(prefix, "prefix")#;
		</cfoutput>
		
		setVars = function() {
			recordID = $('#PRHRecordID').val();
			grossTotal = $('.PRHIField_GT').val();
			paye = $('.PRHIField_PAYE').val();
			ni = $('.PRHIField_NI').val();
			np = $('.PRHIField_NP').val();
		}
		
		rowTotal(prefix);
		calculateGrossTotal(prefix);
		setVars();
		
		$('.PRHIField').each(function(index, element) {
			$(element).bind("keyup", function(event) {
				var value = parseFloat($(element).val());
				if (Math.abs(value) > 12) {
					$(element).val("");
				} else {
					rowTotal(prefix);
					calculateGrossTotal(prefix);
				}
			});
		});
		
		$('#btnSave').click(function(event) {
			setVars();
			serializeFields(prefix, recordID, employee, prWeek, grossTotal, paye, ni, np);
			event.preventDefault();
		});
		
		$('#btnReport').click(function(event) {
			$.ajax({
				type: "POST",
				url: "ajax/AJAX_loadPayrollReport.cfm",
				data: {"weekEnding": prWeek},
				success: function(data) {
					$('#PRContent').html(data);
				}
			});
			event.preventDefault();
		});
		
		$('.PRHIField_NI, .PRHIField_PAYE').keyup(function(event) {
			calculateGrossTotal(prefix);
		});
	});
</script>

<cfoutput>
	<div class="PRHDetails">
		<input type="button" value="Save" id="btnSave" />
		<a href="ajax/AJAX_loadPayrollReport.cfm?weekEnding=#parm.prWeek#" target="_newtab">Report</a>
		<table class="tableList" width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td>
					<table class="tableList" width="100%" border="1" cellpadding="0" cellspacing="0">
						<tr class="PRHDColRow">
							<th class="PRHDColRowCell" align="left">Name:</th>
							<td class="PRHDColRowCell"><strong>#Employee.FirstName# #Employee.LastName#</strong></td>
						</tr>
						<tr class="PRHDColRow">
							<th class="PRHDColRowCell" align="left">Employer:</th>
							<td class="PRHDColRowCell">#Employee.Employer#</td>
						</tr>
						<tr class="PRHDColRow">
							<th class="PRHDColRowCell" align="left">Employer Ref:</th>
							<td class="PRHDColRowCell">#Employee.EmployerRef#</td>
						</tr>
					</table>
				</td>
				<td>
					<table class="tableList" width="100%" border="1" cellpadding="0" cellspacing="0">
						<tr class="PRHDColRow">
							<th class="PRHDColRowCell" align="left">Week Ending:</th>
							<td class="PRHDColRowCell">#parm.prWeek#</td>
						</tr>
						<tr class="PRHDColRow">
							<th class="PRHDColRowCell" align="left">Week No:</th>
							<td class="PRHDColRowCell">TODO</td>
						</tr>
						<tr class="PRHDColRow">
							<th class="PRHDColRowCell" align="left">Tax Code:</th>
							<td class="PRHDColRowCell">#Employee.TaxCode#</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<table class="tableList" width="100%" border="1" cellpadding="0" cellspacing="0">
		<tr>
			<th style="text-align:left;">Type</th>
			<th data-rate="#Employee.Rate2#" data-day="1" class="PRHDay">Sun</th>
			<th data-rate="#Employee.Rate#" data-day="2" class="PRHDay">Mon</th>
			<th data-rate="#Employee.Rate#" data-day="3" class="PRHDay">Tue</th>
			<th data-rate="#Employee.Rate#" data-day="4" class="PRHDay">Wed</th>
			<th data-rate="#Employee.Rate#" data-day="5" class="PRHDay">Thu</th>
			<th data-rate="#Employee.Rate#" data-day="6" class="PRHDay">Fri</th>
			<th data-rate="#Employee.Rate2#" data-day="7" class="PRHDay">Sat</th>
		</tr>
		<form method="post" enctype="multipart/form-data" id="PRHIForm">
			<input type="hidden" id="PRHRecordID" name="RecordID" value="#PayrollRecords.ID#" />
			<cfloop array="#Types#" index="prefix">
				<tr id="#prefix.string#Row" data-prefix="#prefix.string#">
					<th class="PRHLHeader" align="left">#prefix.title#</th>
					<cfloop list="Sun,Mon,Tue,Wed,Thu,Fri,Sat" delimiters="," index="item">
						<cfswitch expression="#item#">
							<cfcase value="Sun"><cfset weekDayInt = 1></cfcase>
							<cfcase value="Mon"><cfset weekDayInt = 2></cfcase>
							<cfcase value="Tue"><cfset weekDayInt = 3></cfcase>
							<cfcase value="Wed"><cfset weekDayInt = 4></cfcase>
							<cfcase value="Thu"><cfset weekDayInt = 5></cfcase>
							<cfcase value="Fri"><cfset weekDayInt = 6></cfcase>
							<cfcase value="Sat"><cfset weekDayInt = 7></cfcase>
						</cfswitch>
						<cfif StructKeyExists(PayrollRecords.WeekDays, "#prefix.string#")>
							<cfset ItemStruct = StructFind(PayrollRecords.WeekDays, "#prefix.string#")>
							<td
								<cfif prefix.string eq "po">
									data-rate="#Employee.Rate3#"
								<cfelse>
									<cfif item eq "Sun" OR item eq "Sat">
										data-rate="#Employee.Rate2#"
									<cfelse>
										data-rate="#Employee.Rate#"
									</cfif>
								</cfif>
								data-day="#weekDayInt#"
								data-dayStr="#item#"
								data-prefix="#prefix.string#"
								class="PRHIDay"
							>
								<cfif StructFind(ItemStruct, item) is 0.00>
									<input type="text" name="ItemDur" class="PRHIField" value="" />
								<cfelse>
									<input type="text" name="ItemDur" class="PRHIField" value="#StructFind(ItemStruct, item)#" />
								</cfif>
							</td>
						<cfelse>
							<td
								<cfif prefix.string eq "po">
									data-rate="#Employee.Rate3#"
								<cfelse>
									<cfif item eq "Sun" OR item eq "Sat">
										data-rate="#Employee.Rate2#"
									<cfelse>
										data-rate="#Employee.Rate#"
									</cfif>
								</cfif>
								data-day="#weekDayInt#"
								data-dayStr="#item#"
								data-prefix="#prefix.string#"
								class="PRHIDay"
							>
								<input type="text" name="ItemDur" class="PRHIField" value="" />
							</td>
						</cfif>
					</cfloop>
					<th id="#prefix.string#Total" align="right">0</th>
				</tr>
			</cfloop>
		</form>
		<tr style="height:20px;"></tr>
		<tr>
			<th class="PRHLHeader" align="left">Holiday Hours</th>
			<td id="PRHHHTotal"><input type="text" name="HolHrs" class="PRHIField" value="" /></td>
		</tr>
		<tr>
			<th class="PRHLHeader" align="left">Gross Total</th>
			<td id="PRHGrossTotal"><input type="text" name="GT" class="PRHIField_GT" value="" /></td>
		</tr>
		<tr>
			<th class="PRHLHeader" align="left">PAYE</th>
			<td><input type="text" name="PAYE" class="PRHIField_PAYE" value="<cfif Len(PayrollRecords.PAYE)>#PayrollRecords.PAYE#<cfelse>0</cfif>" /></td>
		</tr>
		<tr>
			<th class="PRHLHeader" align="left">NI</th>
			<td><input type="text" name="NI" class="PRHIField_NI" value="<cfif Len(PayrollRecords.NI)>#PayrollRecords.NI#<cfelse>0</cfif>" /></td>
		</tr>
		<tr>
			<th class="PRHLHeader" align="left">Net Pay</th>
			<td><input type="text" name="NP" class="PRHIField_NP" value="#PayrollRecords.NP#" /></td>
		</tr>
	</table>
</cfoutput>