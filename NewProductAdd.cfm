<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="product">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset add=product.AddProduct(parm)>

<cfif StructKeyExists(add,"msg")>
	<script type="text/javascript">
		$(document).ready(function() { 
			$('#barcodeCheck').val("");
			//$('#barcodeCheck').focus();
		});
	</script>
	<cfoutput>
		<div class="success"><img src="images/icons/tick.png" width="30" style="float:left;" />#add.msg#</div>
	</cfoutput>
</cfif>

<cfif StructKeyExists(add,"error")>
	<script type="text/javascript">
		$(document).ready(function() { 
			$('#barcodeCheck').val("");
			//$('#barcodeCheck').focus();
		});
	</script>
	<cfdump var="#add#" label="Error" expand="no">
	<cfoutput><div class="error">Opps, something went wrong. Talk to Mike.</div></cfoutput>
</cfif>


