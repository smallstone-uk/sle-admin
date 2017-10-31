<cfsetting requesttimeout="900">

<cfset model = new App.Employee()>
<cfset employees = model.flatten(
	model.where('empStatus', 'active').orderBy('empFirstName').get(),
	['empPin']
)>

<cfoutput>
	<!--- <script>
		$(document).ready(function(e) {
			loadRecord = function() {
				$.ajax({
					type: "POST",
					url: "#parm.url#ajax/AJAX_loadPayrollEmployeeHeader.cfm",
					data: $('##ph2_control_form').serialize(),
					success: function(data) {
						$('.pr2_content').html(data).show();
					}
				});
			}
			$('select[name="employee"]').change(function(event) {
				loadRecord();
			});
			$('.datepicker').datepicker({
				dateFormat: "yy-mm-dd",
				changeMonth: true,
				changeYear: true,
				showButtonPanel: true,
				minDate: new Date(2013, 1 - 1, 1),
				onClose: function() {
					if ($(this).val().length > 0)
						loadRecord();
				}
			});
		});
	</script>
	<div class="module ph2_control">
		<form method="post" enctype="multipart/form-data" id="ph2_control_form" style="float:left;">
			<table class="tableList" border="0" width="100%">
				<tr>
					<td>
						<select name="employee">
							<option value="">Select employee</option>
							<cfloop array="#employees#" index="item">
								<option value="#item.empID#">#item.empFirstName# #item.empLastName#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<input type="text" name="weekending" class="datepicker" placeholder="Pick week">
					</td>
				</tr>
			</table>
		</form>
		<!---<button class="pr2_manageEmployeeBtn" style="float:right;">Manage Employees</button>--->
	</div>
	<div class="module pr2_content" style="display:none;"></div> --->

	<div class="payroll-app">
		<div class="module">
			<select v-model="employee">
				<option :value="null">Select employee</option>
				<option v-for="e in employees" :value="e.empid">
					{{ e.empfirstname }} {{ e.emplastname }}
				</option>
			</select>

			<input v-model="weekEnding" class="datepicker" placeholder="Pick week">
		</div>

		<div v-if="header" class="module">
			<table class="tableList" border="1" width="100%">
				<tr>
					<th align="left" width="200">Employee</th>
					<td width="250">{{ header.employee.firstname }} {{ header.employee.lastname }}</td>
					<th align="left" width="200">Week Ending</th>
					<td width="250">{{ weekEnding }}</td>
				</tr>

				<tr>
					<th align="left" width="200">Tax Code</th>
					<td width="250">{{ header.employee.taxcode }}</td>
					<th align="left" width="200">Week Number</th>
					<td width="250">{{ header.weeknumber }}</td>
				</tr>
			</table>

			<div style="padding: 5px 0"></div>

			<table class="tableList" border="1" width="100%">
				<tr>
					<th></th>
					<th width="75">Monday</th>
					<th width="75">Tuesday</th>
					<th width="75">Wednesday</th>
					<th width="75">Thursday</th>
					<th width="75">Friday</th>
					<th width="75">Saturday</th>
					<th width="75">Sunday</th>
				</tr>

				<tr v-for="d in departments" class="pr2_depts">
					<th class="pr2_dept" align="left">
						{{ d.department.DEPNAME }}
						<strong style="float: right">{{ d.payRate }}</strong>
					</th>

					<td v-for="day in getDays(d.department)" class="pr2_item" width="75">
						<input class="pr2_item_field" :value="day.pihours">
					</td>

					<!--- <cfloop from="1" to="7" index="i">
						<cfif StructKeyExists(deptItems, "#DayOfWeekAsString(i)#")>
							<cfset dayItem = StructFind(deptItems, "#DayOfWeekAsString(i)#")>
							<td class="pr2_item" width="75" data-day="#DayOfWeekAsString(i)#">
								<cfif dayItem.piHours neq 0>
									<input type="text" data-item="true" data-holid="#dept.depID#-#i#" data-holvalue="" class="pr2_item_field" value="#dayItem.piHours#">
								<cfelse>
									<input type="text" data-item="true" data-holid="#dept.depID#-#i#" data-holvalue="" class="pr2_item_field" value="">
								</cfif>
							</td>
						<cfelse>
							<td class="pr2_item" width="75" data-day="#DayOfWeekAsString(i)#">
								<input type="text" data-item="true" data-holid="#dept.depID#-#i#" data-holvalue="" class="pr2_item_field" value="">
							</td>
						</cfif>
					</cfloop> --->
				</tr>
			</table>
		</div>
	</div>

	<script>
		#toScript(employees, 'window.employees')#;

		var app = new Vue({
			el: '.payroll-app',

			data: {
				header: null,
				employee: null,
				weekEnding: '2014-06-28',
				employees: window.employees,
				dayMap: {
					monday: 1,
					tuesday: 2,
					wednesday: 3,
					thursday: 4,
					friday: 5,
					saturday: 6,
					sunday: 7
				}
			},

			computed: {
				departments() {
					var result = [];

					for (var department of this.header.employee.depts) {
						if (department.DEPFIXEDPAY) continue;

						var items = {};
						var dayPay = null;
						var payRate = null;

						if (department.DEPNAME in this.header.items) {
							items = this.header.items[department.DEPNAME];

							if (Object.keys(items).length) {
								for (var key in items) {
									dayPay = items[key];
									payRate = dayPay.pirate; // piRate, not pirate
									break;
								}
							}
						} else {
							payRate = department.RTRATE;
						}

						result.push({
							items: items,
							dayPay: dayPay,
							payRate: payRate,
							department: department
						});
					}

					return result;
				}
			},

			watch: {
				employee: function(newEmployee) {
					if (this.weekEnding === null) return;
					this.fetch();
				},

				weekEnding: function(newWeekEnding) {
					if (newWeekEnding === null) return;
					this.fetch();
				}
			},

			methods: {
				fetch: function() {
					this.$http.get('/api/payroll/'+this.employee+'/'+this.weekEnding)
						.then(function(response) {
							this.header = JSON.parse(response.body);
						});
				},

				getDays(department) {
					var itemArray = [];
					var item = this.header.items[department.DEPNAME.toLowerCase()];

					if (!Object.keys(item).length) {
						for (var d in this.dayMap) {
							itemArray.push({
								piday: d,
								pihours: 0
							});
						}

						return itemArray;
					}

					for (var key in item) {
						itemArray.push(item[key]);
					}

					itemArray.sort(function(a, b) {
						var day1 = a.piday.toLowerCase();
						var day2 = b.piday.toLowerCase();
						return this.dayMap[day1] > this.dayMap[day2];
					}.bind(this));

					return itemArray;
				}
			}
		});

	    $(document).ready(function(e) {
			$('.datepicker').datepicker({
				dateFormat: 'yy-mm-dd',
				changeMonth: true,
				changeYear: true,
				showButtonPanel: true,
				minDate: new Date(2013, 0, 1),
				onClose: function() {
					if ($(this).val().length > 0)
						app.weekEnding = $(this).val();
				}
			});
	    });
	</script>
</cfoutput>
