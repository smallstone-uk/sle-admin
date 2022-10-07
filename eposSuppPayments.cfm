<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>EPOS SuppPayments</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
</head>

<cfdump var="#form#" label="form" expand="false">
<cfset parms={}>
<cfset parms.datasource=application.site.datasource1>

<cfparam name="acc" default="0">
<cfquery name="QItems" datasource="#parms.datasource#">
	SELECT * 
	FROM `tblepos_items` 
	WHERE `eiSuppID` = #val(acc)#
	ORDER BY eiTimestamp
</cfquery>
<cfquery name="QSuppliers" datasource="#parms.datasource#">
	SELECT accID,accCode,accGroup,accPayType,accIndex,accName,accType
	FROM tblAccount
	WHERE accID = #val(acc)#
</cfquery>

<body>
	<cfoutput>
		<table class="tableList">
			<tr>
				<th>#QSuppliers.accCode#</th>
				<th>#QSuppliers.accName#</th>
			</tr>
			<tr>
				<th>Date</th>
				<th>Value</th>
			</tr>
			<cfset total = 0>
			<cfloop query="QItems">
				<tr>
					<td>#DateFormat(eiTimestamp,'ddd dd-mmm-yy')#</td>
					<td align="right">#eiNet#</td>
				</tr>
				<cfset total += eiNet>
			</cfloop>
			<tr>
				<th>Total</th>
				<th align="right">#total#</th>
			</tr>
		</table>
	</cfoutput>
</body>
</html>
