<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Fix Sales Balance</title>
	<link rel="stylesheet" type="text/css" href="css/main3.css"/>
	<style>
		.red {color:#FF0000;}
		.blue {color:#00F;}
		.header {background-color:#CCCCCC; font-weight:bold;}
		.tranheader {background-color:#eee;}
		.tableList {font-size:14px;}
	</style>
</head>

<body>
<cfsetting requesttimeout="30">
<cfflush interval="200">
<cfquery name="QTrans" datasource="#application.site.datasource1#">
	SELECT trnID,trnDate,trnAmnt1,trnActual
	FROM tblTrans 
	WHERE trnLedger = 'sales' 
	AND trnAccountID = 1
	AND trnType = 'inv'
	AND trnDate >= '2015-11-01'
	AND trnDate <= '2015-11-30'
	ORDER BY trnDate
	<!---LIMIT 20;--->
</cfquery>
<cfoutput>
	<table class="tableList" border="1">
	<cfset totals = {}>
	<cfset totals.cash = 0>
	<cfset totals.cheques = 0>
	<cfset totals.suppliers = 0>
	<cfloop query="QTrans">
		<cfset tranCash = -trnAmnt1>
		<cfset totals.cash += tranCash>
		<cfset tranDate = trnDate>
		<tr class="header">
			<td>#trnID#</td>
			<td>#LSDateFormat(trnDate,'ddd dd-mmm-yyyy')#</td>
			<td colspan="3"></td>
			<td align="right">#trnAmnt1#</td>
		</tr>
		<cfquery name="QItems" datasource="#application.site.datasource1#">
			SELECT trnID,trnDate, niNomID,niAmount, nomCode,nomTitle
			FROM tblTrans
			INNER JOIN tblNomItems ON trnID = niTranID
			INNER JOIN tblNominal ON nomID = niNomID
			WHERE niNomID = 191	<!--- CARD Payments--->
			AND trnActual = #tranDate#
			
			UNION
			
			SELECT trnID,trnDate, niNomID,niAmount, nomCode,nomTitle
			FROM tblTrans
			INNER JOIN tblNomItems ON trnID = niTranID
			INNER JOIN tblNominal ON nomID = niNomID
			WHERE niNomID = 101	<!--- SDAL Allowed --->
			AND niAmount <> 0
			AND trnDate = #tranDate#
		</cfquery>
<!---		<tr>
			<td colspan="6"><cfdump var="#QItems#" label="QItems" expand="no"></td>
		</tr>
--->
		<cfloop query="QItems">
			<cfset value = -val(niAmount)>
			<cfif StructKeyExists(totals,nomCode)>
				<cfset currTotal = StructFind(totals,nomCode)>
				<cfset currTotal += value>
				<cfset StructUpdate(totals,nomCode,currTotal)>
			<cfelse>
				<cfset StructInsert(totals,nomCode,value)>
			</cfif>
			<cfif niNomID neq 101>
				<cfset tranCash -= value>
				<cfset totals.cash -= value>
			</cfif>
			<tr class="tranheader">
				<td>#trnID#</td>
				<td>#LSDateFormat(trnDate,'ddd dd-mmm-yyyy')#</td>
				<td>#niNomID#</td>
				<td>#nomCode#</td>
				<td>#nomTitle#</td>
				<td align="right">#value#</td>
			</tr>
		</cfloop>
		
		<cfquery name="QCheques" datasource="#application.site.datasource1#">
			SELECT SUM(trnAmnt1) AS totalChqs, trnDate
			FROM tblTrans
			WHERE trnLedger = 'sales'
			AND trnType = 'pay'
			AND trnMethod LIKE 'chqs'
			AND trnDate = #tranDate#
		</cfquery>
		<cfloop query="QCheques">
			<cfset value = abs(val(totalChqs))>
			<cfset totals.cheques += value>
			<cfset tranCash -= value>
			<cfset totals.cash -= value>
			<tr class="tranheader">
				<td></td>
				<td>#LSDateFormat(trnDate,'ddd dd-mmm-yyyy')#</td>
				<td>1472</td>
				<td>CHQ</td>
				<td>Cheque Account</td>
				<td align="right">#value#</td>
			</tr>
		</cfloop>
		<cfquery name="QSuppliers" datasource="#application.site.datasource1#">
			SELECT SUM(trnAmnt1) AS totalSupps, trnDate
			FROM tblTrans
			WHERE trnLedger = 'purch'
			AND trnType = 'pay'
			AND trnPayAcc LIKE 181
			AND trnDate = #tranDate#
		</cfquery>
		<cfloop query="QSuppliers">
			<cfset value = abs(val(totalSupps))>
			<cfset totals.suppliers += value>
			<cfset tranCash -= value>
			<cfset totals.cash -= value>
			<tr class="tranheader">
				<td></td>
				<td>#LSDateFormat(trnDate,'ddd dd-mmm-yyyy')#</td>
				<td></td>
				<td></td>
				<td>Suppliers Account</td>
				<td align="right">#value#</td>
			</tr>
		</cfloop>
		<tr class="tranheader">
			<td></td>
			<td>#LSDateFormat(trnDate,'ddd dd-mmm-yyyy')#</td>
			<td>181</td>
			<td>CASH</td>
			<td>Cash Account</td>
			<td align="right"><span class="blue">#tranCash#</span></td>
		</tr>		
		<tr><td colspan="6">&nbsp;</td></tr>
	</cfloop>
	</table>
	<!---<cfdump var="#totals#" label="totals" expand="yes">--->
	<cfset grossTotal = 0>
	<br />
	<table class="tableList" border="1">
	<cfloop collection="#totals#" item="key">
		<cfset value = StructFind(totals,key)>
		<cfset grossTotal += value>
		<tr>
			<td>#key#</td><td align="right">#value#</td>
		</tr>
	</cfloop>
		<tr><td>Gross Total:</td><td align="right">#grossTotal#</td></tr>
	</table>
	<br />
</cfoutput>
</body>
</html>