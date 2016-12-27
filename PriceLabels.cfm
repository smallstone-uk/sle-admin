<cftry>
<cfparam name="form.type" default="">
<cfparam name="form.style" default="normal">
<cfobject component="code/products" name="product">
<cfobject component="code/labels" name="labels">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.type=form.type>
<cfset parm.style=form.style>
<cfif StructKeyExists(URL,"cache") AND StructKeyExists(session,"productcache")>
	<cfset labs=labels.LoadPriceLabelsFromCache(parm)>
<cfelse>
	<cfset labs=labels.LoadPriceLabels(parm)>
</cfif>
<cfset cats=product.LoadProductCats(parm)>

<!DOCTYPE html>
<html>
<head>
<title>Price Labels</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<cfif parm.style is "normal">
	<link href="css/labels.css" rel="stylesheet" type="text/css">
<cfelseif parm.style is "small">
	<link href="css/labels-small.css" rel="stylesheet" type="text/css">
<cfelse>
	<link href="css/labels.css" rel="stylesheet" type="text/css">
</cfif>
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/jquery.print.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script type="text/javascript" src="scripts/jquery-barcode.js"></script>
<script type="text/javascript">
	$(document).ready(function() { 
		$('#menu').dcMegaMenu({rowItems: '3',event: 'hover',fullWidth: true});
		$('.labelbox').click(function () {
			var id=$(this).val();
			if($(this).prop('checked')) {
				$('#label'+id).removeClass("no-print");
			} else {
				$('#label'+id).addClass("no-print");
			}		
		});
		$('#SelectAll').click(function () {
			var id=$(this).val();
			if($(this).prop('checked')) {
				$('.labelbox').prop('checked', true);
				$('.label').removeClass("no-print");
			} else {
				$('.labelbox').prop('checked', false);
				$('.label').addClass("no-print");
			}		
		});
		$('.print').click(function (event) {
			event.preventDefault();
			$('.printable').print();
		});
		$('#barcodeCheck').focus();
	});
</script>
</head>


<cfoutput>
<body>
	<div class="searchbar noPrint">
		<form method="post">
			<cfif NOT StructKeyExists(URL,"cache")>
				<select name="type" class="type">
					<cfloop array="#cats#" index="i">
						<option value="#i.ID#"<cfif form.type eq i.ID> selected="selected"</cfif>>#i.Title#</option>
					</cfloop>
				</select>
			</cfif>
			<select name="style" class="style">
				<option value="normal"<cfif form.style eq "normal"> selected="selected"</cfif>>Normal</option>
				<option value="small"<cfif form.style eq "small"> selected="selected"</cfif>>Small</option>
			</select>
			<input type="submit" name="btnSubmit" value="Find" style="float:right;">
		</form>
		<!---<a href="##" class="print button">Print</a>--->
		<div style="clear:both;"></div>
	</div>
<label for="SelectAll" class="selectAll noPrint"><input type="checkbox" id="SelectAll" value="1" checked="checked">&nbsp;Select All</label>
<div style="clear:both;"></div>
<div class="label-wrap printable">
	<cfif ArrayLen(labs.list)>
		<cfset count=0>
		<cfloop array="#labs.list#" index="i">
			<cfset count=count+1>
			<div class="label" id="label#i.ID#">
				<div id="barcodeTarget#i.ID#" class="barcode"><span style="float: left;font-size:12px;margin: -12px 0 0 -20px;">#i.Barcode#</span></div>
				<label for="box#i.ID#"></label>
				<div class="tick noPrint">
					<input type="checkbox" class="labelbox" id="box#i.ID#" value="#i.ID#" checked="checked">
				</div>
				<div class="price">#i.price#</div>
				<div class="title">#i.title#</div>
				<div class="info">#i.UnitSize#</div>
			</div>
			<cfif count eq 14>
				<cfset count=0>
				<!---<div style="page-break-after:always;clear:both;"></div>--->
			</cfif>
			<script type="text/javascript">
				$("##barcodeTarget#i.ID#").barcode('#i.Barcode#', '#i.BarcodeType#');
			</script>
		</cfloop>
	<cfelse>
		No Products Found
	</cfif>
	<div style="clear:both;"></div>
</div>
<script type="text/javascript">
$(".type").chosen({width: "50%"});
$(".style").chosen({width: "25%",disable_search_threshold: 10});
</script>
</body>
</cfoutput>
</html>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>