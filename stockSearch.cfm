<cftry>
<!DOCTYPE html>
<html>
<head>
	<title>Stock List Search</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<!---<link href="css/main4.css" rel="stylesheet" type="text/css">--->
	<link href="css/productstock.css" rel="stylesheet" type="text/css">
	<link href="css/labels-small.css" rel="stylesheet" type="text/css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="scripts/jquery-1.11.1.min.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
	<script src="scripts/jquery.hoverIntent.minified.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script src="scripts/autoCenter.js" type="text/javascript"></script>
	<script src="scripts/popup.js" type="text/javascript"></script>
	<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
	<script src="scripts/jquery-barcode.js" type="text/javascript"></script>
	<script src="scripts/productStock.js" type="text/javascript"></script>
	<script src="scripts/main.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
			$(".srchReport").chosen({width: "200px",disable_search_threshold:10});
			$(".srchGroup").chosen({width: "300px"});
			$(".srchCategory").chosen({width: "300px"});
			$(".srchSupplier").chosen({width: "300px"});
			$(".srchStatus").chosen({width: "300px"});
			$(".srchReorder").chosen({width: "300px"});
			$('#selectAll').click(function(e) {
				if(this.checked) {
					$('.selectitem').prop({checked: true});
					$('.selectAll').prop({checked: true});
				} else {
					$('.selectitem').prop({checked: false});
					$('.selectAll').prop({checked: false});
				};
			});
			$('.selectAll').click(function(e) {
				var id=$(this).val();
				if(this.checked) {
					$('.item'+id).prop({checked: true});
				} else {
					$('.item'+id).prop({checked: false});
				};
			});
			$('#btnPrintLabels').click(function(e) {
				$('#wrapper').addClass("noPrint");
				$('#print-area').removeClass("noPrint");
				PrintLabels("#listForm","#LoadPrint");
				e.preventDefault();
			});
			$('#btnPrintList').click(function(e) {
				$('#header').addClass("noPrint");
				$('#footer').addClass("noPrint");
				$('.form-wrap').addClass("noPrint");
				$('.listcontrols').addClass("noPrint");
				$('#print-area').addClass("noPrint");
				$('#wrapper').removeClass("noPrint");
				$('.stock-wrapper').removeClass("noPrint");
				window.print();
				e.preventDefault();
			});
			$('#btnAddToList').click(function(e) {
				$.ajax({
					type: "POST",
					url: "#parm.url#ajax/AJAX_LabelSaveList.cfm",
					data: $('#listForm').serialize(),
					beforeSend:function(){
						$('#loading').loading(true);
					},
					success:function(data){
						$('#loading').loading(false);
					},
					error:function(data){
						$('#loading').loading(false);
					}
				});
				e.preventDefault();
			});
			$('#quicksearch').on("keyup",function() {
				var srch=$(this).val();
				$('.searchrow').each(function() {
					var id=$(this).attr("data-prodID");
					var str=$(this).attr("data-title");
					
					if (str.toLowerCase().indexOf(srch.toLowerCase()) == -1) {
						$(this).hide();
					} else {
						$(this).show();
					}
					
				});
			});
			$('#btnShowList').click(function(event) {
				$.ajax({
					type: "GET",
					url: "stockGetList.cfm",
					beforeSend: function() {
						$('.stock-wrapper').html("Loading...");
					},
					success: function(data) {
						$('.stock-wrapper').html(data);
					},
					error: function() {
						$('.stock-wrapper').html("Error. Try again. It was probably your fault anyway...");
					}
				});
				event.preventDefault();
			});
			var isEditingTitle = false;
			$('.sod_title').click(function(event) {
				if (!isEditingTitle) {
					var value = $(this).html();
					var prodID = $(this).attr("data-id");
					var htmlStr = "<input type='text' size='40' value='" + value + "' class='sod_title_input' data-id='" + prodID + "'>";
					$(this).html(htmlStr);
					$(this).find('.sod_title_input').focus();
				}
				isEditingTitle = true;
			});
			$(document).on("blur", ".sod_title_input", function(event) {
				var value = $(this).val();
				var prodID = $(this).attr("data-id");
				var cell = $(this).parent('.sod_title');
				$.ajax({
					type: "POST",
					url: "saveProductTitle.cfm",
					data: {"title": value, "prodID": prodID},
					success: function(data) {
						cell.html(data.trim());
						isEditingTitle = false;
					}
				});
			});
			$('.sod_status').click(function(event) {
				var value = $(this).html();
				var prodID = $(this).attr("data-id");
				var cell = $(this);
				$.ajax({
					type: "POST",
					url: "saveProductStatus.cfm",
					data: {"status": value, "prodID": prodID},
					success: function(data) {
						cell.html(data.trim());
						cell.css("color",'red');
						cell.css("font-weight",'bold');
					}
				});
			});
			$('.sod_lock').click(function(event) {
				var value = $(this).html();
				var prodID = $(this).attr("data-id");
				var cell = $(this);
				$.ajax({
					type: "POST",
					url: "saveProductLock.cfm",
					data: {"lock": value, "prodID": prodID},
					success: function(data) {
						cell.html(data.trim());
						cell.css("color",'red');
						cell.css("font-weight",'bold');
					}
				});
			});
			$('.sod_discount').click(function(event) {
				var value = $(this).html();
				var prodID = $(this).attr("data-id");
				var cell = $(this);
				$.ajax({
					type: "POST",
					url: "saveProductDiscount.cfm",
					data: {"discount": value, "prodID": prodID},
					success: function(data) {
						cell.html(data.trim());
						cell.css("color",'red');
						cell.css("font-weight",'bold');
					}
				});
			});
		});
	</script>
	<style type="text/css">
		@page {size:portrait;margin:40px;}
		.lowPOR {background-color:#FF8080;}
		.pm {background-color: #D2E9FF;}
		.catActive {color:#0000FF}
		.catInactive {color:#FF0000}
	</style>
</head>

<cfobject component="code/stock" name="stock">
<cfobject component="code/products" name="prod">
<cfobject component="code/sales" name="sales">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset categories=stock.LoadCategories(parm)>
<cfset supps=prod.LoadSuppiers(parm)>
<cfset groups = sales.LoadGroups(parm)>
<cfparam name="srchReport" default="">
<cfparam name="srchGroup" default="">
<cfparam name="srchCategory" default="">
<cfparam name="srchSupplier" default="">
<cfparam name="srchCatStr" default="">
<cfparam name="srchProdStr" default="">
<cfparam name="srchDateFrom" default="">
<cfparam name="srchDateTo" default="">
<cfparam name="srchStockDate" default="">
<cfparam name="srchStatus" default="">
<cfparam name="srchProdStatus" default="">
<cfparam name="srchReorder" default="">
<cfset statusTitles = "open,closed,outofstock,promo,returned,inactive">
<cfset prodStatusTitles = "active,inactive,donotbuy">
<cfset reOrderTitles = "None,Monday,Thursday,Every">
<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post">
						<div class="form-header">
							Stock Search
							<span><input type="submit" name="btnSearch" value="Search" /></span>
						</div>
						<div class="module">
							<table border="0">
								<tr>
									<td><b>Report</b></td>
									<td>
										<select name="srchReport" class="srchReport" data-placeholder="Select...">
											<option value="1"<cfif srchReport eq "1"> selected="selected"</cfif>>Retail Price List</option>
											<option value="2"<cfif srchReport eq "2"> selected="selected"</cfif>>Trade Price List</option>
											<!---<option value="3"<cfif srchReport eq "3"> selected="selected"</cfif>>Latest Price List</option>--->
											<option value="4"<cfif srchReport eq "4"> selected="selected"</cfif>>Stock Take Report</option>
											<option value="5"<cfif srchReport eq "5"> selected="selected"</cfif>>Stock Sales Performance</option>
										</select>
									</td>
								</tr>
								<tr>
									<td><b>Group</b></td>
									<td>
										<select name="srchGroup" class="srchGroup" multiple="multiple" data-placeholder="Select...(optional)">
											<cfloop query="groups.ProductGroups">
											<option value="#pgID#"<cfif ListFind(srchGroup,pgID)> selected</cfif>>#pgTitle#</option>
											</cfloop>
										</select>
									</td>
								</tr>
								<tr>
									<td><b>Category</b></td>
									<td>
										<select name="srchCategory" class="srchCategory" multiple="multiple" data-placeholder="Select...(optional)">
											<cfloop query="categories.QCategories">
												<option value="#pcatID#"<cfif ListFind(srchCategory,pcatID)> selected="selected"</cfif>>#pcatTitle#</option>
											</cfloop>
										</select>
									</td>
								</tr>
								<tr>
									<td><b>Supplier</b></td>
									<td>
										<select name="srchSupplier" class="srchSupplier" multiple="multiple" data-placeholder="Select...(optional)">
											<cfloop array="#supps#" index="i">
												<option value="#i.id#"<cfif ListFind(srchSupplier,i.id)> selected="selected"</cfif>>#i.name#</option>
											</cfloop>
										</select>									
									</td>
								</tr>
								<tr>
									<td><b>Product Status</b></td>
									<td>
										<select name="srchProdStatus" class="srchStatus" multiple="multiple" data-placeholder="Select...(optional)">
											<cfloop list="#prodStatusTitles#" index="i" delimiters=",">
												<option value="#i#"<cfif ListFind(srchProdStatus,i)> selected="selected"</cfif>>#i#</option>
											</cfloop>
										</select>									
									</td>
								</tr>
								<tr>
									<td><b>Stock Status</b></td>
									<td>
										<select name="srchStatus" class="srchStatus" multiple="multiple" data-placeholder="Select...(optional)">
											<cfloop list="#statusTitles#" index="i" delimiters=",">
												<option value="#i#"<cfif ListFind(srchStatus,i)> selected="selected"</cfif>>#i#</option>
											</cfloop>
										</select>									
									</td>
								</tr>
								<tr>
									<td><b>Reorder Status</b></td>
									<td>
										<select name="srchReorder" class="srchReorder" multiple="multiple" data-placeholder="Select...(optional)">
											<cfloop list="#reOrderTitles#" index="i" delimiters=",">
												<option value="#i#"<cfif ListFind(srchReorder,i)> selected="selected"</cfif>>#i#</option>
											</cfloop>
										</select>									
									</td>
								</tr>
								<tr>
									<td><b>Category Contains</b></td>
									<td>
										<input type="text" name="srchCatStr" value="#srchCatStr#" />
									</td>
								</tr>
								<tr>
									<td><b>Product Title Contains</b></td>
									<td>
										<input type="text" name="srchProdStr" value="#srchProdStr#" />
									</td>
								</tr>
								<tr>
									<td><b>Last Purchased Between</b></td>
									<td>
										<input type="text" name="srchDateFrom" value="#srchDateFrom#" class="datepicker" />
									</td>
								</tr>
								<tr>
									<td><b>...And</b></td>
									<td>
										<input type="text" name="srchDateTo" value="#srchDateTo#" class="datepicker" />
									</td>
								</tr>
								<tr>
									<td><b>Stock Take Date</b></td>
									<td>
										<input type="text" name="srchStockDate" value="#srchStockDate#" class="datepicker" />
									</td>
								</tr>
							</table>
						</div>
					</form>
				</div>

				<cfif StructKeyExists(form,"fieldnames")>
					<cfsetting requesttimeout="900">
					<cfflush interval="200">
					<cfset parm.form=form>
					<span><div id="loading"></div></span>
					<form method="post" id="listForm">
						<div class="module listcontrols">
							<a href="exportBarcodes.cfm" target="_blank" id="btnExport" class="button">Export Barcodes</a>
							<a href="##" id="btnPrintLabels" class="button">Print Labels</a>
							<a href="##" id="btnShowList" class="button">Show List</a>
							<a href="##" id="btnSaveList" class="button">Update List</a>
							<a href="##" id="btnPrintList" class="button">Print</a>
						</div>
						<div class="stock-wrapper module">
							<script>
								$(document).ready(function(e) {
									$('##btnSaveList').click(function(event) {
										var list = [];
										$('.selectitem').each(function(i, e) {
											if ($(e).prop("checked")) {
												list.push($(e).val());
											}
										});
										$.ajax({
											type: "POST",
											url: "stockSaveList.cfm",
											data: {
												"list": JSON.stringify(list),
												"type": "append"
											},
											success: function(data) {
												$.messageBox("List Updated", "success");
											}
										});
										event.preventDefault();
									});
								});
							</script>
							<cfswitch expression="#srchReport#">
								<cfcase value="1">
									<cfset stocklist=stock.StockSearch(parm)>
									<!---<cfdump var="#stocklist#" label="stocklist" expand="false">--->
									<cfset colspan=13>
									<cfif stocklist.recCount GT 0>
										<cfoutput>
											<p><strong>#stocklist.recCount# products</strong></p>
											<table width="100%" class="tableList" border="1">
												<tr>
													<th width="10"></th>
													<th>ID</th>
													<th>Reference</th>
													<th align="left"><input type="text" id="quicksearch" value="" placeholder="Search products" style="width:90%;"></th>
													<th>Product<br>Status</th>
													<th>Discountable</th>
													<th>Lock</th>
													<th>Size</th>
													<th>Price Desc.</th>
													<th>Our Price</th>
													<th>Pack Qty</th>
													<th>Stock<br>Status</th>
													<th>Reorder</th>
													<th>Last Purchased</th>
												</tr>
											<cfset category=0>
											<cfloop query="stocklist.stockItems">
												<cfset ourPrice = val(siOurPrice) eq 0 ? prodOurPrice : siOurPrice>
												<cfif prodCatID neq category>
													<tr class="searchrow" data-title="">
														<th><input type="checkbox" class="selectAll" value="#prodCatID#" style="width:20px; height:20px;" /></th>
														<th colspan="#colspan#" align="left"><strong>#pCatTitle#</strong>
															<cfif pcatShow><span class="catActive">Active</span>
																<cfelse><span class="catInactive">Inactive</span></cfif>
														</th>
													</tr>
													<cfset category=prodCatID>
												</cfif>
												<tr class="searchrow" data-title="#prodTitle#" data-prodID="#prodID#">
													<td><input type="checkbox" name="selectitem" class="selectitem item#prodCatID# searchrowselect#prodID#" value="#prodID#"></td>
													<td><a href="productStock6.cfm?product=#prodID#" target="_blank">#prodID#</a></td>
													<td><a href="stockItems.cfm?ref=#prodID#" target="_blank">#prodRef#</a></td>
													<td class="sod_title disable-select" data-id="#prodID#">#prodTitle#</td>
													<td class="sod_status disable-select" data-id="#prodID#">#prodStatus#</td>
													<td align="center" class="sod_discount" data-id="#prodID#">#prodStaffDiscount#</td>
													<td class="sod_lock disable-select" data-id="#prodID#">#GetToken("unlocked,locked",int(prodLocked)+1,",")#</td>
													<td>#siUnitSize#</td>
													<td>#prodUnitSize#</td>
													<td class="ourPrice">&pound;#ourPrice# <span class="tiny">#GetToken(" ,PM",prodPriceMarked+1,",")#</span></td>
													<td>#siPackQty#</td>
													<td>#siStatus#</td>
													<td>#prodReorder#</td>
													<td>
														<cfif StructKeyExists(stocklist.stockItems,'soDate')>
															#LSDateFormat(soDate,"ddd dd-mmm yy")# <span class="tiny">ordered</span>
														<cfelse>#DateFormat(prodLastBought,"dd-mmm-yyyy")#</cfif>
													</td>
												</tr>
											</cfloop>
											</table>
										</cfoutput>
									<cfelse>
										No records found.
									</cfif>
								</cfcase>
								<cfcase value="2">
									<cfset stocklist=stock.StockSearch(parm)>
									<cfif stocklist.recCount GT 0>
										<cfset colspan=13>
										<cfoutput>
											<p>#stocklist.recCount# products</p>
											<table width="100%" class="tableList" border="1">
												<tr>
													<th width="11"><input type="checkbox" class="selectAll" value="1" checked="checked" style="width:20px; height:20px;" /></th>
													<th>ID</th>
													<th>Reference</th>
													<th>Title</th>
													<th>Unit Size</th>
													<th>VAT Rate</th>
													<th>WSP</th>
													<th>Pack Qty</th>
													<th>Unit Trade</th>
													<th>Our Price</th>
													<th>POR%</th>
													<th>Reorder</th>
													<th>Last Purchased</th>
												</tr>
											<cfset category=0>
											<cfloop query="stocklist.stockItems">
												<cfset ourPrice = val(siOurPrice) eq 0 ? prodOurPrice : siOurPrice>
												<cfset ourPrice = val(ourPrice) eq 0 ? 0.01 : ourPrice>
												<!---<cfset profit = ourPrice - siUnitTrade>
												<cfset POR = int((profit / ourPrice) * 100)>--->

													<cfset unitVAT = val(siUnitTrade) * (prodVATRate / 100)>
													<cfset unitGross = val(siUnitTrade) + unitVAT>
													<cfset profit = ourPrice - unitGross>
													<cfset POR = int((profit / ourPrice) * 100)>



												<cfif prodCatID neq category>
													<tr>
														<td colspan="#colspan#" style="background-color:##eeeeee"><strong>#pCatTitle#</strong></td>
													</tr>
													<cfset category=prodCatID>
												</cfif>
												
												<tr class="searchrow" data-title="#prodTitle#" data-prodID="#prodID#">
													<td><input type="checkbox" name="selectitem" class="selectitem" value="#prodID#" checked="checked"></td>
													<td><a href="productStock6.cfm?product=#prodID#" target="_blank">#prodID#</a></td>
													<td><a href="stockItems.cfm?ref=#prodID#" target="_blank">#prodRef#</a></td>
													<td class="sod_title disable-select" data-id="#prodID#">#prodTitle#</td>
													<td>#siUnitSize#</td>
													<td align="right">#prodVATRate#%</td>
													<td>&pound;#siWSP#</td>
													<td align="center">#siPackQty#</td>
													<td align="right">&pound;#DecimalFormat(unitGross)#</td>
													<td class="ourPrice">&pound;#ourPrice# <span class="tiny">#GetToken(" ,PM",prodPriceMarked+1,",")#</span></td>
													<td>#POR#%</td>
													<td>#prodReorder#</td>
													<td><cfif StructKeyExists(stocklist.stockItems,'soDate')>#LSDateFormat(soDate,"ddd dd-mmm yy")#</cfif></td>
												</tr>
											</cfloop>
											</table>
										</cfoutput>
									<cfelse>
										No records found.
									</cfif>
								</cfcase>
<!---
								<cfcase value="3">
									<cfset stocklist=stock.StockPriceList(parm)><!---<cfdump var="#stocklist#" label="stocklist" expand="false">--->
									<cfif stocklist.recCount GT 0>
										<cfset colspan=7>
										<cfoutput>
												<p><strong>#stocklist.recCount# products</strong></p>
												<table width="100%" class="tableList" border="1">
													<tr>
														<th width="10"></th>
														<th>ID</th>
														<th>Reference</th>
														<th align="left"><input type="text" id="quicksearch" value="" placeholder="Search products" style="width:96%;"></th>
														<th width="80">Unit Size</th>
														<th width="80">Our Price</th>
														<th width="40">Price Marked</th>
														<th width="100">Last Purchased</th>
													</tr>
												<cfset category=0>
												<cfloop query="stocklist.stockItems">
												<cfset ourPrice = val(siOurPrice) eq 0 ? prodOurPrice : siOurPrice>
													<cfif prodCatID neq category>
														<tr class="searchrow" data-title="">
															<th><input type="checkbox" class="selectAll" value="#prodCatID#" style="width:20px; height:20px;" /></th>
															<th colspan="#colspan#" align="left"><strong>#pCatTitle#</strong></th>
														</tr>
														<cfset category=prodCatID>
													</cfif>
													<tr class="searchrow" data-title="#prodTitle#" data-prodID="#prodID#">
														<td><input type="checkbox" name="selectitem" class="selectitem item#prodCatID# searchrowselect#prodID#" value="#prodID#"></td>
													<td><a href="productStock6.cfm?product=#prodID#" target="_blank">#prodID#</a></td>
													<td><a href="stockItems.cfm?ref=#prodID#" target="_blank">#prodRef#</a></td>
														<td class="sod_title disable-select" data-id="#prodID#">#prodTitle#</td>
														<td align="center">#prodUnitSize#</td>
														<td align="right">&pound;#ourPrice#</td>
														<td align="center">#GetToken(" ,PM",prodPriceMarked+1,",")#</td>
														<td align="right">#LSDateFormat(prodLastBought,"ddd dd-mmm yy")#</td>
													</tr>
												</cfloop>
												</table>
										</cfoutput>
									<cfelse>
										No records found.
									</cfif>
								</cfcase>
--->
								<cfcase value="4">
									<cfset stocklist=stock.StockTakeList(parm)>
									<cfdump var="#stocklist#" label="stocklist" expand="no">
									<cfif stocklist.recCount GT 0>
										<cfset colspan=7>
										<cfoutput>
											<p><strong>#stocklist.recCount# products</strong></p>
											<table width="100%" class="tableList" border="1">
												<tr>
													<th width="10"></th>
													<th>ID</th>
													<th width="40">Reference</th>
													<th align="left"><input type="text" id="quicksearch" value="" placeholder="Search products" style="width:76%;"></th>
													<th width="40">Unit Size</th>
													<th width="160">Category</th>
													<th width="40">Our Price</th>
													<th width="30">PM</th>
													<th width="30">VAT</th>
													<th width="40">Trade Price</th>
													<th width="40">Stock Level</th>
													<th width="40">Value</th>
													<th width="40">POR%</th>
													<th width="100">Last Purchased</th>
												</tr>
												<cfset lineCount = 0>
												<cfset lowCount = 0>
												<cfset pmCount = 0>
												<cfset category = 0>
												<cfset totalTradeValue = 0>
												<cfset totalRetailValue = 0>
												<cfset totalPOR = 0>
												<cfset totalItems = 0>
												<cfloop query="stocklist.qstock">
													<cfset lineCount++>
													<cfset unitVAT = val(unitTrade) * (prodVATRate / 100)>
													<cfset unitGross = val(unitTrade) + unitVAT>
													<cfset profit = ourPrice - unitGross>
													<cfset POR = profit / ourPrice>
													<cfset tradeValue = val(unitTrade) * prodStockLevel>
													<cfset retailValue = val(ourPrice) * prodStockLevel>
													
													<cfset totalTradeValue += tradeValue>
													<cfset totalRetailValue += retailValue>
													<cfset totalPOR += POR>
													<cfset totalItems += prodStockLevel>
													<cfset target = int((pgTarget / (100 + pgTarget)) * 100) / 100>
													<cfif prodPriceMarked>
														<cfset class = "pm">
														<cfset pmCount++>
													<cfelseif POR lt target>
														<cfset class = "lowPOR">
														<cfset lowCount++>
													<cfelse>
														<cfset class = "">
													</cfif>
													<tr class="searchrow #class#" data-title="#prodTitle#" data-prodID="#prodID#">
														<td><input type="checkbox" name="selectitem" class="selectitem item#prodCatID# searchrowselect#prodID#" value="#prodID#"></td>
														<td><a href="productStock6.cfm?product=#prodID#" target="_blank">#prodID#</a></td>
														<td><a href="stockItems.cfm?ref=#prodID#" target="_blank">#prodRef#</a></td>
														<td class="sod_title disable-select" data-id="#prodID#">#prodTitle#</td>
														<td align="center">#prodUnitSize#</td>
														<td>#pcatTitle#<br>#pgTitle# (#target*100#%)</td>
														<td align="right"><strong>&pound;#ourPrice#</strong></td>
														<td align="center">#GetToken(" ,PM",prodPriceMarked+1,",")#</td>
														<td align="right">#prodVATRate#%</td>
														<td align="right">&pound;#unitTrade#</td>
														<td align="center">#prodStockLevel#</td>
														<td align="right">&pound;#DecimalFormat(tradeValue)#</td>
														<td align="right">#DecimalFormat(int(POR*10000)/100)#%</td>
														<td align="right">#LSDateFormat(prodLastBought,"ddd dd-mmm yy")#</td>
													</tr>											
												</cfloop>
												<tr>
													<th>#lineCount#</th>
													<th align="right">Items</th>
													<th align="center">#totalItems#</th>
													<th align="right">Retail Value</th>
													<th align="right">&pound;#DecimalFormat(totalRetailValue)#</th>
													<th align="right">Trade Value</th>
													<th align="right" colspan="2">&pound;#DecimalFormat(totalTradeValue)#</th>
													<th>POR</th>
													<th align="left">#DecimalFormat((totalPOR/lineCount))*100#%</th>
													<th></th>
													<th>Low</th>
													<th>#lowCount#</th>
													<th align="right"></th>
												</tr>
											</table>
										</cfoutput>
									</cfif>
								</cfcase>
								<cfcase value="5">
									<cfset stocklist=stock.SalesPerformance(parm)>
									<cfif stocklist.recCount GT 0>
										<cfset colspan=7>
										<cfoutput>
											<p><strong>#stocklist.recCount# products</strong></p>
											<table width="100%" class="tableList" border="1">
												<tr>
													<th>Reference</th>
													<th>Category</th>
													<th>Product</th>
													<th>First Sale</th>
													<th>Last Sale</th>
													<th>Day Span</th>
													<th>Last Sold<br>(days ago)</th>
													<th>No. Sold</th>
													<th>Average</th>
												</tr>
												<cfloop query="stocklist.qstock">
													<tr>
														<td><a href="productStock6.cfm?product=#prodID#" target="stockcheck">#prodRef#</a></td>
														<td>#pcattitle#</td>
														<td>#prodtitle#</td>
														<td>#DateFormat(firstsale)#</td>
														<td>#DateFormat(lastsale)#</td>
														<td align="center">#days#</td>
														<td align="center">#lastsold#</td>
														<th align="center">#productssold#</th>
														<td align="center">#averageSold#</td>
													</tr>												
												</cfloop>
											</table>
										</cfoutput>
									</cfif>
									<!---<cfdump var="#stocklist#" label="stocklist" expand="no">--->
								</cfcase>
								<cfdefaultcase>
									No Report selected.
								</cfdefaultcase>
							</cfswitch>
						</div>
					</form>
				</cfif>
			</div>
		</div>
	</div>
	<div id="print-area"><div id="LoadPrint"></div></div>
</body>
</cfoutput>
</html>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
