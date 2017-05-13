<!DOCTYPE html>
<html>
<head>
<title>Publication Stock</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.11.3.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/pubstock.js" type="text/javascript"></script>
<script type="text/javascript" src="scripts/jquery-barcode.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
		var returned=false;
		$('#supList').change(function() {
			LoadPubs();
		});
		LoadPubs();
		$('#ReceivedPubList').change(function(event) {
			var id=$(this).val();
			ReceivedPubList(id);
			event.preventDefault();
		});
		$('#CreditedPubList').change(function(event) {
			CreditedPubList();
			event.preventDefault();
		});
		$('#ClaimPubList').change(function(event) {
			ClaimPubList();
			event.preventDefault();
		});
		$('#returned-btn').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'UpdateReturnedStock.cfm',
				data : $('#returnPubForm').serialize(),
				beforeSend:function(){
					$('#loading2').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#loading2').html(data);
					$('#loading2').html("<div class='saved'><img src='images/icons/tick.png' style='float:left;margin:3px 5px 0 0;width:20px;'>Saved</div>");
					$('#pub').html("");
					$('#issue').html("");
					$('#received').html("");
					$('#returnedQty').val("");
					setTimeout(function(){$("#loading2").fadeOut("slow");}, 1000 );
					$('#ReceivedPubList').val("");
					$("#ReceivedPubList").trigger("chosen:updated");
					$('#returned-btn').focus(function() {
						this.blur();
					});
					LoadReturns();
					//ReceivedPubList();
				},
				error:function(data){
					$('#loading2').html(data);
				}
			});
			event.preventDefault();
		});
		$('#credited-btn').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'UpdateReturnedStock.cfm',
				data : $('#creditForm').serialize(),
				beforeSend:function(){
					$('#loading3').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#loading3').html(data);
					LoadCredits();
					CreditedPubList();
				},
				error:function(data){
					$('#loading3').html(data);
				}
			});
			event.preventDefault();
		});
		$('#claim-btn').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'AddPubClaim.cfm',
				data : $('#claimForm').serialize(),
				beforeSend:function(){
					$('#loading4').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#loading4').html(data);
					LoadClaims();
					ClaimPubList();
				},
				error:function(data){
					$('#loading4').html(data);
				}
			});
			event.preventDefault();
		});
		$('#UpdateStock').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'UpdatePub.cfm',
				data : $('#stockForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#update').html(data);
					$('#loading').html("<div class='saved'><img src='images/icons/tick.png' style='float:left;margin:3px 5px 0 0;width:20px;'>Saved</div>");
					$('#pub').html("");
					setTimeout(function(){$("#loading").fadeOut("slow");}, 3000 );
					LoadReceived();
					$('#pubList').val("");
					$("#pubList").trigger("chosen:updated");
				},
				error:function(data){
					$('#loading').html(data);
				}
			});
			event.preventDefault();
		});
		$('#NewPub').click(function() {
			var loadingText="<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Retrieving information...</div>";
			var url='NewPublication.cfm';
			var data="";
			$("#orderOverlay").toggle();
			$("#orderOverlay-ui").toggle();
			$.ajax({
				type: 'POST',
				url: url,
				data : data,
				beforeSend:function(){
					$('#orderOverlayForm-inner').html(loadingText).fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
					
				},
				error:function(data){
					$('#orderOverlayForm-inner').html(data).center();
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
		$('.orderOverlayClose').click(function(event) {   
			$("#orderOverlay").fadeOut();
			$("#orderOverlay-ui").fadeOut();
			$('#barcode').val("");
			event.preventDefault();
		});
		$('#ReceivedTab').click(function() {LoadReceived();});
		$('#ReturnedTab').click(function() {LoadReturns();});
		$('#CreditedTab').click(function() {LoadCredits();});
		$('#ClaimTab').click(function() {LoadClaims();});
		LoadReceived();
		$('#preLoad').hide();
		$('#tabs').show();
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true,onClose: function() {
			var id=$(this).attr("id");
			if (id == "Date") {
				LoadReceived();
			} else if (id == "Date2") {
				LoadReturns();
			} else if (id == "Date3") {
				LoadCredits();
			} else if (id == "Date4") {
				LoadClaims();
			}
		}
		});
		$(document).keypress(function(e) {
			if ($('input[type="text"]').is(":focus")) {
			} else {
				StockScanner(e);
			}
		});
		$('#btnPrint').click(function(event) {
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: "pubStockPrintOptions.cfm",
				data: {"date":$('#Date2').val()},
				beforeSend:function(){
					$('#orderOverlayForm-inner').html("<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Loading...</div>").fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
					
				}
			});
			event.preventDefault();
		});
		$('#URN').blur(function(event) {
			var value=$(this).val();
			if (value != "") {
				$('#returnInput').show();
			} else {
				$('#returnInput').hide();
			}
		});
		$('#print-area').addClass("noPrint");
	});
</script>
<style type="text/css">
input[type="text"] {width: 70px;}
input[type="text"].small {width: 40px;}
#tabs {display:none;}
#preLoad {
 text-align:center;
 padding:10px 0;
}
/*#LoadPrint {position:fixed;left:-9999px;}*/
</style>
</head>


