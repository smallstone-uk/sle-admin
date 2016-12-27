<cfsetting showdebugoutput="no">
<cfobject component="code/accounts" name="acc">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.code = code>
<cfset Result = acc.CheckAccountCodeExists(parm.code)>

<cfoutput>#Result#</cfoutput>