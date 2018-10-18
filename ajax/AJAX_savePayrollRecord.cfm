<cftry>
	<cfobject component="code/payroll" name="pr">
	<cfset parm = {}>
	<cfset parm.database = application.site.datasource1>
	<cfset parm.form = {}>
	<cfset parm.form.headers = DeserializeJSON(headers)>
	<cfset parm.form.recID = recID>
	<cfset parm.form.empID = empID>
	<cfset parm.form.prWeek = prWeek>
	<cfset parm.form.grossTotal = grossTotal>
	<cfset parm.form.paye = paye>
	<cfset parm.form.ni = ni>
	<cfset parm.form.np = np>
	<cfset parm.form.totalHours = totalHours>
	<cfset SavePayrollRecord = pr.SavePayrollRecord(parm)>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>