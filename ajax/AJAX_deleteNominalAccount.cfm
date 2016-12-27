<cfsetting showdebugoutput="no">
<cfobject component="code/accounts" name="acc">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.nomID = nomID>
<cfset DeleteNominalAccount = acc.DeleteNominalAccount(parm)>
<cfoutput>#DeleteNominalAccount#</cfoutput>