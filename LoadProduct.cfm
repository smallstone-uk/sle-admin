<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/till" name="till">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.barcode=barcode>
<cfset product=till.GetBarcode(parm)>

<cfoutput>
	<cfif NOT len(product.error)>
		Product Added
	<cfelse>
		#product.error#
	</cfif>
</cfoutput>

