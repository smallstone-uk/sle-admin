<cftry>
	<cfset callback=1>
	<cfsetting showdebugoutput="no">
	<cfparam name="print" default="false">
	<cfobject component="code/publications" name="pub">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.form=form>
	<cfset send=pub.GetBarcode(parm)>
	<cfoutput><cfif send.error>error<cfelse>#val(send.id)#</cfif></cfoutput>	
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
