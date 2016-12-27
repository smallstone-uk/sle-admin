<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/ManualCharge" name="man">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset delete=man.DeleteManualCharges(parm)>

<cfoutput>
	<cfif StructKeyExists(delete,"msg")>#delete.msg#</cfif>
</cfoutput>

