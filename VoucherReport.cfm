<!DOCTYPE html>
<html>
<head>
<title>Voucher Report</title>
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
<script type="text/javascript">
	$(document).ready(function() { 
		$('#menu').dcMegaMenu({rowItems: '3',event: 'hover',fullWidth: true});
		$('#goReport').click(function() {
			$.ajax({
				type: 'POST',
				url: 'LoadVouchers.cfm',
				data : $('#reportForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#report').html(data);
					$('#loading').fadeOut();
				},
				error:function(data){
					$('#report').html(data);
					$('#loading').fadeOut();
				}
			});
			event.preventDefault();
		});
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
		$('#preload').fadeOut(function(){
			$('.form-wrap').fadeIn();
		});
	});
</script>
</head>

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset pubs=func.GetPubs(parm)>
<cfset clients=func.LoadClientList(parm)>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div id="preload" style=" text-align:center;"><h1>Loading</h1><img src='images/loading_2.gif' class='loadingGif' style="float:none;"></div>
				<div class="form-wrap" style="display:none;">
					<form method="post" enctype="multipart/form-data" id="reportForm">
						<div class="form-header">
							Voucher Report
							<span>
								<input type="button" id="goReport" value="Go" style="float:right;" />
								<div id="loading" style="float: right;font-size: 12px;margin: 5px 10px 0 0;"></div>
							</span>
						</div>
						<table border="0" cellpadding="2" cellspacing="0">
							<!---<tr>
								<td width="150">From</td>
								<td><input type="text" name="from" class="datepicker" value="" placeholder="Optional..."></td>
							</tr>
							<tr>
								<td width="150">To</td>
								<td><input type="text" name="to" class="datepicker" value="" placeholder="Optional..."></td>
							</tr>--->
							<tr>
								<td width="150">Client</td>
								<td>
									<select name="client" data-placeholder="Select... (Optional)" id="clientList" multiple="multiple">
										<option value=""></option>
										<cfloop array="#clients#" index="item">
											<option value="#item.ID#">#item.Ref# - #item.Name#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td width="150">Publication</td>
								<td>
									<select name="pub" data-placeholder="Select... (Optional)" id="pubList" multiple="multiple">
										<option value=""></option>
										<cfloop array="#pubs.list#" index="item">
											<option value="#item.ID#">#item.Title#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td></td>
								<td><label><input type="checkbox" name="showCurrent" value="1">&nbsp;Show only current vouchers</label></td>
							</tr>
							<tr>
								<td></td>
								<td><label><input type="checkbox" name="showExp" value="1">
									&nbsp;Show only <span class="expiring">expiring</span>/<span class="expired">expired</span> vouchers</label></td>
							</tr>
						</table>
						<div class="clear"></div>
					</form>
				</div>
				<div id="report"></div>
				<div class="clear"></div>
			</div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
</body>
</cfoutput>
<script type="text/javascript">
	$("#clientList").chosen({width: "350px",enable_split_word_search:true,allow_single_deselect: true});
	$("#pubList").chosen({width: "350px",enable_split_word_search:false,allow_single_deselect: true});
</script>
</html>