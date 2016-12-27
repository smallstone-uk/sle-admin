<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/ManualCharge" name="man">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset AddCharge=man.AddCharge(parm)>

<cfoutput>
	<cfif StructKeyExists(AddCharge,"msg")>
		#AddCharge.msg#
	<cfelse>
		<cfdump var="#AddCharge#" label="AddCharge" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
	</cfif>
</cfoutput>
