<cftry>
	<cfobject component="code/deals" name="deals">
	<cfset parm = {}>
	<cfset parm.prodID = val(prodID)>
	<cfset parm.dealID = val(dealID)>
	<cfset remove = deals.RemoveProductFromDeal(parm.dealID, parm.prodID)>

	<cfcatch type="any">
		<cf_dumptofile var="#cfcatch#">
	</cfcatch>
</cftry>