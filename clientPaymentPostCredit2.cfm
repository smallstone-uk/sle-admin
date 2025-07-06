<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no" requesttimeout="300">
<cfparam name="print" default="false">

<cfobject component="code/accounts2" name="trans">
<cfset parms = {}>
<cfset parms.datasource = application.site.datasource1>
<cfset parms.form = form>
<cfset credit = trans.SaveCreditPayment(parms)>
