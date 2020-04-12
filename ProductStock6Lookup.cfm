
<cftry>
	<cfset callback=1>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.form=form>
	<cfset lookup=pstock.FindProduct(parm)>

	<script type="text/javascript">
		$(document).ready(function() {
			<cfoutput>
				$('##bcode').html("#lookup.barcode#");
				$('##productID').html("#lookup.productID#");
			</cfoutput>
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, maxDate: new Date, minDate: new Date(2012, 1 - 1, 1)});
			
			checkProduct = function() {
				$('span.err').remove();
				var sendIt = true;
				var title = $('#prodRecordTitle').val();
				if (title.length == 0) {
					$('#prodRecordTitle').after('<span class="err">Please enter the product title.</span>');
					sendIt = false;
				} else {
					var displayAs = $('#prodTitle').val();
					if (displayAs.length == 0) {
						$('#prodTitle').val(title)
					}
				}
				var title = $('#prodTitle').val();
				if (title.length == 0) {
					$('#prodTitle').after('<span class="err">Please enter the display title.</span>');
					sendIt = false;
				}
				var vatrate = parseFloat($('#prodVATRate option:selected').val());
				if (isNaN(vatrate)) {
					$('#prodVATRate').after('<span class="err">Please select the VAT rate.</span>');
					sendIt = false;
				}
				var group = $('#productGroup').val();
				if (group.length == 0) {
					$('#productGroup').after('<span class="err">Please select a group.</span>');
					sendIt = false;
				}
				return sendIt;
			}
			$('#AddProduct').click(function(e) {
				$('#AddProductForm').show();
				e.preventDefault();
			})
			$('#btnAddProduct').click(function(e) {
				if (checkProduct()) {
					AddProduct('#ProductForm','#result');
					var bcode = $('#barcode').val();
					setTimeout(function(){	// wait for db to update
						LookupBarcode("product",bcode,0,"#productdiv");
					},1000); ;
				}
				e.preventDefault();			
			})
			$('#AmendProduct').click(function(e) {
				var group = $('#productGroup').val();
				var catID = $('#catID').val();
				GetCats(group,catID,'#category');
				$('#product').hide();
				$('#AmendProductForm').show();
			})
			$('#btnSaveProduct').click(function(e) {
				if (checkProduct()) {
					AmendProduct('#ProductForm','#result');
					var bcode = $('#barcode').val();
					if (len(bcode)) {
						setTimeout(function(){	// wait for db to update
							LookupBarcode("product",bcode,0,"#productdiv");
						},1000);
					} else {
						var prodID = $('#productID').val();
						setTimeout(function(){	// wait for db to update
							LookupBarcode("product","",prodID,"#productdiv");
						},1000); ;
					}
				};
				e.preventDefault();			
			});
			$('#prodRecordTitle').blur(function(e) {
				checkProduct();
			});
			$('#prodTitle').blur(function(e) {
				checkProduct();
			});
			$('#productGroup').change(function(e) {
				var group = $('#productGroup').val();
				var catID = $('#catID').val();
				GetCats(group,catID,'#category');
			});
			$('#btnNewGroup').click(function(e) {
				$.popupDialog({
					file: "AJAX_loadNewProdGroupForm",
					width: 350
				});
				e.preventDefault();
			});
			$('#barcodeForm').submit(function(e) {
				$.ajax({
					type: "POST",
					url: "ajax/AJAX_addbarcode.cfm",
					data: $('#barcodeForm').serialize(),
					beforeSend: function() {
						$('#result').html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Adding barcode...");
					},
					success: function(data) {
						$('#result').html(data)
						var bcode = $('#barcode').val();
						setTimeout(function(){	// wait for db to update
							LookupBarcode("product",bcode,0,"#productdiv");
						},500); ;
					}
				});
				e.preventDefault();
			});
			$('.deleteItem').click(function(e) {
				var barID = $(this).attr("data-id");
				var bcode = $('#barcode').val();
				console.log(barID);
				DeleteBarcode(barID,bcode,'#result');
				var prodID = $('#prodID').val();
				setTimeout(function(){	// wait for db to update
					LookupBarcode("product","",prodID,"#productdiv");
				},1000); ;
				e.preventDefault();
			});
		});
	</script>
	<cfoutput>
		<cfif lookup.action IS "found">
			<div id="msgs">
				<div style="float:left">
				<cfif ArrayLen(lookup.msgs)>
					<cfloop array="#lookup.msgs#" index="msg">
						<cfif len(msg)>#msg#<br /></cfif>
					</cfloop>
				</cfif>
				</div>
				<button id="AmendProduct">Amend</button>
				<div class="clear"></div>
			</div>
			<div id="product">
				<table class="showTable" border="1">
					<tr>
						<th colspan="2">Product Details</th>
					</tr>
					<tr><td>Reference</td>
						<td>#lookup.product.prodRef#
							<span style="float:right">
								<a href="stockItems.cfm?ref=#lookup.product.prodID#" target="_blank" title="See previous orders">#lookup.product.prodID#</a></span>
						</td>
					</tr>
					<tr><td>Description</td><td>#lookup.product.prodRecordTitle#</td></tr>
					<tr><td>Display As</td><td>#lookup.product.prodTitle#</td></tr>
					<tr><td>Group</td><td>#lookup.groupTitle#</td></tr>
					<tr><td>Category</td><td>#lookup.catTitle#</td></tr>
					<tr><td>Minimum Price</td><td>&pound;#lookup.product.prodMinPrice#</td></tr>
					<tr><td>Our Price</td><td>&pound;#lookup.product.prodOurPrice#</td></tr>
					<tr><td>Discountable</td><td>#lookup.product.prodStaffDiscount#</td></tr>
					<tr><td>Price Marked</td><td>#YesNoFormat(lookup.product.prodPriceMarked)#</td></tr>
					<tr><td>VAT Rate</td><td>#lookup.product.prodVATRate#%</td></tr>
					<tr><td>Stock Checked</td><td>#lookup.product.prodCountDate# &nbsp; Check Level #lookup.product.prodStockLevel#</td></tr>
					<tr><td>Status</td><td>#lookup.product.prodStatus# &nbsp; Reorder #lookup.product.prodReorder#</td></tr>
				</table>
				<table class="showTable" border="1">
					<tr>
						<th colspan="2">Latest Stock Item</th>
					</tr>
					<tr><td>Supplied By</td><td>#lookup.supplier#</td></tr>
					<cfif val(lookup.stockItem.siID) gt 0>
						<tr><td>Stock Ref</td><td>#lookup.stockItem.siRef#</td></tr>
						<tr><td>Unit Size</td><td>#lookup.stockItem.siUnitSize#</td></tr>
						<tr><td>Booked In</td><td>#lookup.stockItem.siBookedIn#</td></tr>
						<tr><td>Pack Qty</td><td>#lookup.stockItem.siPackQty#</td></tr>
						<tr><td>Items Received</td><td>#lookup.stockItem.siQtyItems#</td></tr>
						<tr><td>WSP</td><td>&pound;#lookup.stockItem.siWSP#</td></tr>
						<tr><td>Our Price</td><td class="ourPrice">&pound;#lookup.stockItem.siOurPrice# #lookup.product.PriceMarked#</td></tr>
						<tr><td>POR</td><td>#lookup.stockItem.siPOR#%</td></tr>
					<cfelse>
						<tr><td colspan="2">No stock records found.</td></tr>
					</cfif>
				</table>
				<cfif StructKeyExists(lookup,"Deals")>
					<table class="showTable" border="1">
						<tr>
							<th colspan="2">Deals</th>
						</tr>
						<cfloop array="#lookup.deals#" index="dealItem">
							<tr><td>Retail Club</td><td>#dealItem.ercTitle#</td></tr>
							<tr><td>Title</td><td>#dealItem.edTitle#</td></tr>
							<tr><td>Type</td><td>#dealItem.edType#</td></tr>
							<tr><td>Starts</td><td>#LSDateFormat(dealItem.edStarts,"dd-mmm-yy")#</td></tr>
							<tr><td>Ends</td><td>#LSDateFormat(dealItem.edEnds,"dd-mmm-yy")#</td></tr>
							<tr><td>Qty</td><td>#dealItem.edQty#</td></tr>
							<tr><td>Status</td><td>#dealItem.edStatus#</td></tr>
							<tr><td>Deal Type</td><td>#dealItem.edDealType#</td></tr>
							<tr><td>Amount</td><td>#dealItem.edAmount#</td></tr>
							<tr><td colspan="2">&nbsp;</td></tr>
						</cfloop>
					</table>
				</cfif>
				<table class="showTable" border="1">
					<tr><th colspan="2">Barcodes</th></tr>
					<cfloop query="lookup.otherbarcodes">
						<tr>
							<td><a href="?id=#barID#" class="deleteItem" data-id="#barID#" title="delete barcode">
								<img src="images/icons/bin_black.png" width="18" height="18" /></a></td>
							<td>#barcode#</td>
						</tr>
					</cfloop>
					<tr>
						<td colspan="2">
							<form name="addcode" method="post" id="barcodeForm">
								<input type="hidden" name="prodID" id="prodID" value="#lookup.product.prodID#" />
								<input type="text" name="newCode" id="newCode" size="14" maxlength="13" placeholder="new barcode" /><br />
								<input type="submit" name="btnAdd" value="Add" />
							</form>
						</td>
					</tr>
				</table>
			</div>
			<div id="AmendProductForm">
				<form name="ProductForm" id="ProductForm" method="post" enctype="multipart/form-data">
					<input type="hidden" name="barcode" id="barcode" value="#lookup.barcode#" />
					<input type="hidden" name="prodID" id="prodID" value="#lookup.product.prodID#" />
					<input type="hidden" name="catID" id="catID" value="#lookup.catID#" />
					<table border="1" class="tableList3">
						<tr><td>Reference</td><td>
							<input type="text" name="prodRef" id="prodRef" class="field" size="15" value="#lookup.product.prodRef#" /></td></tr>
						<tr><td>Description</td><td>
							<input type="text" name="prodRecordTitle" id="prodRecordTitle" class="field" size="40" value="#lookup.product.prodRecordTitle#" /></td></tr>
						<tr><td>Display As</td><td>
							<input type="text" name="prodTitle" id="prodTitle" class="field" size="40" value="#lookup.product.prodTitle#" /></td></tr>
						<tr><td>Group</td><td>
							<select name="productGroup" class="field" id="productGroup">	
								<option value="">Select...</option>
								<cfloop query="lookup.groups">
									<option value="#pgID#"<cfif pgID eq lookup.groupID> selected="selected"</cfif>>#pgTitle#</option>
								</cfloop>
							</select>
						</td></tr>
						<tr><td>Category</td><td><div id="category"></div></td></tr>
						<tr><td>Minimum Price</td><td>
							<input type="text" name="prodMinPrice" id="prodMinPrice" class="field" size="10" value="#lookup.product.prodMinPrice#" /></td></tr>
						<tr><td>Our Price</td><td>
							<input type="text" name="prodOurPrice" id="prodOurPrice" class="field" size="10" value="#lookup.product.prodOurPrice#" /> (if no stock records)</td></tr>
						<tr><td>Options</td><td>
							Discountable 
							<input type="checkbox" name="prodStaffDiscount" id="prodStaffDiscount"<cfif lookup.product.prodStaffDiscount> checked="checked"</cfif> />
							Price Marked
							<input type="checkbox" name="prodPriceMarked" id="prodPriceMarked"<cfif lookup.product.prodPriceMarked> checked="checked"</cfif> />
						</td></tr>
						<tr>
							<td>VAT Rate</td>
							<td>
								<select name="prodVATRate" id="prodVATRate">
									<option value=""<cfif lookup.product.prodVATRate eq ""> selected="selected"</cfif>>select...</option>
									<option value="0.000"<cfif lookup.product.prodVATRate eq "0.000"> selected="selected"</cfif>>0.00%</option>
									<option value="20.000"<cfif lookup.product.prodVATRate eq "20.000"> selected="selected"</cfif>>20.00%</option>
									<option value="5.000"<cfif lookup.product.prodVATRate eq "5.000"> selected="selected"</cfif>>5.00%</option>
								</select>
							</td>
						</tr>
						<tr>
							<td>Stock Check Date</td>
							<td>
								<input type="text" name="prodCountDate" id="prodCountDate" size="10" class="datepicker" value="#LSDateFormat(lookup.product.prodCountDate,'dd-mmm-yyyy')#" tabindex="6" />
								Stock Check Level
								<input type="text" name="prodStockLevel" id="prodStockLevel" class="field" size="10" value="#lookup.product.prodStockLevel#" />
						</td></tr>
						<tr>
							<td>EPOS Category</td>
							<td>
								<select name="prodEposCatID" id="prodEposCatID">
									<option value="1">Barcoded Product</option>
									<cfloop array="#new App.EPOSCat().getParents()#" index="eposCat">
										<optgroup label="#eposCat.epcTitle#">
											<cfloop array="#eposCat.getChildren()#" index="eposCatChild">
												<option value="#eposCatChild.epcID#" <cfif lookup.product.prodEposCatID is eposCatChild.epcID>selected="true"</cfif>>#eposCatChild.epcTitle#</option>
											</cfloop>
										</optgroup>
									</cfloop>
								</select>
							</td>
						</tr>
						<tr>
							<td>Status</td>
							<td>
								<select name="prodStatus">
									<option value="active"<cfif lookup.product.prodStatus is 'active'>selected="true"</cfif>>Active</option>
									<option value="inactive"<cfif lookup.product.prodStatus is 'inactive'>selected="true"</cfif>>Inactive</option>
									<option value="donotbuy"<cfif lookup.product.prodStatus is 'donotbuy'>selected="true"</cfif>>Do Not Buy</option>
								</select>
								Reorder
								<select name="prodReorder">
									<option value="None"<cfif lookup.product.prodReorder is 'None'>selected="true"</cfif>>None</option>
									<option value="Monday"<cfif lookup.product.prodReorder is 'Monday'>selected="true"</cfif>>Monday</option>
									<option value="Thursday"<cfif lookup.product.prodReorder is 'Thursday'>selected="true"</cfif>>Thursday</option>
									<option value="Every"<cfif lookup.product.prodReorder is 'Every'>selected="true"</cfif>>Every Order</option>
								</select>
							</td>
						</tr>
						<tr><td colspan="2"><input type="submit" name="btnSaveProduct" id="btnSaveProduct" class="field" value="Save Changes" /></td></tr>
					</table>
				</form>
			</div>
		<cfelseif lookup.action IS "Add" OR lookup.action IS "New">
			<h1>#lookup.msg#</h1>
			<button id="AddProduct">Add Product</button>
			<div id="AddProductForm">
				<form name="ProductForm" id="ProductForm" method="post" enctype="multipart/form-data">
					<input type="hidden" name="barcode" id="barcode" value="#lookup.barcode#" />
					<input type="hidden" name="prodID" id="prodID" value="0" />
					<input type="hidden" name="catID" id="catID" value="1" />
					<table border="1" class="tableList3">
						<tr><td>Reference</td><td><input type="text" name="prodRef" id="prodRef" class="field" size="15" value="" /></td></tr>
						<tr><td>Description</td><td><input type="text" name="prodRecordTitle" id="prodRecordTitle" class="field" size="30" value="" /></td></tr>
						<tr><td>Display As</td><td><input type="text" name="prodTitle" id="prodTitle" class="field" size="30" value="" /></td></tr>
						<tr><td>Group</td><td>
							<select name="productGroup" class="field" id="productGroup">	
								<option value="">Select...</option>
								<cfloop query="lookup.groups">
									<option value="#pgID#">#pgTitle#</option>
								</cfloop>
							</select>
						</td></tr>
						<tr><td>Category</td><td><div id="category"></div></td></tr>
						<tr><td>Discountable </td><td>
							<input type="checkbox" name="prodStaffDiscount" id="prodStaffDiscount" /></td></tr>
						<tr><td>Price Marked</td><td>
							<input type="checkbox" name="prodPriceMarked" id="prodPriceMarked" /></td></tr>
						</td></tr>
						<tr><td>Minimum Price</td><td>
							<input type="text" name="prodMinPrice" id="prodMinPrice" class="field" size="10" /></td></tr>
						<tr><td>Our Price</td><td>
							<input type="text" name="prodOurPrice" id="prodOurPrice" class="field" size="10" /> (if no stock records)</td></tr>
						<tr>
							<td>VAT Rate</td>
							<td>
								<select name="prodVATRate" id="prodVATRate">
									<option value="">select...</option>
									<option value="0.000">0.00%</option>
									<option value="20.000">20.00%</option>
									<option value="5.000">5.00%</option>
								</select>
							</td>
						</tr>
						<tr>
							<td>EPOS Category</td>
							<td>
								<select name="prodEposCatID" id="prodEposCatID">
									<option value="1">Barcoded Product</option>
									<cfloop array="#new App.EPOSCat().getParents()#" index="eposCat">
										<optgroup label="#eposCat.epcTitle#">
											<cfloop array="#eposCat.getChildren()#" index="eposCatChild">
												<option value="#eposCatChild.epcID#">#eposCatChild.epcTitle#</option>
											</cfloop>
										</optgroup>
									</cfloop>
								</select>
							</td>
						</tr>
						<tr><td colspan="2">
							<input type="submit" name="btnAddProduct" id="btnAddProduct" class="field" value="Save Product" />
						</td></tr>
					</table>
				</form>
			</div>
		</cfif>
	</cfoutput>
	
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
