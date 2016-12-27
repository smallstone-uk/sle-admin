<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="prod">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset save=prod.AddStock(parm)>

<cfif StructKeyExists(save,"msg")>
	<cfoutput>#save.msg#</cfoutput>
<cfelse>
	<cfdump var="#save#" label="error" expand="no">
</cfif>
