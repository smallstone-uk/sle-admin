<cfsetting showdebugoutput="no">
<cfobject component="code/ProductStock6" name="pstock">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.form = form>
<cfset parm.form.newType = 'product'>
<cfset add = pstock.AddBarcode(parm)>
<cfoutput>#add.msg#</cfoutput>