<!DOCTYPE html>
<html>
<head>
<title>Price List</title>
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
<script src="scripts/productStock.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() {
		var delay = (function(){
			var timer = 0;
			return function(callback, ms){
			clearTimeout (timer);
			timer = setTimeout(callback, ms);
			};
		})();
		$('#print').click(function(e) {
			$('#print-list').printArea({extraHead:"<style type='text/css'>@media print {#LoadPrint {position:relative !important;left:0 !important;}}</style>"});
			e.preventDefault();
		});
		$('#printlabels').click(function(e) {
			PrintLabels("#listForm","#LoadPrint");
			e.preventDefault();
		});
		$('.selectall').click(function(e) {
			var cat=$(this).attr("data-ID");
			if(this.checked) {
				$('.selectprod'+cat).prop({checked: true});
			} else {
				$('.selectprod'+cat).prop({checked: false});
			};
		});
		$('.titleChange').dblclick(function(e) {
			var id=$(this).attr("data-ID");
			$('.prodTitle'+id).show();
			$('.prodTitle'+id).focus();
			$(this).hide();
		});
		$('.priceChange').dblclick(function(e) {
			var id=$(this).attr("data-ID");
			$('.prodPrice'+id).show();
			$('.prodPrice'+id).focus();
			$(this).hide();
		});
		$('.titleChangeField').blur(function(e) {
			var id=$(this).attr("data-ID");
			var text=$(this).val();
			$(this).hide();
			$('span.titleChange'+id).show();
			$('span.titleChange'+id).html(text);
			$.ajax({
				type: 'POST',
				url: 'code/products.cfc',
				data: {
					"method": "SaveTitle",
					<cfoutput>"datasource":"#application.site.datasource1#",</cfoutput>
					"id": id,
					"title": text
				},
				dataType: "json",
				success:function(code){
					//
				}
			});
		});
		$('.priceChangeField').blur(function(e) {
			var id=$(this).attr("data-ID");
			var price=$(this).val();
			$(this).hide();
			$('span.priceChange'+id).show();
			$('span.priceChange'+id).html("£"+Number(price).toFixed(2));
			$.ajax({
				type: 'POST',
				url: 'code/products.cfc',
				data: {
					"method": "SavePrice",
					<cfoutput>"datasource":"#application.site.datasource1#",</cfoutput>
					"id": id,
					"price": price
				},
				dataType: "json",
				success:function(code){
					//
				}
			});
		});
	});
</script>
</head>

<cfobject component="code/products" name="prod">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset list=prod.LoadPriceList(parm)>
<cfoutput>
<body>
	<div id="controls" style="background: ##EEE;padding: 10px;border-bottom: 1px solid ##CCC;position: fixed;top: 0;left: 0;right: 0;z-index: 9999;">
		<a href="##" id="print" class="button" style="float:left;font-size:13px;">Print</a>
		<a href="##" id="printlabels" class="button" style="float:left;font-size:13px;">Print Labels</a>		
		<div style="float:left;" id="loading" class="loading"></div>
		<div class="clear"></div>
	</div>
	<div id="right-nav" style="position: fixed;top: 52px;right: 0;z-index: 9999;width:200px;height: 400px;overflow-y: scroll;border: 1px solid ##CCC;padding: 10px;background: ##fff;">
		<ul style="list-style: none;margin: 0;padding: 0;">
			<cfloop array="#list.ordered#" index="i">
				<cfset cat=StructFind(list.cats,i)>
				<li><a href="##header#cat.ID#" style="font-size: 12px;text-decoration: none;">#cat.Title#</a></li>
			</cfloop>
		</ul>
	</div>
	<div id="print-list" style=" font-family:Arial, Helvetica, sans-serif;font-size:11px;padding:10px;width:860px;margin: 40px 0 0 0;">
		<form method="post" id="listForm">
			<cfloop array="#list.ordered#" index="i">
				<cfset cat=StructFind(list.cats,i)>
				<h1 id="header#cat.ID#">#cat.Title#</h1>
				<table border="1" class="tableList" width="100%" style="font-size:14px;">
					<tr>
						<th width="10"><input type="checkbox" class="selectall" data-ID="#cat.ID#" value="1"></th>
						<th align="left" width="400">Product</th>
						<th width="80">PM</th>
						<th width="80">Size</th>
						<th width="60">Price</th>
						<th width="">Deals</th>
					</tr>
					<cfloop array="#cat.items#" index="p">
						<tr>
							<td style="padding:6px 0;" align="center"><input type="checkbox" name="selectitem" class="selectprod#cat.ID#" value="#p.ID#"></td>
							<td><span class="titleChange titleChange#p.ID#" data-ID="#p.ID#">#p.Title#</span><input type="text" class="titleChangeField prodTitle#p.ID#" value="#p.Title#" data-ID="#p.ID#" style="display:none;width:380px;"></td>
							<td align="center">#YesNoFormat(p.PM)#</td>
							<td align="center">#p.UnitSize#</td>
							<td align="right"><span class="priceChange priceChange#p.ID#" data-ID="#p.ID#">&pound;#DecimalFormat(p.Price)#</span><input type="text" class="priceChangeField prodPrice#p.ID#" value="#p.Price#" data-ID="#p.ID#" style="display:none;width:50px;text-align:right;"></td>
							<td>
								<cfset dCount=0>
								<cfloop array="#p.Deals#" index="d">
									<cfset dCount=dCount+1>
									#d.Title#<cfif dCount neq ArrayLen(p.Deals)>,</cfif>
								</cfloop>
							</td>
						</tr>
					</cfloop>
				</table>
			</cfloop>
		</form>
	</div>
	<div id="print-area" style="padding:10px;width:700px;">
		<div id="LoadPrint"></div>
	</div>
	<div style="clear:both;"></div>
</body>
</cfoutput>
</html>