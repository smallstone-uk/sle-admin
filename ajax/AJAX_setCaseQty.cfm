
<!--- update product field --->

<cfobject component="code/import4" name="import">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.form = form>
<cfset result = import.setCaseQty(parm)>
<cfoutput><div>result</div></cfoutput>

