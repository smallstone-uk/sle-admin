<!DOCTYPE html>
<html>
<head>
<title>Banking Sheet</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/jquery.tablednd.js"></script>

<script type="text/javascript">
	$(document).ready(function() {
		function PrintArea() {
			$('#print-area').printArea({extraHead:"<style type='text/css'>@media print {#LoadPrint {position:relative !important;left:0 !important;}}</style>"});
		};
		function LoadBankingList() {
			$.ajax({
				type: 'POST',
				url: 'paymentBankSheetList.cfm',
				data : $('#bankingSheetForm').serialize(),
				success:function(data){
					$('#BankingList').html(data);
				}
			});
		}
		$('#btnBank').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'paymentBankSheetAction.cfm',
				data : $('#bankingSheetForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Processing...").fadeIn();
				},
				success:function(data){
					$('#loading').fadeOut();
					$('#LoadPrint').html(data).fadeIn(function() {
						LoadBankingList();							   	
						PrintArea();
					});
				}
			});
			event.preventDefault();
		});
		$('#printBanking').click(function() {
			$('#list-area').printArea();
			event.preventDefault();
		});
		$('#today').click(function() {
			$('#date').prop("disabled",true);
			LoadBankingList();
			event.preventDefault();
		});
		$('#showDate').click(function() {
			if (this.checked) {
				$('#date').prop("disabled",false);
				$('#datewrap').fadeIn();
				$('#date').focus();
			} else {
				$('#date').prop("disabled",true);
				$('#datewrap').fadeOut();
			}
		});
		$('.datepicker').datepicker({
			dateFormat: "yy-mm-dd",
			changeMonth: true,
			changeYear: true,
			showButtonPanel: true,
			showOn:"focus",
			onClose: function() {
				LoadBankingList();
				$('#showDate').prop("checked",false);
			}
		});
		LoadBankingList();
	});
</script>
<style type="text/css">
	#LoadPrint {position:fixed;left:-9999px;}
	#ui-datepicker-div {
		top: 40px !important;
		left: 205px !important;
	}
</style>
</head>

<cfoutput>
<body>
	<form method="post" id="bankingSheetForm">
		<div id="controls" style="background: ##EEE;padding: 10px;border-bottom: 1px solid ##CCC;">
			<input type="button" id="btnBank" value="Bank" style="float:left;">
			<a href="##" id="printBanking" class="button" style="float:left;font-size:13px;">Print All</a>
			<a href="##" id="today" class="button" style="float:left;font-size:13px;">Unbanked</a>
			<div style="float:left;margin:0 0 0 20px;font-size:12px;">
				<label><input type="checkbox" id="showDate" value="1">&nbsp;Find previously banked items</label><br>
				<div id="datewrap" style="display:none;"><input type="text" name="date" id="date" class="datepicker" value="#LSDateFormat(Now(),'yymmdd')#" disabled="disabled" style="position:fixed;left:-9999px;"></div>
			</div>
			<div style="float:left;" id="loading" class="loading"></div>
			<div class="clear"></div>
		</div>
		<div id="print-area" style="padding:10px;width:700px;">
			<div id="LoadPrint" style="display:none;"></div>
		</div>
		<div id="list-area" style="padding:10px;width:700px;">
			<div id="BankingList"></div>
		</div>
	</form>
</body>
</cfoutput>
</html>

