<cfsetting showdebugoutput="no">
<cfset callback=true>
<!---<cfif StructKeyExists(form,"fieldnames")>--->
	<cfobject component="code/functions" name="trans">
	<cfset parms.datasource=application.site.datasource1>
	<cfset parms.form=form>
	<cfset payments=trans.SavePayments(parms)>
	<cfdump var="#payments#" label="payments result" expand="no">
<!---</cfif>--->
