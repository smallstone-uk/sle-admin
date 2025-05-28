<cftry>
<cfobject component="code/payroll2" name="pr2">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.form = form>
<cfset record = pr2.LoadPayrollRecord(parm)>
<cfoutput>
	<script>
		$(document).ready(function(e) {
			holidayDays = function() {
				var days = {
					Monday: false,
					Tuesday: false,
					Wednesday: false,
					Thursday: false,
					Friday: false,
					Saturday: false,
					Sunday: false
				};

				$('.pr2_holiday_item').each(function(i, e) {
					var day = $(e).attr("data-day");
					days[day] = ($(e).find('.pr2_holiday').prop('checked')) ? true : false;
				});

				return days;
			}

			serializeHeader = function() {
				return {
					weekending: "#parm.form.weekending#",
					employee: "#record.employee.ID#",
					weekno: "#pr2.GetPayrollWeekNumber(parm.form.weekending)#",
					method: $('##payMethod').find(":selected").text(),
					gross: calculateGrossTotal(),
					paye: nf($('.pr2_gt_paye').val(), "num"),
					ni: nf($('.pr2_gt_ni').val(), "num"),
					pension_employer: nf($('.pr2_gt_pension_employer').val(), "num"),
					pension_member: nf($('.pr2_gt_pension_member').val(), "num"),
					np: calculateNetPay(),
					total_hours: totalHolidayHours() + totalWorkHours(),
					work_hours: totalWorkHours(),
					hol_hours: totalHolidayHours(),
					lottery_subs: nf($('.pr2_gt_lotto').val(), "num"),
					adjustment: nf($('.pr2_gt_adjustment').val(), "num")
				};
			}

			serializeItems = function() {
				var holidays = holidayDays();
				var result = {
					header: serializeHeader(),
					items: []
				};

				$('.pr2_depts').find('.pr2_item').each(function(i, e) {
					var depID = $(e).parent('tr').find('.pr2_dept').attr("data-dept");
					var rate = nf($(e).parent('tr').find('.pr2_dept').attr("data-rate"), "num");
					var day = $(e).attr("data-day");
					var hours = nf($(e).find('.pr2_item_field').val(), "num");
					var holHours = nf($(e).find('.pr2_item_field').attr("data-holvalue"), "num");

					if (hours != 0) {
						result.items.push({
							rate: rate,
							weekday: day,
							hours: hours,
							gross: rate * hours,
							dept: depID,
							holiday: holidays[day],
							holidayHours: holHours
						});
					}
				});

				$('.pr2_fixed_depts').find('.pr2_fixed_item').each(function(i, e) {
					var depID = $(e).parent('tr').find('.pr2_fixed_dept').attr("data-dept");
					var day = $(e).attr("data-day");
					var value = nf($(e).find('.pr2_fixed_item_field').val(), "num");

					if (value != 0) {
						result.items.push({
							rate: 0,
							weekday: day,
							hours: 0,
							gross: value,
							dept: depID,
							holiday: holidays[day]
						});
					}
				});

				return result;
			}

			sumTotalsY = function() {
				var days = {
					Monday: 0,
					Tuesday: 0,
					Wednesday: 0,
					Thursday: 0,
					Friday: 0,
					Saturday: 0,
					Sunday: 0
				};

				$('.pr2_depts').find('.pr2_item').each(function(i, e) {
					var rate = nf($(e).parent('tr').find('.pr2_dept').attr("data-rate"), "num");
					var day = $(e).attr("data-day");
					var hours = nf($(e).find('.pr2_item_field').val(), "num");
					days[day] += rate * hours;
				});

				return days;
			}

			sumFixedTotalsY = function() {
				var days = {
					Monday: 0,
					Tuesday: 0,
					Wednesday: 0,
					Thursday: 0,
					Friday: 0,
					Saturday: 0,
					Sunday: 0
				};

				$('.pr2_fixed_depts').find('.pr2_fixed_item').each(function(i, e) {
					var day = $(e).attr("data-day");
					var value = nf($(e).find('.pr2_fixed_item_field').val(), "num");
					days[day] += value;
				});

				return days;
			}

			showDayTotals = function() {
				var totals = sumTotalsY();
				var fixed_totals = sumFixedTotalsY();

				$('.pr2_totals').find('.pr2_item').each(function(i, e) {
					var day = $(e).attr("data-day");
					var gross = totals[day];
					$(e).find('.pr2_item_field').val(nf(gross, "str"));
				});

				$('.pr2_fixed_totals').find('.pr2_fixed_item').each(function(i, e) {
					var day = $(e).attr("data-day");
					var gross = fixed_totals[day];
					$(e).find('.pr2_fixed_item_field').val(nf(gross, "str"));
				});
			}

			totalHolidayHours = function() {
				var result = 0;

				$('.pr2_holiday_item').each(function(i, e) {
					var day = $(e).attr("data-day");
					if ($(e).find('.pr2_holiday').prop('checked')) {
						$('.pr2_item[data-day="' + day + '"]').find('.pr2_item_field[data-item="true"]').each(function(index, element) {
							result += nf($(element).val(), "num");
						});
					}
				});

				return result;
			}

			totalWorkHours = function() {
				var result = 0;

				$('.pr2_holiday_item').each(function(i, e) {
					var day = $(e).attr("data-day");
					if (!$(e).find('.pr2_holiday').prop('checked')) {
						$('.pr2_item[data-day="' + day + '"]').find('.pr2_item_field[data-item="true"]').each(function(index, element) {
							result += nf($(element).val(), "num");
						});
					}
				});

				return result;
			}

			calculateGrossTotal = function() {
				var result = 0;

				$('.pr2_totals').find('.pr2_item').find('.pr2_item_field').each(function(i, e) {
					var value = nf($(e).val().trim(), "num");
					result += value;
				});

				$('.pr2_fixed_item_field[data-fixed="true"]').each(function(i, e) {
					var value = ($(e).val().length >= 0) ? nf($(e).val(), "num") : 0;
					result += value;
				});

				return nf(result, "num");
			}

			calculateNetPay = function() {
				var gross = calculateGrossTotal();
				var pension = nf($('.pr2_gt_pension_member').val(), "num");
				var taxable = gross - pension;
				var ni = nf($('.pr2_gt_ni').val(), "num");
				var paye = nf($('.pr2_gt_paye').val(), "num");
				var lotto = nf($('.pr2_gt_lotto').val(), "num");
				var adjustment = nf($('.pr2_gt_adjustment').val(), "num");
				var subtotal = taxable - paye - ni;
				var netpay = subtotal - adjustment;
				$('.pr2_gross_totals')
					.find('td[data-role="deductions"]')
					.html(nf(gross - netpay, 'str'));
				return nf(netpay, "str");
			}

			hourTotals = function() {
				$('.pr2_hour_totals').find('td[data-role="holiday"]').html(nf(totalHolidayHours(), "str"));
				$('.pr2_hour_totals').find('td[data-role="work"]').html(nf(totalWorkHours(), "str"));
				$('.pr2_hour_totals').find('td[data-role="total"]').html(nf(totalHolidayHours() + totalWorkHours(), "str"));
			}

			grossTotals = function() {
				$('.pr2_gross_totals').find('td[data-role="gross"]').html(nf(calculateGrossTotal(), "str"));
				$('.pr2_gross_totals').find('td[data-role="netpay"]').html(nf(calculateNetPay(), "str"));
			}

			showDayTotals();
			hourTotals();
			grossTotals();

			$('.pr2_holiday').change(function(event) {
				hourTotals();
				grossTotals();
			});

			$('.pr2_item_field, .pr2_fixed_item_field, .pr2_gt_ni, .pr2_gt_paye, .pr2_gt_pension_employer, .pr2_gt_pension_member, .pr2_gt_adjustment, .pr2_gt_lotto').keyup(function(event) {
				hourTotals();
				showDayTotals();
				grossTotals();
			});

			$('.pr2_saveBtn').click(function(event) {
				serializeItems();
				showDayTotals();
				hourTotals();
				grossTotals();
				$.ajax({
					type: "POST",
					url: "#parm.url#ajax/AJAX_savePayroll2Record.cfm",
					data: {"result": JSON.stringify(serializeItems())},
					beforeSend: function() {},
					success: function(data) {
						$.messageBox("Save successful", "success");
						$('.pr2-table').prepend(data);
					}
				});
				event.preventDefault();
			});

			$('.pr2_emailWeekBtn').click(function(event) {
				var win = window.open("#parm.url#ajax/AJAX_loadWeeklyPayrollEmail.cfm?weekending=#parm.form.weekending#", '_blank');
				win.focus();
				event.preventDefault();
			});

			$('.pr2_printSingleBtn').click(function(event) {
				var win = window.open("#parm.url#ajax/AJAX_loadSinglePayrollReport.cfm?emp=#parm.form.employee#&weekending=#parm.form.weekending#", '_blank');
				win.focus();
				event.preventDefault();
			});

			$('.pr2_printWeekBtn').click(function(event) {
				var win = window.open("#parm.url#ajax/AJAX_loadWeeklyPayrollReport.cfm?weekending=#parm.form.weekending#", '_blank');
				win.focus();
				event.preventDefault();
			});

			$(document).on("keyup", ".pr2_item_hol_field", function(event) {
				var el = $(this);
				var key = el.attr("id").trim();
				var itemField = $('body').find('.pr2_item_field[holid="' + key + '"]');
				itemField.attr("data-holvalue", el.val());
			});
		});
	</script>
	<cfif StructIsEmpty(record.header)>
		<cfset payMethod = record.employee.Method>
	<cfelseif StructKeyExists(record.header,"phMethod")>
		<cfset payMethod = record.header.phMethod>
	<cfelse>
		<cfset payMethod = 'cash'>
	</cfif>

	<div class="pr2-table">
		<table class="tableList" border="1" width="100%">
			<tr>
				<th align="left" width="200">Employee</th>
				<td width="250">#record.employee.FirstName# #record.employee.LastName#</td>
				<th align="left" width="200">Week Ending</th>
				<td width="250">#DateFormat(parm.form.weekending, "dd/mm/yyyy")#</td>
			</tr>
			<tr>
				<th align="left" width="200">Pay Method</th>
				<td width="250">
					<select name="payMethod" id="payMethod">
						<option value="cash" <cfif payMethod eq "cash">selected="selected"</cfif>>Cash</option>
						<option value="bacs" <cfif payMethod eq "bacs">selected="selected"</cfif>>BACS</option>
					</select>
				</td>
				<th align="left" width="200">Week Number</th>
				<td width="250">
					<cfif !StructKeyExists(record.header,"phWeekNo")>
						#pr2.GetPayrollWeekNumber(parm.form.weekending)#
					<cfelse>#record.header.phWeekNo#</cfif>
				</td>
			</tr>
			<tr>
				<th align="left" width="200">Tax Code</th>
				<td width="250">#record.employee.TaxCode#</td>
				<th align="left" width="200">Employer Ref</th>
				<td width="250">#application.controls.employerRef#</td>
			</tr>
		</table>
		<div style="padding:5px 0;"></div>
		<table class="tableList" border="1" width="100%">
			<tr>
				<th></th>
				<cfloop from="1" to="7" index="i">
					<th width="75">#DayOfWeekAsString(i)#</th>
				</cfloop>
			</tr>
			<cfloop array="#record.employee.depts#" index="dept">
				<cfif !dept.depFixedPay>
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
						<th class="pr2_dept" data-dept="#dept.depID#" data-rate="#payRate#" align="left">
							#dept.depName#<strong style="float:right;">#payRate#</strong></th>
						<cfloop from="1" to="7" index="i">
							<cfif StructKeyExists(deptItems, "#DayOfWeekAsString(i)#")>
								<cfset dayItem = StructFind(deptItems, "#DayOfWeekAsString(i)#")>
								<td class="pr2_item" width="75" data-day="#DayOfWeekAsString(i)#">
									<cfif dayItem.piHours + dayItem.piHolHours neq 0>
										<input type="text" data-item="true" data-holid="#dept.depID#-#i#" data-holvalue="" class="pr2_item_field" 
											value="#dayItem.piHours + dayItem.piHolHours#">
									<cfelse>
										<input type="text" data-item="true" data-holid="#dept.depID#-#i#" data-holvalue="" class="pr2_item_field" 
											value="">
									</cfif>
								</td>
							<cfelse>
								<td class="pr2_item" width="75" data-day="#DayOfWeekAsString(i)#">
									<input type="text" data-item="true" data-holid="#dept.depID#-#i#" data-holvalue="" class="pr2_item_field" value="">
								</td>
							</cfif>
						</cfloop>
					</tr>
				</cfif>
			</cfloop>
			<tr>
				<th align="left">Holiday</th>
				<cfloop from="1" to="7" index="i">
					<cfset isHoliday = false>
					<cfset holArray = StructFindKey(record.items, "#DayOfWeekAsString(i)#", "all")>
					<cfif !ArrayIsEmpty(holArray)>
						<cfloop array="#holArray#" index="holItem">
							<cfif holItem.value.piHoliday eq "Yes">
								<cfset isHoliday = true>
							</cfif>
						</cfloop>
					</cfif>
					<td class="pr2_holiday_item" data-day="#DayOfWeekAsString(i)#" width="75">
						<input type="checkbox" class="pr2_holiday" <cfif isHoliday>checked="checked"</cfif>>
					</td>
				</cfloop>
			</tr>
			<tr class="pr2_totals">
				<th align="left">Total</th>
				<cfloop from="1" to="7" index="i">
					<td class="pr2_item" width="75" data-day="#DayOfWeekAsString(i)#">
						<input type="text" class="pr2_item_field" disabled="disabled">
					</td>
				</cfloop>
			</tr>
		</table>
		<cfset hasFixedDepts = false>
		<cfloop array="#record.employee.depts#" index="dept">
			<cfset hasFixedDepts = (dept.depFixedPay) ? true : false>
		</cfloop>
		<cfif hasFixedDepts>
			<div style="padding:5px 0;"></div>
			<table class="tableList" border="1" width="100%">
				<tr>
					<th></th>
					<cfloop from="1" to="7" index="i">
						<th width="75">#DayOfWeekAsString(i)#</th>
					</cfloop>
				</tr>
				<cfloop array="#record.employee.depts#" index="dept">
					<cfif dept.depFixedPay>
						<cfif StructKeyExists(record.items, dept.depName)>
							<cfset deptItems = StructFind(record.items, dept.depName)>
						<cfelse>
							<cfset deptItems = {}>
						</cfif>
						<tr class="pr2_fixed_depts">
							<th class="pr2_fixed_dept" data-dept="#dept.depID#" align="left">#dept.depName#<strong style="float:right;">&pound;</strong></th>
							<cfloop from="1" to="7" index="i">
								<cfif StructKeyExists(deptItems, "#DayOfWeekAsString(i)#")>
									<cfset dayItem = StructFind(deptItems, "#DayOfWeekAsString(i)#")>
									<td class="pr2_fixed_item" width="75" data-day="#DayOfWeekAsString(i)#">
										<cfif dayItem.piGross gt 0>
											<input type="text" data-fixed="true" class="pr2_fixed_item_field" value="#dayItem.piGross#">
										<cfelse>
											<input type="text" data-fixed="true" class="pr2_fixed_item_field" value="">
										</cfif>
									</td>
								<cfelse>
									<td class="pr2_fixed_item" width="75" data-day="#DayOfWeekAsString(i)#">
										<input type="text" data-fixed="true" class="pr2_fixed_item_field" value="">
									</td>
								</cfif>
							</cfloop>
						</tr>
					</cfif>
				</cfloop>
				<tr class="pr2_fixed_totals">
					<th align="left">Total</th>
					<cfloop from="1" to="7" index="i">
						<td class="pr2_fixed_item" width="75" data-day="#DayOfWeekAsString(i)#">
							<input type="text" class="pr2_fixed_item_field" disabled="disabled">
						</td>
					</cfloop>
				</tr>
			</table>
		</cfif>
		<div style="padding:5px 0;"></div>
		<table class="tableList" border="0" width="100%">
			<tr>
				<td style="vertical-align: top;padding: 0;" align="left">
					<table class="tableList pr2_hour_totals" border="1">
						<tr>
							<th align="left" width="150">Holiday Hours</th>
							<td data-role="holiday" width="150" align="right"></td>
						</tr>
						<tr>
							<th align="left" width="150">Work Hours</th>
							<td data-role="work" width="150" align="right"></td>
						</tr>
						<tr>
							<th align="left" width="150">Total Hours</th>
							<td data-role="total" width="150" align="right"></td>
						</tr>
					</table>
				</td>
				<cfif hasFixedDepts>
					<td style="vertical-align: top;padding: 0;" align="center">
						<table class="tableList pr2_fixed_summary_totals" border="1">
							<tr>
								<th align="left" width="150">Fixed Pay</th>
								<td data-role="fixed_gross" width="150" align="right"></td>
							</tr>
							<tr>
								<th align="left" width="150" style="font-size:16px;">Total Pay</th>
								<td data-role="overall_gross" width="150" align="right" style="font-size:16px;"></td>
							</tr>
						</table>
					</td>
				</cfif>
				<td style="vertical-align: top;padding: 0;" align="right">
					<table class="tableList pr2_gross_totals" border="1">
						<tr>
							<th align="left" width="150">Pension Employer</th>
							<td data-role="pension_employer" width="150" style="padding:0;">
								<cfif StructIsEmpty(record.header)>
									<input type="text" class="pr2_gt_pension_employer" value="">
								<cfelse>
									<input type="text" class="pr2_gt_pension_employer" value="#record.header.phEmployerContribution#">
								</cfif>
							</td>
						</tr>
						<tr>
							<th align="left" width="150">Pension Member</th>
							<td data-role="pension_member" width="150" style="padding:0;">
								<cfif StructIsEmpty(record.header)>
									<input type="text" class="pr2_gt_pension_member" value="">
								<cfelse>
									<input type="text" class="pr2_gt_pension_member" value="#record.header.phMemberContribution#">
								</cfif>
							</td>
						</tr>
						<tr>
							<th align="left" width="150">PAYE</th>
							<td data-role="paye" width="150" style="padding:0;">
								<cfif StructIsEmpty(record.header)>
									<input type="text" class="pr2_gt_paye" value="">
								<cfelse>
									<input type="text" class="pr2_gt_paye" value="#record.header.phPAYE#">
								</cfif>
							</td>
						</tr>
						<tr>
							<th align="left" width="150">National Insurance</th>
							<td data-role="ni" width="150" style="padding:0;">
								<cfif StructIsEmpty(record.header)>
									<input type="text" class="pr2_gt_ni" value="">
								<cfelse>
									<input type="text" class="pr2_gt_ni" value="#record.header.phNI#">
								</cfif>
							</td>
						</tr>
						<tr>
							<th align="left" width="150">Lottery Subs</th>
							<td data-role="lotto" width="150" style="padding:0;">
								<cfif StructIsEmpty(record.header)>
									<input type="text" class="pr2_gt_lotto" value="">
								<cfelse>
									<input type="text" class="pr2_gt_lotto" value="#record.header.phLotterySubs#">
								</cfif>
							</td>
						</tr>
						<tr>
							<th align="left" width="150">Adjustment</th>
							<td data-role="adjustment" width="150" style="padding:0;">
								<cfif StructIsEmpty(record.header)>
									<input type="text" class="pr2_gt_adjustment" value="">
								<cfelse>
									<input type="text" class="pr2_gt_adjustment" value="#record.header.phAdjustment#">
								</cfif>
							</td>
						</tr>
					</table>
				</td>
				<td style="vertical-align: top;padding: 0;" align="right">
					<table class="tableList pr2_gross_totals" border="1">
						<tr>
							<th align="left" width="150">Gross Pay</th>
							<td data-role="gross" width="150" align="right"></td>
						</tr>
						<tr>
							<th align="left" width="150">Total Deductions</th>
							<td data-role="deductions" width="150" align="right"></td>
						</tr>
						<tr>
							<th align="left" width="150">Net Pay</th>
							<td data-role="netpay" width="150" align="right"></td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<div style="padding:5px 0;"></div>
		<button class="pr2_saveBtn">Save</button>
		<button class="pr2_printWeekBtn">Print Week</button>
		<button class="pr2_emailWeekBtn">Email Week</button>
		<button class="pr2_printSingleBtn">Print Single</button>
	</div>
</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html"
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
