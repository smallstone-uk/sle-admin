<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Fix Del Item Charges</title>
	<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>

<body>
<p>This function updates del. charges based on newly assigned delivery codes.</p>

<cfparam name="doUpdate" default="false">
<cfflush interval="200">
<cfset loopCount = 0>
<cfset oldTotal = 0>
<cfset newTotal = 0>
<cfquery name="QDelItems" datasource="#application.site.datasource1#">
	SELECT ordID,ordHouseName,ordhouseNumber,ordDeliveryCode,ordDelCodeNew, delPrice1, diID,diDate,diCharge
	FROM tblOrder a, tbldelCharges b, tblDelItems c
	WHERE b.delCode = a.ordDelCodeNew
	AND c.diOrderID = a.ordID
	AND a.ordActive = 1
	AND diDate BETWEEN '2022-05-01' AND '2022-05-28'
	AND diCharge != 0
	ORDER BY diDate, diID
</cfquery>
<table class="tableList" border="1" width="800">
		<tr>
			<th>diID</th>
			<th>House Name</th>
			<th>house Number</th>
			<th>Date</th>
			<th align="center">Delivery Code</th>
			<th align="right">Charge</th>
			<th align="center">Del Code New</th>
			<th align="right">delPrice1</th>
		</tr>
<cfoutput>
	<cfloop query="QDelItems">
		<cfset loopCount++>
		<cfset thisID = ordID>
		<cfset oldTotal += diCharge>
		<cfset newTotal += delPrice1>
		<cfif doUpdate>
			<cfquery name="QDelItems" datasource="#application.site.datasource1#">
				UPDATE tblDelItems
				SET diCharge = #delPrice1#
				WHERE diID = #diID#
			</cfquery>
		</cfif>
		<tr>
			<td>#diID#</td>
			<td>#ordHouseName#</td>
			<td>#ordhouseNumber#</td>
			<td>#LSDateFormat(diDate)#</td>
			<td align="center">#ordDeliveryCode#</td>
			<td align="right">#diCharge#</td>
			<td align="center">#ordDelCodeNew#</td>
			<td align="right">#delPrice1#</td>
		</tr>
	</cfloop>
	<tr>
		<td colspan="3">#loopcount# records<cfif doUpdate> Updated</cfif>.</td>
		<td colspan="2" align="right">#newTotal - oldTotal#</td>
		<td align="right">#oldTotal#</td>
		<td></td>
		<td align="right">#newTotal#</td>
	</tr>
</cfoutput>
</table>
</body>
</html>