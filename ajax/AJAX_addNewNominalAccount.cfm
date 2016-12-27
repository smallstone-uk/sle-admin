<cfsetting showdebugoutput="no">
<cfobject component="code/accounts" name="acc">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.form = form>
<cfset add = acc.AddNominalAccount(parm)>

<cfoutput>
	@message: #add.msg#
	@type: #add.type#
</cfoutput>