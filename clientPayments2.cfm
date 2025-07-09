<!DOCTYPE html>
<html>
<head>
	<title>Customer Payments</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="common/scripts/common.js"></script>
	<!---<script src="scripts/jquery-1.9.1.js"></script>--->
	<script src="js/jquery-1.11.1.min.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
	<script src="scripts/jquery.hoverIntent.minified.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script src="scripts/autoCenter.js" type="text/javascript"></script>
	<script src="scripts/popup.js" type="text/javascript"></script>
	<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
	<script src="scripts/jquery.tablednd.js"></script>
	<script src="scripts/main.js"></script>
	<script src="scripts/checkDates.js" type="text/javascript"></script>
	<!---<script src="scripts/clientPayment.js" type="text/javascript"></script>--->
	<script type="text/javascript">
		function LoadData() {
			$('#searchMsg').fadeOut();
			$('#loadingDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading details...").fadeIn();
			$.ajax({
				type: 'POST',
				url: 'clientLoad.cfm',
				data: $("#srchForm").serialize(),
				success:function(result){
					$('#clientResult').html(result);
					$('#addPaymentButton').show();	/* show Add Payment button */
					$('#viewStatementButton').show();	/* show Statement button */
				}
			});
			$.ajax({
				type: 'POST',
				url: 'clientLoadTrans.cfm',
				data: $("#srchForm").serialize(),
				success:function(result){
					$('#tranResult').html(result);
					$('#clientID').val($('#cltID').val());	// pop client ID into payment form
					$('#clientID2').val($('#cltID').val());	// pop client ID into credit form
					$('#clientRef1').val($('#cltRef').val());	// pop client ref into payment form
					$('#clientRef2').val($('#cltRef').val());	// pop client ref into credit form
					$('#loadingDiv').html("").fadeOut();
				}
			});
			$.getScript('scripts/clientPayment.js', function() {});
 		}
	</script>
	<style type="text/css">
		#payPanel {
			display: none;
			background-color: #eee;
			border: 1px solid #ccc;
			width:760px;
			margin:4px;
		}
		#addPaymentButton {display:none;}
		#viewStatementButton {display:none;}
		#clientPanel {width:760px; margin:4px;}
		#tranResult {margin:4px;padding:4px;}
		#payPanel {margin:4px;}
		#feedback {border:solid 1px #999999; height:20px; width:450px; float:left;}
		#feedback2 {border:solid 1px #999999; height:20px; width:450px; float:left;}
	</style>
</head>
<cfparam name="rec" default="">
<cfif rec neq "">
	<script>
		$(document).ready(function() {
			LoadData();
		});
	</script>
</cfif>

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
				<div class="form-wrap">
					<div class="form-header">Customer Payments</div>
					<div class="form-bar">
						<a href="" id="cltDetailsLink" style="float:right; display:none;" class="button" target="_blank">Client Details</a>
						<div id="loadingDiv">loadingDiv</div>
						<form name="srchForm" id="srchForm" method="post">
							<table border="0" class="tableList">
								<tr>
									<td width="160">Customer Reference</td>
									<td>
										<input type="text" name="clientRef" id="clientRef" class="inputfield" size="6" maxlength="4" value="#rec#" onBlur="LoadData()" />
									</td>
									<td>
										<input type="checkbox" name="allTrans" id="allTrans" value="1" onClick="LoadData()" /> &nbsp; All transactions from: 
									</td>
									<td>
										<input type="text" name="srchDateFrom" id="srchDateFrom" class="datepicker" size="15" value="" onChange="LoadData()" />&nbsp; To: 
									</td>
									<td>
										<input type="text" name="srchDateTo" id="srchDateTo" class="datepicker" size="15" value="" onChange="LoadData()" />
									</td>
									<td><button type="button" id="addPaymentButton">Add Payment</button></td>
									<td><button type="button" id="viewStatementButton">View Statement</button></td>
									<td><button type="button" id="viewAllocButton">View Allocation</button></td>
								</tr>
							</table>
						</form>
						<div id="searchMsg" style="display:block;">Enter a customer reference number.</div>
					</div> 
					<div id="clientResult" class="module"></div>
					<div id="payPanel"><cfinclude template="clientPaymentPanel.cfm"><div class="clear"></div></div>
					<div id="payResult" class="module"></div>
					<div id="tranResult" class="module"></div>
					<!---<div id="lettersload" class="module">lettersload</div>--->
				</div>
				<div class="clear"></div>
				<!---<div id="feedback">feedback</div>--->
			</div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
</body>
</cfoutput>
</html>
