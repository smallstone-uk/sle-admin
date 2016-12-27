<cftry>
	<cfobject component="code/accounts" name="acc">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.url = application.site.normal>
	<cfset parm.newAccount = val(newAccount)>
	<cfset parm.tranID = val(tranID)>
	<cfset moveTran = acc.MoveTranToAccount(parm)>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>