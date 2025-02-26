<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>Import Barcodes</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/main4.css" rel="stylesheet" type="text/css">
	<link href="css/productstock.css" rel="stylesheet" type="text/css">
	<link href="css/labels-small.css" rel="stylesheet" type="text/css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="scripts/jquery-1.11.1.min.js" type="text/javascript"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js" type="text/javascript"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js" type="text/javascript"></script>
	<script src="scripts/jquery.hoverIntent.minified.js" type="text/javascript"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script src="scripts/autoCenter.js" type="text/javascript"></script>
	<script src="scripts/popup.js" type="text/javascript"></script>
	<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
	<script src="scripts/jquery-barcode.js" type="text/javascript"></script>
	<script src="scripts/productStock6.js" type="text/javascript"></script>
	<script src="scripts/main.js"></script>
	<script src="scripts/popup.js" type="text/javascript"></script>

	<script type="text/javascript">
		$(document).ready(function() {
			$('#btnPrintLabels').click(function(e) {
				$('#wrapper').addClass("noPrint");
				$('#print-area').removeClass("noPrint");
				PrintLabels("#listForm","#LoadPrint");
				e.preventDefault();
			});
		});
	</script>
	<style type="text/css">
		body {font-family:Arial, Helvetica, sans-serif;}
		h1 {font-size:24px; padding:0px; margin:10px 0 10px 0;}
		.deals {font-size:11px; background-color:#A6CAF0;}
	</style>
</head>

<body>
	<div id="wrapper">
		<h1>Import Barcodes from Scanner</h1>
		<cfflush interval="500">
		<cfsetting requesttimeout="900">
		<cfobject component="code/ProductStock6" name="pstock">
		<cfset prodIDs = "">
		<cfset barcodes = []>
		<cfset crlf = "#chr(13)##chr(10)#">
		<cfset prodCount = 0>
		<cfset serverDirectory = application.site.dir_data>
		<cfset parm={}>
		<cfset parm.datasource=application.site.datasource1>
		<cfset parm.form=form>
		<cfparam name="choosefile" default="#serverDirectory#">
		<div id="form">
			<cfform  action="" enctype="multipart/form-data">
			   <cfinput type='file' accept='.txt' name="choosefile"><br>
			   <cfinput type="submit" name="loadData" value="Process Data">
			</cfform>
			<a href="##" id="btnPrintLabels" class="button">Print Labels</a>
			<div class="clear"></div>
		</div>
		<cfif StructKeyExists(form,"loadData")>
			<cfif len(choosefile)>
				<cffile action="upload" filefield="choosefile" destination="#serverDirectory#" nameconflict="overwrite">
				<cfif fileExists("#serverDirectory#\#cffile.serverfile#")>
					<cffile action="read" file="#serverDirectory#\#cffile.serverfile#" variable="barcodetext" addnewline="yes" charset="utf-8">
					<cfoutput>
						<div id="content">
						<form method="post" id="listForm">
						<table border="1" class="tableList">
							<tr>
								<th>Barcode</th>
								<!---<th></th>--->
								<th>Prod ID</th>
								<th>Product Reference</th>
								<th>Title</th>
								<th>Unit Size</th>
								<th>VAT Rate</th>
								<th>Reorder</th>
								<th>Staff Discount</th>
								<th>Product Status</th>
								<th>Item Status</th>
								<th>Trade Price</th>
								<th>WSP</th>
								<th>Last Bought</th>
								<th>Order Reference</th>
								<th>Deals</th>
							</tr>
							<cfloop list="#barcodetext#" index="line" delimiters="#crlf#">
								<tr>
									<cfloop list="#line#" index="cell" delimiters=","><!--- ignore all but last cell data ---></cfloop>
									<td>
										<a href="https://www.booker.co.uk/products/product-list?keywords=#cell#" target="booker">#cell#</a>
									</td>
									<cfif ArrayFind(barcodes,cell) eq 0>	<!--- skip duplicates --->
										<cfset prodCount++>
										<cfset ArrayAppend(barcodes,cell)>	<!--- save last cell in row as barcode --->
										<cfset parm.form.barcode = cell>
										<cfset parm.form.source = "product">
										<cfset data = pstock.FindProductData(parm)>
										<!---<td><cfdump var="#data#" label="#cell#" expand="false"></td>--->
										<cfif data.productID neq 0>
											<cfset prodIDs = "#prodIDs#,#data.productID#">
											<td><a href="ProductStock6.cfm?product=#data.productID#" target="product">#data.productID#</a></td>
											<td>#data.QProduct.siRef#</td>
											<td width="340">
												#data.QProduct.prodTitle#
												<cfif data.QDeals.recordcount gt 0>
													<cfloop query="data.QDeals">
														<table class="deals" border="0">
															<tr>
																<th>Deal Title</th>
																<th>Type</th>
																<th>Amount</th>
																<th>Starts</th>
																<th>Ends</th>
															</tr>
															<tr>
																<td>
																	#data.QDeals.ercTitle#<br />
																	#data.QDeals.edTitle#
																</td>
																<td>#data.QDeals.edDealType#</td>
																<td>&pound;#data.QDeals.edAmount#</td>
																<td>#LSDateFormat(data.QDeals.edStarts,'dd-mmm-yy')#</td>
																<td>#LSDateFormat(data.QDeals.edEnds,'dd-mmm-yy')#</td>
															</tr>
														</table>
													</cfloop>
												</cfif>
											</td>
											<td>#data.QProduct.siUnitSize#</td>
											<td>#data.QProduct.prodVATRate#%</td>
											<td align="center">#data.QProduct.prodReorder#</td>
											<td align="center">#data.QProduct.prodStaffDiscount#</td>
											<td align="center">#data.QProduct.prodStatus#</td>
											<td align="center">#data.QProduct.siStatus#</td>
											<td align="right">#data.QProduct.siUnitTrade#</td>
											<td align="right">#data.QProduct.siWSP#</td>
											<td>#LSDateFormat(data.QProduct.prodLastBought,'dd-mmm-yy')#</td>
											<td>#data.QProduct.soRef#</td>
											<td>#data.QDeals.recordcount#</td>
										<cfelse>
											<td>#data.productID#</td>
											<td>Product not found</td>
											<td colspan="11"></td>
										</cfif>
									</cfif>
								</tr>
							</cfloop>
							<tr>
								<td colspan="12">#prodCount# products</td>
							</tr>
						</table>
							<input type="text" name="productIDs" value="#prodIDs#"/>
						</form>
						</div>
					</cfoutput>
				</cfif>
			<cfelse>
				No file selected.
			</cfif>
		</cfif>
		<div id="stockdiv"></div>
		<div id="print-area"><div id="LoadPrint"></div></div>
	</div>
</body>
</html>
