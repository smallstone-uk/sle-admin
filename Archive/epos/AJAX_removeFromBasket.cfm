<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.index = index>
<cfset parm.source = source>
<cfset parm.sourcepath = "session."&parm.source>

<cfif StructKeyExists(session, parm.source)>
	<cfset StructDelete(Evaluate(parm.sourcepath), parm.index)>
</cfif>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes">
</cfcatch>
</cftry>