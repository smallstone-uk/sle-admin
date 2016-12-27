
<cftry>
<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/ProductStock5" name="pstock">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset lookup=pstock.FindProduct(parm)>
<!---<cfdump var="#lookup#" label="lookup" expand="false">--->
<cfset suppliers=pstock.LoadSuppliers(parm)>
<script type="text/javascript">
	$(document).ready(function() {
		$('#btnSubmit').click(function(e) {
			$('span.err').remove();
			var sendIt = true;
			var supplier = $('#accID').val();
			if (supplier == 0) {
				$('#accID').after('<span class="err">Please select a supplier.</span>');
				sendIt = false;
			}
			var vatrate = $('#prodVATCode').val();
			if (vatrate == 0) {
				$('#prodVATCode').after('<span class="err">Please select a VAT rate.</span>');
				sendIt = false;
			}
			if ($('#prodRecordTitle').val() == "") {
				$('#prodRecordTitle').after('<span class="err">Please enter the product title.</span>');
				sendIt = false;
			} 
			var qty = parseInt($('#prodPackQty').val()) || 0;
			if (qty == 0) {
				$('#prodPackQty').after('<span class="err">Please enter the no. of units in each pack.</span>');
				sendIt = false;
			} 
			var qty = parseInt($('#siQtyPacks').val()) || 0;
			if (qty == 0) {
				$('#siQtyPacks').after('<span class="err">Please enter the number of packs received.</span>');
				sendIt = false;
			} 
			var price = parseFloat($('#prodPackPrice').val()).toFixed(2) || 0; 
			if (price == 0 || isNaN(price)) {
				$('#prodPackPrice').after('<span class="err">Please enter the wholesale price of the pack.</span>');
				sendIt = false;
			} 
			var price = parseFloat($('#prodRRP').val()).toFixed(2) || 0; 
			if (price == 0 || isNaN(price)) {
				$('#prodPriceMarkedLabel').after('<span class="err">Please enter the retail price of the product.</span>');
				sendIt = false;
			} 
			var price = parseFloat($('#prodOurPrice').val()).toFixed(2) || 0; 
			if (price == 0 || isNaN(price)) {
				$('#prodOurPrice').after('<span class="err">Please enter our price of the product.</span>');
				sendIt = false;
			} 
			if ($('#soDate').val() == "") {
				$('#soDate').after('<span class="err">Please enter date received.</span>');
				sendIt = false;
			} 
			if (sendIt) {
				if ($('#barcode').val()) {
					$('#result').html(AddProduct('#ProductForm','result'));
				} else {
					$('#result').html(AddStock('#StockForm','result'));
				}
			}
			e.preventDefault();			
		})
		$('.numbersOnly').keyup(function () {
			var num = this.value.replace(/[^0-9\.]/g, '');
			if (this.value != num) {
			   this.value = num;
			}
		});
//		$('#btnAddStock').click(function(e) {
//			$('#result').html(AddStock('#StockForm','result'));
//			e.preventDefault();			
//		})
//		$('#prodRef').blur(function(e) {
//			ref = $(this).val();
//			if (ref.length == 0) {
//				$('#prodRef_msg').html("Please enter a reference");
//			} else {
//				$('#prodRef_msg').html("");
//			}
//		});
		$('.price').blur(function(e) {
			var retailPrice = $('#prodRRP').val();
			if ($('#prodPriceMarked').prop('checked'))
				$('#prodOurPrice').val(retailPrice);
		});
		$('#prodPriceMarked').click(function(e) {
			var retailPrice = $('#prodRRP').val();
			if ($('#prodPriceMarked').prop('checked'))
				$('#prodOurPrice').val(retailPrice);
		});
		$('.itemcount').blur(function(e) {
			var packqty = parseInt($('#prodPackQty').val() || 0);
			var qtypacks = parseInt($('#siQtyPacks').val() || 0);
			$('#siQtyItems').val(packqty * qtypacks);
		});
		$('#productGroup').change(function(e) {
			var group = $('#productGroup').val();
			var catID = $('#catID').val();
			GetCats(group,catID,'#category');
		});
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, maxDate: new Date, minDate: new Date(2012, 1 - 1, 1)});
		$('.datepickerTo').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2012, 1 - 1, 1)});
			var group = $('#productGroup').val();
			var catID = $('#catID').val();
			GetCats(group,catID,'#category');
	});
</script>

