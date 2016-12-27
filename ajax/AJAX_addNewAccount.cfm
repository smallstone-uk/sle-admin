<cftry>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/accounts" name="acc">
	<cfset callback = true>
	<cfset parm = {}>
	<cfset parm.database = application.site.datasource1>
	<cfset parm.url = application.site.normal>
	<cfset parm.form = form>
	<cfset Add = acc.AddAccount(parm)>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>