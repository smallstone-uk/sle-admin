<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix Employee Payment Methods</title>
</head>
<body>
<h1>Fix Employee Payment Methods</h1>
<cfoutput>
	<cfparam name="employeeID" default="2">
	<cfsetting requesttimeout="900">
	<cfquery name="QEmployee" datasource="#application.site.datasource1#">
		SELECT *
		FROM tblEmployee
		WHERE empID=#val(employeeID)#
	</cfquery>
	<cfif val(QEmployee.empID) gt 0>
		<h2>#QEmployee.empFirstName# #QEmployee.empLastName#</h2>
		<cfset nomID = QEmployee.empNomID>
		<cfquery name="QTrans" datasource="#application.site.datasource1#">
			SELECT trnID,trnDate,trnDesc, niAmount, niNomID
			FROM tblTrans 
			INNER JOIN tblNomItems ON trnID=niTranID
			WHERE trnType = 'nom' 
			AND niNomID=#nomID#
			ORDER BY trnDate
		</cfquery>
		<cfif QTrans.recordcount gt 0>
			<cfset dateStr = QTrans.trnDate[1]>dateStr = #dateStr#<br />
			<cfif Find("{",dateStr)>
				<cfset firstDate = dateStr>
			<cfelse>
				<cfset firstDate = CreateDate(ListFirst(dateStr,"-"),Mid(dateStr,6,2),ListLast(dateStr,"-"))>firstDate = #firstDate#<br />
			</cfif>
			<cfquery name="QPaymentUpdate" datasource="#application.site.datasource1#">
				UPDATE tblPayHeader
				SET phMethod='bacs'
				WHERE phDate >= #firstDate#
				AND phEmployee = #employeeID#
			</cfquery>
			<cfquery name="QPayments" datasource="#application.site.datasource1#">
				SELECT *
				FROM tblPayHeader
				WHERE phEmployee=#employeeID#
			</cfquery>
			<table width="300">
			<cfloop query="QPayments">
				<tr>
					<td>#phID#</td>
					<td align="right">#LSDateFormat(phDate,"ddd dd-mmm-yyyy")#</td>
					<td>#phMethod#</td>
					<td align="right">#phNP#</td>
				</tr>
			</cfloop>
			</table>
		</cfif>
	<cfelse>
		#employeeID# Not Found.
	</cfif>
</cfoutput>
</body>
</html>
