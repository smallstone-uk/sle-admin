<!DOCTYPE html>
<html>
<head>
<title>Publication Report</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/report.css" rel="stylesheet" type="text/css">
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
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() { 
		$('#menu').dcMegaMenu({rowItems: '3',event: 'hover',fullWidth: true});
		function BuildReport() {
			$.ajax({
				type: 'POST',
				url: 'GetPubStockReport.cfm',
				data : $('#reportForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					$('#printReport').prop("disabled",true);
				},
				success:function(data){
					$('#report').html(data);
					$('#loading').fadeOut();
					$('#printReport').prop("disabled",false);
				},
				error:function(data){
					$('#report').html(data);
					$('#loading').fadeOut();
				}
			});
		};
		$('#goReport').click(function() {
			BuildReport();
			event.preventDefault();
		});
		$('#printReport').click(function() {
			PrintArea();
			event.preventDefault();
		});
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true,onClose: function() {
				BuildReport();
			}
		});
		BuildReport();
		function PrintArea() {
			$('#print-area').printArea();
		};
	});
</script>
</head>

<cfobject component="code/functions" name="func">
<cfobject component="code/publications" name="pub">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset pubs=func.GetPubs(parm)>
<cfset urns=pub.GetURNs(parm)>
<cfoutput>
<body>
	<div id="wrapper">
		<div class="no-print"><cfinclude template="sleHeader.cfm"></div>
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap no-print">
					<form method="post" enctype="multipart/form-data" id="reportForm">
						<div class="form-header">
							Publication Reports
							<span>
								<input type="button" id="printReport" value="Print" style="float:right;" disabled="disabled" />
								<input type="button" id="goReport" value="Preview" style="float:right;" />
								<div id="loading" class="loading" style="float:right;margin:0 10px 0 0;"></div>
							</span>
						</div>
						<table border="0" cellpadding="2" cellspacing="0">
							<tr>
								<td width="150">From</td>
								<td><input type="text" name="from" class="datepicker" value="#DateFormat(DateAdd('d',-7,Now()),'yyyy-mm-dd')#"></td>
							</tr>
							<tr>
								<td width="150">To</td>
								<td><input type="text" name="to" class="datepicker" value="#DateFormat(Now(),'yyyy-mm-dd')#"></td>
							</tr>
							<tr>
								<td width="150">Publication</td>
								<td>
									<select name="pub" data-placeholder="Select..." id="pubList" multiple="multiple">
										<option value=""></option>
										<cfloop array="#pubs.list#" index="item">
											<option value="#item.ID#">#item.Title#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td width="150">Issue</td>
								<td><input type="text" name="issue" value=""></td>
							</tr>
							<tr>
								<td width="150">URN</td>
								<td>
									<select name="urn" data-placeholder="Select..." id="urnList">
										<option value=""></option>
										<cfloop query="urns.qurns">
											<option value="#psURN#">#DateFormat(psDate,'ddd dd-mmm')# - #psURN# - #total#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td width="150">Report Type</td>
								<td>
									<select name="type" id="typeList">
										<option value="missing credit">Missing Credits</option>
										<option value="movement">Stock Movement</option>
										<option value="claim">Claims</option>
										<option value="newMissing">New Missing Credits</option>
									</select>
								</td>
							</tr>
							<tr>
								<td width="150">Movement Type</td>
								<td>
									<select name="moveType" data-placeholder="Select..." id="moveType" multiple="multiple">
										<option value="received">Received</option>
										<option value="returned">Returned</option>
										<option value="credited">Credited</option>
										<option value="claim">Claimed</option>
										<option value="charge">Charge</option>
									</select>
								</td>
							</tr>
							<tr>
								<td width="150">Customer</td>
								<td>
									<select name="customer" id="custList">
										<option value="0" selected="selected">Shop</option>
										<option value="6291">Treliske</option>
									</select>
								</td>
							</tr>
						</table>
						(reports exclude supplements)
						<div class="clear"></div>
					</form>
				</div>
				<div id="print-area"><div id="report"></div></div>
				<div class="clear"></div>
			</div>
		</div>
		<div class="no-print"><cfinclude template="sleFooter.cfm"></div>
	</div>
</body>
</cfoutput>
<script type="text/javascript">
	$("#pubList").chosen({width: "350px",enable_split_word_search:false,allow_single_deselect: true});
	$("#moveType").chosen({width: "350px",enable_split_word_search:false,allow_single_deselect: true});
	$("#typeList").chosen({width: "350px",disable_search_threshold:10});
	$("#custList").chosen({width: "350px",disable_search_threshold:10});
</script>
</html>