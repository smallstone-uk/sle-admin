<cftry>
	<cfobject component="code/deals" name="deals">
	<cfset parm = {}>
	<cfset parm.form = form>
	<cfset deals.SaveClub(parm.form)>

	<cfcatch type="any">
		<cf_dumptofile var="#cfcatch#">
	</cfcatch>
</cftry>