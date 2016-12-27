<cfsetting showdebugoutput="no">
<cfobject component="code/accounts" name="acc">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.form = DeserializeJSON(params)>
<cfset SaveNominalGroupItemsOrder = acc.SaveNominalGroupItemsOrder(parm)>