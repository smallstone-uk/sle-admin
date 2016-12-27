<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="product">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset cats=product.LoadProductCats(parm)>

<cfoutput>
	<select name="catID" class="type">
		<cfloop array="#cats#" index="i">
			<option value="#i.ID#" style="text-transform:capitalize;">#i.Title#</option>
		</cfloop>
	</select>
</cfoutput>
<script type="text/javascript">
	$(".type").chosen({width: "100%"});
</script>

