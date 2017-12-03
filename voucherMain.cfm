<!DOCTYPE html>
<html>
<head>
<title>Voucher Input</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/voucher.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() {
		$(document).keypress(function(e) {
			if ($('input[type="text"]').is(":focus")) {
			} else {
				if ($('#vchSupp').val() == "WHS") {
					if ($('#ref').val() != "") {
						scanner(e);
					} else {
						$('#loading').html("Please enter an Envelope Reference");
					}
				} else {
					scanner(e);
				}
			}
		});
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true,onClose: function() {
			$('#ref').val("");
			LoadVouchers();
		}});
		$('.blurChange').blur(function() {
			LoadVouchers();
		});
		$('#vchSupp').change(function() {
			$('#ref').val("");
			LoadVouchers();
		});
		$("#qty").keydown(function (e) {
			// Allow: backspace, delete, tab, escape, enter and .
			if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) !== -1 ||
				// Allow: Ctrl+A
				(e.keyCode == 65 && e.ctrlKey === true) || 
				// Allow: home, end, left, right
				(e.keyCode >= 35 && e.keyCode <= 39)) {
				// let it happen, don't do anything
				return;
			}
			// Ensure that it is a number and stop the keypress
			if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
				e.preventDefault();
			}
		});
		$('#btnPrint').click(function(event) {
			PrintVouchers();
			event.preventDefault();
		});
		$('.orderOverlayClose').click(function(event) {
			$("#orderOverlay").fadeOut();
			$("#orderOverlay-ui").fadeOut();
			$('#barcode').val("");
			event.preventDefault();
		});
		LoadVouchers();
		$('#btnDelete').click(function(event){
			$.ajax({
				type: 'POST',
				url: 'voucherDelete.cfm',
				data : $('#listForm').serialize(),
				success:function(data){
					LoadVouchers();
				}
			});
			event.preventDefault();
		});
		$('#btnStatus').click(function(event){
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: 'voucherUpdate.cfm',
				data: $('#listForm').serialize(),
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
	});
</script>
<style type="text/css">
	#LoadPrint {position:fixed;left:-9999px;}
	#LoadResult {float:left;width:790px;}
	#LoadResultNav {float: left;width: 200px;margin: 0 0 0 10px;}
	.red {color:#ff0000; font-weight:bold; }
</style>
</head>

<cfoutput>
<body>
	<div id="wrapper">
		<div class="no-print"><cfinclude template="sleHeader.cfm"></div>
		<div id="content">
			<div id="content-inner">
				<div id="orderOverlay-ui"></div>
					<div id="orderOverlay">
					<div id="orderOverlayForm">
						<a href="##" class="orderOverlayClose">X</a>
						<div id="orderOverlayForm-inner"></div>
					</div>
				</div>
				<div class="form-wrap no-print">
					<form method="post" id="vchForm">
						<div class="form-header">
							Voucher Input
							<span><div id="loading" class="loading"></div></span>
						</div>
						<div style="float:right;width:350px;padding:5px 10px;line-height:20px;">
							Scan the voucher's barcode once you have entered the <b>Date</b> 
							and <b>Reference</b> and selected the relevant supplier.<br>You can use the <b>Quantity</b> field to add muliply vouchers in one scan.<br>
							Once finished, press print.<br>
						</div>
						<input type="hidden" name="barcode" id="barcode" value="" autocomplete="off">
						<table border="0">
							<tr>
								<td width="140"><b>Supplier</b></td>
								<td>
									<select name="SuppID" id="vchSupp">
										<option value="WHS" selected="selected">WHS</option>
										<option value="DASH">DASH</option>
									</select>
								</td>
							</tr>
							<tr>
								<td><b>Return Date</b></td>
								<td><input type="text" id="date" name="date" class="datepicker" value="#DateFormat(Now(),'yyyy-mm-dd')#"></td>
							</tr>
							<tr>
								<td><b>Envelope Reference</b><br><i style="font-size:11px;color:##999;">WHS only</i></td>
								<td><input type="text" id="ref" name="ref" value="" class="blurChange" placeholder="eg. C408769"></td>
							</tr>
							<tr>
								<td><b>Quantity</b></td>
								<td><input type="number" min="1" max="500" size="6" name="qty" id="qty" value="1" placeholder=""></td>
							</tr>
						</table>
					</form>
				</div>
				<span class="red">ENSURE VOUCHER ENVELOPE IS PUT OUT FOR COLLECTION ON SUNDAY IN A SEALED TOTE BOX.</span>
				<div class="clear"></div>
				<div id="print-area" style="padding:10px;width:700px;">
					<div id="LoadPrint" style="display:none;"></div>
				</div>
				<div class="clear"></div>
				<div id="LoadResult"></div>
				<div id="LoadResultNav" class="rightnav">
					<ul>
						<li><a href="##" id="btnPrint">Print</a></li>
					</ul>
					<ul id="tickRequired" style="display:none;">
						<li><a href="##" id="btnDelete">Delete Vouchers</a></li>
						<li><a href="##" id="btnStatus">Update Status</a></li>
					</ul>
				</div>
				<div class="clear"></div>
			</div>
		</div>
		<div class="no-print"><cfinclude template="sleFooter.cfm"></div>
	</div>
	<cfif application.site.showdumps>
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</cfif>
</body>
</cfoutput>
<script type="text/javascript">
	$("#vchSupp").chosen({width: "100%",disable_search_threshold: 10});
	$("#pubList").chosen({width: "350px",enable_split_word_search:false,allow_single_deselect: true});
</script>
</html>
