
<cfsetting showdebugoutput="no">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.form = form>
<cfobject component="code/ProductStock6" name="pstock">
<cfset record = pstock.SaveProductCategory(parm)>
