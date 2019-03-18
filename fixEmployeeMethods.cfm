<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix Employee Payment Methods</title>
</head>

<cfset employeeID = 2>
<cfsetting requesttimeout="900">
<cfquery name="QEmployee" datasource="#application.site.datasource1#">
	SELECT *
	FROM tblEmployee
	WHERE empID=#employeeID#
</cfquery>
<cfdump var="#QEmployee#" label="QEmployee" expand="false">
<cfset nomID = QEmployee.empNomID>
<cfquery name="QTrans" datasource="#application.site.datasource1#">
	SELECT trnID,trnDate,trnDesc, niAmount, niNomID
	FROM tblTrans 
	INNER JOIN tblNomItems ON trnID=niTranID
	WHERE trnType = 'nom' 
	AND niNomID=#nomID#
	ORDER BY trnDate
</cfquery>
<cfset dates = {}>
<cfloop query="QTrans">
	<cfif NOT StructKeyExists(dates,trnDate)>
		<cfset StructInsert(dates,trnDate,niAmount)>
	</cfif>
</cfloop>
<cfdump var="#dates#" label="dates" expand="false">
<cfquery name="QPayments" datasource="#application.site.datasource1#">
	SELECT *
	FROM tblPayHeader
	WHERE phEmployee=#employeeID#
</cfquery>
<cfdump var="#QPayments#" label="QPayments" expand="false">
<body>
<cfoutput>
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
</cfoutput>
</body>
</html>