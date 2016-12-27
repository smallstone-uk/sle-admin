<cftry>
<cfobject component="code/accounts" name="acc">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.tranID = val(tranID)>
<cfset del = acc.DeleteNominalTransaction(parm)>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes">
</cfcatch>
</cftry>