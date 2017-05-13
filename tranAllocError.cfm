<!DOCTYPE html>
<html>
<head>
	<title>Transaction Allocation Check</title>
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
		.err {background-color:#FF0000}
	</style>
</head>

<cfquery name="QTrans" datasource="#application.site.datasource1#">
	SELECT *
	FROM tblTrans
	WHERE trnAccountID = 251
	<!---AND trnAllocID > 0--->
	<!---AND trnDate>'2016-01-01'--->
	ORDER BY trnAllocID,trnDate,trnID
	<!---LIMIT 500--->
</cfquery>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfoutput>
					<cfset allocBal = 0>
					<cfset allocID = -1>
					<table class="tableList" border="1" width="600">
						<tr>
							<td>ID</td>
							<td>Date</td>
							<td>Type</td>
							<td>Method</td>
							<td>Reference</td>
							<td>Description</td>
							<td>Amount1</td>
							<td>Amount2</td>
							<td>Allocated</td>
							<td>AllocID</td>
							<td></td>
						</tr>
						<cfloop query="QTrans">
							<cfif allocID gt -1 AND allocID neq trnAllocID>
								<cfif abs(allocBal) lt 0.001>
									<cfset allocBal = 0>
								</cfif>
								<cfif allocBal neq 0>
									<cfset class = "err">
								<cfelse><cfset class = ""></cfif>
								<tr>
									<td colspan="9"></td>
									<td class="#class#">#allocID#</td>
									<td class="#class#" align="right">#allocBal#</td>
								</tr>
								<cfset allocBal = 0>
							</cfif>
							<tr>
								<td align="right">#trnID#</td>
								<td align="right">#LSDateFormat(trnDate,'dd-mmm-yyyy')#</td>
								<td>#trnType#</td>
								<td>#trnMethod#</td>
								<td>#trnRef#</td>
								<td>#trnDesc#</td>
								<td align="right">#trnAmnt1#</td>
								<td align="right">#trnAmnt2#</td>
								<td align="center">#trnAlloc#</td>
								<td align="right">#trnAllocID#</td>
								<td></td>
							</tr>
							<cfset allocBal += (trnAmnt1 + trnAmnt2)>
							<cfset allocID = trnAllocID>
						</cfloop>
						<cfif abs(allocBal) lt 0.001>
							<cfset allocBal = 0>
						</cfif>
						<tr>
							<td colspan="9"></td>
							<td class="#class#">#allocID#</td>
							<td class="#class#" align="right">#allocBal#</td>
						</tr>
					</table>
				</cfoutput>
			</div>
		</div>
	</div>
</body>
</html>
