<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfset count=0>

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.form=form>
<cfset parm.datasource=application.site.datasource1>

<cfoutput>
<script type="text/javascript">
	$(document).ready(function() {
		$('.orderOverlayClose').click(function(event) {   
			$("##orderOverlay").fadeOut();
			$("##orderOverlay-ui").fadeOut();
			event.preventDefault();
		});
		function GetOrders() {
			var id=$('##OrderID').val();
			$.ajax({
				type: 'POST',
				url: 'LoadClientOrder.cfm',
				data : $('##delPubForm').serialize(),
				beforeSend:function(){},
				success:function(data){$('##OrderList'+id).html(data);},
				error:function(data){}
			});
		};
		$('##PubDelete').click(function(event) { 
			$.ajax({
				type: 'POST',
				url: 'delPubAction.cfm',
				data : $('##delPubForm').serialize(),
				beforeSend:function(){},
				success:function(data){
					GetOrders();			
					$("##orderOverlay").fadeOut();
					$("##orderOverlay-ui").fadeOut();
				},
				error:function(data){}
			});
			event.preventDefault();
		});
	});
</script>
<cfif StructKeyExists(parm.form,"SelectPub")>
	<h1>Remove</h1>
	<form method="post" enctype="multipart/form-data" id="delPubForm">
		<input type="hidden" name="oiOrderID" id="OrderID" value="#parm.form.orderID#" />
		<input type="hidden" name="cltID" value="#parm.form.cltID#" />
		<input type="hidden" name="cltRef" value="#parm.form.cltRef#" />
		<cfloop list="#parm.form.SelectPub#" delimiters="," index="i">
			<cfset count=count+1>
			<input type="hidden" name="selectPub" value="#i#" />
		</cfloop>
		<p>Are you sure you want to remove <cfif count eq 1>this publication<cfelse>these publications</cfif> from this order?</p>
		<table border="0" width="100%">
			<tr>
				<td>
					<button name="btnPubDelete" type="submit" class="overlayNav" id="PubDelete">
						<img src="images/icons/tick.png">&nbsp;Yes
					</button>
				</td>
			</tr>
		</table>
	</form>
<cfelse>
	<h1>Error</h1>
	<p>Please select at least one publication to remove.</p>
</cfif>
</cfoutput>