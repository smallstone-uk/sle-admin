<cftry>
	<cfobject component="code/deals" name="deals">
	<cfset parm = {}>
	<cfset parm.form = DeserializeJSON(jsonContent)>
	<cfset deals.UpdateDeal(parm.form)>

	<cfcatch type="any">
		<cf_dumptofile var="#cfcatch#">
	</cfcatch>
</cftry>