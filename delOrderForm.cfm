<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>

<script type="text/javascript">
	$(document).ready(function() {
		$('.orderOverlayClose').click(function(event) {   
			$("#orderOverlay").hide();
			event.preventDefault();
		});
		$('#btnDelOrder').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'delOrderAction.cfm',
				data : $('#delOrderForm').serialize(),
				success:function(data){
					$("#orderOverlay").hide();
				}
			});
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<h1>Delete Order</h1>
	<form method="post" enctype="multipart/form-data" id="delOrderForm">
		<input type="hidden" name="orderID" value="#parm.form.orderID#" />
		<p>Are you sure you want to delete this order and all items attached to it?</p>
		<table border="0" width="100%">
			<tr>
				<td>
					<input type="button" id="btnDelOrder" value="Yes" />
				</td>
			</tr>
		</table>
	</form>
</cfoutput>