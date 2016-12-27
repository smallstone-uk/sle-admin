<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="prod">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.id=form.prodid>
<cfset getcode=prod.GetProductBarcode(parm)>
<cfoutput>#getcode.code#</cfoutput>