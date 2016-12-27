<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="product">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset save=product.AddProductStock(parm)>

<cfoutput>
	<cfif StructKeyExists(save,"msg")><span style="color:##669900;font-size:32px;">#save.msg#</span></cfif>
</cfoutput>