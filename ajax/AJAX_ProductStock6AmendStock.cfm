<cftry>
	<cfset callback = true>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.url = application.site.normal>
	<cfset parm.id = form.id>
	<cfset parm.barcode = form.barcode>
	<cfset record = pstock.LoadStockItem(parm)>
	<cfset suppliers = pstock.LoadSuppliers(parm)>
	<!---<cfdump var="#record#" label="record" expand="false">--->
	<style type="text/css">
		.field, .itemcount, .price, .datepicker, .datepickerTo, .numbersOnly {font-size:18px}
	</style>
	<script>
		$(document).ready(function(e) {
			var target = <cfoutput>#record.product.pgTarget#</cfoutput>
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, maxDate: new Date, minDate: new Date(2012, 1 - 1, 1)});
			$('.datepickerTo').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2012, 1 - 1, 1)});

			$('#siOurPrice').keydown(function(e) {
				if (e.keyCode > 36 && e.keyCode < 41) {
					var oldPrice = parseFloat($('#siOurPrice').val());
					if (e.keyCode == 38 ) {
						var newPrice = oldPrice + 0.01;
					}
					if (e.keyCode == 40 ) {
						var newPrice = oldPrice - 0.01;
					}
					$('#siOurPrice').val(newPrice.toFixed(2));
					checkPrice(target);
				}
			});
			
			$('.price').blur(function(e) {
				$('div.err').remove();
				checkPrice(target);
			});
			$('#btnSubmit').click(function(e) {
				$('div.err').remove();
				var dataOK = false;
				$('div.err').remove();
				dataOK = checkFields();
				if (dataOK) {
					 SaveStock('#StockForm','#stockdiv');
				}
				e.preventDefault();			
			})
			$('.numbersOnly').keyup(function () {
				var num = this.value.replace(/[^0-9\.]/g, '');
				if (this.value != num) {
				   this.value = num;
				}
			});
			$('.itemcount').blur(function(e) {
				var packqty = parseInt($('#siPackQty').val() || 0);
				var qtypacks = parseInt($('#siQtyPacks').val() || 0);
				$('#siQtyItems').val(packqty * qtypacks);
			});
			checkPrice(target);
		});
	</script>

	<cfoutput query="record.QStockItem">
		<cfset suppID = accID>
			<span class="FCPDIHeader">
				<span>Amend Stock Item</span>
				<span class="FCPDITitle">#record.product.prodTitle#</span>
				<a href="javascript:void(0)" class="FCPDIClose" onclick="javascript:$.closeDialog();" title="Close popup"></a>
			</span>
			<div class="FCPopupDialogInner">
				<span class="FCPDIContent">
					<form name="StockForm" id="StockForm" class="field" method="post" enctype="multipart/form-data">
						<input type="hidden" name="siID" value="#siID#" />
						<input type="hidden" name="siReceived" value="#siReceived#" />
						<input type="hidden" name="siBookedIn" value="#siBookedIn#" />
						<input type="hidden" name="prodID" id="prodID" value="#record.product.prodID#" />
						<input type="hidden" name="barcode" id="barcode" value="#parm.barcode#" />
						<input type="hidden" name="vatRate" value="#record.product.prodVATRate#" />
						<input type="hidden" size="5" name="prodMinPrice" id="prodMinPrice" value="#record.product.prodMinPrice#" />
						<table border="1" class="tableList3">
							<tr>
								<td>Supplier</td>
								<td width="550" colspan="3">
									<select name="accID" class="field" id="accID" tabindex="1">
										<option value="0">select...</option>
										<cfloop query="suppliers">
											<option value="#accID#"<cfif accID eq suppID> selected="selected"</cfif>>#accName#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td width="180">Stock Ref</td>
								<td width="270"><input type="text" name="siRef" size="15" class="field" value="#siRef#" tabindex="2" /></td>
								<td width="180">VAT Rate</td>
								<td width="270">#record.product.prodVATRate#</td>
							</tr>
							<tr>
								<td>Unit Size</td><td><input type="text" name="siUnitSize" size="10" class="field" value="#siUnitSize#" tabindex="3" /></td>
								<td>Pack Price</td><td><input type="text" name="siWSP" id="siWSP" size="10" class="price numbersOnly" value="#siWSP#" tabindex="8" /></td>
							</tr>
							<tr>
								<td>Units per Pack</td>
								<td><input type="text" name="siPackQty" id="siPackQty" class="itemcount numbersOnly" size="3" maxlength="3" value="#siPackQty#" tabindex="4" /></td>
								<td>Unit Gross</td><td><input type="text" name="unitPrice" id="unitPrice" size="10" class="numbersOnly" value="#siUnitTrade#" disabled="disabled" /></td>
							</tr>
							<tr>
								<td>No. Outer Packs</td><td>
									<input type="text" name="siQtyPacks" id="siQtyPacks" class="itemcount numbersOnly" size="3" maxlength="3" value="#siQtyPacks#" tabindex="5" />
									<input type="text" name="siQtyItems" id="siQtyItems" disabled="disabled" class="itemcount" size="5" maxlength="3" value="#siQtyItems#" />
								</td>
								<td>RRP</td>
								<td>
									<input type="text" name="siRRP" id="siRRP" size="10" class="price numbersOnly" value="#siRRP#" tabindex="9" />
									<label id="prodPriceMarkedLabel" for="prodPriceMarked">#record.product.PriceMarked#</label>
								</td>
							</tr>
							<tr>
								<td>Purchase Date</td>
								<td><input type="text" name="soDate" id="soDate" size="10" class="datepicker" value="#LSDateFormat(soDate,'dd-mmm-yyyy')#" tabindex="6" /></td>
								<td>Suggested Price</td>
								<td><input type="text" name="suggPrice" id="suggPrice" class="price numbersOnly" disabled="disabled" size="10" value="" tabindex="11" />
									#record.product.pgTarget * 100#%</td>
							</tr>
							<tr>
								<td>Expiry Date</td><td><input type="text" name="siExpires" size="10" class="datepickerTo" value="#LSDateFormat(siExpires,'dd-mmm-yyyy')#" tabindex="7" /></td>
								<td>Our Price</td><td><input type="text" name="siOurPrice" id="siOurPrice" class="price numbersOnly" size="10" value="#siOurPrice#" tabindex="10" /></td>
							</tr>
							<tr>
								<td>Status</td><td>
									<select name="siStatus" class="field">
										<option value="open"<cfif siStatus eq "open"> selected="selected"</cfif>>Open</option>
										<option value="closed"<cfif siStatus eq "closed"> selected="selected"</cfif>>Closed</option>
										<option value="outofstock"<cfif siStatus eq "outofstock"> selected="selected"</cfif>>Out of Stock</option>
										<option value="promo"<cfif siStatus eq "promo"> selected="selected"</cfif>>Promo</option>
										<option value="returned"<cfif siStatus eq "returned"> selected="selected"</cfif>>Returned</option>
										<option value="inactive"<cfif siStatus eq "inactive"> selected="selected"</cfif>>Inactive</option>
									</select>
								</td>
								<td>POR</td><td><input type="text" name="POR" id="POR" disabled="disabled" size="10" value="" /></td>
							</tr>
						</table>
						<span class="FCPDIControls">#siID#
							<input type="submit" name="btnSubmit" id="btnSubmit" value="Save Changes" class="NAFSubmit" style="float:right;margin-right:10px;" />
							<input type="button" name="cancel" value="Cancel" class="button_white" style="float:right;" onclick="javascript:$.closeDialog();" />
						</span>
					</form>
				</span>
			</div>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

