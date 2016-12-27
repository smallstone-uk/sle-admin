<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/vouchers" name="vch">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset titles=vch.LoadTitles(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('#btnAdd').click(function() {
			$.ajax({
				type: 'POST',
				url: 'voucherNewAction.cfm',
				data: $('#newForm').serialize(),
				success:function(data){
					$("#orderOverlay").fadeOut();
					$("#orderOverlay-ui").fadeOut();
					GetVoucher();
				}
			});
		});
		$('#NewBarcode').val($('#barcode').val());
	});
</script>

<cfoutput>
	<h1>Add Voucher Barcode</h1>
	<form method="post" id="newForm">
		<input type="hidden" name="barcode" id="NewBarcode" value="" autocomplete="off">
		<table border="0" width="500">
			<tr>
				<th width="80">Voucher</th>
				<td>
					<cfif ArrayLen(titles)>
						<select name="TitleID" id="vchTitles">
							<cfloop array="#titles#" index="i">
								<option value="#i.ID#">#i.Title# <cfif i.Amount lt 1>#i.Amount*100#p<cfelse>&pound;#DecimalFormat(i.Amount)#</cfif> Off</option>
							</cfloop>
						</select>
					</cfif>
				</td>
			</tr>
			<tr>
				<td colspan="2"><input type="button" id="btnAdd" value="Add"></td>
			</tr>
		</table>
	</form>
</cfoutput>
<script type="text/javascript">
	$("#vchTitles").chosen({width: "100%",disable_search_threshold: 10});
</script>


