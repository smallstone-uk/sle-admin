<cftry>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/stock" name="stock">
	<cfset parm = {}>
	<cfif discount eq "Yes">
		<cfset discount = "No">
	<cfelse><cfset discount = "Yes"></cfif>
	<cfset parm.newDiscount = discount>
	<cfset parm.product = prodID>
	<cfset parm.datasource = application.site.datasource1>
	<cfset saveStatus = stock.SaveProductDiscount(parm)>

	<cfoutput>#parm.newDiscount#</cfoutput>
	

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

