<!DOCTYPE html>
<html>
<head>
<title>Manual Charging</title>
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
<script src="scripts/manualCharge.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() {
		$('.orderOverlayClose').click(function(event) {   
			$("#orderOverlay").fadeOut();
			$("#orderOverlay-ui").fadeOut();
			$('#barcode').val("");
			event.preventDefault();
		});
		$('#customClients').change(function(event) {
			LoadPubs();
		});
		$('#date').blur(function(event) {
			var clt=$('#customClients').val();
			if (clt != 0) {
				LoadList();
			};
		});
		$('#NewPub').click(function() {
			$.ajax({
				type: 'POST',
				url: 'NewPublication.cfm',
				data : $('#chargeForm').serialize(),
				beforeSend:function(){
					$("#orderOverlay").toggle();
					$("#orderOverlay-ui").toggle();
					$('#orderOverlayForm-inner').html("<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Retrieving information...</div>").fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
					LoadPubs();
				},
				error:function(data){
					$('#orderOverlayForm-inner').html(data).center();
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1), onClose: function() {
			LoadList();
		}});
	});
</script>
</head>


<cfsetting requesttimeout="300">
<cfobject component="code/ManualCharge" name="man">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset clients=man.LoadCustomOrders(parm)>

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
				<form method="post" id="chargeForm">
					<div class="form-wrap">
						<input type="hidden" name="manualCharge" value="1">
						<div class="form-header">
							Manual Charge&nbsp;|&nbsp;<a href="##" id="NewPub" class="button" style="float:none;font-size:12px;">New Publication</a>
							<div id="loading" style="float:right;margin:0 20px 0 0;"></div>
						</div>
						<div id="saveResults" style="display:none;"></div>
						<table border="0">
							<tr>
								<td width="100"><b>Delivery Date</b></td>
								<td width="400">
									<input type="text" name="date" id="date" class="datepicker" value="#LSDateFormat(Now(),'yyyy-mm-dd')#">
									SELECT DATE TO BE DELIVERED
								</td>
							</tr>
							<tr>
								<td width="80"><b>Client</b></td>
								<td width="200">
									<select name="orderID" data-placeholder="Select..." id="customClients">
										<option value=""></option>
										<cfloop array="#clients#" index="i">
											<option value="#i.ID#">#i.ClientName#</option>
										</cfloop>
									</select>
								</td>
							</tr>
						</table>
						<div id="pubForm"></div>
					</div>
					<div class="clear"></div>
					<div id="result"></div>
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
	<script type="text/javascript">
		$("##customClients").chosen({width: "100%",disable_search_threshold: 5});
	</script>
</body>
</cfoutput>
</html>
