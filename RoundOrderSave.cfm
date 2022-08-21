<!--- AJAX call - check client do not show debug data at all --->
<cftry>
	<cfset callback=1><!--- force exit of onrequestend.cfm --->
	<cfsetting showdebugoutput="no" requesttimeout="300">
	<cfparam name="print" default="false">
	
	<cfobject component="code/rounds" name="rnd">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.form=form>
	<cfset order=rnd.SaveRoundOrder(parm)>

	<cfoutput>
		<cfif StructKeyExists(order,"msg")>#order.msg#</cfif>
	</cfoutput>
	
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="roundordersave" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

