<!DOCTYPE html>
<html>
<head>
<title>Invoicing</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.tablednd.js"></script>
<script src="scripts/invoicing.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
		$('#btnView').click(function(event) {
			$('#type').val(1);
			$('#createPDF').val(0);
			$.ajax({
				type: 'POST',
				url: 'InvoicingList.cfm',
				data : $('#invForm').serialize(),
				beforeSend:function(){
					$('#InvoiceList').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Building preview...").fadeIn();
				},
				success:function(data){
					$('#InvoiceList').html(data);
				},
				error:function(data){
					$('#InvoiceList').html(data);
				}
			});
			event.preventDefault();
		});
		$('#btnSave').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'InvoicingSaveMsg.cfm',
				data : $('#invForm').serialize(),
				beforeSend:function(){
					$('#msg').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Saving Message...").fadeIn();
				},
				success:function(data){
					$('#msg').html(data);
				},
				error:function(data){
					$('#msg').html(data);
				}
			});
			event.preventDefault();			
		});
		$('#btnRun').click(function(event) {
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$('#orderOverlayForm-inner').load("invoiceConfirm.cfm");
			$('#orderOverlayForm').center();
			event.preventDefault();
		});
		$('.orderOverlayClose').click(function(event) {   
			$("#orderOverlay").fadeOut();
			$("#orderOverlay-ui").fadeOut();
			event.preventDefault();
		});
		$('#fixflag').click(function(event) {
			if (this.checked) {
				$("#onlycredits").prop("checked", false);
				$("#onlycredits").prop("disabled", true);
			} else {
				$("#onlycredits").prop("disabled", false);
			}
		});
		$('#onlycredits').click(function(event) {
			if (this.checked) {
				$("#fixflag").prop("checked", false);
				$("#fixflag").prop("disabled", true);
			} else {
				$("#fixflag").prop("disabled", false);
			}
		});
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
	});
</script>
<style>
	.missing {background-color:#FF0000; font-weight:bold}
</style>
</head>


<cfsetting requesttimeout="1200">
<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset clients=func.LoadClientList(parm)>
<cfset invData=func.LoadInvoiceData(parm)>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div id="orderOverlay-ui"></div>
				<div id="orderOverlay">
					<div id="orderOverlayForm" style="width:300px;">
						<a href="##" class="orderOverlayClose">X</a>
						<div id="orderOverlayForm-inner"></div>
					</div>
				</div>
				<form method="post" id="invForm">
					<input type="hidden" name="type" id="type" value="1" />
					<input type="hidden" name="createPDF" id="createPDF" value="0" />
					<div class="form-wrap no-print">
						<div class="form-header">
							Invoicing
							<span></span>
						</div>
						<div style="float:left">
						<table border="0">
							<tr>
								<td><b>Deliver invoices on</b></td>
								<td><input type="text" name="delDate" class="datepicker" value="#DateFormat(DateAdd('d',2,invData.InvDate),'yyyy-mm-dd')#"></td>
								<td><input type="checkbox" name="accOrder" value="1" id="accOrder"></td>
								<td><label for="accOrder"><b>Show in Account Order</b></label></td>
							</tr>
							<tr>
								<td rowspan="3"><b>Date invoices as</b></td>
								<td rowspan="3"><input type="text" name="invDate" class="datepicker" value="#DateFormat(invData.InvDate,'yyyy-mm-dd')#"></td>
								<td><input type="checkbox" name="fixflag" value="1" id="fixflag"></td>
								<td><label for="fixflag"><b>Update Invoices (Admin use Only)</b></label></td>
							</tr>
							<tr>
								<td><input type="checkbox" name="onlycredits" value="1" id="onlycredits"></td>
								<td><label for="onlycredits"><b>Only Show Credits</b></label></td>
							</tr>
							<tr>
								<td><input type="checkbox" name="advance" value="1" id="advance"></td>
								<td><label for="advance"><b>Advance Invoice Period (to the To Date)</b></label></td>
							</tr>
							<tr>
								<td><b>From</b></td>
								<td>
									<input type="text" name="fromDate" class="datepicker" value="#DateFormat(DateAdd('d',-invData.InvInterval,invData.InvDate),'yyyy-mm-dd')#">
								</td>
								<td><b>To</b></td>
								<td>
									<input type="text" name="toDate" class="datepicker" value="#DateFormat(invData.InvDate,'yyyy-mm-dd')#">
								</td>
							</tr>
							<tr>
								<td width="120"><b>Client</b></td>
								<td colspan="3">
									<select name="client" data-placeholder="Select... (Optional)" id="clientList" multiple="multiple">
										<option value=""></option>
										<cfloop array="#clients#" index="item">
											<option value="#item.ID#">#item.Ref# - #item.Name#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td valign="top"><strong>Invoice Message</strong><br>appears on all invoices in run</td>
								<td colspan="3">
									<textarea type="text" name="ctlInvMessage" rows="3" cols="60">#invData.ctlInvMessage#</textarea>
									<div id="msg">&nbsp;</div>
								</td>
							</tr>
							<tr>
								<td></td>
								<td colspan="3">
									<input type="button" id="btnSave" value="Save Settings" style="float:left;" />
									<input type="button" id="btnRun" value="Invoice" style="float:right;" />
									<input type="button" id="btnView" value="Preview" style="float:right;" />
								</td>
							</tr>
						</table>
						</div>
						<div style="float:right">
							<table width="400">
								<tr><td><strong>Notes</strong></td></tr>
								<tr><td>NOTE: Transactions posted on the invoicing date will not be included in statements</td></tr>
							</table>
						</div>
						<div class="clear"></div>
					</div>
					<div class="clear"></div>
					<div id="InvoiceList"></div>
					<div class="clear"></div>
				</form>
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
<script type="text/javascript">
	$("#clientList").chosen({width: "350px",enable_split_word_search:true,allow_single_deselect: true});
</script>
</html>

