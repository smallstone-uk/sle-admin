
<cfobject component="code/ProductStock6" name="pstock">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfif form.prodID eq 0>
	<cfset result=pstock.AddProduct(parm)>
	<cfoutput>
		<a href="productStock6.cfm?product=#result.productID#">View Product</a>
	</cfoutput>
<cfelse>
	<cfset result=pstock.AmendProduct(parm)>
</cfif>
