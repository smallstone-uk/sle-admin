<!DOCTYPE html>
<html>
<head>
	<title>Publication Chart</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/main4.css" rel="stylesheet" type="text/css">
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
	<script src="scripts/jquery.tablednd.js"></script>
	<script src="scripts/main.js"></script>
	<script type="text/javascript" src="scripts/checkDates.js"></script>
	<style type="text/css">
		.tableList td {padding:4px;}
	</style>
</head>

<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfquery name="QOrders" datasource="#application.site.datasource1#">
					SELECT pubGroup,pubTitle, count(oiID) AS Orders, 
					SUM(oiSun) AS Sun,
					SUM(oiMon) AS Mon,
					Sum(oiTue) AS Tue,
					Sum(oiWed) AS Wed,
					SUM(oiThu) AS Thu,
					SUM(oiFri) AS Fri,
					SUM(oiSat) AS Sat
					FROM `tblPublication` 
					INNER JOIN tblOrderItem ON pubID=oiPubID
					INNER JOIN tblOrder ON ordID=oiOrderID
					INNER JOIN tblClients ON ordClientID=cltID
					WHERE oiStatus='active'
					AND cltAccountType<>'N'
					GROUP BY pubID
					ORDER BY pubGroup, pubType, pubTitle
				</cfquery>
				
				<cfoutput>
					<table class="tableList" border="1">
						<tr>
							<th colspan="10">Delivery Orders</th>
						</tr>
						<tr>
							<th>Group</th>
							<th>Title</th>
							<th width="40">Orders</th>
							<th width="40">Mon</th>
							<th width="40">Tue</th>
							<th width="40">Wed</th>
							<th width="40">Thu</th>
							<th width="40">Fri</th>
							<th width="40">Sat</th>
							<th width="40">Sun</th>
						</tr>
						<cfloop query="QOrders">
							<tr>
								<td>#pubGroup#</td>
								<td>#pubTitle#</td>
								<td align="center">#Orders#</td>
								<td align="center"><cfif Mon gt 0>#Mon#</cfif></td>
								<td align="center"><cfif Tue gt 0>#Tue#</cfif></td>
								<td align="center"><cfif Wed gt 0>#Wed#</cfif></td>
								<td align="center"><cfif Thu gt 0>#Thu#</cfif></td>
								<td align="center"><cfif Fri gt 0>#Fri#</cfif></td>
								<td align="center"><cfif Sat gt 0>#Sat#</cfif></td>
								<td align="center"><cfif Sun gt 0>#Sun#</cfif></td>
							</tr>
						</cfloop>
					</table>
				</cfoutput>
			</div>
		</div>
	</div>
</body>
</html>
