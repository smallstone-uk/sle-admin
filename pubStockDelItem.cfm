<!--- AJAX call - check client do not show debug data at all --->
<cftry>
	<cfset callback=1><!--- force exit of onrequestend.cfm --->
	<cfsetting showdebugoutput="no">
	<cfparam name="print" default="false">
	
	<cfobject component="code/functions" name="func">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.form=form>
	<cfset delete=func.DeletePubStockItems(parm)>
	<cfoutput><cfif StructKeyExists(delete,"msg")>#delete.msg#</cfif></cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="pubStockDelItem" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
