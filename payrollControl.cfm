<cftry>
<cfsetting requesttimeout="900">
<cfobject component="code/payroll2" name="pr2">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>

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
	</script> --->
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
	<div class="module pr2_content" style="display:none;"></div>

	<div class="payroll-app module">
		<select v-model="employee">
			<option :value="null">Select employee</option>
			<option v-for="employee in employees" :value="employee.empid">
				{{ employee.empfirstname }} {{ employee.emplastname }}
			</option>
		</select>

		<input v-model="weekEnding" class="datepicker" placeholder="Pick week">
	</div>

	<script>
		#toScript(employees, 'window.employees')#;

		var app = new Vue({
			el: '.payroll-app',

			data: {
				header: null,
				employee: null,
				weekEnding: null,
				employees: window.employees
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
					this.$http.get('/ajax/payroll/show.cfm?employee='+this.employee.empid+'&weekending='+this.weekEnding)
						.then(function(response) {
							this.header = response.body;
						});
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

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html"
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
