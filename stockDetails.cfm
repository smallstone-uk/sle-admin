<!--- 
	prodPackPrice field ignored use siWSP instead
	maybe redundant	19/06/22
--->

<!DOCTYPE html>
<html>
<head>
<title>Stock Order Details</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/main4.css" rel="stylesheet" type="text/css">
<link href="css/productstock.css" rel="stylesheet" type="text/css">
<link href="css/labels-small.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/main.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/jquery-barcode.js" type="text/javascript"></script>
<script src="scripts/productStock.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() { 
	
		function calc_total(){
		  var sum = 0;
		  $(".sod_wspTotal").each(function(){
			sum += parseFloat($(this).text());
		  });
		  $('#orderTotal').text(sum);
		}
		
		$('#menu').dcMegaMenu({rowItems: '3',event: 'hover',fullWidth: true});
		$('#btnPrintLabels').click(function(e) {
			$('#order-list').addClass("noPrint");
			$('#wrapper').addClass("noPrint");
			$('#print-area').removeClass("noPrint");
			PrintLabels("#listForm","#LoadPrint");
			e.preventDefault();
		});
		$('#btnPrintList').click(function(e) {
			$('#order-list').removeClass("noPrint");
			$('#wrapper').removeClass("noPrint");
			$('#print-area').addClass("noPrint");
			window.print();
			e.preventDefault();
		});
		$('#selectAll').click(function(e) {   
			if(this.checked) {
				$('.selectitem').prop({checked: true});
			} else {
				$('.selectitem').prop({checked: false});
			};
		});
		var isEditingTitle = false;
		$('.sod_title').click(function(event) {
			if (!isEditingTitle) {
				var value = $(this).html();
				var prodID = $(this).attr("data-id");
				var htmlStr = "<input type='text' value='" + value + "' class='sod_title_input' data-id='" + prodID + "'>";
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
		var isEditingWSP = false;
		$('.sod_wsp').click(function(event) {
			if (!isEditingWSP) {
				var value = $(this).html().trim();
				var rowID = $(this).attr("data-row");
				var stockID = $(this).attr("data-id");
				var ourPrice = $(this).attr("data-ourPrice");
				var vatRate = $(this).attr("data-vatRate");
				var packQty = $(this).attr("data-packqty");
				var qtyPacks = $(this).attr("data-qtyPacks");
				var htmlStr = "<input type='text' size='6' value='" + value + "' class='sod_wsp_input' data-id='" + stockID + "' data-ourPrice='" + ourPrice+ "' data-vatRate='" + vatRate + "' data-packqty='" + packQty + "' data-row='" + rowID
+ "' data-qtyPacks='" + qtyPacks + "' />";
				$(this).html(htmlStr);
				$(this).find('.sod_wsp_input').focus();
			}
			isEditingWSP = true;
		});
		$(document).on("blur", ".sod_wsp_input", function(event) {
			var value = $(this).val();
			var stockID = $(this).attr("data-id");
			var ourPrice = $(this).attr("data-ourPrice");
			var vatRate = $(this).attr("data-vatRate");
			var packQty = $(this).attr("data-packqty");
			var qtyPacks = $(this).attr("data-qtyPacks");
			var rowID = $(this).attr("data-row");
			var rowData = $('#' + rowID).html();
			var myTrade = $(this).closest('tr').find(".sod_unittrade");
			var myTradeTotal = $(this).closest('tr').find(".sod_wspTotal");
			var myPOR = $(this).closest('tr').find(".sod_POR");
			var cell = $(this).parent('.sod_wsp');
			var trade = $(rowID + ' .sod_unittrade');
			$.ajax({
				type: "POST",
				url: "saveProductWSP.cfm",
				data: {"wsp": value, "stockID": stockID, "packQty": packQty, "qtyPacks": qtyPacks, "ourPrice": ourPrice, "vatRate": vatRate},
				success: function(data) {
					var json = $.parseJSON(data);
					cell.html(json.wsp.trim());
					myTrade.html(json.unitTrade.trim());
					myTradeTotal.html(json.tradeTotal.trim());
					myPOR.html(json.por.trim() + "%");
					calc_total();
					isEditingWSP = false;
				}
			});
		});
	});
</script>
<style type="text/css">
	.priceDiff {background-color:#FADCD8;}
	.priceMatch {background-color:#fff;}
	.rowGrey {color:#CCC;}
	.header {font-size:14px; font-weight:bold;}
	.headleft {text-align:left; font-size:12px;}
	.headright {text-align:right; font-size:12px;}
	.substitute {color:#FF0000; font-weight:bold;}
	.small {font-size:10px;}
	.sod_wsp {background-color:#9CF;}
	.ourPrice {font-weight:bold; color:#0066CC; font-size:20px}
	.tiny {font-size:9px}

	@page {size:portrait;margin:40px;}

	@media print {
		.noPrint {display:none;}
	}
</style>
</head>

<cftry>
<cfparam name="ref" default="">
<cfobject component="code/stock" name="stock">
<cfif len(ref)>
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.ref=ref>
	<cfset stockSheet=stock.OrderDetails(parm)>
</cfif>
<body>
	<div id="wrapper">
		<div class="noPrint"><cfinclude template="sleHeader.cfm"></div>
		<div id="content">
			<div id="content-inner">
				<div id="orderOverlay-ui"></div>
				<div id="orderOverlay">
					<div id="orderOverlayForm">
						<a href="##" class="orderOverlayClose">X</a>
						<div id="orderOverlayForm-inner"></div>
					</div>
				</div>
				<div id="order-list" style="page-break-inside:avoid;">
					<cfoutput>
						<script>
							$(document).ready(function(e) {
								$('##btnSaveLabels').click(function(event) {
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
						<div id="bcTarget"></div>
						<div class="module">
						<div style="background:##D9FFCA; float:left; text-align:center; padding:10px; font-weight:bold; font-size:14px; margin:0 5px 5px 0; border:1px solid ##000;">
							New Products
						</div>
						<div style="background:##FADCD8; float:left; text-align:center; padding:10px; font-weight:bold; font-size:14px; margin:0 5px 5px 0; border:1px solid ##000;">
							Retail Price Different To Our Price
						</div>
						<form method="post" id="listForm">
							<div id="order-controls" class="noPrint">
								<input type="button" id="btnSaveLabels" value="Save Labels To List" />
								<input type="button" id="btnPrintLabels" value="Print Labels" />
								<input type="button" id="btnPrintList" value="Print List" />
							</div>
							</div>
							<div class="module">
							<div class="clear"></div>
							<cfif stockSheet.count gt 0>
								<!---<cfdump var="#stockSheet#" label="stockSheet" expand="false">--->
								<table width="100%" id="stockTable" class="tableList" border="1">
									<tr>
										<td class="header" colspan="4">Reference: #stockSheet.OrderRef# (ID: #stockSheet.orderID#)</td>
										<td class="header" colspan="6">Order Date: #stockSheet.OrderDate#</td>
										<td colspan="3"></td>
									</tr>
									<tr>
										<th class="headleft noPrint"><input type="checkbox" id="selectAll" value="1" checked="checked" style="width:20px; height:20px;" /></th>
										<th class="headleft">##</th>
										<th class="headleft">Barcode</th>
										<th class="headleft">Reference</th>
										<th class="headleft">Description</th>
										<th class="headleft">Unit Size</th>
										<th class="headright">WSP</th>
										<th class="headright">Unit<br>Price</th>
										<th>Ordered<br>Packs</th>
										<th>Received<br>Units</th>
										<th class="headright">Order<br>Total</th>
										<th class="headright">Recvd<br>Total</th>
										<th class="headright" width="40">Our Price</th>
										<!---<th>PM</th>--->
										<th class="headright">POR</th>
										<th width="40">VAT Rate</th>
										<th width="40">Status</th>
									</tr>
									<cfset rowCount=0>
									<cfset itemCount=0>
									<cfset category="">
									<cfset orderTotal=0>
									<cfset recvdTotal=0>
									<cfset avgPOR = 0>
									<cfset totalTrade = 0>
									<cfloop array="#stockSheet.items#" index="item">
										
										<cfif StructKeyExists(item,"siPOR")>
											<cfset avgPOR += item.siPOR>
											<cfset packQty = Iif(val(item.prodPackQty) lt 1,1,val(item.prodPackQty))>
										<cfelse><tr><td colspan="17">#item.msg#<!---<cfdump var="#item#" label="item" expand="false">---></td></tr></cfif>
										<cfif StructKeyExists(item,"prodRef") AND item.prodref neq "not found">
											<cfset rowCount++>
											<cfset itemCount++>
											<!---<cfif StructKeyExists(item,"siWSP") AND StructKeyExists(item,"siQtyPacks")>--->
											<cfset orderValue = (val(item.siWSP) * val(item.siQtyPacks))>
											<cfset recvdValue = val(item.siUnitTrade) * val(item.siQtyItems)>
											<cfset orderTotal += orderValue>
											<cfset recvdTotal += recvdValue>
											<!---</cfif>--->
											<cfif item.category neq category>
												<tr>
													<td></td>
													<td colspan="13" style="background-color:##EFF3F7"><strong>#item.category#</strong></td>
												</tr>
												<cfset category=item.category>
											</cfif>
											<cfif item.prodRRP NEQ item.prodOurPrice>
												<cfset rowColor="priceDiff">
											<cfelse><cfset rowColor="priceMatch"></cfif>
											<cfif item.siSubs GT 0>
												<cfset rowColor="#rowColor# rowGrey">
											</cfif>
											<cfset wspTotal = item.siQtyPacks * item.siWSP>
											<tr id="row#rowCount#" class="#rowColor#" <cfif item.newFlag>style="background-color:##D9FFCA;"</cfif>>
												<td class="noPrint"><input type="checkbox" name="selectitem" class="selectitem" 
													value="#item.prodID#" <cfif item.changedFlag OR item.newFlag>checked="checked"</cfif> /></td>
												<td>#itemCount#</td>
												<td width="100">
													<script type="text/javascript">
														$(document).ready(function() {
															var code="#Right(item.barCode,13)#";
															var type="ean13";
															if (code.length == 8) {
																type="ean8";
															} else if (code.length == 13) {
																type="ean13";
															} else {
																type="upc";
															}
															$(".barcode#itemCount#").barcode(code, type); //,{barWidth:2, barHeight:20}
														});
													</script>
													<a href="https://www.booker.co.uk/products/product-list?keywords=#item.barCode#" 
														target="booker"><div class="barcode#itemCount#">#item.barCode#</div></a>
												</td>
												<td><a href="ProductStock6.cfm?product=#item.prodID#" target="_blank">[#item.prodID#] #item.prodRef#</a>
													<cfif len(item.msg)><br /><span class="substitute">#item.msg#</span></cfif></td>
												<td class="sod_title" data-id="#item.prodID#">#item.prodTitle#</td>
												<td>#item.prodPackQty# X #item.prodUnitSize#</td>
												<td align="right" class="sod_wsp" 
													data-row="row#rowCount#" 
													data-id="#item.siID#" 
													data-ourPrice="#item.siOurPrice#"
													data-vatRate="#item.prodVATRate#"
													data-packqty="#item.prodPackQty#"
													data-qtyPacks="#item.siQtyPacks#">
													#item.siWSP#
												</td>
												<td align="center" class="sod_unittrade">#item.siUnitTrade#</td>
												<td align="center">#item.siQtyPacks#</td>
												<td align="center">#item.siReceived#</td>
												<td align="right" >#DecimalFormat(orderValue)#</td>
												<td align="right" >#DecimalFormat(recvdValue)#</td>
												<td align="right" class="sod_wspTotal">#DecimalFormat(wspTotal)#</td>
												<td align="right" class="ourPrice">&pound;#item.siOurPrice# <span class="tiny">#GetToken(" ,PM",item.prodPriceMarked+1,",")#</span></td>
												<!---<td align="center">#YesNoFormat(item.prodPriceMarked)#</td>--->
												<td align="right" class="sod_POR">#item.siPOR#%</td>
												<td align="right" class="sod_vatRate">#DecimalFormat(item.prodVATRate)#%</td>
												<td align="right">#item.siStatus#</td>
											</tr>
										</cfif>
									</cfloop>
									<cfset avgPOR = avgPOR / itemCount>
<!---									<tr height="30">
										<td class="noPrint"></td>
										<td class="headright" colspan="7">Average POR #DecimalFormat(avgPOR)#% &nbsp; Order Value</td>
										<td class="headright" id="orderTotal">#DecimalFormat(orderTotal)#</td>
										<td class="headright" colspan="3">Received Value</td>
										<td class="headright">#DecimalFormat(recvdTotal)#</td>
										<td></td>
									</tr>
--->									
									<tr height="30">
										<td class="noPrint"></td>
										<td class="headright" colspan="9"></td>
										<td class="headright" id="orderTotal">#DecimalFormat(orderTotal)#</td>
										<td class="headright">#DecimalFormat(recvdTotal)#</td>
										<td colspan="6"></td>
									</tr>
								</table>
							<cfelse>
								No items found for order #ref#.
							</cfif>
						</form>
						</div>
					</cfoutput>
				</div>
			</div>
		</div>
		<!---<div class="noPrint"><cfinclude template="sleFooter.cfm"></div>--->
	</div>
	<cfif application.site.showdumps>
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</cfif>
	<div id="print-area"><div id="LoadPrint"></div></div>

    <cfcatch type="any">
		<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
    </cfcatch>
	</body>
</cftry>
</html>
