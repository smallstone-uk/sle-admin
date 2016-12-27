<!DOCTYPE html>
<html>
<head>
<title>New Product</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/labels.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() { 
		$('#menu').dcMegaMenu({rowItems: '3',event: 'hover',fullWidth: true});
		$('#barcodeCheck').blur(function(event) {
			event.preventDefault();
			var lenCheck=$('#barcodeCheck').val();
			if (lenCheck != 0) {
				var loadingText="<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...";
				$.ajax({
					type: 'POST',
					url: 'NewProductCheck.cfm',
					data : $('#barcodeCheck').serialize(),
					beforeSend:function(){
						$('#checkResult').html(loadingText).fadeIn();
					},
					success:function(data){
						$('#checkResult').html(data);
						$('#title').focus();
					},
					error:function(data){
						$('#checkResult').html(data);
					}
				});
			} else {
				$('#barcodeCheck').focus();
			}
		});
		$('#barcodeCheck').focus();
	});
</script>
</head>

<cfif StructKeyExists(URL,"clearcache")>
	<cfif StructKeyExists(session,"productcache")>
		<cfset ArrayClear(session.productcache)>
	</cfif>
	<cfset clearcachemsg="Cache Cleared">
</cfif>
<cfobject component="code/products" name="product">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset cats=product.LoadProductCats(parm)>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div id="barcode-search">
					<h1>Search Products</h1>
					<p>Scan product barcode here</p>
					<cfif StructKeyExists(URL,"clearcache")><p>#clearcachemsg#</p></cfif>
					<input type="text" name="barcodeCheck" id="barcodeCheck" value="" autocomplete="off">
				</div>
				<form id="NewProd" method="post">
					<div id="checkResult"></div>
				</form>
				<div id="PrintBtnWrap">
					<a href="NewProduct.cfm?clearcache=true" class="button" style="float:left;">Clear Cache</a>
					<a href="PriceLabels.cfm?cache=true" class="button" target="_blank">Print Labels</a>
				</div>
				<div class="clear"></div>
			</div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
	<cfif application.site.showdumps>
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</cfif>
	<script type="text/javascript">
		$(".type").chosen({width: "440px"});
	</script>
</body>
</cfoutput>
</html>