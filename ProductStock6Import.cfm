<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>Parse HTML</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/main4.css" rel="stylesheet" type="text/css">
	<link href="css/productstock.css" rel="stylesheet" type="text/css">
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

		});
	</script>
</head>

<body>
	<h1>Import barcode data</h1>
	<cfflush interval="500">
	<cfsetting requesttimeout="900">
	<cfobject component="code/ProductStock6" name="pstock">
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
		<div class="clear"></div>
	</div>
	<cfif StructKeyExists(form,"loadData")>
		<cfif len(choosefile)>
			<cffile action="upload" filefield="choosefile" destination="#serverDirectory#" nameconflict="overwrite">
			<cfif fileExists("#serverDirectory#\#cffile.serverfile#")>
				<cffile action="read" file="#serverDirectory#\#cffile.serverfile#" variable="barcodetext" addnewline="yes" charset="utf-8">
				<cfoutput>
					<div id="content">
					<table border="1" class="tableList">
						<tr>
							<th>Barcode</th>
							<th></th>
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
								<td>#cell#</td>
								<cfif ArrayFind(barcodes,cell) eq 0>
									<cfset prodCount++>
									<cfset ArrayAppend(barcodes,cell)>	<!--- save last cell in row as barcode --->
									<cfset parm.form.barcode = cell>
									<cfset parm.form.source = "product">
									<cfset product = pstock.FindProductData(parm)>
									<td><cfdump var="#product#" label="#cell#" expand="false"></td>
									<cfif product.productID neq 0>
										<td>#product.productID#</td>
										<td>#product.QProduct.siRef#</td>
										<td>#product.QProduct.prodTitle#</td>
										<td>#product.QProduct.prodUnitSize#</td>
										<td>#product.QProduct.prodVATRate#%</td>
										<td align="center">#product.QProduct.prodReorder#</td>
										<td align="center">#product.QProduct.prodStaffDiscount#</td>
										<td align="center">#product.QProduct.prodStatus#</td>
										<td align="center">#product.QProduct.siStatus#</td>
										<td align="right">#product.QProduct.siUnitTrade#</td>
										<td align="right">#product.QProduct.siWSP#</td>
										<td>#LSDateFormat(product.QProduct.prodLastBought,'dd-mmm-yy')#</td>
										<td>#product.QProduct.soRef#</td>
										<td>#product.QDeals.recordcount#</td>
									<cfelse>
										<td>#product.productID#</td>
										<td>Product not found</td>
										<td colspan="12"></td>
									</cfif>
								</cfif>
							</tr>
						</cfloop>
						<tr>
							<td colspan="13">#prodCount# products</td>
						</tr>
					</table>
					</div>
				</cfoutput>
			</cfif>
		<cfelse>
			No file selected.
		</cfif>
	</cfif>
	<div id="stockdiv"></div>
</body>
</html>