<cfoutput>
	<cfif lookup.action IS "found">
		<div class="panel">
			<table class="showTable">
				<tr><td width="120">Supplier</td><td>#lookup.product.accName#</td></tr>
				<tr><td>Reference</td><td><a href="stockItems.cfm?ref=#lookup.product.prodID#" target="_blank" title="See previous orders">#lookup.product.prodRef#</a></td></tr>
				<tr><td>Product</td><td>#lookup.product.prodTitle#</td></tr>
				<tr><td>Group</td><td>#lookup.groupTitle#</td></tr>
				<tr><td>Category</td><td>#lookup.catTitle#</td></tr>
				<tr><td>Unit Size</td><td>#lookup.product.prodUnitSize#</td></tr>
				<tr><td>Our Price</td><td>&pound;#lookup.product.prodOurPrice# #lookup.product.prodPriceMarked#</td></tr>
				<tr><td>Pack Qty</td><td>#lookup.product.prodPackQty#</td></tr>
				<tr><td>Record ID</td><td><a href="stockItems.cfm?ref=#lookup.product.prodID#" target="_blank" title="See previous orders">#lookup.product.prodID#</a></td></tr>
			</table>
		</div>
		<cfif ArrayLen(lookup.msgs)>
			<div class="panel">
				<table class="tableList2">
					<tr><td colspan="4"><strong>Messages</strong></td></tr>
					<tr>
						<th>Order Ref.</th>
						<th>Order Date</th>
						<th>Stock Item ID</th>
						<th>Message</th>
					</tr>
					<cfloop array="#lookup.msgs#" index="item">
						<tr>
							<td>#item.order#</td>
							<td>#item.date#</td>
							<td>#item.item#</td>
							<td>#item.msg#</td>
						</tr>
					</cfloop>
				</table>
			</div>
		</cfif>			
		<cfif ArrayLen(lookup.orders)>
			<div class="panel">
				<table class="tableList2">
					<tr><td colspan="5"><strong>Orders</strong></td></tr>
					<tr>
						<th>Date</th>
						<th>Ref</th>
						<th>Order Status</th>
						<th>Item Status</th>
						<th>Message</th>
					</tr>
					<cfloop array="#lookup.orders#" index="item">
						<tr>
							<td>#item.date#</td>
							<td>#item.order#</td>
							<td>#item.orderStatus#</td>
							<td>#item.itemStatus#</td>
							<td>#item.msg#</td>
						</tr>
					</cfloop>
				</table>
			</div>
		</cfif>
		<div style="clear:both"></div>		
		<div id="entryForm">
			<h1>Add Stock - #lookup.product.prodTitle#</h1>
			<form name="StockForm" id="StockForm" method="post" enctype="multipart/form-data">
				<input type="hidden" name="productID" id="productID" value="#lookup.product.prodID#" />
				<input type="hidden" name="catID" id="catID" value="#lookup.catID#" />
				<table border="1" class="tableList3">
					<tr><td>Description</td><td><input type="text" name="prodRecordTitle" id="prodRecordTitle" class="field" size="30" value="#lookup.product.prodRecordTitle#" /></td></tr>
					<tr><td>Group/Category</td><td>
						<select name="productGroup" class="field" id="productGroup">	
							<option value="">Select...</option>
							<cfloop query="lookup.groups">
								<option value="#pgID#"<cfif lookup.groupID eq pgID> selected="selected"</cfif>>#pgTitle#</option>
							</cfloop>
						</select>
						<br />
						<div id="category"></div>
					</td></tr>
					<tr><td width="140">Unit Size</td><td><input type="text" name="prodUnitSize" size="10" class="field" value="#lookup.product.prodUnitSize#" /></td></tr>
					<tr><td>Units per Pack</td><td><input type="text" name="prodPackQty" id="prodPackQty" class="itemcount numbersOnly" size="10" value="" /></td></tr>
					<tr><td>No. Outer Packs</td><td><input type="text" name="siQtyPacks" id="siQtyPacks" class="itemcount numbersOnly" size="10" value="" /></td></tr>
					<tr><td>Items Received</td><td><input type="text" name="siQtyItems" id="siQtyItems" disabled="disabled" class="itemcount" size="10" value="" /></td></tr>
					<tr><td>Pack Price</td><td><input type="text" name="prodPackPrice" id="prodPackPrice" size="10" class="numbersOnly" value="" /></td></tr>
					<tr><td>RRP</td><td>
						<input type="text" name="prodRRP" id="prodRRP" size="10" class="price numbersOnly" value="" />
						<input type="checkbox" name="prodPriceMarked" id="prodPriceMarked" value="1" title="price marked?" />
						<label id="prodPriceMarkedLabel" for="prodPriceMarked">PM</label>
					</td></tr>
					<tr><td>Our Price</td><td><input type="text" name="prodOurPrice" id="prodOurPrice" class="price numbersOnly" size="10" value="" /></td></tr>
					<tr><td>VAT Rate</td><td>
						<select name="prodVATCode" class="field" id="prodVATCode">
							<option value="0">select...</option>
							<option value="1">0.00%</option>
							<option value="2">20.00%</option>
							<option value="3">5.00%</option>
						</select>
					</td></tr>
					<tr><td>Purchase Date</td><td><input type="text" name="soDate" id="soDate" size="10" class="datepicker" value="" /></td></tr>
					<tr><td>Expiry Date</td><td><input type="text" name="siExpires" size="10" class="datepickerTo" value="" /></td></tr>
					<tr><td colspan="2"><input type="submit" name="btnSubmit" id="btnSubmit" class="field" value="Add Stock" /></td></tr>
				</table>
			</form>
		</div>		
	<cfelseif lookup.action IS "Add">
		<div id="entryForm">
			#lookup.msg#
			<h1>Add Product</h1>
			<form name="ProductForm" id="ProductForm" method="post" enctype="multipart/form-data">
				<input type="hidden" name="barcode" id="barcode" value="#lookup.barcode#" />
				<input type="hidden" name="catID" id="catID" value="1" />
				<table border="1" class="tableList3">
					<tr>
						<td width="140">Supplier</td>
						<td width="550">
							<select name="accID" class="field" id="accID">
								<option value="0">select...</option>
								<cfloop query="suppliers">
									<option value="#accID#">#accName#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr><td>Reference</td><td><input type="text" name="prodRef" id="prodRef" class="field" size="10" value="" /></td></tr>
					<tr><td>Description</td><td><input type="text" name="prodRecordTitle" id="prodRecordTitle" class="field" size="30" value="" /></td></tr>
					<tr><td>Group/Category</td><td>
						<select name="productGroup" class="field" id="productGroup">	
							<option value="">Select...</option>
							<cfloop query="lookup.groups">
								<option value="#pgID#">#pgTitle#</option>
							</cfloop>
						</select>
						<br />
						<div id="category"></div>
					</td></tr>
					<tr><td>Unit Size</td><td><input type="text" name="prodUnitSize" class="field" size="10" value="" /></td></tr>
					<tr><td>Units per Pack</td><td><input type="text" name="prodPackQty" id="prodPackQty" class="itemcount numbersOnly" size="10" value="" /></td></tr>
					<tr><td>No. Outer Packs</td><td><input type="text" name="siQtyPacks" id="siQtyPacks" class="itemcount numbersOnly" size="10" value="" /></td></tr>
					<tr><td>Items Received</td><td><input type="text" name="siQtyItems" id="siQtyItems" disabled="disabled" class="itemcount" size="10" value="" /></td></tr>
					<tr><td>Pack Price</td><td><input type="text" name="prodPackPrice" id="prodPackPrice" size="10" class="numbersOnly" value="" /></td></tr>
					<tr><td>RRP</td><td>
						<input type="text" name="prodRRP" id="prodRRP" size="10" class="price numbersOnly" value="" />
						<input type="checkbox" name="prodPriceMarked" id="prodPriceMarked" value="1" title="price marked?" />
						<label id="prodPriceMarkedLabel" for="prodPriceMarked">PM</label>
					</td></tr>
					<tr><td>Our Price</td><td><input type="text" name="prodOurPrice" id="prodOurPrice" class="price numbersOnly" size="10" value="" /></td></tr>
					<tr><td>VAT Rate</td><td>
						<select name="prodVATCode" class="field" id="prodVATCode">
							<option value="0">select...</option>
							<option value="1">0.00%</option>
							<option value="2">20.00%</option>
							<option value="3">5.00%</option>
						</select>
					</td></tr>
					<tr><td>Purchase Date</td><td><input type="text" name="soDate" id="soDate" size="10" class="datepicker" value="" /></td></tr>
					<tr><td>Expiry Date</td><td><input type="text" name="siExpires" size="10" class="datepickerTo" value="" /></td></tr>
					<tr><td colspan="2"><input type="submit" name="btnSubmit" id="btnSubmit" class="field" value="Add Product" /></td></tr>
				</table>
			</form>
		</div>
	<cfelseif lookup.action IS "clear">
		<div class="msg">#lookup.msg#</div>
	<cfelseif lookup.action IS "delete">
		<div class="msg">#lookup.msg#</div>
	<cfelse>
	</cfif>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>


<!---<cfdump var="#lookup#" label="lookup" expand="true">--->
