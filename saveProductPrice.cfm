<cftry>
<cfsetting showdebugoutput="no">
<cfobject component="code/stock" name="stock">
<cfset parm = {}>
<cfset parm.newPrice = price>
<cfset parm.product = prodID>
<cfset parm.datasource = application.site.datasource1>
<cfset saveTitle = stock.SaveProductPrice(parm)>

<cfoutput>#parm.newPrice#</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>