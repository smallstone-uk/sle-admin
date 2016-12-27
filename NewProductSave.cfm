<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="product">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset save=product.UpdateProduct(parm)>

<cfif StructKeyExists(save,"msg")>
	<script type="text/javascript">
		$(document).ready(function() { 
			$('#barcodeCheck').val("");
			//$('#barcodeCheck').focus();
		});
	</script>
	<cfoutput><div class="success"><img src="images/icons/tick.png" width="30" style="float:left;" />#save.msg#</div></cfoutput>
</cfif>

<cfif StructKeyExists(save,"error")>
	<script type="text/javascript">
		$(document).ready(function() { 
			$('#barcodeCheck').val("");
			//$('#barcodeCheck').focus();
		});
	</script>
	<cfoutput><div class="error">Opps, something went wrong. Talk to Mike.</div></cfoutput>
</cfif>

