<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Shop News Payments</title>
<style type="text/css">
	.footer {background-color:#eeeeee;}
	.red {background-color:#FF0000;}
</style>
</head>
<cfquery name="trans" datasource="#application.site.datasource1#">
	SELECT trnID,trnRef,trnDate,trnType,trnMethod,trnDesc,trnClientRef,trnPaidIn,niAmount
	FROM `tblnomitems` 
	INNER JOIN tblTrans ON niTranID=trnID
	WHERE `niNomID` = 871
	AND trnDate BETWEEN '2016-12-01' AND '2017-04-30'
	ORDER BY trnDate,trnType
</cfquery>

<body>
<cfoutput>
	<cfset theDate = "">
	<cfset theTotal = 0>
	<cfset drTotal = 0>
	<cfset crTotal = 0>
	<cfset drGrandTotal = 0>
	<cfset crGrandTotal = 0>
	<table>
	<cfloop query="trans">
		<cfif len(theDate) gt 0 AND theDate neq trnDate>
			<cfif abs(theTotal) lt 0.001><cfset theTotal = 0></cfif>
			<tr class="footer">
				<td colspan="8" align="right">Totals</td>
				<td align="right">#drTotal#</td>
				<td align="right">#crTotal#</td>
				<td align="right"<cfif theTotal neq 0> class="red"</cfif>>#DecimalFormat(theTotal)#</td>
			</tr>
			<cfset theTotal = 0>
			<cfset drTotal = 0>
			<cfset crTotal = 0>
		</cfif>
		<cfset theDate = trnDate>
		<cfset theTotal += niAmount>
		<tr>
			<td>#trnID#</td>
			<td><cfif trnClientRef gt 0><a href="clientPayments.cfm?rec=#trnClientRef#" target="payments">#trnClientRef#</a></cfif></td>
			<td>#trnRef#</td>
			<td>#LSDateFormat(trnDate,'ddd dd-mmm-yy')#</td>
			<td>#trnPaidIn#</td>
			<td>#trnType#</td>
			<td>#trnMethod#</td>
			<td>#trnDesc#</td>
			<td align="right">
				<cfif niAmount gt 0>
					<cfset drTotal += niAmount>#niAmount#
					<cfset drGrandTotal += niAmount>
				</cfif>
			</td>
			<td align="right">
				<cfif niAmount lt 0>
					<cfset crTotal += niAmount>#niAmount#
					<cfset crGrandTotal += niAmount>
				</cfif>
			</td>
			<td></td>
		</tr>
	</cfloop>
	<cfif abs(theTotal) lt 0.001><cfset theTotal = 0></cfif>
	<tr class="footer">
		<td colspan="8" align="right">Totals</td>
		<td align="right">#drTotal#</td>
		<td align="right">#crTotal#</td>
		<td align="right">#DecimalFormat(theTotal)#</td>
	</tr>
	<tr class="footer">
		<td colspan="8" align="right">Grand Totals</td>
		<td align="right">#drGrandTotal#</td>
		<td align="right">#crGrandTotal#</td>
		<td align="right">#drGrandTotal + crGrandTotal#</td>
	</tr>
	</table>
</cfoutput>
</body>
</html>