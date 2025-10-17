
<cfobject component="code/accReports" name="report">

<cfset parms = {}>
<cfset parms.datasource = application.site.datasource1>
<cfset parms.form = form>

<cfset data = report.InvertValue(parms)>

<cfoutput>#DecimalFormat(data.value)#</cfoutput>
