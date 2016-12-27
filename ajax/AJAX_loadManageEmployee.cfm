<cftry>
<cfobject component="code/payroll2" name="pr2">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset employees = pr2.LoadEmployees(parm)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('.pr2_me_employee').change(function(event) {
				$.ajax({
					type: "POST",
					url: "#parm.url#ajax/AJAX_loadManageEmployeeCallback.cfm",
					data: $('##pr2_me_form').serialize(),
					success: function(data) {
						$('.pr2_me_callback').html(data);
					}
				});
				event.preventDefault();
			});
		});
	</script>
	<h1>Manage Employee</h1>
	<form method="post" enctype="multipart/form-data" id="pr2_me_form">
		<select name="employee" class="pr2_me_employee">
			<cfloop array="#employees#" index="item">
				<option value="#item.empID#">#item.empFirstName# #item.empLastName#</option>
			</cfloop>
		</select>
	</form>
	<div class="pr2_me_callback"></div>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" output="#application.directory#\data\logs\E#DateFormat(Now(), 'yyyymmdd')##TimeFormat(Now(), 'HHmmss')#.html" format="html">
</cfcatch>
</cftry>