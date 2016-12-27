<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.form = form>
<cfset add = epos.AddToBasket(parm)>

<cfdump var="#add#" label="add" expand="no">