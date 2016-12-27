<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix Payroll</title>
</head>

<body>
<cfquery name="QPayroll" datasource="#application.site.datasource1#">
	SELECT YEAR(phDate)*100 + MONTH(phDate) AS yymm,
		SUM(phNP) AS net, 
		SUM(phPAYE) AS PAYE, 
		SUM(phNI) AS NI
	FROM `tblPayHeader` 
	WHERE phDate < '2015-02-01'
	GROUP BY yymm
</cfquery>

<cfset loc = {}>
<cfset loc.net = 0>
<cfset loc.paye = 0>
<cfset loc.ni = 0>
<cfoutput>
	<table width="600">
		<cfloop query="QPayroll">
			<cfset loc.net += net>
			<cfset loc.paye += paye>
			<cfset loc.ni += ni>
			<cfquery name="QTran" datasource="#application.site.datasource1#">
				SELECT trnID,trnRef
				FROM tblTrans
				WHERE trnRef = 'PAY #yymm#'
				AND trnType = 'nom'
			</cfquery>
			<tr>
				<td align="right">#yymm#</td>
				<td align="right">#net#</td>
				<td align="right">#PAYE#</td>
				<td align="right">#NI#</td>
				<td>
					<cfif QTran.recordcount neq 1>
						not found<br />
						<cfset loc.total = net + PAYE + NI>
						<cfset loc.tranDate = CreateDate(left(yymm,4),Mid(yymm,5,2),1)>
						<cfset loc.tranDate = DateAdd("m",1,loc.tranDate)>
						<cfset loc.tranDate = DateAdd("d",-1,loc.tranDate)> #loc.tranDate#<br />
						<cfquery name="QInsertTran" datasource="#application.site.datasource1#" result="QIns">
							INSERT INTO tblTrans (
								trnLedger,trnAccountID,trnType,trnRef,trnDesc,trnDate,trnAlloc
							) VALUES (
								'nom',3,'nom','PAY #yymm#','Payroll Summary',#loc.tranDate#,1
							)
						</cfquery>
						<cfset loc.tranID = QIns.generatedkey> #loc.tranID#<br />
						<cfquery name="QInsertItems" datasource="#application.site.datasource1#">
							INSERT INTO tblNomItems 
								(niNomID,niTranID,niAmount)
							VALUES 
								(1881,#loc.tranID#,#-net#),
								(1891,#loc.tranID#,#-PAYE#),
								(1901,#loc.tranID#,#-NI#),
								(201,#loc.tranID#,#loc.total#)
						</cfquery>
					<cfelse>#trnID#  - #trnRef#</cfif>
				</td>
			</tr>
		</cfloop>
		<tr>
			<td>Totals</td>
			<td align="right">#loc.net#</td>
			<td align="right">#loc.paye#</td>
			<td align="right">#loc.ni#</td>
		</tr>
	</table>
</cfoutput>
</body>
</html>