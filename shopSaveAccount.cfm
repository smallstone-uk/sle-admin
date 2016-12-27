<!DOCTYPE html>
<html>
<head>
<title>Shop News Account Sheet</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/rounds2.css" rel="stylesheet" type="text/css">
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
			$('#print-area').printArea();
		};
		$('#printBanking').click(function() {
			PrintArea();
			event.preventDefault();
		});
	});
</script>
<style type="text/css">
@media print {
	#controls {display:none}
	@page  
	{   size:portrait;
		margin-top:20px;
		margin-left:60px;
		margin-right:20px;
		margin-bottom:20px;
	}
}
</style>
</head>
<cfsetting requesttimeout="300">

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.Date=Now()>
<cfset parm.datasource=application.site.datasource1>
<cfset accounts=func.LoadShopSaveAccounts(parm)>

<cfoutput>
<body>
	<div id="controls" style="background: ##EEE;padding: 10px;border-bottom: 1px solid ##CCC;">
		<a href="##" id="printBanking" class="button" style="float:left;font-size:13px;">Print</a>
		<div style="float:left;" id="loading" class="loading"></div>
		<div class="clear"></div>
	</div>
	<div id="print-area" style="font-family:Arial, Helvetica, sans-serif;font-size:11px;padding:10px;width:860px;">
		<!---<span style="float: right;margin: 0 30px 0 0;line-height: 23px;font-weight: bold;"></span>
		<h1 style="margin: 0 0 10px 0 !important;"></h1>
		<div style="clear:both;"></div>--->
		<table border="1" class="tableList" style="font-size:24px;">
			<tr>
				<td colspan="3">Weekly News Accounts Payments</td>
				<td colspan="2" align="right">Printed: #LSDateFormat(Now(),"DD MMM YY")#</td>
			</tr>
			<tr>
				<th width="120" align="center">Account</th>
				<th width="120" align="right">Total</th>
				<th width="240" align="center">Name</th>
				<th width="140" align="right">Balance on Account</th>
				<th width="140" align="right">Due this Week</th>
			</tr>
			<cfloop array="#accounts#" index="item">
				<cfset total=0>
				<tr>
					<td align="center">#item.cltRef#</td>
					<td align="right">
						<cfif StructKeyExists(item,"order")>
							<cfloop array="#item.order.list#" index="order">
								<cfset total=order.orderPerWeek>
								<cfloop array="#order.items#" index="p">
									<cfquery name="QCheckVouchers" datasource="#parm.datasource#">
										SELECT *
										FROM tblVoucher
										WHERE vchOrderID=#order.OrderID#
										AND vchPubID=#p.PubID#
										AND (vchStart <= '#LSDateFormat(parm.Date,'yyyy-mm-dd')#' AND vchStop >= '#LSDateFormat(parm.Date,'yyyy-mm-dd')#')
									</cfquery>
									<cfset qty=p.qtyMon+p.qtyTue+p.qtyWed+p.qtyThu+p.qtyFri+p.qtySat+p.qtySun>
									<cfif QCheckVouchers.recordcount neq 0>
										<cfset total=total-(p.Price*qty)>
									</cfif>
								</cfloop>
							</cfloop>
							&pound;#DecimalFormat(total+order.DelPerWeek)#
						</cfif>
					</td>
					<td>#item.cltName#</td>
					<td align="right"><cfif item.balance neq 0>&pound;#DecimalFormat(item.balance)#</cfif></td>
					<td align="right">&pound;#DecimalFormat(total+order.DelPerWeek + item.balance)#</td>
				</tr>
			</cfloop>
		</table>
		
		<h2>DO NOT WRITE ALTERATIONS ON THIS SHEET!</h2>
		<p>Any changes must be written clearly on the newspaper enquiry form and put in the office.</p>
	</div>
</body>
</cfoutput>
</html>