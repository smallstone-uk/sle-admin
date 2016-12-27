<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="product">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset load=product.LoadProductCache(parm)>

<cfoutput>
	<table border="1" class="tableList">
		<tr>
			<th>Title</th>
			<th>Pack</th>
			<th>Pack Price</th>
			<th>Price</th>
			<th>Vat Rate</th>
		</tr>
		<cfif ArrayLen(load.list)>
			<cfloop array="#load.list#" index="i">
				<tr>
					<td>#i.Title#</td>
					<td>#i.Pack#</td>
					<td>#i.PackPrice#</td>
					<td>#i.Price#</td>
					<td>#i.VatRate#</td>
				</tr>
			</cfloop>
		<cfelse>
			<tr><td colspan="5">No products have been entered today</td></tr>
		</cfif>
	</table>
</cfoutput>
