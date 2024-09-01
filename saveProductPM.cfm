<cftry>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/stock" name="stock">
	<cfset parm = {}>
	<cfif status eq "active">
		<cfset status = "inactive">
	<cfelse><cfset status = "active"></cfif>
	<cfset parm.newStatus = status>
	<cfset parm.product = prodID>
	<cfset parm.datasource = application.site.datasource1>
	<cfset saveStatus = stock.SaveProductStatus(parm)>

	<cfoutput>#parm.newStatus#</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

