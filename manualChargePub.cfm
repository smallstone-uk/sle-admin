<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/ManualCharge" name="man">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset pubprice=man.LoadPub(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('#qty').focus();
	});
</script>

<cfoutput>
	<input type="hidden" name="pubPrice" value="#pubprice.price#" />
	<input type="number" name="qty" id="qty" min="1" max="20" value="" size="5" style="text-align:center;" />
</cfoutput>


