<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Publication Orders</title>
	<style type="text/css">
		body {font-family:"Courier New", Courier, monospace}
		table {
			font-family:Arial, Helvetica, sans-serif;
			font-size:11px;
			border-collapse:collapse;
		}
		th, td {padding:2px 4px; border:solid 1px #ccc;}
		.price {text-align:right;}
		.clienthead {
			background-color:#ddd;
			font-weight:bold;
			font-size:11px;
		}
		.qty {text-align:center;}
		.qtyHead {text-align:center; width:50px;}
		.linetotal {text-align:right;}
		.footer {
			font-weight:bold;
			background-color:#ddd;
		}
	</style>
<script src="jquery-ui-1.10.3.custom.min.js"></script>
</head>


<body>
	<p><a href="index.cfm">Home</a></p>
	<cfif StructKeyExists(url,"ref")>
		<cfobject component="code/functions" name="func">
		<cfset parms={}>
		<cfset parms.datasource=application.site.datasource1>
		<cfset parms.ref=url.ref>
		<cfset pubOrders=func.PubOrders(parms)>
		<cfoutput>
		<table>
			<tr class="clienthead">
				<td>#pubOrders.pub.ref#</td>
				<td>#pubOrders.pub.title#</td>
				<td></td>
				<td class="qtyHead">Mon<br />&pound;#pubOrders.pub.price1#</td>
				<td class="qtyHead">Tue<br />&pound;#pubOrders.pub.price2#</td>
				<td class="qtyHead">Wed<br />&pound;#pubOrders.pub.price3#</td>
				<td class="qtyHead">Thu<br />&pound;#pubOrders.pub.price4#</td>
				<td class="qtyHead">Fri<br />&pound;#pubOrders.pub.price5#</td>
				<td class="qtyHead">Sat<br />&pound;#pubOrders.pub.price6#</td>
				<td class="qtyHead">Sun<br />&pound;#pubOrders.pub.price7#</td>
				<td>Per Week</td>
			</tr>
			<cfloop array="#pubOrders.clientOrders#" index="item">
				<tr>
					<td>#item.ref#</td>
					<td>#item.name#</td>
					<td>#item.accountType#</td>
					<td class="qty">#item.qtymon#</td>
					<td class="qty">#item.qtytue#</td>
					<td class="qty">#item.qtywed#</td>
					<td class="qty">#item.qtythu#</td>
					<td class="qty">#item.qtyfri#</td>
					<td class="qty">#item.qtysat#</td>
					<td class="qty">#item.qtysun#</td>
					<td class="linetotal">&pound;#decimalformat(item.linePerWeek)#</td>
				</tr>
			</cfloop>
			<tr class="footer">
				<td colspan="3">TOTALS</td>
				<td class="qty">#pubOrders.totals.qtymon#</td>
				<td class="qty">#pubOrders.totals.qtytue#</td>
				<td class="qty">#pubOrders.totals.qtywed#</td>
				<td class="qty">#pubOrders.totals.qtythu#</td>
				<td class="qty">#pubOrders.totals.qtyfri#</td>
				<td class="qty">#pubOrders.totals.qtysat#</td>
				<td class="qty">#pubOrders.totals.qtysun#</td>
				<td class="linetotal">&pound;#decimalformat(pubOrders.totals.line)#</td>
			</tr>
		</table>
		</cfoutput>
	<cfelse>
		Publication reference not specified.
	</cfif>
</body>
</html>