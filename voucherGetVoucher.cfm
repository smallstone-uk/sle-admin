<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfobject component="code/vouchers" name="vch">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset send=vch.GetBarcode(parm)>
<cfoutput><cfif StructKeyExists(send,"error")><cfif send.error>error</cfif><cfelse>#send.msg#</cfif></cfoutput>	
	