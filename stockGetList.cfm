<cftry>
<!DOCTYPE html>
<html>
<head>
	<title>Stock List</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/main4.css" rel="stylesheet" type="text/css">
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
	<script src="scripts/productStock6.js" type="text/javascript"></script>
	<script src="scripts/main.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			
			$(document).keypress(function(e){
				var bcode = "";
				var keyCode = e.keyCode ? e.keyCode : e.which; // get key code pressed
				if ($('input').is(":focus")  || $('select').is(":focus")) {
					//	data entry in form
				//	console.log("input " + keyCode);
				} else {
					bcode = newscanner(e);
					if (bcode) {
						$('#bcode').html(bcode);
						LookupProductStockID("product",bcode,"#result");
						setTimeout(function(){	// wait for db to update
							location.reload();
						},500); ;
					}
					e.preventDefault(); // stop form submission
				}
			});
		});		
</script>

<style type="text/css">
	@page {size:portrait;margin:40px;}
	@media print {
		.tableList {font-size:16px}
		.noprint {display:none};
	}
	#bcode {padding:6px; font-size:18px; color:#999999; border:solid 1px #cccccc; float:left;}
	.was {text-decoration:line-through; color:#ff0000}
	.ourPrice {font-weight:bold; color:#0066CC; font-size:20px}
	.tiny {font-size:9px}
</style>
</head>

<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfsetting showdebugoutput="no">
				<cfobject component="code/ProductStock6" name="pstock">
				<cfset parm = {}>
				<cfset parm.datasource = application.site.datasource1>
				<cfquery name="getStockListFromDB" datasource="#parm.datasource#">
					SELECT ctlStockList
					FROM tblControl
					WHERE ctlID = 1
				</cfquery>
				<cfset parm.stocklist = getStockListFromDB.ctlStockList>
				<cfif Len(parm.stocklist)>
					<cfset stocklist = pstock.LoadStockFromList(parm)>
				<cfelse>
					<strong>Your list is empty.</strong>
					<cfabort>
				</cfif>
				<cfoutput>
					<!---<div class="stock-wrapper">--->
						<script>
							$(document).ready(function(e) {
								$('##btnPrintList').click(function(e) {
									$('##header').addClass("noPrint");
									$('##footer').addClass("noPrint");
									$('.form-wrap').addClass("noPrint");
									$('.listcontrols').addClass("noPrint");
									$('##print-area').addClass("noPrint");
									$('##wrapper').removeClass("noPrint");
									$('.stock-wrapper').removeClass("noPrint");
									window.print();
									e.preventDefault();
								});
								$('##btnPrintLabels').click(function(event) {
									$('##wrapper').addClass("noPrint");
									$('##print-area').removeClass("noPrint");
									PrintLabels("##listForm","##LoadPrint");
									event.preventDefault();
								});
								$('##btnExportList').click(function(event) {
									ExportList("##listForm","##LoadPrint");
									event.preventDefault();
								});
								$('##btnImportOrder').click(function(event) {
									ImportOrder("##listForm","##LoadPrint");
									event.preventDefault();
								});
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
										data: {"list": JSON.stringify(list)},
										success: function(data) {
											$.messageBox("List Saved", "success");
											setTimeout(function(){	// wait for db to update
												location.reload();
											},500); ;
//											$.ajax({
//												type: "GET",
//												url: "stockGetListRaw.cfm",
//												success: function(data) {
//													$('.stock-wrapper').html(data);
//												}
//											});
										}
									});
									event.preventDefault();
								});
								$('.selectAllOnList').click(function(event) {
									if (this.checked) {
										$('.selectitem').prop({checked: true});
										$('.selectAllOnList').prop({checked: true});
									} else {
										$('.selectitem').prop({checked: false});
										$('.selectAllOnList').prop({checked: false});
									}
								});
								$('.selectitem').click(function(event) {
									$('.selectAllOnList').prop({checked: true});
									$('.selectitem').each(function(i, e) {
										if (!$(e).prop("checked")) {
											$('.selectAllOnList').prop({checked: false});
										}
									});
								});
								var isEditingTitle = false;
								$('.sod_title').click(function(event) {
									if (!isEditingTitle) {
										var value = $(this).html();
										var prodID = $(this).attr("data-id");
										var htmlStr = "<input type='text' size='40' value='" + value + "' class='sod_title_input' data-id='" + prodID + "'>";
										$(this).html(htmlStr);
										$(this).find('.sod_title_input').focus();
										isEditingTitle = true;
									}
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
							});
						</script>
						<div class="module noprint">
							<strong>#stocklist.recordcount# products</strong>
							<div id="bcode"></div>
							<div id="result"></div>
							<span><div id="loading"></div></span>
							<a href="##" id="btnPrintList" class="button">Print List</a>
							<a href="##" id="btnPrintLabels" class="button">Print Labels</a>
							<a href="##" id="btnSaveList" class="button">Update List</a>
							<a href="##" id="btnExportList" class="button">Export List</a>
							<a href="##" id="btnImportOrder" class="button">Import Order</a>
						</div>
						<div class="module">
							<form method="post" id="listForm">
								<table class="tableList" border="1">
									<tr>
										<th class="noprint" width="10">
											<input type="checkbox" name="selectAllOnList" class="selectAllOnList" checked="checked" style="width:20px; height:20px;"></th>
										<th>ID</th>
										<th>Barcode</th>
										<th width="200">Category</th>
										<th width="250">Description</th>
										<th width="100">Unit Size</th>
										<th>RRP</th>
										<th>Our Price</th>
										<th class="noprint">Pack Qty</th>
										<th class="noprint">WSP</th>
										<th class="noprint">Last Purchased/<br>Ordered</th>
									</tr>
									<cfset wspTotal = 0>
									<cfloop query="stocklist.stockItems">
										<cfset wspTotal += siWSP>
										<cfif siRRP neq siOurPrice><cfset rrpStyle = "was"><cfelse><cfset rrpStyle = ""></cfif>
										<tr class="searchrow" data-title="#prodTitle#" data-prodID="#prodID#">
											<td class="noprint">
												<input type="checkbox" name="selectitem" class="selectitem item#prodCatID# searchrowselect#prodID#" 
													value="#prodID#" checked="checked"></td>
											<td><a href="ProductStock6.cfm?product=#prodID#" target="stockItem">#prodID#</a></td>
											<td>#barcode#</td>
											<td>#pcatTitle#</td>
											<td class="sod_title" data-id="#prodID#">#prodTitle#</td>
											<td>#siUnitSize#</td>
											<td class="#rrpStyle#">#siRRP#</td>
											<td class="ourPrice">&pound;#siOurPrice# <span class="tiny">#GetToken(" ,PM",prodPriceMarked+1,",")#</span></td>
											<td class="noprint" align="center">#siPackQty#</td>
											<td class="noprint" align="right">#siWSP#</td>
											<td class="noprint">#LSDateFormat(siBookedIn,"ddd dd-mmm yy")#</td>
										</tr>
									</cfloop>
									<tr>
										<th colspan="9">Totals</th>
										<th align="right">#DecimalFormat(wspTotal)#</th>
										<th></th>
									</tr>
								</table>
							</form>
						</div>
					<!---</div>--->
				</cfoutput>
			</div>
		</div>
	</div>
	<div style="clear:both"></div>
	<div id="print-area"><div id="LoadPrint"></div></div>
</body>
</html>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>
