
<cfobject component="code/ProductStock4" name="pstock">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset bookInResult=pstock.BookInProductStock4(parm)>

<cfoutput>
	<table border="1" width="600" class="stockItems">
		<tr><td rowspan="10">#bookInResult.img#</td></tr>
		<tr><td><a href="stockItems.cfm?ref=#bookInResult.prodID#" target="_blank">#bookInResult.prodRef#</a></td></tr>
		<tr><td>#bookInResult.prodTitle#</td></tr>
		<tr><td>Size : #bookInResult.prodUnitSize#</td></tr>
		<tr><td>&pound;#bookInResult.prodOurPrice# <cfif bookInResult.prodPriceMarked> PM </cfif></td></tr>
		<tr><td>Pack Qty : #bookInResult.prodPackQty#</td></tr>
		<tr><td>Received : #bookInResult.packs#</td></tr>
		<tr><td>Expires : #LSDateFormat(bookInResult.siExpires)#</td></tr>
		<tr><td>#bookInResult.msg#</td></tr>
	</table>
</cfoutput>