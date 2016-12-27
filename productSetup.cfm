<!DOCTYPE html>
<html>
<head>
<title>Product Setup</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
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
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/jquery-barcode.js" type="text/javascript"></script>
<script src="scripts/productSetup.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() { 
		$('#menu').dcMegaMenu({rowItems: '3',event: 'hover',fullWidth: true});
		//LoadStockByDate();
		$('.stockitem').click(function(e) {
			var t=$(this).attr("data-type");
			var s=$(this).attr("data-supplier");
			$('.stockitem').removeClass("active");
			SuppSwitch(t,s);
			$(this).addClass("active");
			e.preventDefault();
		});
		$('.orderOverlayClose').click(function(event) {   
			$("#orderOverlay").fadeOut();
			$("#orderOverlay-ui").fadeOut();
			event.preventDefault();
		});
	});
</script>
</head>

<cfobject component="code/products" name="prod">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset supps=prod.LoadSuppiers(parm)>

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
				<a href="ProductStock2PriceList.cfm" style="float:right;" class="button" target="_blank">Price List</a>
				<h1>Product Setup</h1>
				<div id="stocknav">
					<ul>
						<cfif ArrayLen(supps)>
							<cfloop array="#supps#" index="i">
								<li><a href="##" class="stockitem" data-type="#i.type#" data-supplier="#i.id#">#i.name#</a></li>
							</cfloop>
						</cfif>
					</ul>
				</div>
				<div id="stockinput">
				</div>
				<div class="clear" style="padding:10px 0;"></div>
				<div id="resultlist"></div>
				<div id="print-area" style="padding:10px;width:700px;">
					<div id="LoadPrint" style="display:none;"></div>
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
</body>
</cfoutput>
</html>