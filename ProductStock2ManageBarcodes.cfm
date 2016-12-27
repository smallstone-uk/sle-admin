<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="prod">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset codes=prod.LoadProductBarcodes(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('#NewCode').keypress(function(e){
			var id=$('#newprodID').val();
			var row=$('#rowID').val();
			var code=$('#NewCode').val();
			var type='product';
			if (e.keyCode == 13) {
				AddNewBarcode(id,type,row,code);
			}
		});
		$('#btnDelete').click(function(e) {
			var id=$('#newprodID').val();
			var row=$('#rowID').val();
			$.ajax({
				type: 'POST',
				url: 'ProductStock2DeleteBarcode.cfm',
				data : $('#barcodeForm').serialize(),
				success:function(data){
					ManageBarcodes(id,row)
				}
			});
			e.preventDefault();
		});
		$('#NewCode').focus();
	});
</script>

<cfoutput>
	<h1>Barcode Manager</h1>
	<div style="float:left;width:300px;margin:0 20px 0 0;">
		<form method="post" id="barcodeForm">
			<input type="hidden" id="newprodID" value="#parm.form.ID#">
			<input type="hidden" id="rowID" value="#parm.form.row#">
			<h2>Linked Barcodes</h2>
			<table border="1" class="tableList" width="100%">
				<tr>
					<th width="10"><input type="button" id="btnDelete" value="X" style="font-size: 11px;padding: 2px 6px;margin: 0;float: left;"></th>
					<th align="left">Barcodes</th>
				</tr>
				<cfif ArrayLen(codes)>
					<cfloop array="#codes#" index="i">
						<tr>
							<td><input type="checkbox" name="selectcode" class="selectcode" value="#i.ID#"></td>
							<td>#i.Code#</td>
						</tr>
					</cfloop>
				<cfelse>
					<tr><td colspan="2">No barcodes found</td></tr>
				</cfif>
			</table>
		</form>
	</div>
	<div style="float:left;width:300px;">
		<h2>New Barcode</h2>
		<input type="text" name="NewCode" id="NewCode" style="width:280px;" value="" placeholder="Scan barcode here">
	</div>
</cfoutput>


