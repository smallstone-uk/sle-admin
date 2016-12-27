<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/vouchers" name="vch">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>

<script type="text/javascript">
	$(document).ready(function() {
		/*$('#selectState').change(function() {
			var val=$(this).val();
			if (val == "credited") {
				$('#qtycredited').fadeIn();
			} else {
				$('#qtycredited').fadeOut();
			}
		});*/
		$('#btnUpdateVouchers').click(function(e) {
			$.ajax({
				type: 'POST',
				url: 'voucherUpdateAction.cfm',
				data: $('#updateForm').serialize(),
				success:function(data){
					LoadVouchers();
					$("#orderOverlay").fadeOut();
					$("#orderOverlay-ui").fadeOut();
				}
			});
			e.preventDefault();
		});
	});
</script>

<cfoutput>
	<form method="post" id="updateForm">
		<input type="hidden" name="selectitem" value="#parm.form.selectitem#">
		<select name="status" id="selectState">
			<option value="open">Open</option>
			<option value="credited">Credited</option>
			<option value="closed">Closed</option>
		</select>
		<!---<input type="text" name="qtycredited" id="qtycredited" value="" style="display:none;">--->
		<input type="button" id="btnUpdateVouchers" value="Update">
	</form>
</cfoutput>
