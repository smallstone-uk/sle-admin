
<!--- update product field --->

<cfobject component="code/import2" name="import">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.form = form>
<cfset result = import.setValue(parm)>
<cfoutput><div>#result.pm#</div></cfoutput>

