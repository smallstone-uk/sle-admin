<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.index = index>
<cfset parm.newQty = val(newQty)>

<cfif StructKeyExists(session,"epos")>
	<cfset prod=StructFind(session.epos,parm.index)>
	<cfset parm.form.prodID=prod.prodID>
	<cfset parm.form.Qty=parm.newQty>
	<cfset parm.form.type=prod.type>
	<cfset load=epos.LoadProduct(parm)>
	<cfset StructDelete(session.epos,parm.index)>
	<cfset add=epos.AddToBasket(load)>
</cfif>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes">
</cfcatch>
</cftry>