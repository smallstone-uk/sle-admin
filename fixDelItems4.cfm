<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix Del Item Charges</title>
</head>

<body>
<p>This function updates del. charges based on newly assigned delivery codes.</p>

<cfflush interval="200">
<cfset loopCount = 0>
<cfset oldTotal = 0>
<cfset newTotal = 0>
<cfquery name="QDelItems" datasource="#application.site.datasource1#">
	SELECT ordID,ordHouseName,ordhouseNumber,ordDeliveryCode,ordDelCodeNew, delPrice1, diDate, diCharge
	FROM tblOrder a, tbldelCharges b, tblDelItems c
	WHERE b.delCode = a.ordDelCodeNew
	AND c.diOrderID = a.ordID
	AND a.ordActive = 1
	AND diDate BETWEEN '2022-05-01' AND '2022-05-28'
	ORDER BY ordClientID, diDate
</cfquery>
<table width="700">
<cfoutput>
	<cfloop query="QDelItems">
		<cfset loopCount++>
		<cfset thisID = ordID>
		<cfset oldTotal += diCharge>
		<cfset newTotal += delPrice1>
		<tr>
			<td>#ordHouseName#</td>
			<td>#ordhouseNumber#</td>
			<td>#LSDateFormat(diDate)#</td>
			<td>#ordDeliveryCode#</td>
			<td>#diCharge#</td>
			<td>#ordDelCodeNew#</td>
			<td>#delPrice1#</td>
		</tr>
	</cfloop>
	<tr>
		<td colspan="4">#loopcount#</td>
		<td>#oldTotal#</td>
		<td></td>
		<td>#newTotal#</td>
	</tr>
</cfoutput>
</table>
</body>
</html>