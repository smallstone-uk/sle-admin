<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="css/main3.css" rel="stylesheet" type="text/css">
<title>Delivery Charges</title>
</head>
<cftry>
	<cfset groupIt=true>
	<cfset splitIt=true>
	<cfquery name="QDelCharges" datasource="#application.site.datasource1#">
		SELECT cltRef,cltAccountType,delPrice1,delPrice2,delPrice3,delType,ordHouseName,ordHouseNumber,ordStreetCode,
		(SELECT stName FROM tblStreets2 WHERE stID=ordStreetCode) AS Street
		FROM `tblOrder` 
		INNER JOIN tblClients ON `ordClientID`=cltID
		INNER JOIN tblDelCharges ON ordDeliveryCode=delCode
		WHERE cltAccountType<>'N'
		<cfif groupIt>GROUP BY Street
		<cfelse>ORDER BY Street</cfif>
	</cfquery>
	<cfset righthalf=int(QDelCharges.recordCount/2)+1>
	<body>
		<cfoutput>
		<table class="tableList" border="1">
			<cfset streetCode=0>
			<cfset rightCount=righthalf>
			<cfloop query="QDelCharges">
				<cfif NOT groupIt AND streetCode neq ordStreetCode>
					<tr><td colspan="8">&nbsp;</td></tr>
				</cfif>
				<tr>
					<cfif NOT groupIt>
						<td>#cltRef#</td>
						<td>#cltAccountType#</td>
						<td align="right">#ordHouseName# #ordHouseNumber#</td>
					</cfif>
					<td>#currentRow#</td>
					<td>#Street#</td>
					<td>#delPrice1#</td>
					<td>#delPrice2#</td>
					<td>#delPrice3#</td>
					<cfif splitIt>
						<td>&nbsp; &nbsp; &nbsp;</td>
						<td>#rightCount#</td>
						<td>#Street[rightCount]#</td>
						<td>#delPrice1[rightCount]#</td>
						<td>#delPrice2[rightCount]#</td>
						<td>#delPrice3[rightCount]#</td>
						<cfset rightCount++>
					</cfif>
				</tr>
				<cfset streetCode=ordStreetCode>
				<cfif splitIt AND currentRow gt righthalf>
					<cfbreak>
				</cfif>
			</cfloop>
		</table>
		</cfoutput>
	<cfcatch type="any">
		<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
	</cfcatch>
	</cftry>
	</body>
	</html>
