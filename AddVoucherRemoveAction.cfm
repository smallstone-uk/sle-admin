<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset remove=cust.ReturnVoucher(parm)>

<cfoutput><cfif StructKeyExists(remove,"msg")><img src="images/icons/tick.png" width="20" height="20" style="float:left;margin:-2px 10px 0 0;">#remove.msg#</cfif></cfoutput>
