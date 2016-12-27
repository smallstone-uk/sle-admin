<cftry>
<cfobject component="code/accounts" name="acc">
<cfsetting requesttimeout="900" showdebugoutput="no">
<cfflush interval="200">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.form = form>
<cfset trigger = acc.TriggerNominalTotalWipe(parm)>

<!---<cfoutput>#trigger#</cfoutput>--->

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="false">
</cfcatch>
</cftry>