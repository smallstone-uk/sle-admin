<cftry>
	<cfset callback = true>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.barcode = bcode>
	<cfset parm.productID = productID>
	<cfset parm.allStock = StructKeyExists(form,"allStock")>
	<cfset records = pstock.StockItemList(parm)>
	<cfset suppliers=pstock.LoadSuppliers(parm)>
	<script type="text/javascript">
		$(document).ready(function() {
			rates = [0,0,20,5];
			$('#AddStock').click(function(e) {
				$('#AddStock').hide();
				$('#AddStockForm').show();
			})
			$('.editstock').click(function(e) {
				var id = $(this).data("id");
				var barcode = $(this).data("barcode");
				$.popupDialog({
					file: "AJAX_ProductStock6AmendStock",
					data: {"id": id, "barcode": barcode},
					width: 900
				});
				e.preventDefault();
			});
			$('#btnSubmit').click(function(e) {
				var dataOK = false;
				$('div.err').remove();
				dataOK = checkFields();
				if (dataOK) {
					AddStock('#StockForm','#stockdiv');
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
			$('.price').blur(function(e) {
				$('div.err').remove();
				var vatrate = parseInt($('#prodVATRate').val(),10) / 100;
				var unitPrice = parseFloat($('#siWSP').val() / $('#siPackQty').val()).toFixed(2);	// calc unit trade price
				var unitGross = unitPrice * (1 + vatrate);
				var suggPrice = (unitGross * 1.43).toFixed(2);	// calc price at 30% POR
				var pricemarked = $('#prodPriceMarked').prop('checked');
				$('#unitPrice').val(unitPrice);	// show value
				$('#suggPrice').val(suggPrice);	// show value
				var retailPrice = $('#siRRP').val();	// get current value
				var ourPrice = $('#siOurPrice').val();	// get current value
				if ($('#prodPriceMarked').prop('checked')) {
					ourPrice = retailPrice;
					$('#siOurPrice').val(ourPrice);
				}
				if (ourPrice == 0) {
					ourPrice = suggPrice;
					$('#siOurPrice').val(ourPrice);
				}
				if (retailPrice < suggPrice) {
					// ignore it
				}
				if (ourPrice < retailPrice) {
				//	$('#siRRP').after('<div class="err">Our price cannot be less than retail price.</div>');
				} else if (retailPrice > (suggPrice * 1.1)) {
					$('#siRRP').after('<div class="err">Please check retail price is correct.</div>');
				}
				if (!pricemarked) {
					if (ourPrice > (suggPrice * 1.1)) {
						$('#siOurPrice').after('<div class="err">Our price seems too high?</div>');
					} else if (ourPrice < suggPrice) {
						$('#siOurPrice').after('<div class="err">Our price seems too low?</div>');
					}
				}
				var profit = ourPrice - unitGross;
				var por = ((profit / ourPrice) * 100).toFixed(2);
				
				$('#POR').val(por + "%");
			});
			$('.deleteItem').click(function(e) {
				var productID = $('#productID2').html();
				if (confirm('Delete this stock item record?')) {
					DeleteStockItem($(this).data("id"),productID,'#stockdiv');
				} else {
					alert('Deletion cancelled');
				}
				e.preventDefault();
			});
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, maxDate: new Date, minDate: new Date(2012, 1 - 1, 1)});
			$('.datepickerTo').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2012, 1 - 1, 1)});
		});
	</script>
	<cfoutput>
		<cfif records.action eq "clear">
			<h1>#records.msg#</h1>
		<cfelse>
			<table width="400" class="showTable">
				<tr>
					<th align="left">#records.product.prodTitle#</th>
					<th><div id="productID2">#records.product.prodID#</div></th>
					<th></th>
				</tr>
			</table>
			<cfif records.stockitems.recordcount gt 0>
				<table width="100%" border="1" class="tableList">
					<tr>
						<th class="headleft">##</th>
						<th class="headleft"></th>
						<th class="headleft"></th>
						<th class="headleft"></th>
						<th class="headleft">Supplier</th>
						<th class="headleft">Order</th>
						<th class="headleft">Reference</th>
						<th class="headleft">Date</th>
						<th class="headleft">Cases</th>
						<th class="headleft">Items</th>
						<th class="headleft">Total</th>
						<th class="headleft">Size</th>
						<th class="headright">WSP</th>
						<th class="headright">Unit</th>
						<th class="headright">RRP</th>
						<th class="headright">Our Price</th>
						<th class="headright">POR</th>
						<th class="headright">Item <br />Status</th>
					</tr>
					<cfset totalItems = 0>
					<cfloop query="records.stockItems">
						<cfset totalItems += siQtyItems>
					<tr>
						<td align="center">#currentrow#</td>
						<td><a href="?id=#siID#&barcode=#parm.barcode#" class="deleteItem" data-id="#siID#" data-barcode="#parm.barcode#">
							<img src="images/icons/bin_black.png" width="18" height="18" /></a></td>
						<td><a href="?id=#siID#&barcode=#parm.barcode#" class="editstock" data-id="#siID#" data-barcode="#parm.barcode#">
							<img src="images/icons/edit_black.png" width="18" height="18"></a></td>
						<td align="center">#siID#</td>
						<td>#accName#</td>
						<td>#soRef#</td>
						<td>#siRef#</td>
						<td>#LSDateFormat(soDate)#</td>
						<td align="center">#siQtyPacks#</td>
						<td align="center">#siQtyItems#</td>
						<td align="center">#totalItems#</td>
						<td align="center">#siUnitSize#</td>
						<td align="right">#siWSP#</td>
						<td align="right">#siUnitTrade#</td>
						<td align="right">#siRRP#</td>
						<td align="right" class="ourPrice">#siOurPrice# #records.product.PriceMarked#</td>
						<td align="right">#siPOR#%</td>
						<td align="right">#siStatus#</td>
					</tr>
					</cfloop>
					<tr>
						<th colspan="9"></th>
						<th align="center">#totalItems#</th>
						<th colspan="8"></th>
					</tr>
				</table>
			<cfelse>
				<div style="clear:both"></div>
				<h1>No stock records found.</h1>
			</cfif>
			<div id="AddStockForm">
				<form name="StockForm" id="StockForm" method="post" enctype="multipart/form-data">
					<input type="hidden" name="productID" id="productID" value="#records.product.prodID#" />
					<input type="hidden" name="prodVATRate" id="prodVATRate" value="#records.product.prodVATRate#" />
					<input type="hidden" name="barcode" id="barcode" value="#parm.barcode#" />
					<table border="1" class="tableList3">
						<tr>
							<td>Supplier</td>
							<td width="550" colspan="3">
								<select name="accID" class="field" id="accID" tabindex="1">
									<option value="0">select...</option>
									<cfloop query="suppliers">
										<option value="#accID#">#accName#</option>
									</cfloop>
								</select>
							</td>
						</tr>
						<tr>
							<td width="140">Stock Ref</td>
							<td width="350"><input type="text" name="siRef" size="15" class="field" value="" tabindex="2" /></td>
							<td width="140">VAT Rate</td>
							<td width="350">#records.product.prodVATRate#%</td>
						</tr>
						<tr>
							<td>Unit Size</td><td><input type="text" name="siUnitSize" size="10" class="field" value="" tabindex="2" /></td>
							<td>Pack Price</td><td><input type="text" name="siWSP" id="siWSP" size="10" class="price numbersOnly" value="" tabindex="8" /></td>
						</tr>
						<tr>
							<td>Units per Pack</td><td><input type="text" name="siPackQty" id="siPackQty" class="itemcount numbersOnly" size="10" value="" tabindex="3" /></td>
							<td>Unit Gross</td><td><input type="text" name="unitPrice" id="unitPrice" size="10" class="numbersOnly" value="" disabled="disabled" /></td>
						</tr>
						<tr>
							<td>No. Outer Packs</td><td>
								<input type="text" name="siQtyPacks" id="siQtyPacks" class="itemcount numbersOnly" size="10" value="" tabindex="4" />
								<input type="text" name="siQtyItems" id="siQtyItems" disabled="disabled" class="itemcount" size="10" value="" />
							</td>
							<td>RRP</td>
							<td>
								<input type="text" name="siRRP" id="siRRP" size="10" class="price numbersOnly" value="" tabindex="10" />
								<label id="prodPriceMarkedLabel" for="prodPriceMarked">#records.product.PriceMarked#</label>
							</td>
						</tr>
						<tr>
							<td>Purchase Date</td><td><input type="text" name="soDate" id="soDate" size="10" class="datepicker" value="" tabindex="5" /></td>
							<td>Suggested Price</td>
							<td><input type="text" name="suggPrice" id="suggPrice" class="price numbersOnly" disabled="disabled" size="10" value="" tabindex="11" />
								#records.product.pgTarget * 100#%</td>
						</tr>
						<tr>
							<td>Expiry Date</td><td><input type="text" name="siExpires" size="10" class="datepickerTo" value="" tabindex="6" /></td>
							<td>Our Price</td><td><input type="text" name="siOurPrice" id="siOurPrice" class="price numbersOnly" size="10" value="" tabindex="12" /></td>
						</tr>
						<tr>
							<td>Status</td><td>
								<select name="siStatus" class="field">
									<option value="open">Open</option>
									<option value="closed">Closed</option>
									<option value="outofstock">Out of Stock</option>
									<option value="promo">Promo</option>
									<option value="returned">Returned</option>
									<option value="inactive">Inactive</option>
								</select>
							</td>
							<td>POR</td><td><input type="text" name="POR" id="POR" disabled="disabled" size="10" value="" /></td>
						</tr>
						<tr><td colspan="4"><input type="submit" name="btnSubmit" id="btnSubmit" class="field" value="Add Stock" /></td></tr>
					</table>
				</form>
			</div>
		</cfif>
		<button id="AddStock">Add Stock Item</button>
	</cfoutput>
	
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

