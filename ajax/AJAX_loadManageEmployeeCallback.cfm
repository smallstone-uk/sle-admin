<cftry>
<cfobject component="code/payroll2" name="pr2">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.form = form>
<cfset departments = pr2.LoadEmployeeDepartments(parm)>

<cfoutput>
	<script>
		$(document).ready(function(e) {});
	</script>
	<form method="post" enctype="multipart/form-data" id="">
		<cfloop array="#departments#" index="item">
		</cfloop>
	</form>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>