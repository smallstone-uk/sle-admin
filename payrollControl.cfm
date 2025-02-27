<cftry>
<cfsetting requesttimeout="900">
<cfobject component="code/payroll2" name="pr2">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.status = ''>
<cfset employees = pr2.LoadEmployees(parm)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			<!---$('.pr2_manageEmployeeBtn').click(function(event) {
				$.popupDialog({
					file: "AJAX_loadManageEmployee"
				});
				event.preventDefault();
			});--->
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
	<div class="module pr2_content" style="display:none;"></div>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>