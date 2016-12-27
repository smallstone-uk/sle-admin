<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="prod">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset del=prod.DeleteBarcode(parm)>

<cfif StructKeyExists(del,"error")>
	<cfoutput>#del.error.message#</cfoutput>
</cfif>