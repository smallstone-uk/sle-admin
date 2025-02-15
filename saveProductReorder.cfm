<cftry>
<cfsetting showdebugoutput="no">
<cfobject component="code/stock" name="stock">
<cfset parm = {}>
<cfset parm.newReorder = Reorder>
<cfset parm.product = prodID>
<cfset parm.datasource = application.site.datasource1>
<cfset saveReorder = stock.SaveProductReorder(parm)>

<cfoutput>#parm.newReorder#</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>