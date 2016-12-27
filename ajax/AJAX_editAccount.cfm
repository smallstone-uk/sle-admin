<cfsetting showdebugoutput="no">
<cfobject component="code/accounts" name="acc">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.form = form>
<cfset edit = acc.EditAccount(parm)>