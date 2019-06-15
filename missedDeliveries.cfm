<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Missed Deliveries</title>
	<link rel="stylesheet" type="text/css" href="css/main3.css"/>
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="scripts/jquery-1.11.1.min.js" type="text/javascript"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
		});
	</script>
</head>

<cfparam name="dateFrom" default="#Now()#">
<cfparam name="dateTo" default="#Now()#">

<cfquery name="QDeliveries" datasource="#application.site.datasource1#">
	SELECT cltTitle,cltName,cltAccountType, ordHouseNumber,ordHouseName, stName, pubTitle, diDate,diQty,diPrice,diCharge,diReason, rndID,rndTitle
	FROM tbldelitems
	INNER JOIN tblPublication ON diPubID=pubID
	INNER JOIN tblOrder ON diOrderID=ordID
	INNER JOIN tblClients ON diClientID=cltID
	INNER JOIN tblStreets2 ON stID=cltStreetCode
	INNER JOIN tbldelbatch ON diBatchID=dbID
	INNER JOIN tblrounds ON dbRound=rndID
	WHERE diType = 'credit' 
	AND diReason IN ("missed","unwanted","wrong")
	AND diDate >= '#DateFormat(dateFrom,'yyyy-mm-dd')#'
	AND diDate <= '#DateFormat(dateTo,'yyyy-mm-dd')#'
	ORDER BY rndTitle,cltName,diDate
</cfquery>

<cfoutput>
<body>
	<table>
		<tr>
			<td>
				<form method="post">
					From : <input type="text" name="dateFrom" class="datepicker" value="#DateFormat(dateFrom,'yyyy-mm-dd')#" />
					To : <input type="text" name="dateTo" class="datepicker" value="#DateFormat(dateTo,'yyyy-mm-dd')#" />
					<input type="submit" name="btnGo" value="Go" />
				</form>
			</td>
		</tr>
	</table>
	</table>
	<table class="tableList" border="1">
		<tr>
			<th>Customer Name</th>
			<th>Address</th>
			<th>Street</th>
			<th>Acct<br />Type</th>
			<th>Title</th>
			<th>Date</th>
			<th>Reason</th>
			<th>Round</th>
			<th align="center">Qty</th>
			<th align="right">Price</th>
			<th align="right">Charge</th>
			<th align="right">Loss</th>
		</tr>
		<cfset rnd = 0>
		<cfset rndLoss = 0>
		<cfset totalLoss = 0>
		<cfloop query="QDeliveries">
			<cfset loss = diQty * diPrice + diCharge>
			<cfset rndLoss += loss>
			<cfset totalLoss += loss>
			<cfif rnd gt 0 AND rnd neq rndID>
				<tr>
					<th colspan="11" align="right">Round Loss</th>
					<th>#DecimalFormat(rndLoss)#</tthd>
				</tr>
				<cfset rndLoss = 0>
			</cfif>
			<tr>
				<td>#cltTitle# #cltName#</td>
				<td>#ordHouseNumber# #ordHouseName#</td>
				<td>#stName#</td>
				<td>#cltAccountType#</td>
				<td>#pubTitle#</td>
				<td>#DateFormat(diDate,"ddd dd mmm")#</td>
				<td>#diReason#</td>
				<td>#rndTitle#</td>
				<td align="center">#diQty#</td>
				<td align="right">#diPrice#</td>
				<td align="right">#diCharge#</td>
				<td align="right">#DecimalFormat(loss)#</td>
			</tr>
			<cfset rnd = rndID>
		</cfloop>
			<tr>
				<th colspan="11" align="right">Round Loss</th>
				<th>#DecimalFormat(rndLoss)#</th>
			</tr>
		<tr>
			<th colspan="11" align="right">Total Loss</th>
			<th>#DecimalFormat(totalLoss)#</th>
		</tr>
	</table>
	<br />
	<table class="tableList" border="1">
		<tr>
			<td>Missed</td><td>Customer did not receive this paper</td>
		</tr>
		<tr>
			<td>Unwanted</td><td>Customer received a cancelled paper</td>
		</tr>
		<tr>
			<td>Wrong</td><td>Customer received an unwanted paper e.g. Mail instead of Times</td>
		</tr>
		<tr>
			<td colspan="2">Shortage of stock, i.e. titles not arrived on time are not included on this report.</td>
		</tr>
	</table>
</body>
</cfoutput>
</html>