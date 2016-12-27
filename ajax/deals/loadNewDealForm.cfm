<cftry>
<cfobject component="code/deals" name="deals">
<cfset parm = {}>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('##editor_title').html("Create Deal");

			$('*').blur();

			$.scanBarcode({
				unbindOnCallback: false,
				preinit: function() {
					window["barcode"] = "";
					$(document).unbind("keydown.scanBarcodeEvent");
				},
				callback: function(barcode) {
					$.ajax({
						type: "POST",
						url: "ajax/deals/searchBarcode.cfm",
						data: { "barcode": barcode },
						success: function(data) {
							$('*').blur();
							var result = JSON.parse(data);
							if (typeof window.productSelectComplete == "function") {
								if (typeof result.PRODUCT.PRODID != "undefined") {
									window.productSelectComplete([{
										id: result.PRODUCT.PRODID,
										title: result.PRODUCT.PRODTITLE
									}]);
								} else {
									$.messageBox("Product not found", "error");
								}
							} else {
								if (typeof result.PRODUCT.PRODID != "undefined") {
									$('.rowList').append(
										'<tr>' +
											'<td><a href="javascript:void(0)" class="ctrlDelProdItem" data-prodID="' + result.PRODUCT.PRODID + '" data-dealID="">D</a></td>' +
											'<td id="rli_name" align="left">' +
												'<a href="javascript:void(0)" class="deal_product_item" data-title="New Row" data-id="' + result.PRODUCT.PRODID + '">' + result.PRODUCT.PRODTITLE + '</a>' +
											'</td>' +
											'<td id="rli_min" align="right"><input type="text" style="text-align:right;width:50px;" name="edi_minqty" placeholder="Min Qty" value=""></td>' +
											'<td id="rli_max" align="right"><input type="text" style="text-align:right;width:50px;" name="edi_maxqty" placeholder="Max Qty" value=""></td>' +
										'</tr>'
									);
								} else {
									$.messageBox("Product not found", "error");
								}
							}
						}
					});
				}
			});

			$(document).on("click", ".deal_product_item", function(event) {
				var obj = $(this);
				var id = obj.data("id");
				var title = obj.data("title");

				window.isInProductSelect = true;

				$.productSelect({
					maxqty: 1,
					products: [{ id: id, title: title }],
					callback: function(data) {
						obj.data("id", data[0].id);
						obj.data("title", data[0].title);
						obj.html(data[0].title);
						$.messageBox("Product Changed to " + data[0].title);
						window.isInProductSelect = false;
						$('*').blur();
					}
				});

				event.preventDefault();
			});

			$(document).on("click", ".ctrlDelProdItem", function(event) {
				var obj = $(this);
				obj.parents('tr').remove();
				window.isInProductSelect = false;
				$('*').blur();
				event.preventDefault();
			});

			$('.ctrlAddRow').click(function(event) {
				$('.rowList').append(
					'<tr>' +
						'<td><a href="javascript:void(0)" class="ctrlDelProdItem" data-prodID="0" data-dealID="0"></a></td>' +
						'<td id="rli_name" align="left">' +
							'<a href="javascript:void(0)" class="deal_product_item" data-title="New Row" data-id="0">New Row</a>' +
						'</td>' +
						'<td id="rli_min" align="right"><input type="text" style="text-align:right;width:50px;" name="edi_minqty" placeholder="Min Qty" value=""></td>' +
						'<td id="rli_max" align="right"><input type="text" style="text-align:right;width:50px;" name="edi_maxqty" placeholder="Max Qty" value=""></td>' +
					'</tr>'
				);
				event.preventDefault();
			});

			$('.ctrlSaveChanges').click(function(event) {
				var formData = {
					header: $('.DealFormHeader').serializeObject(),
					items: []
				};

				$('.rowList tr').each(function(i, e) {
					formData.items.push({
						id: $(e).find('##rli_name a').data("id"),
						title: $(e).find('##rli_name a').data("title"),
						minqty: $(e).find('##rli_min input').val(),
						maxqty: $(e).find('##rli_max input').val()
					});
				});

				console.log(formData);

				$.ajax({
					type: "POST",
					url: "ajax/deals/createDeal.cfm",
					data: { "jsonContent": JSON.stringify(formData) },
					success: function(data) {
						var dealID = Number(data.trim());
						$.messageBox("Deal Created");
						load_deals();
						$('*').blur();

						editDeal(dealID, function(data) {
							$('.deal_editor').html(data);
						});
					}
				});

				event.preventDefault();
			});

			$('.ctrlDelAllItems').click(function(event) {
				$('.rowList tr').remove();
				$('*').blur();
				event.preventDefault();
			});

			$('.DealFormHeader').submit(function(event) {
				$('*').blur();
				event.preventDefault();
			});

			process_club = function() {
				var opt = $('##edRetailClubSelect').find('option:selected');
				$('##id_ed_starts').val(opt.data("starts"));
				$('##id_ed_ends').val(opt.data("ends"));
			}

			$('##edRetailClubSelect').change(function(event) {
				process_club();
				$('*').blur();
			});

			process_club();
		});
	</script>
	<form method="post" enctype="multipart/form-data" class="DealFormHeader">
		<table class="deal_form" width="100%" border="0">
			<tr>
				<td align="left">Retail Club</td>
				<td>
					<select name="ed_retailclub" id="edRetailClubSelect">
						<cfloop array="#deals.LoadRetailClubs()#" index="item">
							<option <cfif item.ercID is 1>selected</cfif> value="#item.ercID#" data-starts="#LSDateFormat(item.ercStarts, 'yyyy-mm-dd')#" data-ends="#LSDateFormat(item.ercEnds, 'yyyy-mm-dd')#">#item.ercTitle# (#item.ercIssue#)</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td align="left" width="100">Title</td>
				<td><input type="text" name="ed_title" placeholder="Deal Title (printed on labels)"></td>
			</tr>
			<tr>
				<td align="left">Starts</td>
				<td><input type="date" name="ed_starts" id="id_ed_starts" placeholder="Starting date"></td>
			</tr>
			<tr>
				<td align="left">Ends</td>
				<td><input type="date" name="ed_ends" id="id_ed_ends" placeholder="Ending date"></td>
			</tr>
			<tr>
				<td align="left">Type</td>
				<td>
					<select name="ed_dealtype">
						<option value="nodeal">No Deal</option>
						<option value="bogof">Buy One Get One Free</option>
						<option value="twofor">Two For..</option>
						<option value="anyfor">Any For..</option>
						<option value="mealdeal">Meal Deal</option>
						<option value="halfprice">Half Price</option>
						<option value="only">Only (price)</option>
						<option value="b1g1hp">Buy One Get One Half Price</option>
					</select>
				</td>
			</tr>
			<tr>
				<td align="left">Amount</td>
				<td><input type="text" name="ed_amount" placeholder="Amount (GBP)"></td>
			</tr>
			<tr>
				<td align="left">Quantity</td>
				<td><input type="text" name="ed_quantity" placeholder="Qty"></td>
			</tr>
			<tr>
				<td align="left">Status</td>
				<td>
					<select name="ed_active">
						<option value="Active">Active</option>
						<option value="Inactive">Inactive</option>
					</select>
				</td>
			</tr>
		</table>
	</form>
	<div class="deal_items_array">
		<a href="javascript:void(0)" class="ctrlDelAllItems sleui-button" style="float:left;padding: 3px 10px;font-size: 12px;margin-bottom: 10px;">Delete All Rows</a>
		<a href="javascript:void(0)" class="ctrlAddRow sleui-button" style="float:right;padding: 3px 10px;font-size: 12px;margin-bottom: 10px;">Add Row</a>
		<table class="deal_form" width="100%" border="0">
			<tr>
				<th width="25" align="left">##</th>
				<th align="left">Product</th>
				<th align="right" width="100">Minimum Qty</th>
				<th align="right" width="100">Maximum Qty</th>
			</tr>
			<tbody class="rowList">
			</tbody>
		</table>
	</div>
	<a href="javascript:void(0)" class="sleui-button ctrlSaveChanges" style="margin-top:10px;">Save Changes</a>
</cfoutput>

<cfcatch type="any">
	<cf_dumptofile var="#cfcatch#">
</cfcatch>
</cftry>
