<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>VAT Reports</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/main4.css" rel="stylesheet" type="text/css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script type="text/javascript" src="common/scripts/common.js"></script>
	<script src="scripts/jquery-1.9.1.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
	<script src="scripts/jquery.hoverIntent.minified.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
			$(".srchAccount, .srchTranType").chosen({width: "300px"});
		});
	</script>
</head>
<cfset parms={}>
<cfset parms.datasource=application.site.datasource1>
<cfsetting requesttimeout="900">
<cfparam name="srchReport" default="">
<cfparam name="srchDateFrom" default="">
<cfparam name="srchDateTo" default="">

<cfquery name="QSaleItems" datasource="#parms.datasource#">
	SELECT ehMode, 
	eiTimestamp,eiType,eiPayType,eiRetail,eiTrade, SUM(eiQty) AS Qty, SUM(eiNet) AS Net, SUM(eiVAT) AS VAT,
	pgID,pgTitle,pgNomGroup
	FROM tblepos_items
	INNER JOIN tblepos_header ON eiParent=ehID
	INNER JOIN tblProducts ON prodID = eiProdID
	INNER JOIN tblProductCats ON pcatID = prodCatID
	INNER JOIN tblProductGroups ON pgID = pcatGroup
	WHERE eiTimestamp BETWEEN '#srchDateFrom#' AND '#srchDateTo#'
	AND eiClass = 'sale'
	AND ehMode != 'wst'
	GROUP BY pgNomGroup, pgTitle
	ORDER BY pgNomGroup, pgTitle
</cfquery>

<cfquery name="QPurItems" datasource="#parms.datasource#">
	SELECT trnDate, nomID,nomCode,nomTitle, SUM(niAmount) AS Amount, Count(*) AS Num
	FROM `tbltrans` 
	INNER JOIN tblAccount ON accID = trnAccountID
	INNER JOIN tblnomitems ON niTranID = trnID
	INNER JOIN tblNominal ON niNomID = nomID
	WHERE nomID != 11
	AND `trnLedger` = 'purch' 
	AND `trnType` IN ('inv', 'crn') 
	AND trnDate BETWEEN '#srchDateFrom#' AND '#srchDateTo#'
	GROUP BY nomCode
</cfquery>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post">
						<div class="form-header no-print">
							VAT Reports
							<span><input type="submit" name="btnSearch" value="Search" /></span>
						</div>
						<div class="module no-print">
							<table border="0">
								<tr>
									<td><b>Report</b></td>
									<td>
										<select name="srchReport">
											<option value="">Select...</option>
											<option value="1"<cfif srchReport eq "1"> selected="selected"</cfif>>VAT Report</option>
										</select>
									</td>
								</tr>
								<tr>
									<td><b>Date From</b></td>
									<td>
										<input type="text" name="srchDateFrom" value="#srchDateFrom#" class="datepicker" />
									</td>
								</tr>
								<tr>
									<td><b>Date To</b></td>
									<td>
										<input type="text" name="srchDateTo" value="#srchDateTo#" class="datepicker" />
									</td>
								</tr>
							</table>
						</div>
					</form>
				</div>
				<cfif StructKeyExists(form,"fieldnames")>
					<!---<cfdump var="#QSaleItems#" label="QItems" expand="false">--->
					<cfset totNet = 0>
					<cfset totVAT = 0>
					<cfset totQty = 0>
					<table border="1" class="tableList">
						<tr>
							<th>Group</th>
							<th>Description</th>
							<th>QTY</th>
							<th>NET</th>
							<th>VAT</th>
						</tr>
						<cfloop query="QSaleItems">
							<cfset totNet += NET>
							<cfset totVAT += VAT>
							<cfset totQty += QTY>
							<tr>
								<td>#pgNomGroup#</td>
								<td>#pgTitle#</td>
								<td align="center">#QTY#</td>
								<td align="right">#NET#</td>
								<td align="right">#VAT#</td>
							</tr>
						</cfloop>
						<tr>
							<th colspan="2">TOTALS</th>
							<th align="center">#totQty#</th>
							<th align="right">#totNet#</th>
							<th align="right">#totVAT#</th>
						</tr>
					</table>
					<p></p>
					<table border="1" class="tableList">
						<cfloop query="QPurItems">
							<cfset totNet += AMOUNT>
							<cfset totQty += NUM>
							<tr>
								<td>#nomCode#</td>
								<td>#nomTitle#</td>
								<td align="center">#NUM#</td>
								<td align="right">#AMOUNT#</td>
							</tr>
						</cfloop>
						<tr>
							<th colspan="2">TOTALS</th>
							<th align="center">#totQty#</th>
							<th align="right">#totNet#</th>
						</tr>
					</table>
					<!---<cfdump var="#QPurItems#" label="QPurItems" expand="false">--->
				</cfif>
			</div>
		</div>
	</div>
</body>
</cfoutput>
</html>

<!---
	SELECT ehMode, 
	eiTimestamp,eiType,eiPayType,eiRetail,eiTrade, SUM(eiQty) AS Qty, SUM(eiNet) AS Net, SUM(eiVAT) AS VAT,
	prodID,prodTitle, pcatID,pcatTitle, pgID,pgTitle,pgNomGroup
	FROM tblepos_items
	INNER JOIN tblepos_header ON eiParent=ehID
	INNER JOIN tblProducts ON prodID = eiProdID
	INNER JOIN tblProductCats ON pcatID = prodCatID
	INNER JOIN tblProductGroups ON pgID = pcatGroup
	WHERE eiTimestamp BETWEEN '2022-06-01' AND '2022-06-07'
	AND eiClass = 'sale'
	AND ehMode != 'wst'
	GROUP BY pgNomGroup, pgID, pcatID
	ORDER BY pgNomGroup, pgID, pcatID, prodID
--->