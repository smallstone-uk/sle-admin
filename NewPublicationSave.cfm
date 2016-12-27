<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset save=func.AddNewPub(parm)>

<cfoutput>
<cfif StructKeyExists(save,"msg")><span class="success">#save.msg#</span></cfif>
<cfif StructKeyExists(save,"error")><span class="error">#save.error#</span></cfif>
</cfoutput>
