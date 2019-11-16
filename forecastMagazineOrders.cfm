<!DOCTYPE html>
<html>
<head>
<title>Magazine Order Forecasting</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/main4.css" rel="stylesheet" type="text/css">
<!---<link href="css/rounds2.css" rel="stylesheet" type="text/css">--->
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
	$(document).ready(function(e) {
		PrintArea = function() {
		//	$('#print-area').printArea();
		window.print();
		}
		
		$('#printBanking').click(function(event) {
			PrintArea();
			event.preventDefault();
		});
		
		$('.showClients').click(function(event) {
			var id = $(this).data("id");
			$.ajax({
				type: "POST",
				url: "ajax/AJAX_loadCustomersForPub.cfm",
				data: { "id": id },
				success: function(data) {
					$.popup(data);
				}
			});
			event.preventDefault();
		});
	});
</script>
<style type="text/css">
	body {background-color:#FFFFFF;}
	.tableList td {padding:5px 2px 5px 2px;}
	@media print {
		.noPrint {display:none;}
		a:hover, a:visited, a:link, a:active {text-decoration: none;}
	}
</style>
</head>

<cfsetting requesttimeout="300">
<cfobject component="code/forecasting" name="cast">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset forecast=cast.MagazineOrders(parm)>
<!---<cfdump var="#forecast#" label="forecast" expand="true">--->
<cftry>
<cfoutput>
<body>
	<div id="total"></div>
	<div id="controls" class="noPrint" style="background: ##EEE;padding: 10px;border-bottom: 1px solid ##CCC;">
		<a href="##" id="printBanking" class="button" style="float:left;font-size:13px;">Print</a>
		<div style="float:left;" id="loading" class="loading"></div>
		<div class="clear"></div>
	</div>
	<div id="print-area" style="font-family:Arial, Helvetica, sans-serif;font-size:13px;padding:10px;width:860px;background: ##fff;">
		<span style="float: right;margin: 0 30px 0 0;line-height: 23px;font-weight: bold; font-size:14px;">Printed: #LSDateFormat(Now(),"DD MMM YY")#</span>
		<h1 style="margin: 0 0 10px 0 !important;">Publication Distribution</h1>
		<div style="clear:both;"></div>
		<table border="1" class="tableList trhover" style="float:left;font-size:16px;margin:0 10px 0 0;">
			<tr>
				<th colspan="4">Delivery Rounds</th>
			</tr>
			<tr>
				<th colspan="4">(these go on the shelf)</th>
			</tr>
			<tr>
				<th>Qty</th>
				<th align="left">Publication</th>
				<th>Qty</th>
				<th align="left">Publication</th>
			</tr>
			<cfset halfway = int(ArrayLen(forecast.RoundsSorted) / 2)>
			<cfloop from="1" to="#halfway#" index="i">
				<cfset ItemKeyLeft = forecast.RoundsSorted[i]>
				<cfset item=StructFind(forecast.rounds,ItemKeyLeft)>
				<tr>
					<td align="center">#item.Qty#</th>
					<td><a href="javascript:void(0)" data-id="#item.id#" class="showClients">#item.Title#</a></th>
					<cfset ItemKeyRight = forecast.RoundsSorted[i+halfway]>
					<cfset item=StructFind(forecast.rounds,ItemKeyRight)>
					<td align="center">#item.Qty#</th>
					<td><a href="javascript:void(0)" data-id="#item.id#">#item.Title#</a></th>
				</tr>
			</cfloop>
			<cfif ArrayLen(forecast.RoundsSorted) MOD 2>
				<cfset ItemKeyRight = forecast.RoundsSorted[ArrayLen(forecast.RoundsSorted)]>
				<cfset item=StructFind(forecast.rounds,ItemKeyRight)>
				<tr>
					<td></td>
					<td></td>
					<td align="center">#item.Qty#</th>
					<td><a href="javascript:void(0)" data-id="#item.id#" class="showClients">#item.Title#</a></th>
				</tr>
			</cfif>
		</table>
		<table border="1" class="tableList trhover" style="float:left;font-size:16px;margin:0 10px 0 0;">
			<tr>
				<th colspan="2">Shop Save</th>
			</tr>
			<tr>
				<th colspan="2">(these go in the grey box)</th>
			</tr>
			<tr>
				<th>Qty</th>
				<th align="left">Publication</th>
			</tr>
			<cfloop array="#forecast.shopsaveSorted#" index="s">
				<cfset item=StructFind(forecast.shopsave,s)>
				<tr>
					<td align="center">#item.Qty#</th>
					<td><a href="javascript:void(0)" data-id="#item.id#" class="showClients">#item.Title#</a></th>
				</tr>
			</cfloop>
		</table>
<!---
		<table border="1" class="tableList trhover" style="float:left;font-size:11px;margin:0 10px 0 0;">
			<tr>
				<th colspan="2">Magazine Box</th>
			</tr>
			<tr>
				<th>Qty</th>
				<th align="left" width="230">Publication</th>
			</tr>
			<cfloop array="#forecast.boxSorted#" index="b">
				<cfset item=StructFind(forecast.box,b)>
				<tr>
					<td align="center">#item.Qty#</th>
					<td><a href="javascript:void(0)" data-id="#item.id#" class="showClients">#item.Title#</a></th>
				</tr>
			</cfloop>
		</table>
--->
		<div style="clear:both;text-align:center;font-weight:bold;padding:40px 0 0 0;font-size:16px;">This sheet does not account for customer holidays</div>
	</div>
	<div style="clear:both;"></div>
</body>
</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

