<cftry>
	<cfobject component="code/functions" name="cust">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.url = application.site.normal>
	<!---<cfset parm.form = DeserializeJSON(formData)>--->
	<cfset parm.form = form>
	<cfset save = cust.SaveMsg(parm)>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="SaveMsg" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
