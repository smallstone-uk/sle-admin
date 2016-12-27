<cfsetting showdebugoutput="no">
<cfset callback=true>
<cfobject component="code/functions" name="trans">
<cfset parms.datasource=application.site.datasource1>
<cfset parms.form=form>
<cfset payments=trans.SavePayments(parms)>
<cfif application.site.showdumps><cfdump var="#payments#" label="payments result" expand="no"></cfif>
