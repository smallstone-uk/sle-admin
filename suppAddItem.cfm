<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfdump var="#form#" label="form" expand="yes" format="html" 
output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
<cfobject component="code/accounts" name="supp">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset add=supp.AddItem(parm)>

<cfoutput>
	<cfif StructKeyExists(add,"msg")>#add.msg#</cfif>
</cfoutput>
