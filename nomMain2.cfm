<!DOCTYPE html>
<html>
<head>
<title>Nominal Accounts</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/nominal.css" rel="stylesheet" type="text/css">
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
<script src="scripts/nominal.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
		AddRow();
		$('#NetAmount').blur(function() {
			GrossTotal();
		});
		$('#VATAmount').blur(function() {
			GrossTotal();
		});
		$('#EditID').blur(function() {
			var val=$(this).val();
			if (val != "") {
				GetData(val);
			}
		});
		$('.updateCheckTotal').blur(function() {
			CheckTotal();
		});
		$('#btnSave').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'nomMainSave.cfm',
				data : $('#nomForm').serialize(),
				success:function(data){
					$('#result').html(data);
					setTimeout(function() {
						$('#result span').fadeOut();
					}, 3000);
				}
			});
			event.preventDefault();
		});
		$('#btnReset').click(function(event) {
			Reset();
			event.preventDefault();
		});
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1),
			onClose: function() {
				WorkOutMonthInt($('#nomDateInt').val());
			}
		});
	});
</script>
</head>


<cfsetting requesttimeout="300">

<cfoutput>
<body>
	<div id="wrapper">
		<div class="no-print"><cfinclude template="sleHeader.cfm"></div>
		<div id="content">
			<div id="content-inner">
				<input type="button" id="btnReset" value="New Transaction" tabindex="99" style="float:right;" />
				<h1>Nominal Ledger</h1>
				<!---CALCULATE PERIOD FROM currMonth AND Financial Year Start Month
					=IF(B6>=$C$2,B6-$C$2+1,13+(B6-$C$2))
					IF currMonth >= FYM : PRD=currMonth-FYM+1 : PRD=13+currMonth-FYM --->
				<input type="text" id="nomDateInt" value="2014-02-01" class="datepicker">
				<div id="nomDateIntResult"></div>
				<div id="result"></div>
				<form method="post" id="nomForm">
					<input type="hidden" name="type" value="nom" id="Type">
					<input type="hidden" name="mode" value="1" id="Mode">
					<input type="hidden" name="row" value="0" id="Row">
					<table border="1" class="tableList" width="100%">
						<tr>
							<th width="100" align="left">ID</th>
							<td><input type="text" name="trnID" value="" id="EditID" tabindex="2"></td>
							<th width="100" align="left">Net Amount</th>
							<td><input type="text" name="trnAmnt1" value="" id="NetAmount" tabindex="5"></td>
						</tr>
						<tr>
							<th width="100" align="left">Date</th>
							<td><input type="text" name="trnDate" value="" id="trnDate" class="updateCheckTotal" tabindex="3"></td>
							<th width="100" align="left">VAT Amount</th>
							<td><input type="text" name="trnAmnt2" value="" id="VATAmount" tabindex="6"></td>
						</tr>
						<tr>
							<th width="100" align="left">Ref</th>
							<td><input type="text" name="trnRef" value="" tabindex="4" id="Ref" class="updateCheckTotal"></td>
							<th width="100" align="left">Gross Total</th>
							<td><input type="text" name="trnTotal" value="" id="GrossTotal" tabindex="7"></td>
						</tr>
						<tr>
							<th align="left">Description</th>
							<td colspan="2"><input type="text" name="trnDesc" value="" tabindex="4" size="60" id="desc" class="updateCheckTotal"></td>
							<td id="btnCell"><input type="button" id="btnSave" value="Save" tabindex="8" style="float:right;" disabled="disabled" /></td>
						</tr>
					</table>
					<div id="nomList"></div>
					<table width="500">
						<tr>
							<td width="10">&nbsp;</td>
							<td width="248">&nbsp;</td>
							<td width="100" id="drTotal" align="right" style="font-weight:bold;padding:4px;"></td>
							<td width="100" id="crTotal" align="right" style="font-weight:bold;padding:4px;"></td>
						</tr>	
						<tr>
							<td colspan="4" id="subTotal" align="right" style="font-weight:bold;padding:6px;font-size:14px;"></td>
						</tr>	
					</table>										
				</form>
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
</html>
