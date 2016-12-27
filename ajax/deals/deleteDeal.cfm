<cftry>
	<cfobject component="code/deals" name="deals">
	<cfset parm = {}>
	<cfset dealID = val(dealID)>
    <cfset deals.DeleteDeal(dealID)>

	<cfcatch type="any">
		<cf_dumptofile var="#cfcatch#">
	</cfcatch>
</cftry>