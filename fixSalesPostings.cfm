<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Fix Sales Postings</title>
	<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>

<body>
	<h1>Fix Sales Postings</h1>
	
	<cfflush interval="200">
	<cfsetting requesttimeout="30">
	<cfoutput>
	
		<!--- view sales items to be moved from SHOP account (201) to CASH account (181) --->
		<cfquery name="QTransView" datasource="#application.site.datasource1#">
			SELECT *
			FROM tblNomItems 
			INNER JOIN tblTrans ON trnID=niTranID
			WHERE trnAccountID=1
			AND niNomID=201
		</cfquery>
		<!---<cfdump var="#QTransView#" label="QTransView" expand="no">--->
		<table width="500">
		<cfloop query="QTransView">
			<tr>
				<td align="right">#trnID#</td>
				<td>#trnRef#</td>
				<td align="right">#LSDateFormat(trnDate,"ddd dd-mmm-yyyy")#</td>
				<td>#trnLedger#</td>
				<td>#trnType#</td>
				<td align="right">#trnAmnt1#</td>
				<td align="right">#niNomID#</td>
				<td align="right">#niAmount#</td>
			</tr>
		</cfloop>
		</table>
	
		<!--- view COD payment items to be moved from SHOP account (201) to CASH account (181) --->
		<cfquery name="QTransView" datasource="#application.site.datasource1#">
			SELECT *
			FROM tblNomItems 
			INNER JOIN tblTrans ON trnID=niTranID
			WHERE trnLedger='purch'
			AND trnType='pay'
			AND trnPayAcc=181
			AND niNomID=201
		</cfquery>
		<!---<cfdump var="#QTransView#" label="QTransView" expand="no">--->
		<table width="500">
		<cfloop query="QTransView">
			<tr>
				<td align="right">#trnID#</td>
				<td>#trnRef#</td>
				<td align="right">#LSDateFormat(trnDate,"ddd dd-mmm-yyyy")#</td>
				<td>#trnLedger#</td>
				<td>#trnType#</td>
				<td align="right">#trnAmnt1#</td>
				<td align="right">#niNomID#</td>
				<td align="right">#niAmount#</td>
			</tr>
		</cfloop>
		</table>
	</cfoutput>
</body>
</html>