<!DOCTYPE html>
<html>
<head>
<title>Product Stock</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/tabs.css" rel="stylesheet" type="text/css">
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
		function LoadCache() {
			$.ajax({
				type: 'POST',
				url: 'ProductStockLoadCache.cfm',
				data : $('#stockForm').serialize(),
				success:function(data){
					$('#cacheList').html(data);
				}
			});
		};
		$('#barcodeCheck').blur(function(event) {
			event.preventDefault();
			var lenCheck=$('#barcodeCheck').val();
			if (lenCheck != 0) {
				var loadingText="<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...";
				$.ajax({
					type: 'POST',
					url: 'ProductStockCheck.cfm',
					data : $('#stockForm').serialize(),
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
		LoadCache();
	});
</script>
<style type="text/css">
	html {overflow:hidden !important;}
</style>
</head>

<cfobject component="code/products" name="product">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div id="orderOverlay-ui"></div>
				<div id="orderOverlay">
					<div id="orderOverlayForm">
						<a href="##" class="orderOverlayClose">X</a>
						<div id="orderOverlayForm-inner"></div>
					</div>
				</div>
				<script type="text/javascript">
					$(function() {
						$("##tabs").tabs();
					});
				</script>
				<div id="tabs" style="margin:0;">
					<ul>
						<li><a href="##Received" id="ReceivedTab">Received</a></li>
						<li><a href="##Returned" id="ReturnedTab">Returned</a></li>
					</ul>
					<div id="Received">
						<div class="form-wrap">
							<form method="post" enctype="multipart/form-data" id="stockForm">
								<div class="form-header">
									Stock Received
									<a href="PriceLabels.cfm?cache=true" target="_blank" class="button" style="margin:1px 0 0 0;">Print Labels</a>
									<span><div id="loading"></div></span>
								</div>
								<table border="0" cellpadding="2" cellspacing="0">
									<tr>
										<td width="150">Date</td>
										<td><input type="text" name="pskDate" id="Date" value="#DateFormat(Now(),'DD/MM/YYYY')#"></td>
									</tr>
									<tr>
										<td width="150">Barcode</td>
										<td><input type="text" name="barcodeCheck" id="barcodeCheck" value="" autocomplete="off"></td>
									</tr>
								</table>
								<div id="checkResult"></div>
							</form>
							<div id="cacheList" style="margin:20px 0 0 0;clear:both;height: 150px;overflow-y: scroll;"></div>
						</div>
					</div>
					<div id="Returned">
					</div>
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
		$("select").chosen({width: "100%"});
	</script>
</body>
</cfoutput>
</html>