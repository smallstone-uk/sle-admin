<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="cust">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.form = form>
<cfset result = cust.SaveMsg(parm)>

<cfoutput>
	<cfif StructKeyExists(result,"msg")>#result.msg#</cfif>
</cfoutput>