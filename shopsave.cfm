<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>Shop Save</title>
	<style type="text/css">
		body {font-family:"Courier New", Courier, monospace}
		table {
			font-family:Arial, Helvetica, sans-serif;
			font-size:13px;
			border-collapse:collapse;
		}
		td, th {
			padding:4px 4px;
			border:solid 1px #ccc;
		}
	</style>
<script src="jquery-ui-1.10.3.custom.min.js"></script>
</head>

<cfset site={}>
<cfset site.datasource1=application.site.datasource1>
<cfset site.fileDir="#ExpandPath(".")#\source\">
<cfquery name="QShopSave" datasource="#application.site.datasource1#">
	SELECT cltRef,cltName,cltDelHouse,cltDelAddr,cltDelTel,cltOverdue,cltBalance,cltLastDel,cltLastPaid,cltAccountType
	FROM tblClients
	WHERE cltStreetCode=227
	ORDER BY cltName
</cfquery>
<body>
	<h1>SHOP SAVE ACCOUNTS</h1>
	<table border="1">
		<tr>
			<th>No.</th>
			<th>Account</th>
			<th>Name</th>
			<th>House</th>
			<th>Type</th>
			<!---<th>Address</th>
			<th>Telephone</th>
			<th>Overdue</th>--->
			<th align="right" width="80">Balance</th>
			<th align="right">Last Delivery</th>
			<th align="right">Last Paid</th>
		</tr>
		<cfset balance=0>
		<cfoutput query="QShopSave">
			<cfset balance=balance+cltBalance>
			<tr>
				<td>#currentrow#</td>
				<td align="center">#cltRef#</td>
				<td>#cltName#</td>
				<td>#cltDelHouse#</td>
				<td align="center">#cltAccountType#</td>
				<!---<td>#cltDelAddr#</td>
				<td>#cltDelTel#</td>
				<td>#cltOverdue#</td>--->
				<td align="right">#DecimalFormat(cltBalance)#</td>
				<td align="right">#DateFormat(cltLastDel,"dd-mmm-yyyy")#</td>
				<td align="right">#DateFormat(cltLastPaid,"dd-mmm-yyyy")#</td>
			</tr>
		</cfoutput>
		<cfoutput>
		<tr>
			<td colspan="5"></td>
			<td align="right"><strong>#DecimalFormat(balance)#</strong></td>
			<td colspan="2"></td>
		</tr>
		</cfoutput>
	</table>
</body>
</html>