<cfobject component="code/functions" name="func">
<cfobject component="code/ManualCharge" name="man">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.AllowReturns=true>
<cfset pubs=func.LoadPublications(parm)>
<cfset clients=man.LoadCustomOrders(parm)>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<script type="text/javascript">
					$(function() {
						$("##tabs").tabs();
					});
				</script>
				<div id="orderOverlay-ui"></div>
					<div id="orderOverlay">
					<div id="orderOverlayForm">
						<a href="##" class="orderOverlayClose">X</a>
						<div id="orderOverlayForm-inner"></div>
					</div>
				</div>
				<div id="preLoad">
					<h1>Loading...</h1>
					<p>Building publication menus</p>
					<img src='images/loading_2.gif' class='loadingGif' style="float:none;">
				</div>
				<div id="dump"></div>
				<div id="tabs">
					<ul>
						<li><a href="##Received" id="ReceivedTab">Received</a></li>
						<li><a href="##Returned" id="ReturnedTab">Returned</a></li>
						<li><a href="##Credited" id="CreditedTab">Credited</a></li>
						<li><a href="##Claim" id="ClaimTab">Claim</a></li>
					</ul>
					<div id="Received">
						<div class="form-wrap">
							<form method="post" enctype="multipart/form-data" id="stockForm">
								<input type="hidden" name="psType" value="received">
								<input type="hidden" name="listOrder" id="listOrder" value="entry">
								<div class="form-header noPrint">
									Publications Received&nbsp;|&nbsp;
									<a href="##" id="NewPub" class="button" style="float:none;font-size:12px;color:##fff;">New Publication</a>
									<span><div id="loading" class="loading"></div></span>
								</div>
								
								<div id="Supp">
									<table border="0" cellpadding="2" cellspacing="0">
										<tr>
											<td width="120">Date</td>
											<td><input type="text" name="psDate" id="Date" class="datepicker" value="#DateFormat(Now(),'yyyy-mm-dd')#" style="width:120px;"></td>
										</tr>
										<tr>
											<td width="120">Supplier</td>
											<td>
												<select name="psSupID" data-placeholder="Select..." id="supList">
													<option value=""></option>
													<option value="WHS" selected="selected">Smiths</option>
													<option value="DASH">Dash</option>
												</select>
											</td>
										</tr>
									</table>
								</div>
								<div id="pubs"></div>
								<div id="pub"></div>
								<div class="form-bottom">
									<input type="button" name="btnUpdateStock" id="UpdateStock" value="Add" style="float:left;display:none;" />
									<div class="clear"></div>
								</div>
								<div class="clear"></div>
								<div id="update"></div>
							</form>
						</div>
						<div id="receivedlist"></div>
					</div>
					<div id="Returned">
						<div class="form-wrap">
							<form method="post" enctype="multipart/form-data" id="returnPubForm">
								<input type="hidden" name="GetType" value="received">
								<input type="hidden" name="psType" value="returned">
								<input type="hidden" name="listOrder" id="listOrder" value="entry">
								<input type="hidden" name="pubID" id="pubID" value="0">
								<div class="form-header noPrint">
									Publication Returned<a href="##" id="btnPrint" class="button" style="float:right;font-size:12px;color:##eee;">Print</a>
									<span><div id="loading2" class="loading"></div></span>
								</div>
								
								<div id="date">
									<table border="0" cellpadding="2" cellspacing="0">
										<tr>
											<td width="150">Return Date</td>
											<td><input type="text" name="psDate" id="Date2" class="datepicker" value="#LSDateFormat(Now(),'yyyy-mm-dd')#" style="width:120px;"></td>
											<td width="150" align="right">URN</td>
											<td><input type="text" name="URN" id="URN" value="" style="width:200px;" placeholder="Scan the return sheet barcode"></td>
										</tr>
									</table>
								</div>
								<div class="pub-list" id="returnInput" style="display:none;">
									<table border="1" class="tableList" width="100%">
										<tr>
											<th>Title</th>
											<th width="180">Issue</th>
											<th width="70">Received</th>
											<th width="50">Sold</th>
											<th width="60">Returned</th>
											<th width="160">Returned From</th>
										</tr>
										<tr>
											<td>
												<select name="psPubID" data-placeholder="Select..." id="ReceivedPubList">
													<option value=""></option>
													<cfloop array="#pubs.list#" index="item">
														<option value="#item.ID#" style="text-transform:capitalize;">#LCase(item.Title)#</option>
													</cfloop>
												</select>
												<div id="pubTitlePlaceholder"></div>
											</td>
											<td id="issue"></td>
											<td id="received" align="center"></td>
											<td id="Sold" align="center"></td>
											<td><input type="text" name="psQty" value="" size="3" id="returnedQty" style="display:none;text-align:center;"></td>
											<td>
												<select name="psOrderID" data-placeholder="Shop" id="customClients">
													<option value=""></option>
													<cfloop array="#clients#" index="i">
														<option value="#i.ID#">#i.ClientName#</option>
													</cfloop>
												</select>
											</td>
											<td width="40"><input type="button" name="btnAddReturned" value="+" id="returned-btn" style="display:none;"></td>
										</tr>
									</table>
								</div>
							</form>
						</div>
						<div id="returnedlist"></div>
					</div>
					<div id="Credited">
						<div class="form-wrap">
							<form method="post" enctype="multipart/form-data" id="creditForm">
								<input type="hidden" name="GetType" value="returned">
								<input type="hidden" name="psType" value="credited">
								<input type="hidden" name="listOrder" id="listOrder" value="entry">
								<div class="form-header noPrint">
									Publication Credited
									<span><div id="loading3" class="loading"></div></span>
								</div>
								
								<div id="date" class="noPrint">
									<table border="0" cellpadding="2" cellspacing="0">
										<tr>
											<td width="150">Credit Date</td>
											<td><input type="text" name="psDate" id="Date3" class="datepicker" value="#DateFormat(Now(),'yyyy-mm-dd')#" style="width:120px;"></td>
										</tr>
									</table>
								</div>
								<div class="pub-list noPrint">
									<table border="1" class="tableList">
										<tr>
											<th width="250">Title</th>
											<th width="270">Issue</th>
											<th width="180">Action</th>
											<th width="100">Returned</th>
											<th width="60">Quantity</th>
											<th width="75"></th>
										</tr>
										<tr>
											<td>
												<select name="psPubID" data-placeholder="Select..." id="CreditedPubList">
													<option value=""></option>
													<cfloop array="#pubs.list#" index="item">
														<option value="#item.ID#" style="text-transform:capitalize;">#LCase(item.Title)#</option>
													</cfloop>
												</select>
											</td>
											<td id="issue2"></td>
											<td>
												<select name="psAction" id="CreditAction">
													<option value="Credited">Credited</option>
													<option value="Returned too late">Returned too late</option>
													<option value="Exceeds supply">Exceeds supply</option>
												</select>
											</td>
											<td id="returnedqtys" align="center"></td>
											<td><input type="text" name="psQty" value="0" size="3" id="creditedQty" style="display:none;text-align:center;"></td>
											<td><input type="button" name="btnAddCredited" value="+" id="credited-btn" style="display:none;"></td>
										</tr>
									</table>
								</div>
							</form>
						</div>
						<div id="creditedlist"></div>
					</div>
					<div id="Claim">
						<div class="form-wrap">
							<form method="post" enctype="multipart/form-data" id="claimForm">
								<input type="hidden" name="GetType" value="received">
								<input type="hidden" name="psType" value="claim">
								<input type="hidden" name="listOrder" id="listOrder" value="entry">
								<div class="form-header noPrint">
									Publication Claim
									<span><div id="loading4" class="loading"></div></span>
								</div>
								
								<div id="date">
									<table border="0" cellpadding="2" cellspacing="0">
										<tr>
											<td width="150">Claim Date</td>
											<td><input type="text" name="psDate" id="Date4" class="datepicker" value="#DateFormat(Now(),'yyyy-mm-dd')#" style="width:120px;"></td>
										</tr>
									</table>
								</div>
								<div class="pub-list">
									<table border="1" class="tableList">
										<tr>
											<th width="250">Title</th>
											<th width="220">Issue</th>
											<th width="220">Claim Reference</th>
											<th width="60">Received</th>
											<th width="60">Qty</th>
											<th></th>
										</tr>
										<tr>
											<td>
												<select name="psPubID" data-placeholder="Select..." id="ClaimPubList">
													<option value=""></option>
													<cfloop array="#pubs.list#" index="item">
														<option value="#item.ID#" style="text-transform:capitalize;">#LCase(item.Title)#</option>
													</cfloop>
												</select>
											</td>
											<td id="issue4"></td>
											<td><input type="text" name="psRef" value="" id="claimRef" style="display:none;width:150px;"></td>
											<td id="receivedqtys"></td>
											<td><input type="text" name="psQty" value="0" size="3" id="claimQty" style="display:none;text-align:center;"></td>
											<td><input type="button" name="btnAddClaim" value="+" id="claim-btn" style="display:none;"></td>
										</tr>
									</table>
								</div>
							</form>
						</div>
						<div id="claimedlist"></div>
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
	<div id="print-area" style="padding:10px;width:700px;">
		<div id="LoadPrint" style="display:none;"></div>
	</div>
</body>
</cfoutput>
<script type="text/javascript">
	$("#typeList").chosen({width: "110px",disable_search_threshold: 10});
	$("#supList").chosen({width: "100px",disable_search_threshold: 10});
	$("#ReceivedPubList").chosen({width: "250px",enable_split_word_search:false});
	$("#CreditedPubList").chosen({width: "250px",enable_split_word_search:false});
	$("#ClaimPubList").chosen({width: "250px",enable_split_word_search:false});
	$("#customClients").chosen({width: "150px",disable_search_threshold: 5,allow_single_deselect:true});
	$("#CreditAction").chosen({width: "125px",disable_search_threshold: 10});
</script>
</html>

