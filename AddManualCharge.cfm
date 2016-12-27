<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.form=form>
<cfset parm.datasource=application.site.datasource1>
<cfset AddCharge=func.AddManualCharge(parm)>
