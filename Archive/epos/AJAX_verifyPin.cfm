<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.user = user>
<cfset parm.pin = val(pin)>
<cfset verify = epos.VerifyPin(parm)>

<cfoutput>
	@id: #verify.id#
	@firstname: #verify.firstname#
	@lastname: #verify.lastname#
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>