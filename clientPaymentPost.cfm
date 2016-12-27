<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/accounts" name="trans">
<cfset parms={}>
<cfset parms.datasource=application.site.datasource1>
<cfset parms.form=form>
<cfset payments=trans.SavePayments(parms)>
