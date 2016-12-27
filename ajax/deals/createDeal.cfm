<cftry>
	<cfobject component="code/deals" name="deals">
	<cfset parm = {}>
	<cfset parm.form = DeserializeJSON(jsonContent)>
	<cfset result = deals.CreateDeal(parm.form)>

    <cfoutput>
        #result.addHeader_result.generatedKey#
    </cfoutput>

	<cfcatch type="any">
		<cf_dumptofile var="#cfcatch#">
	</cfcatch>
</cftry>