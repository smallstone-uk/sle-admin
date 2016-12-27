<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.form = form>
<cfset get = epos.GetBarcode(parm)>
<cfoutput>
	@id: <cfif StructKeyExists(get,"ID")>#get.ID#<cfelse>0</cfif>
	@type: <cfif StructKeyExists(get,"type")>#get.type#<cfelse></cfif>
	@price: <cfif StructKeyExists(get,"price")>#get.price#<cfelse>0</cfif>
	@error: <cfif StructKeyExists(get,"error")>#get.error#<cfelse>true</cfif>
</cfoutput>