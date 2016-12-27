<cfobject component="code/accounts" name="acc">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.form = form>
<cfset SaveAccountTransRecord = acc.SaveAccountTransRecord(parm)>
