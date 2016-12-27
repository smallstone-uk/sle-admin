<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfsetting requesttimeout="3000">

<cfobject component="code/rounds" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset save=rnd.AddToRounds(parm)>

<cfoutput>
	<cfif StructKeyExists(save,"msg")>
		#save.msg#
	</cfif>
</cfoutput>