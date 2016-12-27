<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/accounts" name="supp">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset add=supp.AddItem(parm)>

<cfoutput>
	<cfif StructKeyExists(add,"msg")>#add.msg#</cfif>
</cfoutput>
