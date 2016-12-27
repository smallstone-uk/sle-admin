<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="prod">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset add=prod.AddBarcode(parm)>

<cfif StructKeyExists(add,"error")>
	<cfoutput>#add.error.message#</cfoutput>
</cfif>