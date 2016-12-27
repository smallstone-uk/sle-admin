
<cfobject component="code/ProductStock6" name="pstock">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset lookup=pstock.FindProduct(parm)>
<cfif lookup.action eq "Found">
	<cfset parm.product = lookup.product.prodID>
	<cfset result=pstock.AddProductToList(parm)>
</cfif>
