<cftry>
<cfsetting showdebugoutput="no">
<cfobject component="code/stock" name="stock">
<cfset parm = {}>
<cfset parm.newTitle = title>
<cfset parm.product = prodID>
<cfset parm.datasource = application.site.datasource1>
<cfset saveTitle = stock.SaveProductTitle(parm)>

<cfoutput>#parm.newTitle#</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>