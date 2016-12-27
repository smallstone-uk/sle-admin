<cftry>
	<cfobject component="code/accounts" name="acc">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.form = DeserializeJSON(data)>
	<cfset parm.accID = accID>
	<cfset alloc = acc.AllocateItems(parm)>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
