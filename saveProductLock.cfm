<cftry>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/stock" name="stock">
	<cfset parm = {}>
	<cfif lock eq 'locked'>
		<cfset lock = 'unlocked'>
	<cfelse><cfset lock = 'locked'></cfif>
	<cfset parm.newLock = lock>
	<cfset parm.product = prodID>
	<cfset parm.datasource = application.site.datasource1>
	<cfset saveLock = stock.SaveProductLock(parm)>

	<cfoutput>#parm.newLock#</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

